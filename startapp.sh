#!/usr/bin/with-contenv bash
export HOME=/config
cd $HOME

# make a symbolic link so we can access to the whole conteiner files from the windows emulated GUI
ln -s / /config/computer
chown -v 1028:100 /config/computer

# Set up symlinks.
# We need to launch ROMVault from /config as this is where it will write its config.
for f in /opt/romvault/*; do
    ln -fs $f /config/ || true
done

# permissions
chown -R 1028:100 \
	/config

#!/bin/sh
#ln -sf /usr/local/bin/ROMVault3.exe /romvault/ROMVault35.exe
#\cp /usr/local/bin/ROMVault3.exe /romvault/ 

/usr/bin/mono --aot -O=all /config/ROMVault35.exe
/usr/bin/mono /config/ROMVault35.exe