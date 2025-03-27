# Install.ps1
# Installation script for Start-UserMode PowerShell module

# Ensure we're running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]'Administrator')) {
    Write-Warning "This script requires administrator privileges to install the module for all users."
    Write-Warning "Please run this script as an administrator."
    
    $installForCurrentUser = Read-Host "Would you like to install for current user only? (Y/N)"
    if ($installForCurrentUser -ne 'Y') {
        return
    }
}

# Determine install location based on PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major
$moduleName = "Start-UserMode"

if ($psVersion -ge 6) {
    # PowerShell 6+ (PowerShell Core, PowerShell 7)
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]'Administrator')) {
        $modulePath = Join-Path $env:ProgramFiles "PowerShell\Modules\$moduleName"
    } else {
        $modulePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\Modules\$moduleName"
    }
} else {
    # Windows PowerShell 5.1 and below
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]'Administrator')) {
        $modulePath = Join-Path $env:ProgramFiles "WindowsPowerShell\Modules\$moduleName"
    } else {
        $modulePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules\$moduleName"
    }
}

# Create the module directory if it doesn't exist
if (-not (Test-Path $modulePath)) {
    Write-Host "Creating module directory: $modulePath"
    New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
}

# Create the module file
$moduleContent = @'
# Start-UserMode.psm1
# Module to start applications in user mode with specific trust level

# Function to start an application in user mode
function Start-UserMode {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ApplicationPath
    )
    
    # First check if it's a full path
    if (Test-Path $ApplicationPath) {
        $FullPath = $ApplicationPath
    }
    # Then check if it's in the current directory
    elseif (Test-Path (Join-Path (Get-Location) $ApplicationPath)) {
        $FullPath = Join-Path (Get-Location) $ApplicationPath
    }
    # Finally check if it's in the PATH
    else {
        $Command = Get-Command $ApplicationPath -ErrorAction SilentlyContinue
        if ($Command) {
            $FullPath = $Command.Source
        }
        else {
            Write-Error "Application not found: $ApplicationPath"
            return
        }
    }
    
    # Set the trust level environment variable
    $env:APP_TRUSTLEVEL = "0x20000"
    
    Write-Host "Running $FullPath in user mode with trust level: $env:APP_TRUSTLEVEL"
    
    # Run the application with runas and the specified trust level
    try {
        Start-Process "runas.exe" -ArgumentList "/trustlevel:$env:APP_TRUSTLEVEL `"$FullPath`"" -Wait
        Write-Host "Application execution completed."
    }
    catch {
        Write-Error "Failed to execute the application: $_"
    }
}

# Export the function so it can be used when the module is imported
Export-ModuleMember -Function Start-UserMode
'@

$moduleFile = Join-Path $modulePath "$moduleName.psm1"
Write-Host "Creating module file: $moduleFile"
Set-Content -Path $moduleFile -Value $moduleContent

# Create module manifest
$manifestParams = @{
    Path              = Join-Path $modulePath "$moduleName.psd1"
    RootModule        = "$moduleName.psm1"
    ModuleVersion     = "1.0.0"
    Author            = "Your Name"
    Description       = "Starts applications in user mode with a specific trust level"
    PowerShellVersion = "5.1"
    FunctionsToExport = @("Start-UserMode")
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}

Write-Host "Creating module manifest"
New-ModuleManifest @manifestParams

Write-Host "Module installation completed successfully!" -ForegroundColor Green
Write-Host "You can now use the module by running: Import-Module $moduleName" -ForegroundColor Green
Write-Host "To test it, try: Start-UserMode cmd.exe" -ForegroundColor Green

# Import the module automatically if user wants
$importModule = Read-Host "Do you want to import the module now? (Y/N)"
if ($importModule -eq 'Y') {
    Import-Module $moduleName -Force
    Write-Host "Module imported successfully. You can now use Start-UserMode to run applications." -ForegroundColor Green
}
