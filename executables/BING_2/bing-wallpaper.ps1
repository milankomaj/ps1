#(v0.0.2)
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
   [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
   private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
   public static void SetWallpaper(string path) {
      SystemParametersInfo( 0x14, 0, path, 3 );
   }
}
"@
[xml]$Config = Get-Content SettingsBw.xml
$market = $Config.Configuration.market
$resolution = $Config.Configuration.resolution

$folderpath = $Config.Configuration.folderpath
$metadata = $Config.Configuration.metadata
$foldername = $Config.Configuration.foldername
$debug = $Config.Configuration.debug

Add-Type -Assembly System.Web | Out-Null
$BW = New-Object Net.WebClient
$BW.Encoding = [Text.Encoding]::UTF8
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$notification = New-Object System.Windows.Forms.NotifyIcon 
$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid | Select-Object -ExpandProperty Path))
if ($notification.Visible = $Config.Configuration.notification -match 'true') {
$notification.Visible = $Config.Configuration.notification} 

try
{
$json = ConvertFrom-Json ($BW.DownloadString("https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$market"))
$url = "https://www.bing.com{0}_$resolution.jpg" -f $json.images.urlbase
$copyright = ($json.images.copyright)
$urlbase = ($json.images.urlbase)
$startdate = ($json.images.startdate)
$shortname = ($urlbase -match '/th\?id=OHR.(.*)$') | Foreach {$Matches[1].split('_')[0]}
$title = ($json.images.title)
$author = ($copyright.Split([IO.Path]::GetInvalidFileNameChars()) -join '_').split("()")[1]
$description = ($copyright.Split([IO.Path]::GetInvalidFileNameChars()) -join ' ').split('()')[0]
$outpath = [Environment]::GetFolderPath($folderpath) + "\" + $foldername
# $ImageFileName = "$($outpath)\$($shortname)_$($startdate)_$($resolution)($($author)).jpg"
$ImageFileName = "./executables/BING_2/latest.jpg" # github
$TestPath = ((Test-Path -ErrorAction SilentlyContinue "$ImageFileName") -And (Get-ChildItem -ErrorAction SilentlyContinue "$ImageFileName"))

if ($debug -match 'true') {
$request = [System.Net.WebRequest]::create($url)
$response = $request.getResponse()
$HTTP_Status = [int]$response.StatusCode.value__    
Write-Host HTTP_Status:($HTTP_Status)
Write-Host TestPath:($TestPath)
Write-Host market:($market)
Write-Host url:($url)
Write-Host copyright:($copyright)
Write-Host urlbase:($urlbase)
Write-Host startdate:($startdate)
Write-Host shortname:($shortname)
Write-Host author:($author)
Write-Host ImageFileName:($ImageFileName) 
Write-Host description:($description)  
Write-Host title:($title)
}

if ($TestPath -match 'false') 
{   
$BW.DownloadFile($url,$ImageFileName)
# [Wallpaper]::SetWallpaper($ImageFileName)

if ($metadata -match 'true') {
Add-Type -Path .\XperiCode.JpegMetadata.dll
$adapter = `New-Object XperiCode.JpegMetadata.JpegMetadataAdapter(${ImageFileName})` 
$adapter.Metadata.Title = ${copyright};
$adapter.Metadata.Subject = ${author};
$adapter.Metadata.Rating = $Config.Configuration.rating;
$adapter.Metadata.Keywords.Add(${shortname});
$adapter.Metadata.Comments = ${url};
$adapter.Save() = "SilentlyContinue"
}

} 
else {}
if ($notification.Visible -match 'true') {
$notification.BalloonTipIcon = "Info"
$notification.BalloonTipText = $copyright
$notification.BalloonTipTitle = if ($TestPath -match 'false') {"Wallpaper was downloaded and changed."} else {"Wallpaper already exist."}
$notification.ShowBalloonTip(30000)
[void][System.Threading.Thread]::Sleep(30000)
$notification.Dispose() }

}
catch
{
$ErrorMessageFull = $_.Exception.Message
$ErrorMessage = $_.Exception.Message.split(':')[2].split([IO.Path]::GetInvalidFileNameChars()) -join ''
if ($debug -match 'true') {
Write-Output "Failed! $ErrorMessage"
Write-Output "Failed! $ErrorMessageFull"
}
if ($notification.Visible -match 'true') {
$notification.BalloonTipIcon = "Error"
$notification.BalloonTipText = $ErrorMessageFull
$notification.BalloonTipTitle = $ErrorMessage
$notification.ShowBalloonTip(30000)
[void][System.Threading.Thread]::Sleep(30000)
$notification.Dispose() }
exit 1
}




