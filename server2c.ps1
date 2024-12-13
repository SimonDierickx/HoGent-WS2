# Values
Write-Host "Setting up variables."
$DNS = "192.168.24.11"
$RANGE = "192.168.24.0"
$NAME = "ws2-2425-simon.hogent"
$REVERSE_ZONE = "24.168.192.in-addr.arpa"

# Configure DNS
Write-Output "Configuring secondary DNS server."
# Configure the forward lookup zone
if (-not (Get-DnsServerZone -Name $NAME -ErrorAction SilentlyContinue)) {
    Add-DnsServerSecondaryZone -Name $NAME -MasterServers $DNS -ZoneFile "$NAME.DNS"
    Write-Host "Forward lookup zone for $NAME added succesfully."
} else {
    Write-Output "Forward lookup zone for $NAME already exists. Skipping."
}

# Configure the reverse lookup zone
if (-not (Get-DnsServerZone -Name $REVERSE_ZONE -ErrorAction SilentlyContinue)) {
    Add-DnsServerSecondaryZone -Name $REVERSE_ZONE -MasterServers $DNS -ZoneFile "$REVERSE_ZONE.DNS"
    Write-Host "Reverse lookup zone for $REVERSE_ZONE added succesfully."
} else {
    Write-Output "Reverse lookup zone for $REVERSE_ZONE already exists. Skipping."
}

New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4

