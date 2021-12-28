#(v0.0.3)
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
$timeout = $Config.Configuration.timeout
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
$shortname = ($urlbase -match '/th\?id=OHR.(.*)$') | ForEach-Object {$Matches[1].split('_')[0]}
$author = ($copyright.split([IO.Path]::GetInvalidFileNameChars()) -join (' ')).split('()')[1]
$title = ($json.images.title)
$description = ($copyright.split([IO.Path]::GetInvalidFileNameChars()) -join ' ').split('()')[0]
$tag = Select-String '\b[A-Z]\w+,*' -CaseSensitive -input $description -AllMatches | ForEach-Object {$_.matches}
$outpath = [Environment]::GetFolderPath($folderpath) + "\" + $foldername
$ImageFileName = "$($outpath)\$($shortname)_$($startdate)_$($resolution)($($author)).jpg"
$TestPath = ((Test-Path "$ImageFileName") -And (Get-ChildItem "$ImageFileName"))

if ($debug -match 'true') {
$request = [System.Net.WebRequest]::create($url)
$response = $request.getResponse()
$HTTP_Status = [int]$response.StatusCode.value__

[string]$t = $host.ui.RawUI.ForegroundColor
[string]$host.ui.RawUI.ForegroundColor = "Green"
[string]$host.ui.RawUI.ForegroundColor

 Write-Output("HTTP_Status: $HTTP_Status")
 Write-Output("TestPath:$TestPath")
 Write-Output("outpath: $outpath")
 Write-Output("metadata: $metadata")
 Write-Output("market:$market")
 Write-Output("url: $url")
 Write-Output("copyright: $copyright")
 Write-Output("urlbase: $urlbase")
 Write-Output("startdate: $startdate")
 Write-Output("shortname: $shortname")
 Write-Output("author:$author ")
 Write-Output("ImageFileName: $ImageFileName")
 Write-Output("description: $description")
 Write-Output("tag: $tag")
 Write-Output("title: $title")
 Write-Output("notification: " + [string]$Config.Configuration.notification)

[string]$host.ui.RawUI.ForegroundColor = $t
[string]$host.ui.RawUI.ForegroundColor

}else {}

if (!$TestPath)
{
$BW.DownloadFile($url,$ImageFileName)
[Wallpaper]::SetWallpaper($ImageFileName)



if ($metadata -match 'true') {
Add-Type -Path .\XperiCode.JpegMetadata.dll
$adapter = `New-Object XperiCode.JpegMetadata.JpegMetadataAdapter(${ImageFileName})` 
$adapter.Metadata.Title = ${copyright};
$adapter.Metadata.Subject = ${author};
$adapter.Metadata.Rating = $Config.Configuration.rating;
$adapter.Metadata.Keywords.Add("${tag}"+", ${shortname}");
$adapter.Metadata.Comments = ${url};
$adapter.Save() = "SilentlyContinue"
}else {}

}
else {}

$notification.BalloonTipIcon = "Info"
$notification.BalloonTipText = $copyright
$notification.BalloonTipTitle = if (!$TestPath) {"Wallpaper was downloaded and changed."} else {"Wallpaper already exist."}
$notification.ShowBalloonTip($timeout)
[void][System.Threading.Thread]::Sleep($timeout)
$notification.Dispose()
}

catch
{
#$_.Exception.Message.split(':')[2] -eq $null
$ErrorMessageFull = $_.Exception.Message
if(!($null -eq ($ErrorMessageFull.split(':')[2])) -and ! ($null -eq ($ErrorMessageFull.split(':')[1])))
{$ErrorMessage = $ErrorMessageFull.split(':')[2].split([IO.Path]::GetInvalidFileNameChars()) -join ''}
elseif(!($null -eq ($ErrorMessageFull.split(':')[2])) -and ! ($null -eq ($ErrorMessageFull.split(':')[0])))
{$ErrorMessage = $ErrorMessageFull.split(':')[1].split([IO.Path]::GetInvalidFileNameChars()) -join ''}
elseif(!($null -eq ($ErrorMessageFull.split("''")[1])))
{$ErrorMessage = $ErrorMessageFull.split("''")[1].split([IO.Path]::GetInvalidFileNameChars()) -join ''}
else{$ErrorMessage = $ErrorMessageFull.split('.')[0].split([IO.Path]::GetInvalidFileNameChars()) -join ''}


if ($debug -match 'true') {
Write-Output "Failed! $ErrorMessageFull"
Write-Output "Failed! $ErrorMessage"
}else {}

$notification.BalloonTipIcon = "Error"
$notification.BalloonTipText = $ErrorMessageFull
$notification.BalloonTipTitle = $ErrorMessage
$notification.ShowBalloonTip($timeout)
[void][System.Threading.Thread]::Sleep($timeout)
$notification.Dispose()

exit 1
}






