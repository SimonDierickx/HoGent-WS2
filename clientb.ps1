# Values
Write-Host "Setting up variables..."
$LANG = "nl-BE"
$IFNAME = "Ethernet 2"
$RANGE = "192.168.24.0"
$GW = "192.168.24.1"
$DNS = "192.168.24.11"
$DNS2 = "192.168.24.21"
$NAME = "ws2-2425-simon.hogent"
$USERNAME = "simon"
$PASSWORD = "Secure!Passw0rd"
$OU = "OU=gebruikers,DC=ws2-2425-simon,DC=hogent"
$SECUREPASS = ConvertTo-SecureString $PASSWORD -AsPlainText -Force
$CREDENTIAL = New-Object System.Management.Automation.PSCredential("$USERNAME@$NAME", $SECUREPASS)

$SF = "C:\vagrant"
$LOCALPATH = "C:\Users\vagrant\shared_folder"
$SSMSInstallerPath = "C:\Users\vagrant\shared_folder\SSMS-Setup-ENU.exe"

# Installing RSAT Management Tools
Write-Host "Starting RSAT management tools installation..."
$RSATFeatures = @(
    "RSAT.ActiveDirectory.DS-LDS.Tools",
    "RSAT.DNS.Tools",
    "RSAT.FileServices.Tools",
    "RSAT.GroupPolicy.Management.Tools",
    "RSAT.ServerManager.Tools",
    "Rsat.DHCP.Tools"
)

foreach ($Feature in $RSATFeatures) {
    Write-Output "Installing feature: $Feature..."
    DISM /Online /Add-Capability /CapabilityName:$Feature~~~~0.0.1.0 | Out-Null
    Write-Host "$Feature has been installed succesfully."
}

Write-Output "All RSAT tools have been installed."

# Installing SQL Server Management Studio
Write-Host "Installing SQL Server Management Studio (SSMS)..."
if (Test-Path $SSMSInstallerPath) {
    Start-Process -FilePath $SSMSInstallerPath -ArgumentList "/install /quiet /norestart" -Wait
    Write-Host "SQL Server Management Studio installed succesfully."
} else {
    Write-Warning "Could not locate SSMS installer at path: $SSMSInstallerPath."
}

# Verifying installations
Write-Output "Verifying all installations..."
foreach ($Feature in $RSATFeatures) {
    $State = Get-WindowsOptionalFeature -Online -FeatureName $Feature | Select-Object -ExpandProperty State
    Write-Host "Feature: $Feature, Status: $State"
}

Write-Host "Script execution completed succesfully."
