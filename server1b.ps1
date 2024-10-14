Write-Host "Setting variables."
$IP = "192.168.24.11"
$GW = "192.168.24.1"
$InterfaceName = "Ethernet"
$name = "WS2-2425-simon.hogent"
$DNS2 = "192.168.24.12"
$Password = ConvertTo-SecureString -AsPlainText "24Admin25" -Force

# DNS
Write-Host "Configuring DNS."
Install-WindowsFeature -Name DNS -IncludeManagementTools
Add-DnsServerPrimaryZone -Name "$name" -ZoneFile "$name.dns"
Add-DnsServerPrimaryZone -NetworkId "192.168.24.0/24" -ReplicationScope "Domain"

# A-Records for the DNS Servers
Write-Host "Add A-records."
Add-DnsServerResourceRecordA -Name "PrimaryServer" -ZoneName "$name" -IPv4Address "$IP"
Add-DnsServerResourceRecordA -Name "SecondaryServer" -ZoneName "$name" -IPv4Address "$DNS2"

# PTR Records for Reverse Lookup
Write-Host "Add PTR-records."
Add-DnsServerResourceRecordPTR -Name "11" -ZoneName "24.168.192.in-addr.arpa" -PtrDomainName "PrimaryServer.$name"
Add-DnsServerResourceRecordPTR -Name "12" -ZoneName "24.168.192.in-addr.arpa" -PtrDomainName "SecondaryServer.$name"

# Allow zone transfers
Write-Host "Allow zone transfers."
Set-DnsServerPrimaryZone -Name "$name" -AllowZoneTransfer -SecondaryServers "$DNS2"
Set-DnsServerPrimaryZone -Name "24.168.192.in-addr.arpa" -AllowZoneTransfer -SecondaryServers "$DNS2"

# DHCP
Write-Host "Setup DHCP."
Add-DhcpServerv4Scope -Name "ClientScope" -StartRange 192.168.24.101 -EndRange 192.168.24.150 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -DnsServer $IP -Router $GW

Restart-Computer