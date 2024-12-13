# Varibles
Write-Host "Setting varibles."
$GW = "192.168.24.1"
$IP = "192.168.24.11"
$IP2 = "192.168.24.21"
$RANGE = "192.168.24.0"
$REVERSE = "24.168.192.in-addr.arpa"
$NAME = "ws2-2425-simon.hogent"
$ISO = "C:\Users\administrator\shared_folder\en_sql_server_2019_standard_x64_dvd_814b57aa.iso"
$PathToAdd = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\"
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# Configure users
Write-Host "Add users to the OU."
$ADUsers = Import-Csv "C:\vagrant\gebruikers.csv" -Delimiter ";"

foreach ($User in $ADUsers) {
    $FIRSTNAME = $User.Voornaam
    $LASTNAME = $User.Achternaam
    $INITIALS = $User.Initialen
    $USERNAME = $User.Gebruikersnaam
    $PASSWORD = $User.Password
    $OU = $User.OU

if (-not (Get-ADUser -F { SamAccountName -eq $USERNAME })) {
    New-ADUser `
        -SamAccountName $USERNAME `
        -UserPrincipalName "$USERNAME@$NAME" `
        -Name "$FIRSTNAME $LASTNAME" `
        -GivenName "$FIRSTNAME" `
        -Surname "$LASTNAME" `
        -Displayname "$FIRSTNAME $LASTNAME" `
        -AccountPassword (ConvertTo-SecureString $PASSWORD -AsPlainText -Force) -ChangePasswordAtLogon $False `
        -Path $OU `
        -Enabled $true
    Write-Output "User '$USERNAME' created sucessfully."
} else {
    Write-Host "User '$USERNAME' already exists."
}
}