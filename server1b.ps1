# Variables
Write-Host "Setting up variables"
$NAME = "ws2-2425-simon.hogent"
$PASSWORD = "Secure!Passw0rd"

# Promote SERVER1 to domain controller
Write-Output "Promoting SERVER1 to domain controllr..."
Install-ADDSForest -DomainName $NAME `
    -ForestMode WinThreshold `
    -DomainMode WinThreshold `
    -InstallDns `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $PASSWORD -AsPlainText -Force) `
    -Force
Write-Host "SERVER1 successfully promoted to domain controller."
