# PowerShell Script to Connect to Shared Printer with Correct Credentials
# Written per AKIEN Directives: Includes inline comments and terminal commands.

# Function to check and prompt for elevation
Function Ensure-Elevated {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script requires administrative privileges. Restarting as Administrator..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
        exit
    }
}

# Ensure the script runs as Administrator
Ensure-Elevated

# Variables (customize these values for your environment)
$PrinterServer = "AKIENYOGAI7"          # The name of the computer hosting the printer
$PrinterShare = "printer"    # The shared name of the printer
$PrinterUsername = "printer"           # The local account username
$PrinterPassword = "printer"           # The local account password

# Step 1: Remove any cached credentials for the printer server
Write-Host "Removing cached credentials for $PrinterServer..." -ForegroundColor Cyan
$CachedCredentials = cmdkey /list | Select-String $PrinterServer
if ($CachedCredentials) {
    cmdkey /delete:$PrinterServer
    Write-Host "Cached credentials removed for $PrinterServer." -ForegroundColor Green
} else {
    Write-Host "No cached credentials found for $PrinterServer." -ForegroundColor Yellow
}

# Step 2: Add new credentials for the printer server
Write-Host "Adding new credentials for $PrinterServer..." -ForegroundColor Cyan
cmdkey /add:$PrinterServer /user:$PrinterUsername /pass:$PrinterPassword
Write-Host "Credentials added for $PrinterServer." -ForegroundColor Green

# Step 3: Connect to the shared printer
$PrinterPath = "\\$PrinterServer\$PrinterShare"
Write-Host "Attempting to connect to the printer at $PrinterPath..." -ForegroundColor Cyan
try {
    Add-Printer -ConnectionName $PrinterPath
    Write-Host "Printer successfully connected!" -ForegroundColor Green
} catch {
    Write-Host "Failed to connect to the printer. Error: $_" -ForegroundColor Red
}

# Step 4: Final Message
Write-Host "Script complete. Please test the printer connection." -ForegroundColor Cyan
