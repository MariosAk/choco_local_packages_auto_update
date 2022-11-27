$omahaproxy = ( Invoke-WebRequest  "https://omahaproxy.appspot.com/all.json" -UseBasicParsing| ConvertFrom-Json )
$chromeLatest = $omahaproxy[0].versions[4].version
$temp = choco list chrome --all | Select-String -Pattern 'chrome *'

if($temp.Count -gt 1)
{
	$index = $temp.Count-1
	$temp = $temp[$index]
}

$chromeRepo = $temp -replace "[^0-9\.]",''

$repoVersion = $temp -replace "[^0-9]", ''
$latestVersion = $chromeLatest -replace "[^0-9]", ''

if([long]$latestVersion -gt [long]$repoVersion){
	write-host "Update Available from ($chromeRepo) to $chromeLatest"
}
else{
	write-host "No available update"
}

$line = Get-Content chrome.nuspec  | Select-String "<version>" | Select-Object -ExpandProperty Line
$content = Get-Content chrome.nuspec

$contentps1 = Get-Content -Path "./tools/chocolateyinstall.ps1"
New-Item "C:/repository/Chrome/$chromeLatest" -itemType Directory
Copy-Item -Path "C:/repository/Chrome/$chromeRepo/*" -Destination "C:/repository/Chrome/$chromeLatest/" -Recurse
cd "C:/repository/Chrome/$chromeLatest"
Set-Content -Path "./tools/chocolateyinstall.ps1" -Value $contentps1
$content | ForEach-Object {$_ -replace $line,"<version>$chromeLatest</version>"} | Set-Content chrome.nuspec
Remove-Item "chrome.$chromeRepo.nupkg"

$url = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$fileName = "Chrome Setup $chromeLatest.exe"
Invoke-WebRequest -Uri $url -OutFile "./tools/$fileName"

cd tools
Remove-Item "Chrome Setup $chromeRepo.exe"

cd ..
choco pack
choco push --source "http://localhost/chocolatey" -k="chocolateyrocks" --force