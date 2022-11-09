@ECHO OFF

REM pass arguements into parameters
set container=%1
shift
set prog_name=%1
shift
set out=%1
shift
set outfile=%1

REM docker exec %container% bash -c "cd /mnt"
docker exec %container% bash -c "bundle exec ruby $TPP_FILE /mnt/%prog_name% -o /mnt/%outfile%"
