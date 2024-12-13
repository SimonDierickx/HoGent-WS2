# Values
Write-Output "Setting up variables."
$NAME = "ws2-2425-simon.hogent"
$USERNAME = "simon"
$PASSWORD = "Secure!Passw0rd"
$SECUREPASS = ConvertTo-SecureString $PASSWORD -AsPlainText -Force
$CREDENTIAL = New-Object System.Management.Automation.PSCredential("$USERNAME@$NAME", $SECUREPASS)

# Join domain
Write-Host "Joining the existing domain: $NAME."
Add-Computer -DomainName $NAME -Credential $CREDENTIAL -Force -Restart
Write-Output "Succesfully joined the domain. The system will now restart."
