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
$ScriptRedacted = "$logs\$targetDatabaseName.Redacted.GenerateDeployScript.sql"
$dacServices.GenerateDeployScript($dacPackage, $targetDatabaseName, $dacProfile.DeployOptions) | Out-File $script
#new bit
$myFileReader = New-Object System.IO.StreamReader -Arg $script
$myFileWriter = [System.IO.StreamWriter] $ScriptRedacted
$ScriptRedactedFileName = Split-Path $ScriptRedacted -leaf
$ScriptFileName = Split-Path $Script -leaf
while ($null -ne ($myLine = $myFileReader.ReadLine())) {
    if ($myLine.StartsWith(":setvar")) {
        $myParam = $myLine.Substring(8).Split('"')
        Write-Host "Removing value of"$myParam[0]"from"$ScriptRedactedFileName
        $myLine = $myLine -Replace ('"([^"]+)"', "value_deleted")
    }
    $myFileWriter.WriteLine($myLine)
}
$myFileReader.Close()
$myFileWriter.Close()
Remove-Item $script -Force | Out-Null
Rename-Item -Path $ScriptRedacted -NewName $ScriptFileName
#end of new bit
$msg = "Deployment Script Created at $script"

