# Values
Write-Host "Setting variables."
$IP = "192.168.24.12"
$GW = "192.168.24.1"
$InterfaceName = "Ethernet"
$firstname = "simon"
$DNS = "192.168.24.11"
$DomainAdmin = "Vagrant"
$Password = ConvertTo-SecureString -AsPlainText "vagrant" -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainAdmin, $Password)

# Keyboard Layout
Write-Host "Setting keyboard layout."
Set-WinUserLanguageList -LanguageList nl-BE -Force

# Setting up static IPv4 IP
Write-Host "Setting up IPv4."
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IP -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNS

# icmpv4 rule
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=out action=allow

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

Restart-Computer

# Join Server 2 to the domain
Write-Host "Joining the domain."
Add-Computer -DomainName "WS2-2425-$firstname.hogent" -Credential $Credential

# Install DNS
Write-Host "Installing AD and DNS."
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Create secondary zones for forward and reverse lookups
Write-Host "Creating zones."
Add-DnsServerSecondaryZone -Name "WS2-2425-$firstname.hogent" -ZoneFile "WS2-2425-$firstname.hogent.dns" -MasterServers "$DNS"
Add-DnsServerSecondaryZone -Name "24.168.192.in-addr.arpa" -ZoneFile "24.168.192.in-addr.arpa.dns" -MasterServers "$DNS"

Restart-Computer
