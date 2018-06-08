#Instructions: The Objects must be all separated in 3 different folders. Modified, Target and Result
param
(
    [Parameter(Mandatory=$true)]
    [string]$modifiedfilepath,
    [Parameter(Mandatory=$true)]
    [string]$targetfilepath,
    [Parameter(Mandatory=$true)]
    [string]$resultpath
)

Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\NavModelTools.ps1"
Import-Module "C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1"
Import-Module $PSScriptRoot\Merge-NAVVersionListStringscript.ps1

 
Get-ChildItem $modifiedfilepath -Filter *.txt |
 
Foreach-Object {
    $ProgressPreference = 'SilentlyContinue'
 
    $modifiedObj = $modifiedfilepath + $_.BaseName + '.txt'
    $targetObj = $targetfilepath + $_.BaseName + '.txt'
    $resultObj = $resultpath + $_.BaseName + '.txt'
 
    $modifiedproperty=Get-NAVApplicationObjectProperty -Source $modifiedObj
    $sourceproperty = Get-NAVApplicationObjectProperty -Source $targetObj
        
    $targetversionlist = Merge-NAVVersionListString -source $sourceproperty.VersionList -target $modifiedproperty.VersionList -mode SourceFirst -newversion $newversion
    Set-NAVApplicationObjectProperty -Target $resultobj -VersionListProperty $targetversionlist
    $ProgressPreference = 'Continue'
} 