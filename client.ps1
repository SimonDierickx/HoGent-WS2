# Values
Write-Host "Setting variables."
$firstname = "simon"
$DomainName = "WS2-2425-$firstname.hogent"
$DomainAdmin = "Vagrant"
$IP = "192.168.24.13"
$GW = "192.168.24.1"
$DNS = "192.168.24.11"  
$InterfaceName = "Ethernet"# "Ethernet 2" als je met Internal Network werkt
$Password = ConvertTo-SecureString -AsPlainText "vagrant" -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainAdmin, $Password)

# Static IPv4 IP instellen
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

netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=out localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=out localport=5986 action=allow

# Join the client to the domain
Write-Host "Joining the domain."
Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force

Restart-Computer