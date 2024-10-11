# PowerShell 5.1 Testing

This module was made near exclusively on PowerShell 7.5.5 , these are just tests to ensure  it works on PowerShell 5.1.  If you find any issues, please let me know.


```powershell
=== PowerShell Performance Analysis Report ===
Script: .\win10_portscan.ps1
Time: 2024-10-11 11:40:51

Summary:
Total Issues Found: 19

== ArrayAddition (2 issues) ==i
  Line 81:
    Code: $IPList.Add($CurrIP)
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 135:
    Code: $hosts += [PSCustomObject]@{
                          value = "$($($IP.IP).Trim())";
                          port = "$($Port.Trim())";
                      }
    Suggestion: Consider using ArrayList or Generic List for better performance

== LargeCollectionLookup (1 issues) ==
  Line 135:
    Code: @{
                          value = "$($($IP.IP).Trim())";
                          port = "$($Port.Trim())";
                      }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections

== OutputSuppression (10 issues) ==
  Line 8:
    Code: $null|out-null
    Suggestion: Consider using [void] for better performance
  Line 9:
    Code: $null|out-null
    Suggestion: Consider using [void] for better performance
  Line 115:
    Code: Function Main(){

              $start_time = $(Get-Date)

              Write-host "Started scanning at $($start_time)"

              $ip_var = $(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected" }).IPv4Address.IPAddress

              if([IPAddress]$ip_var){
                  $address = $ip_var -replace '.\d+$',''
              }

              $Discovered_Hosts = Find-LANHosts
              $Discovered_Hosts = $Discovered_Hosts | Where {$_.IP -like "$address*"} | Sort -Property IP -Unique

              [Array]$hosts = @()
              #for ($i = 1; $i -lt 254; $i++)
              foreach($IP in $Discovered_Hosts)
              {
                  if(PortScanTCP $($IP.IP) $Port){
                      $hosts += [PSCustomObject]@{
                          value = "$($($IP.IP).Trim())";
                          port = "$($Port.Trim())";
                      }
                  }
              }

              ## Hostname and SNMP Lookup
              foreach($host_item in $hosts.value){
                  $index = [array]::IndexOf($hosts.value, "$host_item")
                  try{
                      $DNSQuery = [System.Net.Dns]::GetHostEntry($host_item).HostName

                      $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'name' -Value $DNSQuery -Force
                  }
                  catch{
                      $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'name' -Value "Unknown" -Force
                  }
                  try{
                      $SNMP = New-Object -ComObject olePrn.OleSNMP
                      $SNMP.open($host_item,'public',2,1000)
                      $Result = $SNMP.get('.1.3.6.1.2.1.1.1.0')
                      $Result = ($Result -replace '/P','').Trim()
                      $name = $Result;
                      $snmp_open = $true;
                      $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'snmp' -Value $name -Force
                  }
                  catch{
                      $name = "";
                      $snmp_open = $false;
                      $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'snmp' -Value "Unknown" -Force
                  }
                  finally{
                      $SNMP.Close()
                  }
              }

              Write-Host "Hosts Found: $($hosts.Count)"

              $Output.out.hosts = $hosts;
              write-host $(ConvertTo-Json $hosts -Depth 5);

              #$Output.out.openports = "Test"

              $Output.success = $true;
              $end_time = $(Get-Date)
              [timespan]$total = $end_time - $start_time
              Write-Host "Total Time: $($total.ToString())"
              Write-Host "Finished scanning at $($end_time)"
          }
    Suggestion: Consider using [void] for better performance
  Line 100:
    Code: $Hosts | Where-Object { $_ -match "dynamic" } | % { ($_.trim() -replace " {1,}", ",") | ConvertFrom-Csv -Header "IP", "MACAddress" }
    Suggestion: Consider using [void] for better performance
  Line 128:
    Code: $Discovered_Hosts | Where {$_.IP -like "$address*"} | Sort -Property IP -Unique
    Suggestion: Consider using [void] for better performance
  Line 135:
    Code: [PSCustomObject]@{
                          value = "$($($IP.IP).Trim())";
                          port = "$($Port.Trim())";
                      }
    Suggestion: Consider using [void] for better performance
  Line 148:
    Code: Add-Member -MemberType NoteProperty -Name 'name' -Value $DNSQuery -Force
    Suggestion: Consider using [void] for better performance
  Line 151:
    Code: Add-Member -MemberType NoteProperty -Name 'name' -Value "Unknown" -Force
    Suggestion: Consider using [void] for better performance
  Line 160:
    Code: Add-Member -MemberType NoteProperty -Name 'snmp' -Value $name -Force
    Suggestion: Consider using [void] for better performance
  Line 165:
    Code: Add-Member -MemberType NoteProperty -Name 'snmp' -Value "Unknown" -Force
    Suggestion: Consider using [void] for better performance

== WriteHostUsage (6 issues) ==
  Line 97:
    Code: Write-Host "WARNING: Scan took longer than 15 seconds, ARP entries may have been flushed. Recommend lowering DelayMS parameter"
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 119:
    Code: Write-host "Started scanning at $($start_time)"
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 172:
    Code: Write-Host "Hosts Found: $($hosts.Count)"
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 175:
    Code: write-host $(ConvertTo-Json $hosts -Depth 5)
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 183:
    Code: Write-Host "Total Time: $($total.ToString())"
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 184:
    Code: Write-Host "Finished scanning at $($end_time)"
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
```

## Post Refactoring

```
PS C:\Users\c> pslint -Path .\win10_portscan.ps1

=== PowerShell Performance Analysis Report ===
Script: .\win10_portscan.ps1
Time: 2024-10-11 11:56:21

Summary:
Total Issues Found: 11

== ArrayAddition (2 issues) ==
  Line 90:
    Code: $IPList.Add($CurrIP)
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 152:
    Code: $hosts += [PSCustomObject]@{
                value = "$($($IP.IP).Trim())";
                port  = "$($Port.Trim())";
            }
    Suggestion: Consider using ArrayList or Generic List for better performance

== LargeCollectionLookup (1 issues) ==
  Line 152:
    Code: @{
                value = "$($($IP.IP).Trim())";
                port  = "$($Port.Trim())";
            }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections

== OutputSuppression (8 issues) ==
  Line 128:
    Code: Function Main()
{

    $start_time = $(Get-Date)

    [console]::writeline("Started scanning at $($start_time)");

    $ip_var = $(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected" }).IPv4Address.IPAddress

    if ([IPAddress]$ip_var)
    {
        $address = $ip_var -replace '.\d+$', ''
    }

    $Discovered_Hosts = Find-LANHosts
    $Discovered_Hosts = $Discovered_Hosts | Where { $_.IP -like "$address*" } | Sort -Property IP -Unique

    $hosts =  [System.Collections.ArrayList]@();

    #for ($i = 1; $i -lt 254; $i++)
    foreach ($IP in $Discovered_Hosts)
    {
        if (PortScanTCP $($IP.IP) $Port)
        {
            $hosts += [PSCustomObject]@{
                value = "$($($IP.IP).Trim())";
                port  = "$($Port.Trim())";
            }
        }
    }

    ## Hostname and SNMP Lookup
    foreach ($host_item in $hosts.value)
    {
        $index = [array]::IndexOf($hosts.value, "$host_item")
        try
        {
            $DNSQuery = [System.Net.Dns]::GetHostEntry($host_item).HostName

            $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'name' -Value $DNSQuery -Force
        }
        catch
        {
            $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'name' -Value "Unknown" -Force
        }
        try
        {
            $SNMP = New-Object -ComObject olePrn.OleSNMP
            $SNMP.open($host_item, 'public', 2, 1000)
            $Result = $SNMP.get('.1.3.6.1.2.1.1.1.0')
            $Result = ($Result -replace '/P', '').Trim()
            $name = $Result;
            $snmp_open = $true;
            $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'snmp' -Value $name -Force
        }
        catch
        {
            $name = "";
            $snmp_open = $false;
            $hosts[$index] | Add-Member -MemberType NoteProperty -Name 'snmp' -Value "Unknown" -Force
        }
        finally
        {
            $SNMP.Close()
        }
    }

    [console]::writeline("Hosts Found: $($hosts.Count)");

    $Output.out.hosts = $hosts;
    [console]::writeline($(ConvertTo-Json $hosts -Depth 5));

    #$Output.out.openports = "Test"

    $Output.success = $true;
    $end_time = $(Get-Date)
    [timespan]$total = $end_time - $start_time
    [console]::Writeline("Total Time: $($total.ToString())");
    [console]::writeline("Finished scanning at $($end_time)");
}
    Suggestion: Consider using [void] for better performance
  Line 112:
    Code: $Hosts | Where-Object { $_ -match "dynamic" } | % { ($_.trim() -replace " {1,}", ",") | ConvertFrom-Csv -Header "IP", "MACAddress" }
    Suggestion: Consider using [void] for better performance
  Line 143:
    Code: $Discovered_Hosts | Where { $_.IP -like "$address*" } | Sort -Property IP -Unique
    Suggestion: Consider using [void] for better performance
  Line 152:
    Code: [PSCustomObject]@{
                value = "$($($IP.IP).Trim())";
                port  = "$($Port.Trim())";
            }
    Suggestion: Consider using [void] for better performance
  Line 167:
    Code: Add-Member -MemberType NoteProperty -Name 'name' -Value $DNSQuery -Force
    Suggestion: Consider using [void] for better performance
  Line 171:
    Code: Add-Member -MemberType NoteProperty -Name 'name' -Value "Unknown" -Force
    Suggestion: Consider using [void] for better performance
  Line 181:
    Code: Add-Member -MemberType NoteProperty -Name 'snmp' -Value $name -Force
    Suggestion: Consider using [void] for better performance
  Line 187:
    Code: Add-Member -MemberType NoteProperty -Name 'snmp' -Value "Unknown" -Force
    Suggestion: Consider using [void] for better performance
```

Module needs a bit more TLC not gonna lie.