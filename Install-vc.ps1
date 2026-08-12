<#
.SYNOPSIS
   Installs the Desk Connect Client.
.DESCRIPTION
   Do not modify this script.  It was generated specifically for your account.
.EXAMPLE
   powershell.exe -f Install-DeskConnect.ps1
   powershell.exe -f Install-DeskConnect.ps1 -DeviceAlias "My Super Computer" -DeviceGroup "My Stuff"
#>

param (
	[string]$DeviceAlias,
	[string]$DeviceGroup,
	[string]$Path,
	[string]$OrganizationId,
	[string]$ServerUrl,
	[switch]$Uninstall,
	[switch]$Quiet
)

#region Set SecurityProtocol
# This will include all security protocols greater than or equal to TLS 1.2.
[System.Net.SecurityProtocolType]$SecurityProtocols = 0;
[System.Enum]::GetValues([System.Net.SecurityProtocolType]) | Where-Object {
	$_ -ge [System.Net.SecurityProtocolType]::Tls12
} | ForEach-Object {
	$SecurityProtocols = $SecurityProtocols -bor $_
}
[System.Net.ServicePointManager]::SecurityProtocol = $SecurityProtocols
#endregion

#region Set Variables
$LogPath = "$env:TEMP\DeskConnect_Install.txt"

[string]$HostName = "http://116.73.117.214:5010"
if ($ServerUrl) {
	$HostName = $ServerUrl
}

[string]$Organization = "e8f4ad87-4a4b-4da1-bcb2-1788eaeb80e8"
if ($OrganizationId) {
	$Organization = $OrganizationId
}

$ConnectionInfo = $null

if ([System.Environment]::Is64BitOperatingSystem) {
	$Platform = "x64"
}
else {
	$Platform = "x86"
}

$InstallPath = "$env:ProgramFiles\DeskConnect"
#endregion

#region Functions
function Write-Log($Message) {
	if (!$Quiet) {
		Write-Host $Message
	}
	"$((Get-Date).ToString()) - $Message" | Out-File -FilePath $LogPath -Append
}
function Do-Exit() {
	Write-Log "Exiting..."
	Start-Sleep -Seconds 3
	exit
}
function Is-Administrator() {
	$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$Principal = New-Object System.Security.Principal.WindowsPrincipal -ArgumentList $Identity
	return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Run-StartupChecks {

	if (!$HostName -or !$Organization) {
		Write-Log "Required parameters are missing.  Please try downloading the installer again."
		Do-Exit
	}

	if (!(Is-Administrator)) {
		Write-Log -Message "Install script requires elevation.  Attempting to self-elevate..."
		Start-Sleep -Seconds 3

		$Params = "-File `"$($MyInvocation.ScriptName)`"";
		if ($OrganizationId) {
			$Params += " -OrganizationId $OrganizationId"
		}
		if ($ServerUrl) {
			$Params += " -ServerUrl $ServerUrl"
		}
		if ($DeviceAlias) {
			$Params += " -DeviceAlias $DeviceAlias"
		}
		if ($DeviceGroup) {
			$Params += " -DeviceGroup $DeviceGroup"
		}
		if ($Path) {
			$Params += " -Path `"$Path`""
		}
		if ($Uninstall) {
			$Params += " -Uninstall"
		}
		if ($Quiet) {
			$Params += " -Quiet"
		}
		Start-Process -FilePath powershell.exe -ArgumentList $Params -Verb RunAs
		exit
	}
}

function Stop-DeskConnect {
	Start-Process -FilePath "cmd.exe" -ArgumentList "/c sc delete dcsvc" -Wait -WindowStyle Hidden
	Stop-Process -Name dcsvc -Force -ErrorAction SilentlyContinue
	Stop-Process -Name dcsupport -Force -ErrorAction SilentlyContinue
}

function Uninstall-DeskConnect {
	Stop-DeskConnect
	Remove-Item -Path $InstallPath -Force -Recurse -ErrorAction SilentlyContinue
	Remove-NetFirewallRule -Name "Desk Connect Desktop Unattended" -ErrorAction SilentlyContinue
}

function Install-DeskConnect {
	$HeadResponse = Invoke-WebRequest -Uri "$HostName/Content/DC-Win-$Platform.zip" -Method Head -UseBasicParsing
	$ETag = $HeadResponse.Headers["ETag"]
	if (!$Etag) {
		Write-Log "Failed to get ETag from server.  Aborting install."
	}

	if ((Test-Path -Path "$InstallPath") -and (Test-Path -Path "$InstallPath\ConnectionInfo.json")) {
		$ConnectionInfo = Get-Content -Path "$InstallPath\ConnectionInfo.json" | ConvertFrom-Json
		if ($ConnectionInfo) {
			$ConnectionInfo.Host = $HostName
			$ConnectionInfo.OrganizationID = $Organization
			$ConnectionInfo.ServerVerificationToken = ""
		}
	}
	else {
		New-Item -ItemType Directory -Path "$InstallPath" -Force
	}

	if (!$ConnectionInfo) {
		$NewDeviceId = [System.Guid]::NewGuid().ToString();
		$ConnectionInfo = @{
			DeviceID                = $NewDeviceId;
			Host                    = $HostName;
			OrganizationID          = $Organization;
			ServerVerificationToken = "";
		}
	}

	if ($HostName.EndsWith("/")) {
		$HostName = $HostName.Substring(0, $HostName.LastIndexOf("/"))
	}

	if ($Path) {
		Write-Log "Copying install files..."
		Copy-Item -Path $Path -Destination "$env:TEMP\DC-Win-$Platform.zip"

	}
	else {
		$ProgressPreference = 'SilentlyContinue'
		Write-Log "Downloading client..."
		Invoke-WebRequest -Uri "$HostName/Content/DC-Win-$Platform.zip" -OutFile "$env:TEMP\DC-Win-$Platform.zip" -UseBasicParsing
		$ProgressPreference = 'Continue'
	}

	if (!(Test-Path -Path "$env:TEMP\DC-Win-$Platform.zip")) {
		Write-Log "Client files failed to download."
		Do-Exit
	}

	Stop-DeskConnect
	Get-ChildItem -Path $InstallPath | Where-Object { $_.Name -notlike "ConnectionInfo.json" } | Remove-Item -Recurse -Force

	Expand-Archive -Path "$env:TEMP\DC-Win-$Platform.zip" -DestinationPath "$InstallPath" -Force

	New-Item -ItemType File -Path "$InstallPath\ConnectionInfo.json" -Value (ConvertTo-Json -InputObject $ConnectionInfo) -Force

	New-Item -ItemType File -Path "$InstallPath\etag.txt" -Value $ETag -Force

	if ($DeviceAlias -or $DeviceGroup) {
		$DeviceSetupOptions = @{
			DeviceAlias     = $DeviceAlias;
			DeviceGroupName = $DeviceGroup;
			OrganizationID  = $Organization;
			DeviceID        = $ConnectionInfo.DeviceID;
		}

		$Body = $DeviceSetupOptions | ConvertTo-Json
		Invoke-RestMethod -Method Post -ContentType "application/json" -Uri "$HostName/api/devices" -Body $Body
	}

	New-Service -Name "dcsvc" -BinaryPathName "`"$InstallPath\dcsvc.exe`"" -DisplayName "Desk Connect Service" -StartupType Automatic -Description "Background service that maintains a secure connection to the Desk Connect server for authorized remote support and maintenance."
	Start-Process -FilePath "cmd.exe" -ArgumentList "/c sc.exe failure `"dcsvc`" reset=5 actions=restart/5000" -Wait -WindowStyle Hidden
	Start-Service -Name dcsvc
}

#endregion

#region Main

try {
	Run-StartupChecks

	Write-Log "Install/uninstall logs are being written to `"$LogPath`""

	if ($Uninstall) {
		Write-Log "Uninstall started."
		Uninstall-DeskConnect
		Write-Log "Uninstall completed."
		exit
	}
	else {
		Write-Log "Install started."
		Install-DeskConnect
		Write-Log "Install completed."
		exit
	}
}
catch {
	Write-Log -Message "Error occurred: $($Error[0].InvocationInfo.PositionMessage)"
	throw $Error[0]
	Do-Exit
}
#endregion