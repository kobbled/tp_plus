@ECHO OFF

docker run -dit -v "%cd%:/mnt" -e FILSYS_ROOT="%cd%" --name %1 tp-plus
