# Uses Powershell 3
$sm_installation = "C:\GCTI\SpeechMiner\utopy\product\bin\release"

$sm_installation = "${env:ProgramFiles(x86)}\Genesys\Software\utopy\product\bin\release"
$config_file = "$sm_installation\Uplatform.exe.Config"
$conf_file = "$sm_installation\Uplatform.conf"

# Read db information
$connection_string = Get-Content -Path "C:\Scripts\connectionString"
$db_server = $connection_string.Split(' ')[0]
$db_username = $connection_string.Split(' ')[1]
$db_password = $connection_string.Split(' ')[2]
$db_name = $connection_string.Split(' ')[3]

# Load Triple Des Encryption DLL
$encryptor_dll = [Reflection.Assembly]::LoadFile("C:\Scripts\Encryptor.dll")
$encryptor = New-Object Encryptor.bSecurityCrypto.TripleDESEncryptor
$encrypted_pass = $encryptor.encrypt($db_password)

$config_string = "server=[SERVER];uid=[USER];pwd=[PASSWORD];database=[DB]"
$conf_string = "server=[DB_Server];uid=[User];pwd=[Password];database=[DB]"

# Replace connectionString
$connection_string = "server=$db_server;uid=$db_username;pwd=$db_password;database=$db_name"
(Get-Content $config_file).Replace($config_string, $connection_string) | Set-Content $config_file

$connection_string = "server=$db_server;uid=$db_username;pwd=$encrypted_pass;database=$db_name"
(Get-Content $conf_file).Replace($conf_string, $connection_string) | Set-Content $conf_file

# Rename config file so that IIS will encrypt it
Rename-Item $config_file "web.Config"

# Encrypt using IIS
$iss = ${env:systemroot} + "\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe"
$params = @('-pef', "connectionStrings", "$sm_installation", '-prov', 'RsaProtectedConfigurationProvider')
& $iss $params

# Rename config file back to original name
Rename-Item ($sm_installation + "\web.Config") "Uplatform.exe.Config"

# Register Shutdown script
regedit /s C:\Scripts\RegisterShutDown.reg

# Run SQL Script
#sqlcmd -S $db_server -U $db_username -P $db_password -d $db_name -i "c:\Scripts\StartUpScript.sql"

# Create SM User
$smuser = Get-Content -Path "C:\Scripts\LocalCredentials"
$computer = [ADSI]"WinNT://."
$user = $computer.Create("User","SMUSER")
$user.setpassword($smuser)
$user.UserFlags = 65536 # set p]assword never expires
$user.SetInfo()
$group = [ADSI]"WinNT://./Administrators,group" 
$group.add("WinNT://SMUSER,user") # add to administrator group

# Install Uplatform service 
$uplatform = "$sm_installation\Uplatform.exe"
$smuser_encrypted = $encryptor.encrypt($smuser)
$u_params = "-i SMUSER $smuser_encrypted -s Uplatform"
& "$uplatform" $u_params
