# Indicates that the windowsservercore image will be used as the base image.
FROM microsoft/windowsservercore

ARG NASAKEY=local
ENV NASAKEY=${NASAKEY}
# Metadata indicating an image maintainer.
MAINTAINER Charles Smith -trey@avari.tech
# Sets a command or process that will run each time a container is run from the new image.
CMD powershell .\ItsFullOfMars.ps1 -APIkey 
#copies the code
COPY . C:\\
