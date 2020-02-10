# Script to specify a directory and display the size of folders within

dir C:\ -Directory | foreach {
    $stats = dir $_.FullName -Recurse -File |
    Measure-Object length -Sum
    $_ | Select-Object FullName,
    @{Name="Size";Expression={$stats.sum}},
    @{Name="Files";Expression={$stats.count}}
} | Sort Size