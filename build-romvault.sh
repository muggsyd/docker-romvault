#/bin/sh
#Build script
URL="https://www.romvault.com"
LINK=$(curl -s $URL |  grep -o '<a href="[a-z]\+[^>"]*' | sed -ne 's/^<a href="\(.*\)/\1/p' | grep ROMVault_V -m1) 
ROMVAULT_VERSION=$(echo $LINK | grep -Eo '[0-9]+\.[0-9]+\.[0-9]')
docker build . -t romvault:$ROMVAULT_VERSION  -t romvault:latest --build-arg ROMVAULT_VERSION=$ROMVAULT_VERSION --build-arg UID=1028 --no-cache
