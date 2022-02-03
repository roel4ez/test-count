[CmdletBinding()]
param (
  [string]$GitRepoPath = '.',
  [string]$E2ePath = 'Tests/E2E',
  [string]$IntegrationPath = 'Tests/Integration' ,
  [string]$UnitPath = 'Tests/Unit',
  [string]$TestAttributeRegex = '\[ *(Fact|Theory) *\]',
  [string]$OutputFile = 'test-count.csv'
)

$ErrorActionPreference = 'Stop'

$fullOutputPath = Join-Path -Path $PWD -ChildPath $outputFile

Write-Host "Current directory: " $PWD " OutputPath: " $fullOutputPath
Clear-Content -Path $fullOutputPath -ErrorAction SilentlyContinue
Push-Location $gitRepoPath
Write-Host "Changed to repository directory: " $PWD

Write-Host "Counting E2E tests..."

git log '--pretty=%h %ai' $e2ePath |
  ForEach-Object { $t = $_ -split ' ', 4;
      New-Object psobject -Property @{ Type = "E2E"; Commit = $t[0]; Date = $t[1]; TestCount = $(git grep -E $testAttributeRegex $t[0] -- $e2ePath\*.cs  | Measure-Object | Select-Object -ExpandProperty Count) }
  } | ConvertTo-Csv | Out-File -Path $fullOutputPath

Write-Host "Counting Integration tests..."

git log '--pretty=%h %ai' $integrationPath |
  ForEach-Object { $t = $_ -split ' ', 4;
      New-Object psobject -Property @{ Type = "Integration"; Commit = $t[0]; Date = $t[1]; TestCount = $(git grep -E $testAttributeRegex $t[0] -- $e2ePath\*.cs  | Measure-Object | Select-Object -ExpandProperty Count) }
  } | ConvertTo-Csv | Select-Object -Skip 1 | Out-File -Append -Path $fullOutputPath

Write-Host "Counting Unit tests..."

git log '--pretty=%h %ai' $unitPath |
  ForEach-Object { $t = $_ -split ' ', 4;
      New-Object psobject -Property @{ Type = "Unit"; Commit = $t[0]; Date = $t[1]; TestCount = $(git grep -E $testAttributeRegex $t[0] -- $e2ePath\*.cs  | Measure-Object | Select-Object -ExpandProperty Count) }
  } | ConvertTo-Csv | Select-Object -Skip 1 | Out-File -Append -Path $fullOutputPath

Pop-Location

Write-Host "Done, Curent Directory: " + $PWD