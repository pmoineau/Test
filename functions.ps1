function Import-ExchangeAndAD(){
  $EXSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://BTEXHUB01/PowerShell/ -Authentication Kerberos
  $ADSession = New-PSSession -computerName DETAD03

  Invoke-Command -Session $ADSession { Import-Module activedirectory  }
  Import-PSSession $ADSession -Module ActiveDirectory
  Import-PSSession $EXSession
}
function Remove-ExchangeAndAD(){
  Remove-PSSession -ComputerName DETAD03
  Remove-PSSession -ComputerName BTEXHUB01
}
function Import-AD(){
  Write-Host "Connecting to DETAD03"
  $ADSession = New-PSSession -computerName DETAD03

  Invoke-Command -Session $ADSession { Import-Module activedirectory  }
  Import-PSSession $ADSession -Module ActiveDirectory
}
function Remove-AD(){
  Write-Host "Disconnecting from DETAD03"
  Remove-PSSession -ComputerName DETAD03
}


function Get_BTComputer($staffID)
{
    $astStaffID = "*" + $staffID + "*"
    $computers = Get-ADComputer -filter {name -like $astStaffID}
    foreach ($computer in $computers)
    {
        $report = @()
        $report = '' | select ComputerName, ADLocation, Online

        $isOnline = Test-Connection -ComputerName $computer.name -Quiet -Count 1

        $report.ComputerName = $computer.Name
        $report.ADlocation = $computer.DistinguishedName
        $report.OnLine = $isOnline
        $report
        <#
        Write-Host "Computer name: " -NoNewline
        if($isOnline){
            Write-Host $computer.name -ForegroundColor Green
        }
        Else{
            Write-Host $computer.name -ForegroundColor Red

        }
        Write-Host "AD Location:" $computer.DistinguishedName
        Write-Host "Computer online:" $isOnline
        Write-Host
        #>
    }
}

function win10userXfer($username, $newComputer){

    $source = "C:\Users\" + $username + "\"

    $documents = "Documents"
    $downloads = "Downloads"
    $favorites = "Favorites"
    $music = "Music"
    $pictures = "Pictures"
    $videos = "Videos"

    $sourceDocuments = $source + $documents
    $sourceDownloads = $source + $downloads
    $sourceFavorites = $source + $favorites
    $sourceMusic = $source + $music
    $sourcePictures = $source + $pictures
    $sourceVideos = $source + $videos

    $destination = "\\" + $newComputer + "\C$\Users\" + "$username" + "\"

    $destinationDocuments = $destination + $documents
    $destinationDownloads = $destination + $downloads
    $destinationFavorites = $destination + $favorites
    $destinationMusic = $destination + $music
    $destinationPictures = $destination + $pictures
    $destinationVideos = $destination + $videos


    Robocopy.exe $sourceDocuments $destinationDocuments /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:documents.log
    Robocopy.exe $sourceDownloads $destinationDownloads /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:downloads.log
    Robocopy.exe $sourceFavorites $destinationFavorites /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:favorites.log
    Robocopy.exe $sourceMusic $destinationMusic /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:music.log
    Robocopy.exe $sourcePictures $destinationPictures /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:pictures.log
    Robocopy.exe $sourceVideos $destinationVideos /COPY:DATSO /MIR /Z /XD DONOTMOVE /R:3 /W:3 /Log:videos.log


}

function goonline(){
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
}

function gooffline(){
    Remove-PSSession $Session

}

function gs($staffid){
    Write-Host
    $dump = get-aduser $staffid -Properties *
    $dump.name
    $dump.physicalDeliveryOfficeName
    $dump.Office
    $dump.OfficePhone
    $dump.EmailAddress
    Write-Host
}
