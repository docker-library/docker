# escape=`

FROM microsoft/windowsservercore as builder

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV DOCKER_CHANNEL test
ENV DOCKER_VERSION 17.09.0-ce-rc1
ENV DOCKER_DOWNLOAD_URL https://download.docker.com/win/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.zip

RUN Invoke-WebRequest -Uri $env:DOCKER_DOWNLOAD_URL -OutFile 'docker.zip'
RUN Expand-Archive -Path docker.zip -DestinationPath .

FROM microsoft/nanoserver

COPY --from=builder ["docker\\docker.exe", "C:\\Program Files\\docker\\docker.exe"]
RUN setx PATH "%PATH%;C:\Program Files\docker"

ENTRYPOINT ["docker"]
