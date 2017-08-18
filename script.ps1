cls

$logs = "$PSScriptRoot"
$dacpac = Join-Path $PSScriptRoot 'CobaltDb.dacpac'
$profile = Join-Path $PSScriptRoot 'CobaltDb.publish.xml'

$targetConnectionString = 'SERVER=.;Integrated Security=True'
$targetDatabaseName = 'CobaltDb'

$dac = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\Microsoft.SqlServer.Dac.dll"
Add-Type -path $dac
Write-Verbose -Verbose 'Loaded DAC assembly.'
$dacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($Dacpac)
Write-Verbose ('Loaded dacpac ''{0}''.' -f $Dacpac) -Verbose

$dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($Profile)
$msg = 'Loaded publish profile ''{0}''.' -f $Profile
Write-Verbose $msg -Verbose
Remove-Variable -name msg

$dacServices = New-Object Microsoft.SqlServer.Dac.DacServices $targetConnectionString

Write-Verbose 'Generating Deployment Script...' -Verbose
$script = "$logs\$targetDatabaseName.GenerateDeployScript.sql"
$dacServices.GenerateDeployScript($dacPackage, $targetDatabaseName, $dacProfile.DeployOptions) | Out-File $script
$msg = "Deployment Script Created at $script"

