param(
    [switch] $Update
)

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

function Out-Warning {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Warning $Message
    Out-Log $Message
}

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

    "$([DateTime]::Now.ToString("yyyy-MM-dd hh:mm:ss tt")) $Message" >> $LogFile
}

function Success($msg) {
    "SUCCESS    : $msg"
}

function Warning($msg) {
    "ERROR      : $msg"
}

function Installing($msg) {
    "INSTALLING : $msg"
}

function Installed($msg) {
    "INSTALLED  : $msg"
}


function Complete($msg) {
    "COMPLETE   : $msg"
}


function Begin($msg) {
    "BEGIN      : $msg"
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

function Test-Module ([string] $name) {
    return ((Get-Module -ListAvailable | ? { $_.Name -eq $name } | measure).Count -eq 1)
}
###########################################################
# Install Functions
###########################################################

function chocolatey($names, $source = "https://chocolatey.org/api/v2/") {
    $names | % {
        Installing $_ | Out-Host
        & chocolatey.bat install $_ -source $source | Out-Log
        Installed $_ | Out-Host
    }
}

function psget($names) {
    $names | % {
        Installing $_ | Out-Host
        Install-Module $_ | Out-Log
        Installed $_ | Out-Host
    }
}

function profile([string] $content) {
    $profContent = Get-Content $profile
    if (($profContent | % { $_.Contains($content) } | ? { $_ -eq $true }) -eq $null) {
        $profContent += ([Environment]::NewLine + $content)
        Set-Content -Path "$profile" -Value $profContent
        Success "Added to `$PROFILE : $content" | Out-Host
    }
    else {
        Complete "Already in `$PROFILE : $content" | Out-Host
    }
}

function alias([string] $alias, [string] $command) {
    profile "if ((Get-Alias $alias -ea si) -eq `$null) { New-Alias $alias $command }"
}

function gem([string] $gem) {
    chocolatey $gem "ruby"
}

function windows([string] $feature) {
    chocolatey $feature "windowsfeatures"
}

###########################################################
# UPDATE LOGIC
###########################################################

if ($Update) {
    (new-object Net.WebClient).DownloadString("http://bit.ly/hwyfwk-rc") > RunMe.ps1
    Success "Updated" | Out-Host
    return;
}

###########################################################
# FIRST RUN LOGIC
###########################################################

if ((Test-Path .\RunMe.Config.ps1) -eq $false) {
    Warning "WELCOME TO ROADCREW" | Out-Host
    Warning "It appears you're running this for the first time" | Out-Host
    Warning "We've created a file, RunMe.config.ps1" | Out-Host
    Warning "Please update it to reflect your projects needs"  | Out-Host
    Warning "and then re-execute RunMe.ps1" | Out-Host
    @"
# RoadCrew makes it very easy to install the requirements
# of your software package.  You can add lines below which
# install various pieces, using our handy helpers:
#
# ### Install a http://chocolatey.org packages
# chocolatey <package> <optional: source>
#
# ### Install a http://psget.net powershell module
# psget <package>
#
# ### Install a windows feature using chocolatey
# windows <package>
#
# ### Install a ruby gem using chocolatey
# gem <package>
#
# ### Add a line to the user's `$PROFILE
# profile <package>
#
# ### Add an alias to the user's `$PROFILE
# alias <package>
"@ > .\RunMe.config.ps1
    return;
}

###########################################################
# Main Script
###########################################################

Begin "RunMe.ps1" | Out-Host

# Check the PowerShell version
# --------------------------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Warning "PowerShell version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) is detected, but version 3.0 is required.  Please visit http://bit.ly/poshupgrade to install the latest version."
    return;
}
else {
    Complete "PowerShell version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) is detected"
}

# Check for Admin rights
# --------------------------------------------------------------------
if ((Test-IsAdmin) -eq $false) { 
    Warning("Must be running as Administrator") | Out-Warning 
    return;
} else {
    Complete("Running as Administrator") | Out-Host
}

# Check for internet connection
# --------------------------------------------------------------------
if ((Test-Connection google.com -Count 1 -ErrorAction SilentlyContinue -Quiet) -eq $false) {
    Warning("Internet connection is required") | Out-Warning
    return;
}
else {
    Complete("Internet connection confirmed") | Out-Host
}

# Check for Execution Policy
# --------------------------------------------------------------------
if ((Get-ExecutionPolicy) -ne "Unrestricted") {
    Warning("PowerShell ExecutionPolicy not properly set, attempting to correct") | Out-Warning

    # Try to fix the ExecutionPolicy
    Set-ExecutionPolicy -Scope LocalMachine -Force Unrestricted -ErrorAction SilentlyContinue

    # If not successful, exit the RunMe
    if ((Get-ExecutionPolicy) -ne "Unrestricted") { return; }
    else { Success("PowerShell ExecutionPolicy has been successfully corrected") }
}
else {
    Complete("PowerShell ExeuctionPolicy is correctly set") | Out-Host
}

# Install Chocolatey - More Info at http://chocolatey.org
# --------------------------------------------------------------------
if ((Test-Path C:\Chocolatey) -eq $false) {
    Warning "Chocolatey install not found, installing"
    ExecuteFromUrl https://chocolatey.org/install.ps1 | Out-Log
    sc Env:\Path "$(gc Env:\Path);$(gc Env:\SystemDrive)\chocolatey\bin" | Out-Log
}
else {
    Complete "Chocolatey already installed"
}

# Install PSGet - More Info at http://psget.net
# --------------------------------------------------------------------
if ((Test-Module "PsGet") -eq $false) {
    Installing "PsGet" | Out-Host
    ExecuteFromUrl http://psget.net/GetPsGet.ps1 | Out-Log
    Installed "PsGet" | Out-Host
}
else {
    Complete "PsGet already installed" | Out-Host
}

Import-Module PsGet
profile "Import-Module PsGet"


Begin "RunMe.config.ps1" | Out-Host
. .\RunMe.config.ps1
