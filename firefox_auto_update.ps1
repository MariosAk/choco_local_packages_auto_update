$FFLatest = ( Invoke-WebRequest  "https://product-details.mozilla.org/1.0/firefox_versions.json" -UseBasicParsing| ConvertFrom-Json ).LATEST_FIREFOX_VERSION
$temp = choco list firefox --all | Select-String -Pattern 'firefox *'
$FFRepo = $temp -replace "[^0-9.]", ''
 

$repoVersion = $temp -replace "[^0-9]", ''
$latestVersion = $FFLatest -replace "[^0-9]", ''

if([int]$latestVersion -gt [int]$repoVersion){
	write-host "Update Available from ($FFRepo) to $FFLatest"
}
else{
	write-host "No available update"
}

$line = Get-Content firefox.nuspec  | Select-String "<version>" | Select-Object -ExpandProperty Line
$content = Get-Content firefox.nuspec

$contentps1 = Get-Content -Path "./tools/chocolateyinstall.ps1"
#$contentps1[12] = "`$fileLocation= Join-Path `$toolsDir `'Firefox Setup $FFLatest.msi`'"

New-Item "C:/repository/Firefox/$FFLatest" -itemType Directory
Copy-Item -Path "C:/repository/Firefox/$FFRepo/*" -Destination "C:/repository/Firefox/$FFLatest/" -Recurse
cd "C:/repository/Firefox/$FFLatest"
Set-Content -Path "./tools/chocolateyinstall.ps1" -Value $contentps1
$content | ForEach-Object {$_ -replace $line,"<version>$FFLatest</version>"} | Set-Content firefox.nuspec
Remove-Item "firefox.$FFRepo.nupkg"

$url = "https://download-origin.cdn.mozilla.net/pub/firefox/releases/$FFLatest/win64/en-US/Firefox%20Setup%20$FFLatest.msi"
$fileName = "Firefox Setup $FFLatest.msi"
Invoke-WebRequest -Uri $url -OutFile "./tools/$fileName"

cd tools
Remove-Item "Firefox Setup $FFRepo.msi"

cd ..
choco pack
choco push --source "http://localhost/chocolatey" -k="chocolateyrocks" --force