function Get-SJNewDownloads{

<#
.SYNOPSIS   
Get Downloadlink from new episodes of your shows automaticly to a Textfile.
    
.DESCRIPTION 
In the same directory as the script you must have the "SJ.csv". You can use the default one from GitHub and configure it.

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
$MyShowsCSV = Import-Csv D:\SJ.csv -Delimiter ","
$AllreadyFetchedEpisodesCSV = Import-Csv D:\allreadyFetched.csv -Delimiter ","


#########
$hoster = "/so_"
#########

$NewEpisodes = @()


foreach ($Show in $MyShowsCSV){

$NewEpisodes += $AllNewEpisodesXML.rss.channel.item | Where {$_.title -like $Show.name+$Show.quality+$Show.group }

}


$EpisodesToDownload = Compare-Object $AllreadyFetchedEpisodesCSV $NewEpisodes -Property title, link


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
}
