Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
public class Wallpaper {
   [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
   private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
   public static void SetWallpaper(string path) {
      SystemParametersInfo( 0x14, 0, path, 3 );
   }
}
"@

Add-Type -Assembly System.Web | Out-Null
$BW = New-Object Net.WebClient
$BW.Encoding = [Text.Encoding]::UTF8

$json = ConvertFrom-Json ($BW.DownloadString('https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1'))
$url = 'https://www.bing.com{0}_1920x1080.jpg' -f $json.images.urlbase

Write-Host ("`n {0}`n`n URL: {1}" -f $json.images.copyright, $url)

$destPath = $targetPath = Join-Path -Path ([environment]::getfolderpath('mypictures')) -ChildPath 'BingWallpaper'


$filename = "./BingWallpaper/latest.jpg"    



$BW.DownloadFile($url, $filename)
[Wallpaper]::SetWallpaper($filename)
