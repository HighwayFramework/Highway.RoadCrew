###########################################################
# RunMe.ps1 - Framework by Tim Rayburn & Devlin Liles
# Part of the Highway.RoadCrew project
#
# License and Original Source located at :
# http://github.com/HighwayFramework/HighwayRoadCrew
#
# DO NOT MODIFY THIS FILE, MODIFY RunMeConfig.ps1 INSTEAD
###########################################################

###########################################################
# FUNCTIONS
###########################################################

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

if ((Test-IsAdmin) -eq $false) { 
    throw "You must be running as an Administrator" 
}