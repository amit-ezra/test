echo off
set sm_installation=%ProgramFiles(x86)%\Genesys\Software\utopy\product\bin\release
set config_file=%sm_installation%\Uplatform.exe.Config
set conf_file=%sm_installation%\Uplatform.conf
set config_string=server=[SERVER];uid=[USER];pwd=[PASSWORD];database=[DB]
set conf_string=server=[DB_Server];uid=[User];pwd=[Password];database=[DB]

:: read connection string from file

set /P connectionString=<c:\connectionString.txt

:: save DB Credentials and information from env variables to config files
Powershell.exe -Command "(Get-Content '%config_file%').Replace('%config_string%','%connectionString%') | Set-Content '%config_file%'"

:: Rename config file so that IIS will encrypt it

Ren "%config_file%" web.Config

:: Encrypt using IIS
set iss="%systemroot%\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe"
set params=-pef "connectionStrings" "%sm_installation%" -prov RsaProtectedConfigurationProvider
%iss% %params%

:: Rename config file back to original name
Ren "%sm_installation%\web.Config" Uplatform.exe.Config

::TODO encrypt conf file ***** maybe embed into AMI

:: Run SQL Script
sqlcmd -S %ENV_DBSERVER% -U %ENV_DBUSERNAME% -P %ENV_DBPASSWORD% -d %ENV_DBNAME% -i c:\StartUpScript.sql

:: TODO Register shutdown scripts using c:\shutdownPs.ps1