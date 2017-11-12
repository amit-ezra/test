# Uses Powershell 3
$sm_installation = ${env:ProgramFiles(x86)} + "\Genesys\Software\utopy\product\bin\release"
$config_file = $sm_installation + "\Uplatform.exe.Config"
$conf_file = $sm_installation + "\Uplatform.conf"

$config_string = "server=[SERVER];uid=[USER];pwd=[PASSWORD];database=[DB]"
$conf_string = "server=[DB_Server];uid=[User];pwd=[Password];database=[DB]"

# replace connectionString
$connectionString = Get-Content -Path "C:\Scripts\connectionString"
(Get-Content $config_file).Replace($config_string, $connectionString) | Set-Content $config_file
(Get-Content $conf_file).Replace($conf_string, $connectionString) | Set-Content $conf_file

# Read db credentials for sql commands
[xml]$xmlfile = Get-Content -Path $config_file
$db_server = $xmlfile.configuration.connectionStrings.add.GetAttribute('connectionString').Split(';')[0].Split('=')[1]
$db_username = $xmlfile.configuration.connectionStrings.add.GetAttribute('connectionString').Split(';')[1].Split('=')[1]
$db_password = $xmlfile.configuration.connectionStrings.add.GetAttribute('connectionString').Split(';')[2].Split('=')[1]
$db_name = $xmlfile.configuration.connectionStrings.add.GetAttribute('connectionString').Split(';')[3].Split('=')[1]

# Rename config file so that IIS will encrypt it
Rename-Item $config_file "web.Config"

# Encrypt using IIS
$iss = ${env:systemroot} + "\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe"
$params = @('-pef', "connectionStrings", "$sm_installation", '-prov', 'RsaProtectedConfigurationProvider')
& $iss $params

 # Rename config file back to original name
Rename-Item ($sm_installation + "\web.Config") "Uplatform.exe.Config"

# TODO -> Encrypt Uplatform.conf 

#register Shutdown script
regedit /s C:\Scripts\RegisterShutDown.reg

# Run SQL Script
sqlcmd -S $db_server -U $db_username -P $db_password -d $db_name -i "c:\Scripts\StartUpScript.sql"

# TODO Restart Uplatform service? 
