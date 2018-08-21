# ItsFullOfMars

ItsFullOfMars connects to NASA's API to download photos from a given list of dates from each of the Mars rovers,
then generates an HTML file compiled with each of those files. The HTML file is rewritten each time the script is run.
Image files are also overwritten if queried twice.
## Requirements

  - Powershell v5 or later
    - _note: the script may run with earlier versions but is not verified or tested on earlier versions_
  - Windows 7 SP1, windows server 2008 or later
  - executionpolicy must be set to allow the script to run
  - write access to the specified output directory
  - storage for images on said directory
  - a correctly formatted list of dates to download images
  - an API key for accessing NASA's API. Get one here: _https://api.nasa.gov/index.html#apply-for-an-api-key_ Keep it secret. Keep it safe.


## Instructions

Download the script and run it with the following command:

ItsFullOfMars.ps1 -inputFile _[inputFileName]_ -outputDir _[outputDirectoryName]_ -**APIKey** _[assignedAPIKeyfromNASA]_

Bolded arguments **REQUIRED**

Default Values
  - _inputFile_ = "dates.txt"
  - _outputDir_ = "images"


_Note: a sample dates.txt file is included in this repository to show formatting and error handling of an invalid date_

Questions/comments/concerns? contact the author Charles Smith : trey@avari.tech
