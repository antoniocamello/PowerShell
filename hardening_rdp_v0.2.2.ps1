<#
	Hardening de RDP Services

	References:
	http://www.it.ltsoy.com/windows/lock-down-remote-desktop-services-server-2012/
	https://calcomsoftware.com/rds-configuration-hardening-guide/
	https://admx.help/?Category=Windows_10_2016

	VERSION: 0.1
#>

param(
	[switch] $disable,
    [switch] $all,
	[string] $username = "",
	[string] $sid = ""
)

$version = "0.2.2"


function Update-Regedit-Value{
	param($Path, $Name, $Type, $Value)
	If  ( -Not ( Test-Path "Registry::$Path")){
		New-Item -Path "Registry::$Path" -ItemType RegistryKey -Force
	}
	Set-ItemProperty -Path "Registry::$Path" -Name $Name -Type $Type -Value $Value -Force
}

function Start-a-program-on-connection {
	<#
		.DESCRIPTION
		Executar o Winthor assim que o usuario se conectar ao RDP.

		.LINK
		Opcao 1
		Configures Remote Desktop Services to run a specified program automatically upon connection.
		https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_START_PROGRAM_1
		
		Opcao 2
		https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsLogon::Run_1
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		#Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name fInheritInitialProgram -Type DWord -Value 1
		#Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name InitialProgram -Type String -Value "D:\WinThor\Prod\mod-000\PCINF000MOB.EXE"
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run" -Name 1 -Type String -Value "P:\PCINF000MOB.EXE"
	}else{
		#Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name fInheritInitialProgram -Type DWord -Value 0
		#Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name InitialProgram -Force
		Remove-ItemProperty -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run" -Name 1 -Force
	}
}

function Disable-Popup-ManageServer {
	<#
		.DESCRIPTION
		Desabilitar o pop-up do Manager Server no login do usuário
		"On Server open Task Scheduler. Navigate to Task Scheduler Library\Microsoft\Windows\Server Manager. Disable task “ServerManager” which triggers at log on of any user. Mesmo habilitado o ""Server Manager"" abre somente para contas de admins."

		.LINK
		Do not display Server Manager automatically at logon https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.ServerManager::DoNotLaunchServerManager
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Server\ServerManager" -Name DoNotOpenAtLogon -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Server\ServerManager" -Name DoNotOpenAtLogon -Type DWord -Value 0
	}
}

function Disable-AdministrativeTools {
	<#
		.DESCRIPTION
		Desabilitar o acesso ao Painel de Controle (inclusive Administrative Tools)

		This setting removes Control Panel from:
		The Start screen
		File Explorer

		This setting removes PC settings from:
		The Start screen
		Settings charm
		Account picture
		Search results

		.LINK
		Prohibit access to Control Panel and PC settings https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.ControlPanel::NoControlPanel
		https://www.maketecheasier.com/restrict-administrative-tools-access-windows/
		Hide specified Control Panel items https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.ControlPanel::DisallowCpls
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name StartMenuAdminTools -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoControlPanel -Type DWord -Value 1

		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 1 -Type String -Value "Microsoft.AdministrativeTools"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 2 -Type String -Value "Microsoft.AutoPlay"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 3 -Type String -Value "Microsoft.ActionCenter"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 4 -Type String -Value "Microsoft.ColorManagement"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 5 -Type String -Value "Microsoft.DefaultPrograms"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 6 -Type String -Value "Microsoft.DeviceManager"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 7 -Type String -Value "Microsoft.EaseOfAccessCenter"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 8 -Type String -Value "Microsoft.FolderOptions"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 9 -Type String -Value "Microsoft.iSCSIInitiator"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 10 -Type String -Value "Microsoft.NetworkAndSharingCenter"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 11 -Type String -Value "Microsoft.NotificationAreaIcons"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 12 -Type String -Value "Microsoft.PhoneAndModem"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 13 -Type String -Value "Microsoft.PowerOptions"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 14 -Type String -Value "Microsoft.ProgramsAndFeatures"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 15 -Type String -Value "Microsoft.System"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 16 -Type String -Value "Microsoft.TextToSpeech"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 17 -Type String -Value "Microsoft.UserAccounts"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 18 -Type String -Value "Microsoft.WindowsFirewall"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 19 -Type String -Value "Microsoft.WindowsUpdate"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 20 -Type String -Value "Microsoft.DateAndTime"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 21 -Type String -Value "Microsoft.RegionAndLanguage"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 22 -Type String -Value "Microsoft.RemoteAppAndDesktopConnections"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 23 -Type String -Value "Install Application On Remote Desktop Server"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 24 -Type String -Value "Java"
		# Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 25 -Type String -Value "Flash Player"
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name StartMenuAdminTools -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoControlPanel -Type DWord -Value 0

		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 1  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 2  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 3  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 4  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 5  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 6  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 7  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 8  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 9  -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 10 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 11 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 12 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 13 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 14 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 15 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 16 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 17 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 18 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 19 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 20 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 21 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 22 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 23 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 24 -Force
		# Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowCpl" -Name 25 -Force
	}
}

function Disable-TaskManager {
	<#
		.DESCRIPTION
		Desabilitar "Task Manager"

		.LINK
		Remove Task Manager https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.ControlAltDelete::DisableTaskMgr
	#>
	param([bool]$apply, [string]$regUserPath)
	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableTaskMgr -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableTaskMgr -Type DWord -Value 0
	}
}

function Disable-CLI-Commands {
	<#
		.DESCRIPTION
		Remover acesso ao PowerShell
		"
		[User Configuration\Administrative Templates\System] Don't run specified Windows applications --> Enabled

		Click in Show and add:
		* powershell.exe
		* cmd.exe"

		.LINK
		Don't run specified Windows applications https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsTools::DisallowApps
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 1 -Type String -Value "powershell.exe"
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 2 -Type String -Value "cmd.exe"
	}else{
		Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 1 -Force
		Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 2 -Force
	}
}

function Block-WindowsExplorer-Access {
	<#
		.DESCRIPTION
		Restringir/remover acesso ao Windows Explorer
		[User Configuration\Policies\Administrative Templates\Control Panel]

		.LINK
		Prevent access to drives from My Computer https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoViewOnDrive
		Hide these specified drives in My Computer https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoDrives
		Remove Search button from File Explorer https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoShellSearchButton
		Remove File menu from File Explorer https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoFileMenu
		Do not allow Folder Options to be opened from the Options button on the View tab of the ribbon https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoFolderOptions
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		# Restrict A, B, C and D drives only
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoViewOnDrive -Type DWord -Value 15
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDrives -Type DWord -Value 15
		# Restrict all drives
		#Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoViewOnDrive -Type DWord -Value 67108863
		#Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDrives -Type DWord -Value 67108863

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoShellSearchButton -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoFileMenu -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoFolderOptions -Type DWord -Value 1

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 3 -Type String -Value "explorer.exe"
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 4 -Type String -Value "%windir%\explorer.exe"
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoViewOnDrive -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDrives -Type DWord -Value 0

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoShellSearchButton -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoFileMenu -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoFolderOptions -Type DWord -Value 0

		Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 3 -Force
		Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -Name 4 -Force
	}
}

function Disable-PropertiesFile-SecutityTab {
	<#
		.DESCRIPTION
		https://www.top-password.com/blog/remove-or-restore-security-tab-in-folder-properties/
		Remover "Security tab" das propriedades dos arquivos

		.LINK
		Remove Security tab https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoSecurityTab
	#>
	param([bool]$apply, [string]$regUserPath)
	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSecurityTab  -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSecurityTab  -Type DWord -Value 0
	}
}

function Disable-DisableRegistryTools {
	<#
		.DESCRIPTION
		Desabilitar modificações em registro

		.LINK
		Prevent access to registry editing tools https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsTools::DisableRegedit
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableRegistryTools  -Type DWord -Value 2
	}else{
		Remove-ItemProperty -Path "Registry::$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableRegistryTools -Force
	}

}

function Disable-WindowsInstaller {
	<#
		.DESCRIPTION
		Não permitir que o usuário use o Windows Installer

		-- The "Never" option indicates Windows Installer is fully enabled. Users can install and upgrade software. This is the default behavior for Windows Installer on Windows 2000 Professional, Windows XP Professional and Windows Vista when the policy is not configured.
		-- The "For non-managed applications only" option permits users to install only those programs that a system administrator assigns (offers on the desktop) or publishes (adds them to Add or Remove Programs). This is the default behavior of Windows Installer on Windows Server 2003 family when the policy is not configured.
		-- The "Always" option indicates that Windows Installer is disabled.
		This policy setting affects Windows Installer only. It does not prevent users from using other methods to install and upgrade programs.

		.LINK
		Always install with elevated privileges https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.MSI::AlwaysInstallElevated_1
		Always install with elevated privileges https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.MSI::AlwaysInstallElevated_2
		http://systemmanager.ru/win2k_regestry.en/92830.htm
		Turn off Windows Installer https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.MSI::DisableMSI

	#>
	param([bool]$apply, [string]$regUserPath)

	Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -Type DWord -Value 0
	Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -Type DWord -Value 0

	if($apply){
		# always
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" -Name DisableMSI -Type DWord -Value 2
		# For non-managed applications only
		# Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" -Name DisableMSI -Type DWord -Value 1
	}else{
		# never
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" -Name DisableMSI -Type DWord -Value 0
	}
}

function Hide-Notification-InstallUpdadesAndShutdown {
	<#
		.DESCRIPTION
		Não mostrar opção "Install updates and shutdown" para o usuário

		.LINK
		Do not display ‘Install Updates and Shut Down’ options https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsUpdate::AUDontShowUasPolicy

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAUShutdownOption -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAUShutdownOption -Type DWord -Value 0
	}

}

function Hide-Notification-NonAdmin {
	<#
		.DESCRIPTION
		Desabilitar notificações de updates para usuários que não são administradores

		Note: disable by default

		.LINK
		Allow non-administrators to receive update notifications https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsUpdate::ElevateNonAdmins_Title
	#>
	param([bool]$apply)

	Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name ElevateNonAdmins -Type DWord -Value 0

}

function Limit-SessionNumber-RDP {
	<#
		.DESCRIPTION
		Permitir somente 1 sessão RDP por usuário

		.LINK
		Limit number of connections https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_MAX_CON_POLICY

	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxInstanceCount -Type DWord -Value 1
	}else{
		Remove-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxInstanceCount -Force
	}
}

function Set-Timeout-RDP-DisconnectedSessions {
	<#
		.DESCRIPTION
		Configurar tempo limite para sessões desconectadas

		Tempo: 5 minutes (300000)

		Note: If you disable or do not configure this policy setting, this policy setting is not specified at the Group Policy level. By default, Remote Desktop Services disconnected sessions are maintained for an unlimited amount of time.

		.LINK
		Set time limit for disconnected sessions https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_SESSIONS_Disconnected_Timeout_2
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Type String -Value "300000"
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Type String -Value "0"
	}

}

function Set-Timeout-RDP-InactiveSessions {
	<#
		.DESCRIPTION
		Configurar tempo limite para sessões inativas

		Tempo: 30 minutes (1800000)

		Note: If you disable or do not configure this policy setting, the time limit is not specified at the Group Policy level. By default, Remote Desktop Services allows sessions to remain active but idle for an unlimited amount of time.

		.LINK
		Set time limit for active but idle Remote Desktop Services sessions https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_SESSIONS_Idle_Limit_1
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Type DWord -Value 1800000
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Type DWord -Value 0
	}
}

function Disable-ActionCenter {
	<#
		.DESCRIPTION
		Remover o ícone do Action Center

		Note: If you disable or do not configure this policy setting, Notification and Security and Maintenance will be displayed on the taskbar.

		.LINK
		Remove Notifications and Action Center https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TaskBar2::DisableNotificationCenter
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\Explorer" -Name DisableNotificationCenter -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\Explorer" -Name DisableNotificationCenter -Type DWord -Value 0
	}

}

function Disable-Features-WindowsUpdate {
	<#
		.DESCRIPTION
		Remover acesso a todas as funcionalidades do Windows Update

		.LINK
		Remove access to use all Windows Update features https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsUpdate::RemoveWindowsUpdate
	#>
	param([bool]$apply, [string]$regUserPath)
	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" -Name DisableWindowsUpdateAccess -Type DWord -Value 0
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" -Name DisableWindowsUpdateAccess -Type DWord -Value 1
	}
}

function Disable-RunCommand {
	<#
		.DESCRIPTION
		Não permitir o acesso ao "Run" do servidor

		.LINK
		Remove Run menu from Start Menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoRun
		http://systemmanager.ru/win2k_regestry.en/58876.htm
		https://www.top-password.com/blog-Valueisable-run-command-in-windows-10/#:~:text=Once%20you%20get%20to%20the,That's%20it!

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoRun -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoRun -Type DWord -Value 0
	}
}

function Disable-MapDrivers-Client {
	<#
		.DESCRIPTION
		Não permitir mapeamento de drivers do client para o servidor

		Note: If you enable this setting, the system removes the Map Network Drive and Disconnect Network Drive commands from the toolbar and Tools menus in File Explorer and Network Locations and from menus that appear when you right-click the File Explorer or Network Locations icons.
		This setting does not prevent users from connecting to another computer by typing the name of a shared folder in the Run dialog box.

		.LINK
		Remove "Map Network Drive" and "Disconnect Network Drive" https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoNetConnectDisconnect

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoNetConnectDisconnect -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoNetConnectDisconnect -Type DWord -Value 0
	}
}

function Disable-Autoplay {
	<#
		.DESCRIPTION
		Desabilitar a opção de autoplay para mídias removíveis

		.LINK
		Turn off Autoplay https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.AutoPlay::Autorun

	#>
	param([bool]$apply)

	if($apply){
		#CD-ROM and removable media drives
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDriveTypeAutoRun -Type DWord -Value 181
	}else{
		Remove-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDriveTypeAutoRun -Force
	}
}

function Disable-Client-PrinterRedirection {
	<#
		.DESCRIPTION
		Não permitir "client printer redirection"

		Note: ao atualizar o valor pelo gpedit.msc, o efeito é aplicado na hora, mas ao alterar pelo registro, precisa reiniciar a maquina

		.LINK
		Do not allow client printer redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_PRINTER

	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCpm -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCpm -Type DWord -Value 0
	}
}

function Disable-ClibpoardRedirection {
	<#
		.DESCRIPTION
		Não permitir "clipboard redirection"

		.LINK
		Do not allow Clipboard redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_CLIPBOARD
		Do not allow Clipboard redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer-Server::TS_CLIENT_CLIPBOARD

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableClip -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableClip -Type DWord -Value 0
	}
}

function Disable-COM-Redirection {
	<#
		.DESCRIPTION
		Não permitir "COM port redirection"

		.LINK
		Do not allow COM port redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_COM
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCcm -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCcm -Type DWord -Value 0
	}
}

function Disable-Driver-Redirection {
	<#
		.DESCRIPTION
		Não permitir "drive redirection"

		.LINK
		Do not allow drive redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_DRIVE_M
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCdm -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCdm -Type DWord -Value 0
	}
}

function Disable-LPT-Redirection {
	<#
		.DESCRIPTION
		Não permitir "LPT port redirection"

		.LINK
		Do not allow LPT port redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_LPT
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableLPT -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableLPT -Type DWord -Value 0
	}
}

function Disable-PlugAndPlay-Redirection {
	<#
		.DESCRIPTION
		Não permitir "Plug and Play device redirection"

		.LINK
		Do not allow supported Plug and Play device redirection https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_PNP
	#>
	param([bool]$apply)

	if($apply){
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisablePNPRedir -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisablePNPRedir -Type DWord -Value 0
	}
}

function Disable-Buttons-RebootShutdown {
	<#
		.DESCRIPTION
		Não apresentar ao usuário opções de reboot/shutdown do servidor

		.LINK
		Remove and prevent access to the Shut Down, Restart, Sleep, and Hibernate commands https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoClose

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoClose -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoClose -Type DWord -Value 0
	}
}

function Hide-PasswordReveal{
	<#
		.DESCRIPTION
		Não mostrar a opção "password reveal" após o usuário digitar a senha para logar

		.LINK
		Do not display the password reveal button https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.CredentialsUI::DisablePasswordReveal

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		# Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CredUI" -Name DisablePasswordReveal -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\CredUI" -Name DisablePasswordReveal -Type DWord -Value 1
	}else{
		# Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CredUI" -Name DisablePasswordReveal -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows\CredUI" -Name DisablePasswordReveal -Type DWord -Value 0
	}
}

function Disable-Password-Saving{
	<#
		.DESCRIPTION
		Não mostrar a opção "password reveal" após o usuário digitar a senha para logar

		.LINK
		Do not allow passwords to be saved https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_DISABLE_PASSWORD_SAVING_1
		Do not allow passwords to be saved https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_CLIENT_DISABLE_PASSWORD_SAVING_2
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name DisablePasswordSaving -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name DisablePasswordSaving -Type DWord -Value 0
	}
}

function Disable-Right-Click{
	<#
		.DESCRIPTION
		Desabilitar o botão direito do mouse

		.LINK
		Remove File Explorer's default context menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoViewContextMenu

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoViewContextMenu -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoViewContextMenu -Type DWord -Value 0
	}
}

function Disable-Cortana-Searchbar{
	<#
		.DESCRIPTION
		Desabilitar no taskbar o search do Cortana

		.LINK
		https://social.technet.microsoft.com-Forceorums/en-US/51e07e01-41ed-41a1-b3f9-530b2f9715d7-Valueisable-or-hide-searchbox-in-taskbar-windows-10-version-2004?forum=win10itprogeneral
	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Type DWord -Value 0
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Type DWord -Value 1
	}
}

function Disable-TaskViewBar{
	<#
		.DESCRIPTION
		Desabilitar no taskbar o botão "Visão de Tarefas" / Task View

		.LINK
		https://social.technet.microsoft.com-Forceorums/en-US/51e07e01-41ed-41a1-b3f9-530b2f9715d7-Valueisable-or-hide-searchbox-in-taskbar-windows-10-version-2004?forum=win10itprogeneral

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Type DWord -Value 0
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Type DWord -Value 1
	}
}

function Disable-WinHotkeys{
	<#
		.DESCRIPTION
		Desabilitar os atalhoes de teclado do windows.

		.LINK
		https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsExplorer::NoWindowsHotKeys

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoWinKeys -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoWinKeys -Type DWord -Value 0
	}
}

function Remove-StartMenu-Shortcuts{
	<#
		.DESCRIPTION
		Remove no Menu Iniciar os atalhos padrões

		Irá remover os arquivos do usuário Default e do usuário requisitado
	#>
	param([string]$username)

	$Pathtoremove = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	#Windows Ease of Access
	$Pathtoremove = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessibility\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessibility\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
	
	$Pathtoremove = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\"
	If (Test-Path $Pathtoremove) {Remove-Item -Recurse -Force -Path $Pathtoremove}
}

function Block-Taskbar{
	<#
		.DESCRIPTION
		Restringir ações no taskbar

		.LINK
		Lock all taskbar settings https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TaskBar2::TaskbarLockAll
		Lock the Taskbar https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::LockTaskbar
		Prevent users from adding or removing toolbars https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TaskBar2::TaskbarNoAddRemoveToolbar

		Do not search communications https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoSearchCommInStartMenu
		Do not search for files https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoSearchFilesInStartMenu
		Do not search Internet https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoSearchInternetInStartMenu
		Do not search programs and Control Panel items https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoSearchProgramsInStartMenu

		Remove pinned programs from the Taskbar https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TaskBar2::TaskbarNoPinnedList
		Do not allow pinning programs to the Taskbar https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TaskBar2::NoPinningToTaskbar
		Do not keep history of recently opened documents  https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoRecentDocsHistory
		Remove access to the context menus for the taskbar https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoTrayContextMenu


	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarLockAll -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name LockTaskbar -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarNoAddRemoveToolbar -Type DWord -Value 1
		
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchCommInStartMenu -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchFilesInStartMenu -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchInternetInStartMenu -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchProgramsInStartMenu -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarNoPinnedList -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoPinningToTaskbar -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoRecentDocsHistory -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoTrayContextMenu -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarLockAll -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name LockTaskbar -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarNoAddRemoveToolbar -Type DWord -Value 0

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchCommInStartMenu -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchFilesInStartMenu -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchInternetInStartMenu -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSearchProgramsInStartMenu -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name TaskbarNoPinnedList -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoPinningToTaskbar -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoTrayContextMenu -Type DWord -Value 0
	}
}

function Block-StartMenu{
	<#
		.DESCRIPTION
		Restringir ações no Start Menu

		.LINK
		Remove All Programs list from the Start menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoMoreProgramsList
		Remove Default Programs link from the Start menu. https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoSMConfigurePrograms

		Remove pinned programs list from the Start Menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoPinnedPrograms
		Remove user's folders from the Start Menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoStartMenuSubFolders

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		#Collapse and disable setting
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuMorePrograms -Type DWord -Value 2
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSMConfigurePrograms -Type DWord -Value 1

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuPinnedList -Type DWord -Value 1
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuSubFolders -Type DWord -Value 1
	}else{
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuMorePrograms -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoSMConfigurePrograms -Type DWord -Value 0

		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuPinnedList -Type DWord -Value 0
		Update-Regedit-Value -Path "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuSubFolders -Type DWord -Value 0
	}
}

function Remove-RecycleBin{
	<#
		.DESCRIPTION
		Remove o icone da lixeira do desktop

		.LINK
		Remove File Explorer's default context menu https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsDesktop::NoRecycleBinIcon

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		#write-output "Removendo Lixeira"
		Update-Regedit-Value "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWORD -Value 1
	}else{
		#write-output "Nao remove a lixeira"
		Update-Regedit-Value "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWORD -Value 0
	}
}

function Remove-CommonGroups{
	<#
		.DESCRIPTION
		Remove do Menu Iniciar as pastas de Programas

		.LINK
		https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.StartMenu::NoCommonGroups

	#>
	param([bool]$apply, [string]$regUserPath)

	if($apply){
		Update-Regedit-Value "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCommonGroups -Type DWORD -Value 1
	}else{
		Update-Regedit-Value "$regUserPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCommonGroups -Type DWORD -Value 0
	}
}

function IE-Hardening {
		<#
		.DESCRIPTION
		Remove do Menu Iniciar as pastas de Programas

		.LINK
		

	#>
	param([bool]$apply, [string]$regUserPath)
	
	if($apply){
		Update-Regedit-Value "$regUserPath\SOFTWARE\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name AddPolicySearchProviders -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name AdvancedTab -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name Check_Associations -Type String -Value "no"
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name HomePage -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name "Start Page" -Type String -Value "www.0.com"
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name AlwaysShowMenus -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name NoNavBar -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name NoCommandBar -Type DWORD -Value 1
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpMenu -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name DisablePopupFilterLevel -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name Proxy -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name NoChangeDefaultSearchProvider -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name RestrictPopupExceptionList -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\PhishingFilter" -Name Enabled -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\TabbedBrowsing" -Name PopupsUseNewWindow -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\LinksBar" -Name Enabled -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Recovery" -Name NoReopenLastSession -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\ActiveXFiltering" -Name IsEnabled -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Activities" -Name NoActivities -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoSelectDownloadDir -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserSaveAs -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name NoBrowserSaveWebComplete -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFileNew -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFileOpen -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpItemSendFeedback -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpItemTutorial -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFavorites -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserOptions -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserContextMenu -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation" -Name MSCompatibilityMode -Type DWORD -Value 0
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation\PolicyList" -Name totvs.com.br -Type String -Value "totvs.com.br"
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation\PolicyList" -Name fluig.com -Type String -Value "fluig.com"
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Privacy" -Name ClearBrowsingHistoryOnExit -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name PrivacyTab -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name ProgramsTab -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name SecurityTab -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name AutoSearch -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" -Name DisableToolbars -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Privacy" -Name EnableInPrivateBrowsing -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" -Name DisableInPrivateBlocking -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name TextOption -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoToolbarCustomize -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoBandCustomize -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name CommandBarEnabled -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name StatusBarWeb -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbar" -Name Locked -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name ShowLeftAddressToolbar -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\IEDevTools" -Name Disabled -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name DisableToolbarUpgrader -Type DWORD -Value 1
	}else{
		Update-Regedit-Value "$regUserPath\SOFTWARE\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name AddPolicySearchProviders -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name AdvancedTab -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name Check_Associations -Type String -Value "yes"
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name HomePage -Type DWORD -Value 1
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name "Start Page" -Force
		
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name AlwaysShowMenus -Force
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name NoNavBar -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name NoCommandBar -Type DWORD -Value 0
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpMenu -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name DisablePopupFilterLevel -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name Proxy -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name NoChangeDefaultSearchProvider -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name RestrictPopupExceptionList -Type DWORD -Value 0
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\PhishingFilter" -Name Enabled -Force
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -Type DWORD -Value 0
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\TabbedBrowsing" -Name PopupsUseNewWindow -Force
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\LinksBar" -Name Enabled -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Recovery" -Name NoReopenLastSession -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\ActiveXFiltering" -Name IsEnabled -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Activities" -Name NoActivities -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoSelectDownloadDir -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserSaveAs -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" -Name NoBrowserSaveWebComplete -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFileNew -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFileOpen -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpItemSendFeedback -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoHelpItemTutorial -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoFavorites -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserOptions -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Restrictions" -Name NoBrowserContextMenu -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation" -Name MSCompatibilityMode -Type DWORD -Value 1
		
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation\PolicyList" -Name totvs.com.br -Force
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation\PolicyList" -Name fluig.com -Force
		
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Privacy" -Name ClearBrowsingHistoryOnExit -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name PrivacyTab -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name ProgramsTab -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Control Panel" -Name SecurityTab -Type DWORD -Value 0
		Remove-ItemProperty -Path "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name AutoSearch -Force
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" -Name DisableToolbars -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Privacy" -Name EnableInPrivateBrowsing -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" -Name DisableInPrivateBlocking -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name TextOption -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoToolbarCustomize -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoBandCustomize -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name CommandBarEnabled -Type DWORD -Value 1
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Main" -Name StatusBarWeb -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbar" -Name Locked -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\CommandBar" -Name ShowLeftAddressToolbar -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\IEDevTools" -Name Disabled -Type DWORD -Value 0
		Update-Regedit-Value "$regUserPath\Software\Policies\Microsoft\Internet Explorer\Toolbars\Restrictions" -Name DisableToolbarUpgrader -Type DWORD -Value 0
	}
}


function Get-SID-User{
	param($username)

	$objUser = New-Object System.Security.Principal.NTAccount($username)
	$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
	return $strSID.Value
}

function Resolve-SID-User{
	param($sid)
	$objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
	$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
	return $objUser.Value
}



function Set-Hardening-Values{
	param(
		[bool]$valueAction, 
		[string]$currentUserPath,
		[string]$username
	)

	write-Output ""
	Write-Output "Updating values in LOCAL_COMPUTER"
	write-Output ""

	Write-Output "Executing Start-a-program-on-connection"
	Start-a-program-on-connection -apply $valueAction -regUserPath $currentUserPath

	Write-Output "Executing Disable-Popup-ManageServer"
	Disable-Popup-ManageServer -apply $valueAction

	Write-Output "Executing Hide-Notification-NonAdmin"
	Hide-Notification-NonAdmin -apply $valueAction
	
	Write-Output "Executing Limit-SessionNumber-RDP"
	Limit-SessionNumber-RDP -apply $valueAction

	Write-Output "Executing Set-Timeout-DisconnectedSessions"
	Set-Timeout-RDP-DisconnectedSessions -apply $valueAction

	Write-Output "Executing Disable-Autoplay"
	Disable-Autoplay -apply $valueAction

	Write-Output "Executing Disable-COM-Redirection"
	Disable-COM-Redirection -apply $valueAction
	
    Write-Output "Disable-Driver-Redirection will not be executed"
    Disable-Driver-Redirection -apply $false

	Write-Output "Executing Disable-LPT-Redirection"
	Disable-LPT-Redirection -apply $valueAction
	
	Write-Output "Executing Disable-PlugAndPlay-Redirection"
	Disable-PlugAndPlay-Redirection -apply $valueAction	

	Write-Output "Executing Disable-Client-PrinterRedirection"
	Disable-Client-PrinterRedirection -apply $valueAction

	write-Output ""
	Write-Output "Updating values to user $username"
	write-Output ""
	
	Write-Output "Executing Disable-AdministrativeTools"
	Disable-AdministrativeTools -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-TaskManager"
	Disable-TaskManager -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-CLI-Commands"
	Disable-CLI-Commands -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Block-WindowsExplorer-Access"
	Block-WindowsExplorer-Access -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-PropertiesFile-SecutityTab"
	Disable-PropertiesFile-SecutityTab -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Disable-WindowsInstaller will not be executed"
	# Item desabilitado pois impacta na atualização de alguns pacotes via chocolatey
	#Disable-WindowsInstaller -apply $valueAction -regUserPath $currentUserPath
	Disable-WindowsInstaller -apply $false -regUserPath $currentUserPath
	
	Write-Output "Executing Hide-Notification-InstallUpdadesAndShutdown"
	Hide-Notification-InstallUpdadesAndShutdown -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Set-Timeout-RDP-InactiveSessions"
	Set-Timeout-RDP-InactiveSessions -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-ActionCenter"
	Disable-ActionCenter -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-Features-WindowsUpdate"
	Disable-Features-WindowsUpdate -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-RunCommand"
	Disable-RunCommand -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-MapDrivers-Client"
	Disable-MapDrivers-Client -apply $valueAction -regUserPath $currentUserPath
	
	#Write-Output "Executing Disable-ClibpoardRedirection"
	#Disable-ClibpoardRedirection -apply $valueAction -regUserPath $currentUserPath

	Write-Output "Executing Disable-Buttons-RebootShutdown"
	Disable-Buttons-RebootShutdown -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Hide-PasswordReveal"
	Hide-PasswordReveal -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-Password-Saving"
	Disable-Password-Saving -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-Right-Click"
	Disable-Right-Click -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-Cortana-Searchbar"
	Disable-Cortana-Searchbar -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-TaskViewBar"
	Disable-TaskViewBar -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Disable-WinHotkeys"
	Disable-WinHotkeys -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Block-Taskbar"
	Block-Taskbar -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing Block-StartMenu"
	Block-StartMenu -apply $valueAction -regUserPath $currentUserPath

	Write-Output "Executing Remove-RecycleBin"
	Remove-RecycleBin -apply $valueAction -regUserPath $currentUserPath

	Write-Output "Executing Remove-CommonGroups"
	Remove-CommonGroups -apply $valueAction -regUserPath $currentUserPath
	
	Write-Output "Executing IE-Hardening"
	IE-Hardening -apply $valueAction -regUserPath $currentUserPath
	
	if($valueAction){
		Write-Output "Executing Remove-StartMenu-Shortcuts"
		Remove-StartMenu-Shortcuts -username $username
	}

	# essa função precisa ser a última para executar
	Write-Output "Executing Block-Disable-DisableRegistryTools"
	Disable-DisableRegistryTools -apply $valueAction -regUserPath $currentUserPath
}

function Set-IAM-Values {
	# Política de senhas: especificar tamanho de senha - Sugestão: 8 caracteres
	net accounts /MINPWLEN:8

	# Política de senhas: Idade mínima da senha - Sugestão: 1 dia
	net accounts /MINPWAGE:1

	# Política de senhas: Expiração de senha - Sugestão: 45 dias
	net accounts /MAXPWAGE:45

	# Política de senhas: Complexidade de senha habilitada	
	# net accounts /a

	# Política de senhas: Senhas lembradas (Password History) - Sugestão: últimas 10 senhas	
	net accounts /UNIQUEPW:10

	# Política de senhas: lockout policy-Valueisable lockout - Sugestão: bloquear o usuário após 5 tentativas erradas. Desbloquear após 30 minutos bloqueado.
	net accounts /lockoutthreshold:5
}

function Set-Hardening-Registry{
	param(
		[bool]$valueAction, 
		[string]$currentUserPath,
		[string]$username
	)
    
    #Write-Output "Script running: $scriptname"
    Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningFile -Type String -Value $scriptname
	Update-Regedit-Value -Path "$currentUserPath\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningFile -Type String -Value $scriptname
    
	#Write-Output "Version: $version"
	Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningVersion -Type String -Value $version
    Update-Regedit-Value -Path "$currentUserPath\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningVersion -Type String -Value $version
	
	#Write-Output "Time of execution: $date"
	Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningExecutionTime -Type String -Value $date
	Update-Regedit-Value -Path "$currentUserPath\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningExecutionTime -Type String -Value $date
    
    if($valueAction){
		#Write-Output "Hardening applied"
		#Salva essa infocação do HKLM porque alguns itens do hardening afetam esse registro.
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningApplied -Type DWORD -Value 1
        Update-Regedit-Value -Path "$currentUserPath\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningApplied -Type DWORD -Value 1
	}else{
		#Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxDisconnectionTime -Type String -Value "0"
        Write-Output "Hardening not applied"
		Update-Regedit-Value -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningApplied -Type DWORD -Value 0
        Update-Regedit-Value -Path "$currentUserPath\SOFTWARE\WOW6432NODE\TOTVS\Security" -Name UserHardeningApplied -Type DWORD -Value 0
	}
}

function Apply-Hardening{
    param(
        [parameter(mandatory = $true)]
        $username
    )

#Remove os atalhos que aparecem quando clica com o botao direito sobre o Menu Iniciar 
    $Pathtoremove = "C:\Users\Default\AppData\Local\Microsoft\Windows\WinX\"
    Microsoft.PowerShell.Management\Remove-Item $Pathtoremove -Recurse -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

<#
	O modulo "user-profile" eh utilizado para criar o profile do usuario (caso ainda nao exista). Assim as demais configuracoes poderao ser aplicadas sem problemas.
#>

$checkprofile = Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $username }
if(-not $checkprofile){
    Import-Module .\user-profile.psm1 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Force
    Create-NewProfile -username $username
}


$valueAction = $true
if($disable){
	$valueAction = $false
}

$currentUserPath = "HKEY_CURRENT_USER"
$currentSID = ""
if($sid){
	$exists = Resolve-SID-User -sid $sid
	if(-not $exists){
		throw "Invalid SID value"
	}
	$currentSID = $sid
}
if($username){
	$exists = Get-SID-User -username $username
	if(-not $exists){
		throw "Username not found in this computer"
	}
	$currentSID = $exists
}
if($currentSID){
	$currentUserPath = "HKEY_USERS\$currentSID"
}


# is current user or currentSID admin?
if(((-not $sid) -and (-not $username)) -or $currentSID){
	# get the current user if variable currentSID is empty
	if(-not $currentSID){
		$currentSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
	}
	# $patternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
	$patternSIDAdministrator = 'S-1-5-21-\d+-\d+\-\d+\-500$'
	if($currentSID -match $patternSIDAdministrator){
		throw "The current user is an Administrator. This script is not allowed to set values to the Administrator user, choose other user."
	}
}


$username = (Resolve-SID-User -sid $currentSID).Split("\")[1]


$isHiveLoaded = $false
if(-not ($currentUserPath -eq "HKEY_CURRENT_USER")){
	try{
		$exists = Get-ChildItem -Path registry::$currentUserPath -ErrorAction Stop
	}catch [System.Exception]{
		$isHiveLoaded = $true
        # load hive
		$path = Resolve-Path "$env:USERPROFILE\..\$username\NTUSER.DAT"
		reg load "HKU\$currentSID" $path
	}
}


Set-Hardening-Registry -valueAction $valueAction -currentUserPath $currentUserPath -username $username
Set-Hardening-Values -valueAction $valueAction -currentUserPath $currentUserPath -username $username
# Set-IAM-Values

# if hive is loaded, unload
if($isHiveLoaded){
	# Reference: https://4sysops.com/archives/remove-hkcu-registry-keys-of-multiple-users-with-powershell/
	#			 https://stackoverflow.com/a/32000057
	[System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    $retryCount = 0
    $retryLimit = 20
    $retryTime = 1 #seconds
    [gc]::Collect()
    reg unload "HKU\$currentSID" #> $null

    while ($LASTEXITCODE -ne 0 -and $retryCount -lt $retryLimit) {
       Write-Verbose "Error unloading 'HKU\$sid', waiting and trying again." -Verbose
       Start-Sleep -Seconds $retryTime
       $retryCount++
       reg unload "HKU\$sid"
    }
}

Write-Output "Done"
}

function Apply-Hardening-All-Users{

    $tmp = [System.IO.Path]::GetTempFileName()
    
    Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
    
    secedit.exe /export /cfg "$($tmp)"
    
    $c = Get-Content -Path $tmp
    
    $currentSetting = @()
    
    foreach($s in $c) {
        if( ($s -like "SeInteractiveLogonRight*") -or ($s -like "SeRemoteInteractiveLogonRight*")) {
            $x = $s.split("= ",[System.StringSplitOptions]::RemoveEmptyEntries)
            $currentSetting += $x[1].Split(",")
        }
    }
    
    #Remove as entradas duplicadas
    $currentSetting = $currentSetting | select -Unique
    
    #Remove o grupo Administrator da lista
    $cs = $currentSetting -ne '*S-1-5-32-544'
    
    $usuarios = @()
    foreach ( $grupo in $cs ) {
        if ( $grupo -match '^\*S*' ) {
            $grupo = (Get-LocalGroup | Select-Object -Property SID,Name | Where-Object -Property SID -like $grupo | Select -expand Name)
            $usuarios += (Get-LocalGroupMember -Group $grupo | Select -expand Name) | Out-string -Stream | %{ $_.Split('\')[1]; }
    
        }elseif (Get-LocalGroup | Where-Object {$_.Name -eq "$grupo"}){
            $usuarios += (Get-LocalGroupMember -Group $grupo | Select -expand Name) | Out-string -Stream | %{ $_.Split('\')[1]; }
    
        }elseif (Get-LocalUser | Where-Object {$_.Name -eq "$grupo"} | Select -expand Name ){
            $usuarios += $grupo
        }
    }
    
    #Remove usuarios duplicados
    $usuarios = $usuarios | select -Unique
    
    foreach ($element in $usuarios) {
        write-output "Applying RDP Hardenig for user $element"
        $username = $element
        Apply-Hardening -username $username
    }
    
    Remove-Item -Path $tmp
    
    }

# ===== start script =====

$date = Get-Date -Format "dd/MMM/yyyy - HH:mm:ss K"
$scriptname = $PSCommandPath

if($all){
	#Aplica o hardening para todos os usuarios elegiveis
	Apply-Hardening-All-Users
}else{
	#chama o arquivo para aplicar o hardening, utilizando as opções -default, -username, -restoreprofile ou -disable
	Apply-Hardening -username $username
}