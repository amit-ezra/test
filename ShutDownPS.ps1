# Uses Powershell 3
# Must be run as administrator
$sm_installation = ${env:ProgramFiles(x86)} + "\Genesys\Software\utopy\product\bin\release"
$config_file = $sm_installation + "\Uplatform.exe.Config"

# Rename config file so that IIS will dencrypt it

Rename-Item $config_file "web.Config"

# Dencrypt using IIS
$iss = ${env:systemroot} + "\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe"
$params = @('-pdf', "connectionStrings", "$sm_installation")
& $iss $params

 # Rename config file back to original name
Rename-Item ($sm_installation + "\web.Config") "Uplatform.exe.Config"

# Read DB Credentials and information

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

# Run SQL Script

Invoke-Sqlcmd -ServerInstance $db_server -Username $db_username -Password $db_password -Database $db_name -InputFile "C:\ShutDownScript.sql"

# set user data to run on startup, in case this is a restart and not termintation.

$aws_config = "C:\Program Files\Amazon\Ec2ConfigService\Settings\config.xml"
[xml]$aws_xml = Get-Content -Path $aws_config
$index = $aws_xml.Ec2ConfigurationSettings.Plugins.Plugin.Name.IndexOf("Ec2HandleUserData")
$aws_xml.Ec2ConfigurationSettings.Plugins.Plugin[$index].State = "Enabled"
$aws_xml.Save($aws_config)