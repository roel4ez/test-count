# test-count

> Count number of tests per type in a git repository

Simple PowerShell script that outputs a csv file of the number of tests, per
type and per commit. This data can then be used to generate a simple chart such
as:

![Test Count Chart](chart.png)

The script has a few parameters that can be set:

> The script does not yet accept these as input parameters. These need to be set
in the script itself!

| Name | Default | Description |
| --- | --- | --- |
| `gitRepoPath` | | The path to the repository |
| `e2ePath` | `.\Tests\E2E` | Path to the subdirectory where the e2e tests live |
| `integrationPath` | `.\Tests\Integration` | Path to the subdirectory where the integration tests live |
| `unitPath` | `.\Tests\Unit` | Path to the subdirectory where the unit tests live |
| `testAttributeRegex` | `\[ *(Fact\|Theory) *\]` | The regular expression used to find the tests. This is usually the attribute which decorates your tests cases. Default value is for xUnit. |
| `outputFile` | `test-count-csv` | The output csv file, will be stored in the current directory |
