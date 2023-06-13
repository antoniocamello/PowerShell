#*---------------------------------------------------------------*
#|				Removing unwanted services						 |
#*---------------------------------------------------------------*

#https://blogs.technet.microsoft.com/secguide/2017/05/29/guidance-on-disabling-system-services-on-windows-server-2016-with-desktop-experience/
#Removed
#			"Print Spooler",
#			"Printer Extensions and Notifications",
#			"Internet Connection Sharing (ICS)", - removido por estar impedindo o RDP
$services = @(
			"ActiveX Installer (AxInstSV)",
			"AllJoyn Router Service",
			"Auto Time Zone Updater",
#			"App Readiness",
			"Bluetooth Support Service",
			"Computer Browser",
			"Contact Data",
			"dmwappushsvc",
			"Downloaded Maps Manager",
			"Geolocation Service",
			"Link-Layer Topology Discovery Mapper",
			"Microsoft Account Sign-in Assistant",
			"Microsoft App-V Client",
			"Net.Tcp Port Sharing Service",
			"Network Connection Broker",
			"Offline Files",
			"Phone Service",
			"Program Compatibility Assistant Service",
			"Quality Windows Audio Video Experience",
			"Radio Management Service",
			"Routing and Remote Access",
			"Sensor Data Service",
			"Sensor Monitoring Service",
			"Sensor Service",
			"Shell Hardware Detection",
			"Smart Card",
			"Smart Card Device Enumeration Service",
			"SSDP Discovery",
			"Still Image Acquisition Events",
			"Touch Keyboard and Handwriting Panel Service",
			"Telephony",
			"UPnP Device Host",
			"WalletService",
			"Windows Camera Frame Server",
			"Windows Image Acquisition (WIA)",
			"Windows Insider Service",
			"Windows Mobile Hotspot Service",
			"Windows Push Notifications System Service",
			"Xbox Live Auth Manager", 
			"Xbox Live Game Save"
			);
			
foreach($service in $services){
	
    Write-Output "Disabling service: $service"
	$serviceProp = Get-Service | Where-Object { $_.DisplayName -eq $service }
	$serviceExists = -not([string]::IsNullOrEmpty($serviceName))
	If ($serviceExists) {
		$serviceIsNotStopped = -not($serviceProp.Status -eq "Stopped")
			if ($serviceIsNotStopped) {
				Stop-Service -Name $serviceProp.Name -Force
			}
		
        #A opção "Remove-Service" existe apenas no PowerShell 6.0 ou posterior. Windows PowerShell 5.1 is already installed by default in all versions, starting with Win10 and W2k16.
		#Remove-Service -Name $serviceName
		#cmd /c "sc delete $serviceName"
        Set-Service -Name $serviceProp.Name -Status stopped -StartupType disable
        
		# Write-Output "Service removed"
	}
}

#Removing tasks of Xbox Live Game
$ScheduledTasks = @(
	"XblGameSaveTask",
	"XblGameSaveTaskLogon"
)

foreach ($ScheduledTask in $ScheduledTasks) {
	$ScheduledTaskExists = ((Get-ScheduledTask | Where-Object { $_.TaskName -eq "XblGameSaveTask" }).Count -eq 1)
	if ($ScheduledTaskExists) {
		Unregister-ScheduledTask -TaskName $ScheduledTask -Confirm:$False
	}
}
