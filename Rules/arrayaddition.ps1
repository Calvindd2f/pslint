<#

$results = @()
$results += Get-Something
$results += Get-SomethingElse
$results

Array addition is inefficient because arrays have a fixed size. Each addition to the array creates a new array big enough to hold all elements of both the left and right operands. The elements of both operands are copied into the new array. For small collections, this overhead may not matter. Performance can suffer for large collections.

$results = [System.Collections.Generic.List[object]]::new()
$results.AddRange((Get-Something))
$results.AddRange((Get-SomethingElse))
$results

The performance impact of using array addition grows exponentially with the size of the collection and the number additions. This code compares explicitly assigning values to an array with using array addition and using the Add(T) method on a [List<T>] object. It defines explicit assignment as the baseline for performance.

When you're working with large collections, array addition is dramatically slower than adding to a List<T>.

When using a [List<T>] object, you need to create the list with a specific type, like [String] or [Int]. When you add objects of a different type to the list, they are cast to the specified type. If they can't be cast to the specified type, the method raises an exception.

$intList = [System.Collections.Generic.List[int]]::new()
$intList.Add(1)
$intList.Add('2')
$intList.Add(3.0)
$intList.Add('Four')
$intList

MethodException:
Line |
   5 |  $intList.Add('Four')
     |  ~~~~~~~~~~~~~~~~~~~~
     | Cannot convert argument "item", with value: "Four", for "Add" to type
     "System.Int32": "Cannot convert value "Four" to type "System.Int32".
     Error: "The input string 'Four' was not in a correct format.""

1
2
3

When you need the list to be a collection of different types of objects, create it with [Object] as the list type. You can enumerate the collection inspect the types of the objects in it.

$objectList = [System.Collections.Generic.List[object]]::new()
$objectList.Add(1)
$objectList.Add('2')
$objectList.Add(3.0)
$objectList | ForEach-Object { "$_ is $($_.GetType())" }

1 is int
2 is string
3 is double

If you do require an array, you can call the ToArray() method on the list or you can let PowerShell create the array for you:

$results = @(
    Get-Something
    Get-SomethingElse
)

In this example, PowerShell creates an [ArrayList] to hold the results written to the pipeline inside the array expression. Just before assigning to $results, PowerShell converts the [ArrayList] to an [Object[]].
#>

$tests = @{
    'PowerShell Explicit Assignment' = {
        param($count)

$result = foreach($i in 1..$count) {
            $i
        }
    }
    '.Add(T) to List<T>' = {
        param($count)

$result = [Collections.Generic.List[int]]::new()
        foreach($i in 1..$count) {
            $result.Add($i)
        }
    }
    '+= Operator to Array' = {
        param($count)

$result = @()
        foreach($i in 1..$count) {
            $result += $i
        }
    }
}

5kb, 10kb, 100kb | ForEach-Object {
    $groupResult = foreach($test in $tests.GetEnumerator()) {
        $ms = (Measure-Command { & $test.Value -Count $_ }).TotalMilliseconds

[pscustomobject]@{
            CollectionSize    = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round($ms, 2)
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