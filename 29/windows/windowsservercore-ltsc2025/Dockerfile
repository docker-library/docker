#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:ltsc2025

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0}\Docker\bin;{1}' -f $env:ProgramFiles, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

ENV DOCKER_VERSION 29.10.1
ENV DOCKER_URL https://download.docker.com/win/static/stable/x86_64/docker-cli_29.10.1.zip
ENV DOCKER_SHA256 0a9434db59f31b58853e9620c54f11488fcec8d2527d223a9d8dbb2273c74c44

RUN Write-Host ('Downloading {0} ...' -f $env:DOCKER_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_URL -OutFile 'docker.zip'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:DOCKER_SHA256); \
	if ((Get-FileHash docker.zip -Algorithm sha256).Hash -ne $env:DOCKER_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive docker.zip -DestinationPath ('{0}\Docker' -f $env:ProgramFiles); \
# (this archive has "bin/docker.exe" in it, hence the "bin" directory we added to PATH above -- the "cli-plugins" directory below goes right next to it, which is where the CLI looks for plugins)
	\
	Write-Host 'Removing ...'; \
	Remove-Item 'docker.zip' -Force; \
	\
	Write-Host 'Verifying install ("docker --version") ...'; \
	docker --version; \
	\
	Write-Host 'Complete.';

# https://github.com/docker-library/docker/issues/409#issuecomment-1462868414
ENV DOCKER_BUILDX_VERSION 0.39.1
ENV DOCKER_BUILDX_URL https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.windows-amd64.exe
ENV DOCKER_BUILDX_SHA256 4a665d2c71f6f87a42313cb8847b8e834e2dfb1626a1b57fcdbaacf41a6c8387
RUN $dir = ('{0}\Docker\cli-plugins' -f $env:ProgramFiles); \
	Write-Host ('Creating {0} ...' -f $dir); \
	New-Item -ItemType Directory $dir -Force; \
	\
	$plugin = ('{0}\docker-buildx.exe' -f $dir); \
	Write-Host ('Downloading {0} ...' -f $env:DOCKER_BUILDX_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_BUILDX_URL -OutFile $plugin; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:DOCKER_BUILDX_SHA256); \
	if ((Get-FileHash $plugin -Algorithm sha256).Hash -ne $env:DOCKER_BUILDX_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Verifying install ("docker buildx version") ...'; \
	docker buildx version; \
	\
	Write-Host 'Complete.';
ENV DOCKER_COMPOSE_VERSION 5.8.0
ENV DOCKER_COMPOSE_URL https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-windows-x86_64.exe
ENV DOCKER_COMPOSE_SHA256 0c2d9245a5f61e8e3cc85009b8b4888fa82fded08239d28bd6da5ca818eda2b2
RUN $dir = ('{0}\Docker\cli-plugins' -f $env:ProgramFiles); \
	Write-Host ('Creating {0} ...' -f $dir); \
	New-Item -ItemType Directory $dir -Force; \
	\
	$plugin = ('{0}\docker-compose.exe' -f $dir); \
	Write-Host ('Downloading {0} ...' -f $env:DOCKER_COMPOSE_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_COMPOSE_URL -OutFile $plugin; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:DOCKER_COMPOSE_SHA256); \
	if ((Get-FileHash $plugin -Algorithm sha256).Hash -ne $env:DOCKER_COMPOSE_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Verifying install ("docker compose version") ...'; \
	docker compose version; \
	\
	$link = ('{0}\Docker\bin\docker-compose.exe' -f $env:ProgramFiles); \
	Write-Host ('Linking {0} to {1} ...' -f $plugin, $link); \
	New-Item -ItemType SymbolicLink -Path $link -Target $plugin; \
	\
	Write-Host 'Verifying install ("docker-compose --version") ...'; \
	docker-compose --version; \
	\
	Write-Host 'Complete.';
