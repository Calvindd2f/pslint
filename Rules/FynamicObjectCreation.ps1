OrderedDictionary to dynamically create new objects

# There are situations where we may need to dynamically create objects based on some input, the perhaps most commonly used way to create a new PSObject and then add new properties using the Add-Member cmdlet. The performance cost for small collections using this technique may be negligible however it can become very noticeable for big collections. In that case, the recommended approach is to use an [OrderedDictionary] and then convert it to a PSObject using the [pscustomobject] type accelerator. For more information, see the Creating ordered dictionaries section of about_Hash_Tables.

# Assume you have the following API response stored in the variable $json.

$json = @"
{
  "tables": [
    {
      "name": "PrimaryResult",
      "columns": [
        { "name": "Type", "type": "string" },
        { "name": "TenantId", "type": "string" },
        { "name": "count_", "type": "long" }
      ],
      "rows": [
        [ "Usage", "63613592-b6f7-4c3d-a390-22ba13102111", "1" ],
        [ "Usage", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "1" ],
        [ "BillingFact", "63613592-b6f7-4c3d-a390-22ba13102111", "1" ],
        [ "BillingFact", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "1" ],
        [ "Operation", "63613592-b6f7-4c3d-a390-22ba13102111", "7" ],
        [ "Operation", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "5" ]
      ]
    }
  ]
}
"@

# Now, suppose you want to export this data to a CSV. First you need to create new objects and add the properties and values using the Add-Member cmdlet.

$data = $json | ConvertFrom-Json
$columns = $data.tables.columns
$result = foreach ($row in $data.tables.rows) {
    $obj = [psobject]::new()
    $index = 0

foreach ($column in $columns) {
        $obj | Add-Member -MemberType NoteProperty -Name $column.name -Value $row[$index++]
    }

$obj
}

# Using an OrderedDictionary, the code can be translated to:

$data = $json | ConvertFrom-Json
$columns = $data.tables.columns
$result = foreach ($row in $data.tables.rows) {
    $obj = [ordered]@{}
    $index = 0

foreach ($column in $columns) {
        $obj[$column.name] = $row[$index++]
    }

[pscustomobject] $obj
}

# In both cases the $result output would be same:

# Here is a performance comparison of three techniques for creating objects with 5 properties:

$tests = @{
  '[ordered] into [pscustomobject] cast' = {
    param([int] $iterations, [string[]] $props)

    foreach ($i in 1..$iterations)
    {
      $obj = [ordered]@{}
      foreach ($prop in $props)
      {
        $obj[$prop] = $i
      }
      [pscustomobject] $obj
    }
  }
  'Add-Member'                           = {
    param([int] $iterations, [string[]] $props)

    foreach ($i in 1..$iterations)
    {
      $obj = [psobject]::new()
      foreach ($prop in $props)
      {
        $obj | Add-Member -MemberType NoteProperty -Name $prop -Value $i
      }
      $obj
    }
  }
  'PSObject.Properties.Add'              = {
    param([int] $iterations, [string[]] $props)

    # this is how, behind the scenes, `Add-Member` attaches
    # new properties to our PSObject.
    # Worth having it here for performance comparison

    foreach ($i in 1..$iterations)
    {
      $obj = [psobject]::new()
      foreach ($prop in $props)
      {
        $obj.PSObject.Properties.Add(
          [psnoteproperty]::new($prop, $i))
      }
      $obj
    }
  }
}

$properties = 'Prop1', 'Prop2', 'Prop3', 'Prop4', 'Prop5'

1kb, 10kb, 100kb | ForEach-Object {
  $groupResult = foreach ($test in $tests.GetEnumerator())
  {
    $ms = Measure-Command { & $test.Value -iterations $_ -props $properties }

    [pscustomobject]@{
      Iterations        = $_
      Test              = $test.Key
      TotalMilliseconds = [math]::Round($ms.TotalMilliseconds, 2)
    }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }

  $groupResult = $groupResult | Sort-Object TotalMilliseconds
  $groupResult | Select-Object *, @{
    Name       = 'RelativeSpeed'
    Expression = {
      $relativeSpeed = $_.TotalMilliseconds / $groupResult[0].TotalMilliseconds
      [math]::Round($relativeSpeed, 2).ToString() + 'x'
    }
  }
}