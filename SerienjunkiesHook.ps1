<#
.SYNOPSIS   
Get Downloadlink from new episodes of your shows automaticly to a Textfile.
    
.DESCRIPTION 
In the same directory as the script you must have the "SJ.csv". You can use the default one from GitHub and configure it.
Also you need the hoster.csv

.NOTES   
Name: Get-SJNewDownloads.ps1
Author: Maximilian Wiedemann
Version: 0.1
DateCreated: 2015-05-08
DateUpdated: 2015-05-08

.LINK
https://github.com/MoraX92/Active-Directory-Management

.EXAMPLE   
Get-ADNews -Period 10 | ft name, whencreated, objectclass

Description:
Displays you every new Group, User and new/modified GPO in a table, that was created betweeen the last three days 


#>


[xml]$AllNewEpisodesXML = Invoke-WebRequest http://serienjunkies.org/xml/feeds/episoden.xml
$MyShowsCSV = Import-Csv .\SJ.csv -Delimiter ","
$AllreadyFetchedEpisodesCSV = Import-Csv .\allreadyFetched.csv -Delimiter ","
$HosterCSV = Import-Csv .\hoster.csv -Delimiter ","

$NewEpisodes = @()
$AllreadyFetchedEpisodes = @()

foreach ($Part in $HosterCSV){

if($Part.bol -eq "1") {$hoster = $Part.hostertag}

}





foreach ($Show in $MyShowsCSV){

$NewEpisodes += $AllNewEpisodesXML.rss.channel.item | Where {$_.title -like $Show.name+$Show.quality+$Show.group }

}


$EpisodesToDownload = Compare-Object $AllreadyFetchedEpisodesCSV $NewEpisodes -Property title, link


$AllreadyFetchedEpisodes += $EpisodesToDownload

$AllreadyFetchedEpisodes | Export-Csv .\allreadyFetched.csv -Delimiter "," -Append


foreach ($Episode in $EpisodesToDownload){

$ShowUrlAsARRAY = @()

$ShowURL = Invoke-WebRequest $Episode.link

$ShowUrlAsSTRING = $ShowURL.Content | Out-String

$ShowUrlAsARRAY = $ShowUrlAsSTRING -split "</p>"

$EpisodeToFind = $Episode.title.Remove(0,10)

$EpisodePartOfURL = $ShowUrlAsARRAY | Select-String -Pattern $EpisodeToFind

$EpisodePartOfURLAsARRAY = $EpisodePartOfURL -split '"'

$DownloadURL = $EpisodePartOfURLAsARRAY | Select-String -Pattern $hoster

Write-Host "$DownloadURL"

}
