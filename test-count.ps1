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

Out-TestCountCsv 'Integration' $integrationPath $fullOutputPath
Out-TestCountCsv 'E2E' $e2ePath $fullOutputPath
Out-TestCountCsv 'Unit' $unitPath $fullOutputPath

Pop-Location

Write-Host "Done, Curent Directory: " + $PWD

function Out-TestCountCsv
{
  param ([string]$type,
         [string]$path,
         [string]$csvPath)

  Write-Verbose "Counting $type tests..."

  git log '--pretty=%h %ai' $path |
    ForEach-Object {
        $t = $_ -split ' ', 4;
        $count = git grep -E $testAttributeRegex $t[0] -- $path\*.cs |
            Measure-Object |
            Select-Object -ExpandProperty Count
        if ($LASTEXITCODE) { throw }
        New-Object psobject -Property @{
          Type = $type;
          Commit = $t[0];
          Date = $t[1];
          TestCount = $count;
        }
    } |
    ConvertTo-Csv |
    Select-Object -Skip 1 |
    Out-File -Append -Path $csvPath
    if ($LASTEXITCODE) { throw }
}

Pop-Location

Write-Host "Done, Curent Directory: " + $PWD