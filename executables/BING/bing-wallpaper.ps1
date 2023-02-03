# (v8.1.2.3)

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


[xml]$Config = Get-Content -Encoding utf8 SettingsBw.xml
$market = $Config.Configuration.market
$resolution = $Config.Configuration.resolution
$connection = $Config.Configuration.connection
$folderpath = $Config.Configuration.folderpath
$metadata = $Config.Configuration.metadata
$foldername = $Config.Configuration.foldername


$Encoding = [Text.Encoding]::UTF8
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid | Select-Object -ExpandProperty Path))
if ($notification.Visible = $Config.Configuration.notification -match 'true') {
$notification.Visible = $Config.Configuration.notification}

$DownloadDirectory = $targetPath = Join-Path -Path ([environment]::getfolderpath($folderpath)) -ChildPath $foldername
$bingImageApi = "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=$($market))"
$dch = "Wallpaper was downloaded and changed."
$conect = "Non internet conection."


While (!(Test-Connection -ComputerName $connection -count 2 -Quiet -ErrorAction SilentlyContinue )) {
	$notification.BalloonTipIcon = "Error"
	$notification.BalloonTipText = "Please Turn ON."
	$notification.BalloonTipTitle = $conect
	$notification.ShowBalloonTip(20000)
	[void][System.Threading.Thread]::Sleep(20000)
	$notification.Dispose()

	exit 1
}

New-Item -ItemType directory -Force -Path $DownloadDirectory | Out-Null
$ProgressPreference = "SilentlyContinue"
[xml]$Bingxml = (Invoke-WebRequest -Uri $bingImageApi).Content
$ImageUrl = "https://www.bing.com$($Bingxml.images.image.urlBase)_$($resolution).jpg";
$copyright = "$($Bingxml.images.image.copyright)"
$startdate = "$($Bingxml.images.image.startdate)"
$urlbase = "$($Bingxml.images.image.urlbase)"
$regex = ($urlbase -match '/th\?id=OHR.(.*)$')
$shortname = $Matches[1].split('_')[0]
$author = $copyright.split('()')[1].split([IO.Path]::GetInvalidFileNameChars()) -join '_'
# $tag = ($copyright -match '\w*[A-Z]+')
$ImageFileName = "$($shortname)_$($startdate)($($author)).jpg"
$BingImageFullPath = "$($DownloadDirectory)\$($ImageFileName)"

if ((Test-Path "$BingImageFullPath") -And (Get-ChildItem "$BingImageFullPath"))
{
	$notification.BalloonTipIcon = "Info"
	$notification.BalloonTipText = $copyright
	$notification.BalloonTipTitle = "Wallpaper already exist."
	$notification.ShowBalloonTip(20000)
	[void][System.Threading.Thread]::Sleep(20000)
	$notification.Dispose()
	exit 0
}
else {
Invoke-WebRequest -UseBasicParsing -Uri $ImageUrl -OutFile "$BingImageFullPath";


if ($metadata -match 'true') {
Add-Type -Path .\XperiCode.JpegMetadata.dll
$adapter = `New-Object XperiCode.JpegMetadata.JpegMetadataAdapter(${BingImageFullPath})`
$adapter.Metadata.Title = ${copyright};
$adapter.Metadata.Subject = ${author};
$adapter.Metadata.Rating = $Config.Configuration.rating;
$adapter.Metadata.Keywords.Add(${shortname});
$adapter.Metadata.Comments = ${ImageUrl};
$adapter.Save() = "SilentlyContinue"
}

[Wallpaper]::SetWallpaper($BingImageFullPath)
	$notification.BalloonTipIcon = "Info"
	$notification.BalloonTipText = $copyright
	$notification.BalloonTipTitle = $dch
	$notification.ShowBalloonTip(30000)
	[void][System.Threading.Thread]::Sleep(30000)
	$notification.Dispose()
	exit 0

}

exit 0
