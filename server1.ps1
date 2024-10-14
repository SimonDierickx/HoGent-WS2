# Variables
Write-Host "Setting variables."
$IP = "192.168.24.11"
$GW = "192.168.24.1"
$InterfaceName = "Ethernet"
$name = "WS2-2425-simon.hogent"
$netBios = "ws2425"
$DNS2 = "192.168.24.12"
$Password = ConvertTo-SecureString -AsPlainText "24Admin25" -Force

# Keyboard Layout
Write-Host "Setting keyboard layout."
Set-WinUserLanguageList -LanguageList nl-BE -Force

# Setting up static IPv4 IP
Write-Host "Setting up IPv4."
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IP -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $IP

# Install ADDS and DHCP
Write-Host "Installing AD and DHCP."
Install-WindowsFeature -Name AD-Domain-Services,DHCP -IncludeManagementTools -Verbose

# Import ADDSDeployment module
Write-Host "Importing module."
Import-Module ADDSDeployment

# Install forest
Write-Host "Install forest."
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DomainMode "WinThreshold" `
    -DomainName $name `
    -DomainNetbiosName $netBios `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SafeModeAdministratorPassword $Password `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force=$true

# icmpv4 rule
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=out action=allow

netsh advfirewall firewall add rule name="ping4" protocol=icmpv6:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ping4" protocol=icmpv6:8,any dir=out action=allow

# Kerberos

# TCP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos TCP Inbound" -Direction Inbound -Protocol TCP -LocalPort 88 -Action Allow -Profile Domain

# UDP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos UDP Inbound" -Direction Inbound -Protocol UDP -LocalPort 88 -Action Allow -Profile Domain
    
# TCP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos TCP Outbound" -Direction Outbound -Protocol TCP -LocalPort 88 -Action Allow -Profile Domain

# UDP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos UDP Outbound" -Direction Outbound -Protocol UDP -LocalPort 88 -Action Allow -Profile Domain

# WinRM

netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow

Write-Host "Rebooting device."
Restart-Computer