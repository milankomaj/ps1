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
$shortname = ($urlbase -match '/th\?id=OHR.(.*)$') | Foreach {$Matches[1].split('_')[0]}
$title = ($json.images.title)
$description = ($copyright.split([IO.Path]::GetInvalidFileNameChars()) -join ' ').split('()')[0]
$tag = Select-String '\b[A-Z]\w+,*' -CaseSensitive -input $description -AllMatches | Foreach {$_.matches}
$author = ($copyright.split([IO.Path]::GetInvalidFileNameChars()) -join (' ')).split('()')[1]
$outpath = [Environment]::GetFolderPath($folderpath) + "\" + $foldername
$ImageFileName = "$($outpath)\$($shortname)_$($startdate)_$($resolution)($($author)).jpg"
$TestPath = ((Test-Path -ErrorAction SilentlyContinue "$ImageFileName") -And (Get-ChildItem -ErrorAction SilentlyContinue "$ImageFileName"))

if ($debug -match 'true') {
$request = [System.Net.WebRequest]::create($url)
$response = $request.getResponse()
$HTTP_Status = [int]$response.StatusCode.value__    
Write-Host HTTP_Status:   -ForegroundColor Yellow -NoNewline; Write-Host ($HTTP_Status)  -ForegroundColor Green; 
Write-Host TestPath:      -ForegroundColor Yellow -NoNewline; Write-Host ($TestPath)     -ForegroundColor Green;
Write-Host outpath:       -ForegroundColor Yellow -NoNewline; Write-Host($outpath)       -ForegroundColor Cyan; 
Write-Host market:        -ForegroundColor Yellow -NoNewline; Write-Host($market)        -ForegroundColor Cyan; 
Write-Host url:           -ForegroundColor Yellow -NoNewline; Write-Host($url)           -ForegroundColor Blue; 
Write-Host copyright:     -ForegroundColor Yellow -NoNewline; Write-Host($copyright)     -ForegroundColor Gray;  
Write-Host urlbase:       -ForegroundColor Yellow -NoNewline; Write-Host($urlbase)       -ForegroundColor Gray; 
Write-Host startdate:     -ForegroundColor Yellow -NoNewline; Write-Host($startdate)     -ForegroundColor Gray;  
Write-Host shortname:     -ForegroundColor Yellow -NoNewline; Write-Host($shortname)     -ForegroundColor Red; 
Write-Host author:        -ForegroundColor Yellow -NoNewline; Write-Host($author)        -ForegroundColor Red; 
Write-Host ImageFileName: -ForegroundColor Yellow -NoNewline; Write-Host($ImageFileName) -ForegroundColor Cyan;  
Write-Host description:   -ForegroundColor Yellow -NoNewline; Write-Host($description)   -ForegroundColor Red;     
Write-Host tag:           -ForegroundColor Yellow -NoNewline; Write-Host($tag)           -ForegroundColor Red; 
Write-Host title:         -ForegroundColor Yellow -NoNewline; Write-Host($title)         -ForegroundColor Red; 
}

if ($TestPath -match 'false') 
{   
$BW.DownloadFile($url,$ImageFileName)
[Wallpaper]::SetWallpaper($ImageFileName)

if ($metadata -match 'true') {
Add-Type -Path .\XperiCode.JpegMetadata.dll
$adapter = `New-Object XperiCode.JpegMetadata.JpegMetadataAdapter(${ImageFileName})` 
$adapter.Metadata.Title = ${copyright};
$adapter.Metadata.Subject = ${author};
$adapter.Metadata.Rating = $Config.Configuration.rating;
$adapter.Metadata.Keywords.Add("${shortname}, ${tag}");
$adapter.Metadata.Comments = ${url};
$adapter.Save() = "SilentlyContinue"
}

} 
else {}
if ($notification.Visible -match 'true') {
$notification.BalloonTipIcon = "Info"
$notification.BalloonTipText = $copyright
$notification.BalloonTipTitle = if ($TestPath -match 'false') {"Wallpaper was downloaded and changed."} else {"Wallpaper already exist."}
$notification.ShowBalloonTip($timeout)
[void][System.Threading.Thread]::Sleep($timeout)
$notification.Dispose() }

}
catch
{
$ErrorMessageFull = $_.Exception.Message
if(!$ErrorMessageFull.split(':')[2] -eq $null) {$ErrorMessage = $ErrorMessageFull.split(':')[2].split([IO.Path]::GetInvalidFileNameChars()) -join ''} else {$ErrorMessage = $ErrorMessageFull.split(':')[1].split([IO.Path]::GetInvalidFileNameChars()) -join ''}
if ($debug -match 'true') {
Write-Output "Failed! $ErrorMessageFull"
Write-Output "Failed! $ErrorMessage"
}
if ($notification.Visible -match 'true') {
$notification.BalloonTipIcon = "Error"
$notification.BalloonTipText = $ErrorMessageFull
$notification.BalloonTipTitle = $ErrorMessage
$notification.ShowBalloonTip($timeout)
[void][System.Threading.Thread]::Sleep($timeout)
$notification.Dispose() }
exit 1
}




