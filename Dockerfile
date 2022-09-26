# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.15-glibc-v3

# environment settings
ENV PYTHONIOENCODING=utf-8
ENV APPNAME="ROMVault" UMASK_SET="022"

ARG ROMVAULT_VERSION
ARG UID

RUN apk update --no-cache && apk upgrade --no-cache && \
    apk add gtk+2.0 binutils unzip curl bash fontconfig --no-cache && \
    apk add mono --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing --no-cache && \
    apk add libgdiplus --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing  --no-cache

RUN ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so && \
    ln -s /lib/libuuid.so.1 /usr/lib/libuuid.so.1 && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1
ENV LD_LIBRARY_PATH /usr/lib

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

RUN sed-patch 's/<application type="normal">/<application type="normal" title="RomVault ($ROMVAULT_VERSION) \/romvault">/' /etc/xdg/openbox/rc.xml
RUN sed-patch 's/<decor>no<\/decor>/<decor>yes<\/decor>/' /etc/xdg/openbox/rc.xml
# Copy the start script.
COPY startapp.sh /startapp.sh
