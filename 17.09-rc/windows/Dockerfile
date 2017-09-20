# escape=`
FROM microsoft/windowsservercore

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV DOCKER_CHANNEL test
ENV DOCKER_VERSION 17.09.0-ce-rc1
ENV DOCKER_DOWNLOAD_URL https://download.docker.com/win/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.zip

RUN Invoke-WebRequest -Uri $env:DOCKER_DOWNLOAD_URL -OutFile 'docker.zip' ; `
    Expand-Archive -Path docker.zip -DestinationPath $Env:ProgramFiles ; `
    Remove-Item -Force docker.zip ; `
    Remove-Item -Force $Env:ProgramFiles\docker\\dockerd.exe

RUN $newPath = ('C:\Program Files\docker;{0}' -f $env:PATH) ; `
    [Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine)

ENTRYPOINT ["docker"]
