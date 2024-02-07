#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0}\docker;{1}' -f $env:ProgramFiles, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

ENV DOCKER_VERSION 25.0.3
ENV DOCKER_URL https://download.docker.com/win/static/stable/x86_64/docker-25.0.3.zip
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN Write-Host ('Downloading {0} ...' -f $env:DOCKER_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_URL -OutFile 'docker.zip'; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive docker.zip -DestinationPath $env:ProgramFiles; \
# (this archive has a "docker/..." directory in it already)
	\
	Write-Host 'Removing ...'; \
	Remove-Item @( \
			'docker.zip', \
			('{0}\docker\dockerd.exe' -f $env:ProgramFiles) \
		) -Force; \
	\
	Write-Host 'Verifying install ("docker --version") ...'; \
	docker --version; \
	\
	Write-Host 'Complete.';

# https://github.com/docker-library/docker/issues/409#issuecomment-1462868414
ENV DOCKER_BUILDX_VERSION 0.12.1
ENV DOCKER_BUILDX_URL https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.windows-amd64.exe
ENV DOCKER_BUILDX_SHA256 0ff0853a09960ff8f454d5db7253d5d935f5538856ea4985a276cbd1b28a96a5
RUN $dir = ('{0}\docker\cli-plugins' -f $env:ProgramFiles); \
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
ENV DOCKER_COMPOSE_VERSION 2.24.5
ENV DOCKER_COMPOSE_URL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-windows-x86_64.exe
ENV DOCKER_COMPOSE_SHA256 eb60363d21a5c85eff2d2e18a4ed94d84d5016be59471d77d520046fdd888aa9
RUN $dir = ('{0}\docker\cli-plugins' -f $env:ProgramFiles); \
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
	$link = ('{0}\docker\docker-compose.exe' -f $env:ProgramFiles); \
	Write-Host ('Linking {0} to {1} ...' -f $plugin, $link); \
	New-Item -ItemType SymbolicLink -Path $link -Target $plugin; \
	\
	Write-Host 'Verifying install ("docker-compose --version") ...'; \
	docker-compose --version; \
	\
	Write-Host 'Complete.';
