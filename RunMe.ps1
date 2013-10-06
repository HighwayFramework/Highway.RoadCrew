###########################################################
# RunMe.ps1 - Framework by Tim Rayburn & Devlin Liles
# Part of the Highway.RoadCrew project
#
# License and Original Source located at :
# http://github.com/HighwayFramework/HighwayRoadCrew
#
# DO NOT MODIFY THIS FILE, MODIFY RunMeConfig.ps1 INSTEAD
###########################################################

$LogFile = ".\RunMe.log"

###########################################################
# FUNCTIONS
###########################################################

function Out-Host {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Host $Message
    Out-Log $Message
}

function Out-Verbose {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Verbose -Message $Message
    Out-Log $Message
}

function Out-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    $Message >> $LogFile
}

function Success($msg) {
    "SUCCESS : $msg"
}

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}

###########################################################
# Main Script
###########################################################

"BEGIN : RunMe.ps1" | Out-Host

if ((Test-IsAdmin) -eq $false) { 
    throw "You must be running as an Administrator" 
} else {
    Success("Running as Administrator") | Out-Host
}