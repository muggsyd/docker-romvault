# Pull base image.
#FROM jlesage/baseimage-gui:debian-10-v4
FROM jlesage/baseimage-gui:debian-11-v4
# environment settings
ENV PYTHONIOENCODING=utf-8
ENV APPNAME="ROMVault" UMASK_SET="022"

ARG ROMVAULT_VERSION
ARG UID

RUN apt update -y
RUN add-pkg --virtual apt-transport-https dirmngr gnupg ca-certificates curl coreutils unzip libgtk2.0-0
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt update -y
RUN apt install mono-xsp4 -y

RUN useradd -m -u $UID -g users -s /bin/bash romvault

# Get latest version of ROMVault windows binary & RVCmd linux binary
RUN FILTER='head -1' && \
    ROMVAULT_DOWNLOAD=$(curl -kLs 'https://www.romvault.com' | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        grep -i download | \
        grep -i romvault | \
        sort -r -f -u | \
        $FILTER) \
        && \
    RVCMD_DOWNLOAD=$(curl -kLs 'https://www.romvault.com' | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        grep -i download | \
        grep -i rvcmd | \
        grep -i linux | \
        sort -r -f -u | \
        $FILTER) \
        && \
    # Document Versions
    echo "romvault" $(basename --suffix=.zip $ROMVAULT_DOWNLOAD | cut -d "_" -f 2) >> /VERSIONS && \
    echo "rvcmd" $(basename --suffix=.zip $RVCMD_DOWNLOAD | cut -d "_" -f 2) >> /VERSIONS && \
    # Download RomVault
    mkdir -p /opt/romvault_downloads/ && \
    curl --output /opt/romvault_downloads/romvault.zip "https://www.romvault.com/${ROMVAULT_DOWNLOAD}" && \
    curl --output /opt/romvault_downloads/rvcmd.zip "https://www.romvault.com/${RVCMD_DOWNLOAD}" && \
    unzip /opt/romvault_downloads/romvault.zip -d /opt/romvault/ && \
    unzip /opt/romvault_downloads/rvcmd.zip -d /opt/romvault/ && \
    chown romvault /opt/romvault -R && chgrp users /opt/romvault -R && \
    chmod -R +x /opt/romvault

RUN sed-patch 's/<decor>no<\/decor>/<decor>yes<\/decor>/' /opt/base/etc/openbox/rc.xml.template
RUN sed-patch 's/<maximized>true<\/maximized>/<maximized>false<\/maximized>/' /opt/base/etc/openbox/rc.xml.template

# Copy the start script.
COPY files/graphics.zip /opt/romvault
COPY startapp.sh /startapp.sh
