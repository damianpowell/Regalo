param($projectName, $assemblyInfoFilename)

Set-StrictMode -Version Latest

#$DebugPreference = "Continue"
#$VerbosePreference = "Continue"

# Try to find git.exe in the path
$gitPath = $(cmd /c where git.exe 2> $null)

# If it's not there, look for it in GitHub for Windows
if (!$gitPath) {
    $gitPath = $(
        (gci -rec -inc git.exe ~\AppData\Local\github |
            select -ExpandProperty FullName) -like '*\cmd\git.exe' |
                select -First 1
    )
}

Write-Debug "gitPath=$gitPath"
function git { & $gitPath $args }

$gitVersion = git describe --tags --long --match "v*.*.*" --abbrev=40
$gitVersion -match "^v(\d+)\.(\d+)\.(\d+)\-(\d+)-(g[a-f0-9]{40})`$"
($major, $minor, $build, $revision) = $Matches[1..4]

$assemblyVersion = "$major.$minor.$build.$revision"

write-host "Building output as $assemblyVersion..."

$assemblyInfo = @"
using System.Reflection;

[assembly: AssemblyDescription("A basic implementation of Greg Young's CQRS/ES pattern. Built from version $gitVersion.")]
[assembly: AssemblyVersion("$assemblyVersion")]
[assembly: AssemblyFileVersion("$assemblyVersion")]
"@

$assemblyInfo > $assemblyInfoFilename
