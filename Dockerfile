# Indicates that the windowsservercore image will be used as the base image.
FROM microsoft/windowsservercore

# Metadata indicating an image maintainer.
#Charles Smith -trey@fehuit.com

# Creates an HTML file and adds content to this file.
RUN echo "Hello World - Dockerfile" > c:\index.html

# Sets a command or process that will run each time a container is run from the new image.
CMD [ "cmd" ]
