# Avoid wrapping cmdlet pipelines
## Most cmdlets are implemented for the pipeline, which is a sequential syntax and process. For example:

cmdlet1 | cmdlet2 | cmdlet3

# Initializing a new pipeline can be expensive, therefore you should avoid wrapping a cmdlet pipeline into another existing pipeline.

# Consider the following example. The Input.csv file contains 2100 lines. The Export-Csv command is wrapped inside the ForEach-Object pipeline. The Export-Csv cmdlet is invoked for every iteration of the ForEach-Object loop.

$measure = Measure-Command -Expression {
    Import-Csv .\Input.csv | ForEach-Object -Begin { $Id = 1 } -Process {
        [PSCustomObject]@{
            Id   = $Id
            Name = $_.opened_by
        } | Export-Csv .\Output1.csv -Append
    }
}

'Wrapped = {0:N2} ms' -f $measure.TotalMilliseconds

# For the next example, the Export-Csv command was moved outside of the ForEach-Object pipeline. In this case, Export-Csv is invoked only once, but still processes all objects passed out of ForEach-Object.

$measure = Measure-Command -Expression {
    Import-Csv .\Input.csv | ForEach-Object -Begin { $Id = 2 } -Process {
        [PSCustomObject]@{
            Id   = $Id
            Name = $_.opened_by
        }
    } | Export-Csv .\Output2.csv
}

'Unwrapped = {0:N2} ms' -f $measure.TotalMilliseconds
# The unwrapped example is 372 times faster. Also, notice that the first implementation requires the Append parameter, which isn't required for the later implementation.