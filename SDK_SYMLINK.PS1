[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$Target = "../.."
)
function Test-Admin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal( $identity )
    return $principal.IsInRole( [System.Security.Principal.WindowsBuiltInRole]::Administrator )
}
function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    return New-Item -ItemType Directory -Path (Join-Path $parent $name)
}
try {
    # Check if can create symlink, but only if whatif is disabled, for cleaner whatif output
    if ($PSCmdlet.ShouldProcess($Path)) {
        $dir = New-TemporaryDirectory
        New-Item -Path $(Join-Path $dir.FullName $dir.Name) -Target $dir.FullName -Type SymbolicLink -ErrorAction Stop | Out-Null
    }
}
catch {
    # Couldn't create symlink, Warn not admin
    if (!(Test-Admin)) {
        $scriptFile = ${function:Test-Admin}.File
        $params = @()
        $psboundparameters.keys |
        foreach {
            $params += "-$($_)"
            $params += $psboundparameters.$_
        }
        if ($scriptFile) {
            Write-Host "User is not running with administrative rights. Attempting to elevate..."
            $command = 
            "
            `"cd '$pwd'; & '$($scriptFile)' $($params);`"
            pause
            exit
            "
            Start-Process powershell -verb runas "-ExecutionPolicy bypass -noexit -Command $command"
        }
        else {
            Write-Host "User is not running with administrative rights.`nPlease open a PowerShell console as administrator and try again."
        }
        return
    }
}
# Make sure ../../ exists
if (Resolve-Path $Path) {
    # Make symlink to dirs
    Get-ChildItem $Path -Directory | forEach { New-Item -Path $(Join-Path $Target $_.Name) -Target $_.FullName -Type SymbolicLink }
}