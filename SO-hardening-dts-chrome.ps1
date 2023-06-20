#*---------------------------------------------------------------*
#|							Sources  	 						 |
#*---------------------------------------------------------------*
#CIS Microsoft Windows Server 2016 RTM (Release 1607) Benchmark v1.3.0 - https://learn.cisecurity.org/l/799323/2021-07-16/6xdlc
#https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.LanmanWorkstation::Pol_EnableInsecureGuestLogons
#https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/user-rights-assignment
#https://medium.com/blue-team/preventing-mimikatz-attacks-ed283e7ebdd5 - Preventing Mimikatz Attacks
#https://support.microsoft.com/pt-br/help/243330/well-known-security-identifiers-in-windows-operating-systems

if (test-path -literalpath "C:\outsourcing\totvs\cloud\datasul\instance\custom_data.json") {
  $CUSTOM_OBJECT = Get-Content -Path "C:\outsourcing\totvs\cloud\datasul\instance\custom_data.json" | ConvertFrom-Json
}
elseif (test-path -literalpath "C:\tcloud\config\custom-data.json") {
  $CUSTOM_OBJECT = Get-Content -Path "C:\tcloud\config\custom-data.json" | ConvertFrom-Json
}

$ipcore = $custom_data.topology.instances | 
Where-Object { $_.service_type -match "core_instance" } | 
Select-Object -ExpandProperty private_ip

<#
    Google Chrome CIS 2.0.0
    Level 1 (L1) -Corporate/Enterprise Environment (general use)
    obe the starting baseline for most organizations;obe practical and prudent;oprovide a clear security benefit; andonot inhibit the utility of the technology beyond acceptable means

    Level 2 (L2) -High Security/Sensitive Data Environment (limited functionality)
    are intended for environments or use cases where security is more critical than manageability and usability
    may negatively inhibit the utility or performance of the technology; and
    limit the ability of remote management/access.

    Note: Implementation of Level 2 requires that both Level 1 and Level 2 settings are applied.

    To block address bar and tabs, it need to execute as: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --app=http://google.com   
#>


# Enforced Defaults
#1.1.1 (L1) Ensure 'Enable curtaining of remote access hosts' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v RemoteAccessHostRequireCurtain /t REG_DWORD /d 0 /f

#1.1.3 (L1) Ensure 'Allow remote users to interact with elevated windows in remote assistance sessions' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v RemoteAccessHostAllowUiAccessForRemoteAssistance /t REG_DWORD /d 0 /f

#1.2 (L1) Ensure 'Continue running background apps when Google Chrome is closed' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f

#1.4 (L1) Ensure 'Disable saving browser history' is set to 'Disabled' (Scored) - Browser history shall be saved as it may contain indicators of compromise.
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v SavingBrowserHistoryDisabled /t REG_DWORD /d 0 /f

#1.9 (L1) Ensure 'Extend Flash content setting to all content' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v RunAllFlashInAllowMode /t REG_DWORD /d 0 /f


#2 Attack Surface Reduction
#2.1 (L1) Ensure 'Default Flash Setting' is set to 'Enabled' (Click to Play) (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v DefaultPluginsSetting /t REG_DWORD /d 3 /f

#2.8 (L1) Ensure 'Enable saving passwords to the password manager' is Configured (Not Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v PasswordManagerEnabled /t REG_DWORD /d 0 /f

#2.11 (L1) Ensure 'Allow running plugins that are outdated' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v AllowOutdatedPlugins /t REG_DWORD /d 0 /f

#2.13 (L1) Ensure 'Enable Site Isolation for every site' is set to 'Enabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v SitePerProcess /t REG_DWORD /d 1 /f

#2.14 (L1) Ensure 'Allow download restrictions' is set to 'Enabled' with 'Block dangerous downloads' specified. (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v DownloadRestrictions /t REG_DWORD /d 1 /f


#Privacidade
#3.1 (L2) Ensure 'Default cookies setting' is set to 'Enabled' (Keep cookies for the duration of the session) (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v DefaultCookiesSetting /t REG_DWORD /d 1 /f

#3.2 (L1) Ensure 'Default geolocation setting' is set to 'Enabled' with 'Do not allow any site to track the users' physical location' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v DefaultGeolocationSetting /t REG_DWORD /d 2 /f

#3.3 (L1) Ensure 'Enable Google Cast' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v EnableMediaRouter /t REG_DWORD /d 0 /f

#3.7 (L1) Ensure 'Browser sign in settings' is set to 'Enabled' with 'Disabled browser sign-in' specified (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v BrowserSignin /t REG_DWORD /d 0 /f

#3.8 (L1) Ensure 'Enable Translate' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v TranslateEnabled /t REG_DWORD /d 0 /f

#3.9 (L1) Ensure 'Enable network prediction' is set to 'Enabled' with 'Do not predict actions on any network connection' selected (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v NetworkPredictionOptions /t REG_DWORD /d 2 /f

#3.10 (L1) Ensure 'Enablesearch suggestions' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v SearchSuggestEnabled /t REG_DWORD /d 0 /f

#3.13 (L1) Ensure 'Disable synchronization of data with Google' is set to 'Enabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v SyncDisabled /t REG_DWORD /d 1 /f

#3.16 (L1) Ensure 'Enable deleting browser and download history' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v AllowDeletingBrowserHistory /t REG_DWORD /d 0 /f

#4 Management/visibility/performance
#4.1.1 (L1) Ensure 'Enable firewall traversal from remote access host' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v RemoteAccessHostFirewallTraversal /t REG_DWORD /d 0 /f

#5 Data Loss Prevention
#5.2 (L1) Ensure 'Import saved passwords from default browser on first run' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v ImportSavedPasswords /t REG_DWORD /d 0 /f

#5.3 (L1) Ensure 'Enable AutoFill for credit cards' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v AutofillCreditCardEnabled /t REG_DWORD /d 0 /f

#5.4 (L1) Ensure 'Enable AutoFill for addresses' is set to 'Disabled' (Scored)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v AutofillAddressEnabled /t REG_DWORD /d 0 /f


# CUSTOM VALUES

#Cognito Force
#    0 = Incognito mode available
#    1 = Incognito mode disabled
#    2 = Incognito mode forced
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome" /v IncognitoModeAvailability /t REG_DWORD /d 0 /f

#Default cookies setting
#    1 = Allow all sites to set local data
#    2 = Do not allow any site to set local data
#    4 = Keep cookies for the duration of the session
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome" /v DefaultCookiesSetting /t REG_DWORD /d 4 /f

#URLAllowlist	Allow access to a list of URLs
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 1 /t REG_SZ /d "localhost" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 2 /t REG_SZ /d "localhost:*" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 3 /t REG_SZ /d "127.0.0.1" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 4 /t REG_SZ /d "127.0.0.1:*" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 5 /t REG_SZ /d "totvs.com.br" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 6 /t REG_SZ /d ".totvs.com.br" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 7 /t REG_SZ /d "cloudtotvs.com.br" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 8 /t REG_SZ /d ".cloudtotvs.com.br" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 9 /t REG_SZ /d "totvs.com" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 10 /t REG_SZ /d ".totvs.com" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 11 /t REG_SZ /d "totvslauncherdi://*" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 12 /t REG_SZ /d "totvslauncherdi:*" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist" /v 13 /t REG_SZ /d $ipcore /f

#URLBlocklist	Block access to a list of URLs
#No primeiro acesso abre com a barra da navegação bloqueada, mas ao abrir uma segunda aba vem com a barra de navegação liberada, com isso ainda consegue acessar os diretórios da máquina.
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLBlocklist" /v 1 /t REG_SZ /d "file://*" /f
#REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLBlocklist" /v 2 /t REG_SZ /d "*" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLBlocklist" /v 2 /t REG_SZ /d "file:///C:/" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLBlocklist" /v 3 /t REG_SZ /d "file:///D:/" /f

#UserFeedbackAllowed	Permitir feedback do usuário
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome" /v UserFeedbackAllowed /t REG_DWORD /d 0 /f

#DeveloperToolsAvailability Control where Developer Tools can be used (default 0)
#    0 = Disallow usage of the Developer Tools on extensions installed by enterprise policy, allow usage of the Developer Tools in other contexts
#    1 = Allow usage of the Developer Tools
#    2 = Disallow usage of the Developer Tools
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome" /v DeveloperToolsAvailability /t REG_DWORD /d 2 /f

#Open TOTVS Execute DI
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome" /v AutoLaunchProtocolsFromOrigins /t REG_SZ /d '[{\"allowed_origins\": [\"*\"],\"protocol\":\"totvslauncherdi\"}]' /f
