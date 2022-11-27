$TBLatest = ( Invoke-WebRequest  "https://product-details.mozilla.org/1.0/thunderbird_versions.json" -UseBasicParsing| ConvertFrom-Json ).LATEST_THUNDERBIRD_VERSION
$temp = choco list thunderbird --all | Select-String -Pattern 'thunderbird *'

if($temp.Count -gt 1)
{
	$index = $temp.Count-1
	$temp = $temp[$index]
}

$TBRepo = $temp -replace "[^0-9\.]",''

$repoVersion = $temp -replace "[^0-9]", ''
$latestVersion = $TBLatest -replace "[^0-9]", ''

if([int]$latestVersion -gt [int]$repoVersion){
	write-host "Update Available from ($TBRepo) to $TBLatest"
}
else{
	write-host "No available update"
}

$line = Get-Content thunderbird.nuspec  | Select-String "<version>" | Select-Object -ExpandProperty Line
$content = Get-Content thunderbird.nuspec

$contentps1 = Get-Content -Path "./tools/chocolateyinstall.ps1"
New-Item "C:/repository/Thunderbird/$TBLatest" -itemType Directory
Copy-Item -Path "C:/repository/Thunderbird/$TBRepo/*" -Destination "C:/repository/Thunderbird/$TBLatest/" -Recurse
cd "C:/repository/Thunderbird/$TBLatest"
Set-Content -Path "./tools/chocolateyinstall.ps1" -Value $contentps1
$content | ForEach-Object {$_ -replace $line,"<version>$TBLatest</version>"} | Set-Content thunderbird.nuspec
Remove-Item "thunderbird.$TBRepo.nupkg"

$url = "https://download.mozilla.org/?product=thunderbird-$TBLatest-SSL&os=win&lang=el"
$fileName = "Thunderbird Setup $TBLatest.exe"
Invoke-WebRequest -Uri $url -OutFile "./tools/$fileName"

cd tools
Remove-Item "Thunderbird Setup $TBRepo.exe"

cd ..
choco pack
choco push --source "http://localhost/chocolatey" -k="chocolateyrocks" --force
