<#
.SYNOPSIS   
Get Downloadlink from new episodes of your shows automaticly to a Textfile.
    
.DESCRIPTION 
In the same directory as the script you must have the "SJ.csv". You can use the default one from GitHub and configure it.
Also you need the hoster.csv

.NOTES   
Name: Get-SJNewDownloads.ps1
Author: MoraX92
Version: 0.1
DateCreated: 2015-05-08
DateUpdated: 2015-05-08

.LINK
https://github.com/MoraX92/SJ-Linkadder
#>

[xml]$AllNewEpisodesXML = Invoke-WebRequest http://serienjunkies.org/xml/feeds/episoden.xml
$MyShowsCSV = Import-Csv .\SJ.csv -Delimiter ","
$AllreadyFetchedEpisodesCSV = Import-Csv .\allreadyFetched.csv -Delimiter ","
$HosterCSV = Import-Csv .\hoster.csv -Delimiter ","

$NewEpisodes = @()
$AllreadyFetchedEpisodes = @()
$DownloadURLArray = @()
$EpisodesToDownload = @()
$EpisodePartOfURLAsARRAY = @()

foreach ($Part in $HosterCSV){
if($Part.bol -eq "1") {$hoster = $Part.hostertag}
}

foreach ($Show in $MyShowsCSV){
$NewEpisodes += $AllNewEpisodesXML.rss.channel.item | Where {$_.title -like $Show.name+$Show.quality+$Show.group }
}

$EpisodesToDownload = Compare-Object -referenceObject $NewEpisodes -differenceObject $AllreadyFetchedEpisodesCSV -Property title, link | Where {$_.SideIndicator -eq "<="}
$EpisodesToDownload | Export-Csv .\allreadyFetched.csv -Delimiter "," -Append

foreach ($Episode in $EpisodesToDownload){
$ShowUrlAsARRAY = @()

$ShowURL = Invoke-WebRequest $Episode.link
$ShowUrlAsSTRING = $ShowURL.Content | Out-String
$ShowUrlAsARRAY = $ShowUrlAsSTRING -split "</p>"
$EpisodeToFind = $Episode.title.Remove(0,10)
$EpisodePartOfURL = $ShowUrlAsARRAY | Select-String -Pattern $EpisodeToFind
$EpisodePartOfURLAsARRAY = $EpisodePartOfURL -split '"'
$DownloadURL = $EpisodePartOfURLAsARRAY | Select-String -Pattern $hoster
$DownloadURLArray += $DownloadURL
Write-Host "$DownloadURL"

}

$DownloadURLArray | Where {$_ -ne ""} | Out-File .\DownloadLinks.txt -Append
$tempTXT = Get-Content .\DownloadLinks.txt
$tempTXT | Where {$_ -ne ""} | Out-File .\DownloadLinks.txt

Write-Host -NoNewLine 'Here are your Links. They were added to "Downloadlinks.txt. Press any key to exit.';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');