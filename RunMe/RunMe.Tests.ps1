$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\$sut"

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}

Describe "RunMe should ensure Admin execution writes" {

    Context "When elevated" {

        $exceptionThrown = $false

        try {
            . .\RunMe.ps1
        } catch {
            $exceptionThrown = $true
        }

        It "assumes you're running elevated" {
            Test-IsAdmin | Should Be $true
        }

        It "will execute properly" {
            $exceptionThrown | Should Be $false
        }

    }

    Context "When non-elevated" {
    
        $script = Get-Item -Path .\RunMe.ps1
        $drive = Get-Item -Path TestDrive:\
        & powershell.exe -nologo -noprofile -executionpolicy bypass -command @"
function Test-IsAdmin {
    try {
        `$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        `$principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList `$identity
        return `$principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f `$_
    }
}
Write-Host `$(Test-IsAdmin)
. $($script.FullName) -ErrorAction Stop
New-Item -Path $drive\FileShouldNotExist.test -ItemType File
"@
        $fileCreated = Test-Path -Path TestDrive:\FileShouldNotExist.test

        It "will throw" {
            $fileCreated | Should Be $false
        }

    }
}

