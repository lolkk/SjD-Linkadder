<#
.SYNOPSIS   
Get Downloadlinks from new episodes of your shows automaticly to a Textfile.
    
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


Try {
    [xml]$AllNewEpisodesXML = Invoke-WebRequest http://serienjunkies.org/xml/feeds/episoden.xml
    $MyShowsCSV = Import-Csv .\SJ.csv -Delimiter ","
    $AllreadyFetchedEpisodesCSV = Import-Csv .\allreadyFetched.csv -Delimiter ","
    $HosterCSV = Import-Csv .\hoster.csv -Delimiter ","
}
Catch {
    Write-Host -ForegroundColor Red "Check your depending files and Internet connection! The Script will exit in 5 seconds."
    Start-Sleep -s 5
    exit
}

$NewEpisodes = @()

"#"+(Get-Date) | Out-File .\DownloadLinks.crawljob -Append

foreach ($Part in $HosterCSV){
    if($Part.bol -eq "1") {$hoster = $Part.hostertag}
}

foreach ($Show in $MyShowsCSV){
    $NewEpisodes += $AllNewEpisodesXML.rss.channel.item | Where {$_.title -like "*"+$Show.name+"*"+$Show.quality+"*"+$Show.group}
}

$EpisodesToDownload = Compare-Object -referenceObject $NewEpisodes -differenceObject $AllreadyFetchedEpisodesCSV -Property title, link | Where {$_.SideIndicator -eq "<="}
$EpisodesToDownload | Export-Csv .\allreadyFetched.csv -Delimiter "," -Append

foreach ($Episode in $EpisodesToDownload){

    $ShowURL = Invoke-WebRequest $Episode.link -UseBasicParsing

    do{
        $ShowUrlAsSTRING = $ShowURL.Content | Out-String
        $ShowUrlAsARRAY = $ShowUrlAsSTRING -split "</p>"
        $EpisodeToFind = $Episode.title.Remove(0,10)
        $EpisodePartOfURL = $ShowUrlAsARRAY | Select-String -Pattern $EpisodeToFind
        $EpisodePartOfURLAsARRAY = $EpisodePartOfURL -split '"'
        $DownloadURL = $EpisodePartOfURLAsARRAY | Select-String -Pattern $hoster
    } while (!$DownloadURL)

    "->"+$EpisodeToFind | Out-File .\DownloadLinks.crawljob -Append
    "text="+$DownloadURL | Out-File .\DownloadLinks.crawljob -Append

    Write-Host -ForegroundColor Green "$DownloadURL"

}

$tempTXT = Get-Content .\DownloadLinks.crawljob
$tempTXT | Where {$_ -ne ""} | Out-File .\DownloadLinks.crawljob

Write-Host ""
Write-Host -ForegroundColor Yellow 'If there are new links and you got no errors they were added to "Downloadlinks.crawljob". The Script will exit in 5 seconds.';
Start-Sleep -s 5