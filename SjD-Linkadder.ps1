<#
.SYNOPSIS   
Add new episodes from your favorite shows automated to JDownloader 2.
    
.DESCRIPTION
- Activate "folderwatch" in JDownloader 2.
- Clone the git-repository in the "folderwatch" directory (SjD-Linkadder and its files must not be in a subfolder). 
- Define the name, quality and releasegroup of your shows/releases in the "SJ.csv" (Take a look at the examples).
- Select your preferred hoster in the "hoster.csv". Set the first number to "1" to select a hoster. Select just one hoster!
- Start "SjD-Linkadder.ps1"

.NOTES   
Name: SjD-Linkadder.ps1
Author: MoraX92
Version: 0.2
DateCreated: 2015-05-08
DateUpdated: 2015-05-15

.LINK
https://github.com/MoraX92/SjD-Linkadder
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

"#"+(Get-Date) | Out-File .\DownloadLinks.crawljob -Encoding utf8

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

    "->"+$EpisodeToFind | Out-File .\DownloadLinks.crawljob -Append utf8
    "text="+$DownloadURL | Out-File .\DownloadLinks.crawljob -Append utf8

    Write-Host -ForegroundColor Green "$DownloadURL"

}

$tempTXT = Get-Content .\DownloadLinks.crawljob
$tempTXT | Where {$_ -ne ""} | Out-File .\DownloadLinks.crawljob -Encoding utf8

Write-Host ""
Write-Host -ForegroundColor Yellow 'If there are new links and you got no errors they were added to "Downloadlinks.crawljob". The Script will exit in 5 seconds.';
Start-Sleep -s 5