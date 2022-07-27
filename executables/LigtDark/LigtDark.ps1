#(v0.0.4)
[Text.Encoding]::UTF8
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid | Select-Object -ExpandProperty Path))
$notification.Visible = $True

[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$speech = New-Object System.Speech.Synthesis.SpeechSynthesizer


[xml]$Config = Get-Content Settings.xml
$light = $Config.Configuration.light
$dark = $Config.Configuration.dark
$min = Get-Date $light
$max = Get-Date $dark
$now = Get-Date
$lightTheme = $Config.Configuration.lightTheme
$darkTheme = $Config.Configuration.darkTheme



if ($min.TimeOfDay -le $now.TimeOfDay -and $max.TimeOfDay -ge $now.TimeOfDay) {
if ($lightTheme -eq "false") {
}else {
Invoke-Expression .\$lightTheme
}

Set-ItemProperty -Name AppsUseLightTheme -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Force -Value 1
Set-ItemProperty -Name SystemUsesLightTheme -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Force -Value 1
$brightness = $Config.Configuration.lightbrightness
$display = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBrightnessMethods
$display.WmiSetBrightness(1, $brightness)
$speech.Speak("Light mode activated.")
	$notification.BalloonTipIcon = "Info"
	$notification.BalloonTipText = $now
	$notification.BalloonTipTitle = "🌞" + "Light Mode" +  " (🕕 " +$light + "-" +$dark + " )"
	$notification.ShowBalloonTip(20000)
	[void][System.Threading.Thread]::Sleep(20000)
	$notification.Dispose()
	exit 0
} else {
if ($darkTheme -eq "false") {
}else {
Invoke-Expression .\$darkTheme
}
Set-ItemProperty -Name AppsUseLightTheme -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Force -Value 0
Set-ItemProperty -Name SystemUsesLightTheme -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Force -Value 0
$brightness = $Config.Configuration.darkbrightness
$display = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBrightnessMethods
$display.WmiSetBrightness(1, $brightness)
$speech.Speak("Dark mode activated.")
 	$notification.BalloonTipIcon = "Info"
	$notification.BalloonTipText = $now
	$notification.BalloonTipTitle = "🌜" + "Dark Mode" +  " (🕖 " +$dark + "-" +$light + " )"
	$notification.ShowBalloonTip(20000)
	[void][System.Threading.Thread]::Sleep(20000)
	$notification.Dispose()
	exit 0
}
exit 0