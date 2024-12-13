# Variables
Write-Host "Setting variables."
$LANG = "nl-BE"
$IFNAME = "Ethernet 2"
$GW = "192.168.24.1"
$IP = "192.168.24.11"
$SF = "C:\vagrant"
$LOCALPATH = "C:\Users\administrator\shared_folder"

# Keyboard Layout
Write-Output "Configuring keyboard lay-out..."
Set-WinUserLanguageList -LanguageList $LANG -Force
Write-Host "Keyboard layout configured to $LANG."

# Copying shared folder locally
Write-Output "Copying shared folder to the local path."
if (!(Test-Path $LOCALPATH)) {
    New-Item -Path $LOCALPATH -ItemType Directory -Force
    Write-Output "Local path created at $LOCALPATH."
}
Copy-Item -Path $SF\* -Destination $LOCALPATH -Recurse -Force
Write-Host "Shared folder successfully copied to $LOCALPATH."

# Setting up static IPv4 IP
Write-Host "Configuring static IPv4 IP."
New-NetIPAddress -InterfaceAlias $IFNAME -IPAddress $IP -PrefixLength 24 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $IFNAME -ServerAddresses $IP
Write-Output "Static IP set to $IP for interface $IFNAME."

# Installing all necessary packages
Write-Host "Installing required Windows features."
Install-WindowsFeature -Name DHCP, AD-Domain-Services, DNS -IncludeManagementTools
Write-Output "All required packages installed successfully."

# Rebooting
Write-Host "Rebooting system to apply changes."
Restart-Computer -Force
