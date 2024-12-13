# Values
Write-Host "Setting up variables."
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

# Keyboard Layout
Write-Output "Setting keyboard layout."
Set-WinUserLanguageList -LanguageList $LANG -Force
Write-Host "Keyboard layout configured to $LANG."

# Copying shared folder locally
Write-Host "Copying shared folder locally."
New-Item -Path $LOCALPATH -ItemType Directory -Force
Copy-Item -Path $SF\* -Destination $LOCALPATH -Recurse -Force
Write-Output "Shared folder copied succesfully to $LOCALPATH."

# Setup IP with DHCP
Write-Output "Configuring DHCP settings..."
netsh interface ip set address name=$IFNAME source=dhcp
netsh interface ip set dns name=$IFNAME source=dhcp
Write-Host "DHCP configuration complete."

# Join domain
Write-Host "Joining existing domain: $NAME."
Add-Computer -DomainName $NAME -Credential $CREDENTIAL -Force -Restart
Write-Output "System added to domain $NAME and will restart."
