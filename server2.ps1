# Values
Write-Host "Setting variables."
$LANG = "nl-BE"
$IFNAME = "Ethernet 2"
$DNS = "192.168.24.11"
$IP = "192.168.24.21"
$GW = "192.168.24.1"
$SF = "C:\vagrant"
$LOCALPATH = "C:\Users\vagrant\shared_folder"

# Keyboard Layout
Write-Output "Configuring keyboard layout to $LANG."
Set-WinUserLanguageList -LanguageList $LANG -Force
Write-Host "Keyboard lay-out successfully configured."

# Copying shared folder locally
Write-Host "Checking and copying shared folder locally."
if (!(Test-Path $LOCALPATH)) {
    Write-Output "Creating local path at $LOCALPATH."
    New-Item -Path $LOCALPATH -ItemType Directory -Force | Out-Null
    Write-Output "Local path $LOCALPATH created."
}
Copy-Item -Path $SF\* -Destination $LOCALPATH -Recurse -Force
Write-Host "Shared folder copied succesfully to $LOCALPATH."

# Setting up static IPv4 IP
Write-Output "Configuring static IP for interface $IFNAME."
New-NetIPAddress -InterfaceAlias $IFNAME -IPAddress $IP -PrefixLength 24 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $IFNAME -ServerAddresses $DNS
Write-Host "Static IP $IP and DNS $DNS configured for interface $IFNAME."

# Installing all necessary packages
Write-Host "Installing required Windows features."
Install-WindowsFeature -Name DNS -IncludeManagementTools
Write-Output "DNS feature and management tools installed succesfully."

# Rebooting
Write-Host "Rebooting system to apply changes."
Restart-Computer -Force
