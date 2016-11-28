#script to launch pester and run tests.  this will be run by the VSTS build server.  eventually will be replaced by a Psake build script.
#below script found at URL https://writeabout.net/2016/01/02/run-pester-tests-in-github-with-vsts-vso-build-badge/
param(
    [string]$SourceDir = $env:BUILD_SOURCESDIRECTORY,
    [string]$TempDir = $env:TEMP,
    [String]$TestName
)
$ErrorActionPreference = 'Continue'
 
$Scripts = Get-ChildItem "$SourceDir\ModuleParts" -Filter *.ps1 -Recurse
$Scripts | get-content | out-file -FilePath "$TempDir\infoblox.ps1"
. "$TempDir\infoblox.ps1"
$scripts | %{. $_.FullName}

 
$modulePath = Join-Path $TempDir Pester-master\Pester.psm1
 
if (-not(Test-Path $modulePath)) {
 
    # Note: PSGet and chocolatey are not supported in hosted vsts build agent  
    $tempFile = Join-Path $TempDir pester.zip
    Invoke-WebRequest https://github.com/pester/Pester/archive/master.zip -OutFile $tempFile
 
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempFile, $tempDir)
 
    Remove-Item $tempFile
}

Import-Module $modulePath -DisableNameChecking
 
$outputFile = "$SourceDir\$TestName-pester.xml"
 
Invoke-Pester -Script "$SourceDir\tests\$TestName.tests.ps1" -PassThru -OutputFile $outputFile -OutputFormat NUnitXml -EnableExit