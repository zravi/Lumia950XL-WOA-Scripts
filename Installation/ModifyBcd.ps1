. "$PSScriptRoot\Functions.ps1"

function SetupBootShimEntry() 
{
	param([string]$bcdFileName)

	$output = & bcdedit /store $($bcdFileName) /create /d ""BootShim"" /application BOOTAPP
	$guid = $output|%{$_.split(' ')[2]}

	$tmp = & bcdedit /store $bcdFileName /set $guid path \EFI\boot\BootShim.efi

	return $guid
}

Write-Host "Working..."

$mainOs = GetMainOS
$volume = $mainOs.Volume
$driveLetter = $volume.DriveLetter

$bcdFileName = "$($driveLetter):\EFIESP\EFI\Microsoft\BOOT\bcd"

Write-Host "We're going to modify the BCD file at $($bcdFileName)"
Write-Host "Press ENTER to proceed"
Read-Host

$guid = SetupBootShimEntry $bcdFileName

$bootMgrPartitionPath = GetBootMgrPartitionPath $bcdFileName

& bcdedit /store $bcdFileName /set $guid device partition=$bootMgrPartitionPath
& bcdedit /store $bcdFileName /set `{bootmgr`} displaybootmenu on
& bcdedit /store $bcdFileName /deletevalue `{bootmgr`} customactions 
& bcdedit /store $bcdFileName /deletevalue `{bootmgr`} custom:54000001 
& bcdedit /store $bcdFileName /deletevalue `{bootmgr`} custom:54000002 
& bcdedit /store $bcdFileName /displayorder $guid `{default`}
& bcdedit /store $bcdFileName /set $guid testsigning on 
& bcdedit /store $bcdFileName /set $guid nointegritychecks on