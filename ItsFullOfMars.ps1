﻿#ItsFullOfMars.ps1 - Charles Smith - charlesrsmith@ymail.com
#parameters

 param ( 
 [string]$inputFile = "dates.txt",
 [string]$outputDir = "images",
 [string]$APIKey = $null
 )
 $htmlOutFile = ".\images\PhotoList.html" #you can edit, but in general should be the same file. 

#fixme Unit/Integration Testing/performance testing? 
#fixme docker ? 


#initializing necessary stuff
function Initialize(){ #we validate that directories exist and that filenames are accessable. Will error if can't make the directory. Also checks powershell version and alerts for compatability 
    try{
        if($PSVersionTable.PSVersion.Major -lt 5){write-output "You have an older version of powershell than version 5.0 and may experience issues. Script will continue, but continue upgrading"}        
        if($inputFile.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1){HandleError "FILE NAME $inputFile IS NOT VALID, EXITING" $TRUE} #try/catch won't catch these errors so had to handle them this way for the names
        if($outputDir.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1){HandleError "FILE NAME $inputFile IS NOT VALID, EXITING" $TRUE} #-1 is value if filename is valid
        if($APIKey -eq ""){HandleError "API KEY REQUIRED, exiting " $true}
        if((Test-Path $inputFile) -ne $True){HandleError "$inputFile doesn't exist, exiting" $TRUE}
        if((Test-Path $outputDir) -ne $True){mkdir $outputDir}
        if((Test-Path $htmlOutFile) -eq $True){Remove-Item -Path $htmlOutFile}
        New-Item -Path $htmlOutFile #this should be sufficient to check for write access
    }catch{HandleError "problem with file initialization, check permissions for creating images folder and read/write access under said folder. exiting" $TRUE }
}

function GetDates(){
    $fileContent = get-content $inputFile
    $dateStr = @() #initialize it as a collection not as a single string. 
    foreach ($line in $fileContent){        
       try{$date = [datetime]$line}catch{HandleError "$line is not an acceptable date. Please reformat or check your date, continuing" $false;continue} #skips the bad dates. If only we all could. Make sure to continue or it'll add the previous one 2x
         $dateStr += "$($date.Year)-$($date.Month)-$($date.Day)" #format of year-month-day. A happy little string for the API 
    }
    return $dateStr
}

function GetRoverList(){
    try{$roverQuery = Invoke-RestMethod -uri "https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=$($APIKey)"}
    catch [Exception]{HandleError "$($_.Exception.Message) exiting" $TRUE}
    $roverNames = $roverQuery.rovers | select name
    return $roverNames
}

function GetPhotos($roverName,$dateList){ #$roverName is a string, $dates is collection of strings formatted as [int]$year-[int]$month-[int]$day 
    foreach($individualDateStr in $dateList){ # for each date, 
        try{
            
            $photoQuery = Invoke-RestMethod -uri "https://api.nasa.gov/mars-photos/api/v1/rovers/$($roverName.name)/photos?earth_date=$($individualDateStr)&api_key=$($APIKey)"
            $sources = $photoQuery.photos | select img_src #has a few properties including the image source
            foreach ($source in $sources){               
                write-output $source.img_src
                add-content -path $htmlOutFile -Value "<img src=$($source.img_src)>"
                #download the file to the directory, trimming off the filename from the end
                $fileName = "$($roverName.name).$($individualDateStr).$($source.img_src.split("/")[-1])" #here we generate a unique file name using the rover name, date, and original name of the file. 
                #It tokenizes that URL, accessing -1 array obj is the last object which should be all after the last '/', which will be our file name
                #if we need to split it later, we can just split with the dots for easy parsing
                try{Invoke-WebRequest -uri "$($source.img_src)" -OutFile "$($outputDir)\$($fileName)" }
                catch [Exception]{HandleError "$($_.Exception.Message) continuing" $false}
                }     
        }
        catch [Exception]{
            HandleError "$($_.Exception.Message) continuing" $false; #if can't connect for 1 date, continue. 
        }
    }
}

function HandleError($errorInfo,$boolExit){
    Write-error($errorInfo) #here we could integrate with slack, log to event log, send an email etc. 
    if($boolExit -eq $TRUE){exit} 
}

Initialize
$dates = GetDates
$headers = Invoke-WebRequest -uri "https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=$($APIKey)"
$requestsRemaining = $headers.Headers.'X-RateLimit-Remaining'
Write-Output "You've got $requestsRemaining API requests remaining. If this script runs to completion, you are expected to use $($dates.count * 3 + 2) requests. NASA API requests reset hourly" 
$rovers = GetRoverList #list of names of rovers available
foreach($rover in $rovers){
    GetPhotos $rover $dates
}

try{Start-Process $htmlOutFile} #opens up html file in default browser. Last step
catch{HandleError "I'm afraid we can't start the browser " $false}
#Lho58WQQCuheR3UcNMR7SupuBtveprwzEZK2L3fT


#https://api.nasa.gov/planetary/apod?api_key=Lho58WQQCuheR3UcNMR7SupuBtveprwzEZK2L3fT

#https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=Lho58WQQCuheR3UcNMR7SupuBtveprwzEZK2L3fT