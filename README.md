# docker-romvault

Very poor attempt at building a docker image for Romvault. The user id referneces are in relation to my external volumes that are in use for my rom folder structure

It uses the excellent docker image from jlesage as the base
https://github.com/jlesage/docker-baseimage-gui 

These fles are speciifc to my environment. You will need to edit the following files with your own user id and group id

Line 5 of build-removault.sh - edit --build-arg UID=1028 to reflect your romvault user ID 
Line 9 & 18 of startapp.sh and change to your user id

use a VNC viewer application to connect to dockerhost:5900 or a web broser to access http://dockerhost:5800

I use docker compose for running my container

version: '3.3'
services:
  romvault:
    image: romvault:latest
    container_name: romvault
    volumes:
      ## Specific container volumes
    tmpfs:
      - /config/cache
    ports:
      - 5800:5800
      - 5900:5900
    environment:
      - USER_ID=1028
      - GROUP_ID=100
      - DISPLAY_WIDTH=1920
      - DISPLAY_HEIGHT=1080      
      - APP_NAME=RomVault
      - KEEP_APP_RUNNING=1
