<#
.SYNOPSIS
    Count number of tests per type in a git repository
.DESCRIPTION
    Simple PowerShell script that outputs a csv file of the number of tests, per
type and per commit. This data can then be used to generate a simple chart.
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory=$true, Position=0)]
  [string]
  $GitRepoPath #Path to the repository of which tests should be counted
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $E2ePath = 'Tests/E2E' #Relative path to the directory containing E2E tests (default = Tests/E2E)
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $IntegrationPath = 'Tests/Integration' #Relative path to the directory containing Integration tests (default = Tests/Integration)
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $UnitPath = 'Tests/Unit' #Relative path to the directory containing Unit tests  (default = Tests/Unit)
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $FileExtensionWildcard = '*.cs' #File extension of the files containing tests  (default = *.cs)
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $TestAttributeRegex = '\[ *(Fact|Theory) *\]' #Regex of attributes that define tests in your setup  (default = \[ *(Fact|Theory) *\])
  
  ,[Parameter(Mandatory=$false)]
  [string]
  $OutputFile = 'test-count.csv' #Name of the output file, will be stored in current directory (default = test-count.csv)
)

$ErrorActionPreference = 'Stop'

function Out-TestCountCsv
{
  param ([string]$type,
         [string]$path,
         [string]$csvPath)

Write-Host "Counting $type tests..."

git log '--pretty=%h %ai' $path |
    ForEach-Object {
        $t = $_ -split ' ', 4;
        $count = git grep -E $TestAttributeRegex $t[0] -- $path\$FileExtensionWildcard |
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

$FullOutputPath = Join-Path -Path $PWD -ChildPath $OutputFile

Write-Host "Current directory: $PWD"
Write-Host "OutputPath: $FullOutputPath"
try { 
    Push-Location -Path $GitRepoPath
    Write-Host "Changed to repository directory: $PWD"
    
    Clear-Content -Path $FullOutputPath -ErrorAction SilentlyContinue
   
    Out-TestCountCsv 'Integration' $IntegrationPath $FullOutputPath
    Out-TestCountCsv 'E2E' $E2ePath $FullOutputPath
    Out-TestCountCsv 'Unit' $UnitPath $FullOutputPath
}
finally {
    Pop-Location
}
Write-Host "Changed to repository directory: $PWD"
Write-Host "Done, check $FullOutputPath"
