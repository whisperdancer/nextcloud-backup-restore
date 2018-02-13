#!/bin/sh

#
# Bash script for restoring backups of Nextcloud.
# Usage: ./ncrestore.sh -a '<borg archive to restore>' -d '<database dump file>'
# 

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/path-to-your-repo

# Setting this, so you won't be asked for your repository passphrase:
#export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'
# or this to ask an external program to supply the passphrase:
#export BORG_PASSCOMMAND='pass show backup'

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
        errorecho "ERROR: This script has to be run as root!"
        exit 1
fi

#
# get the archive and database arguments
#
while getopts a:d: option
do
 case "${option}"
 in
 a) borg_archive=${OPTARG};;
 d) fileNameBackupDb=${OPTARG};;
 esac
done

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
exit 1
fi

if [ -z "${borg_archive}" ]
  then
    echo "No borg archive supplied"
exit 1
fi

if [ -z "${fileNameBackupDb}" ]
  then
    echo "No database file supplied"
exit 1
fi

# Variables
# nextcloudFileDir = the folder of your nextcloud installation. This must match the path in the ncbackup.sh script
nextcloudFileDir="/var/www/nextcloud"
nextcloudDataDir="/var/nc_data"
# dbdumpdir = the temp folder for db dumps. *** This must match the path used in ncbackup.sh ***
dbdumpdir="/home/pi/dbdump"
dbUser="nextcloud"
dbPassword="nextcloud"
nextcloudDatabase="nextcloud"
webserverUser="www-data"
webserverServiceName="apache2"

# show variables
echo "borg archive is	 " $borg_archive
echo "db file is	 " $fileNameBackupDb

#
# Set maintenance mode
#
echo "Set maintenance mode for Nextcloud..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:mode --on
cd ~
echo "Done"
echo

#
# Stop web server
#
echo "Stopping web server..."
service "${webserverServiceName}" stop
echo "Done"
echo

#
# change to the root dir. This is critical as borg extract uses relative dir so we must change to the root for the 
# extract to restore the files properly
#
echo "Changing to the root directory..."
cd /
echo "pwd is $(pwd)"
echo "db backup file location is " "${dbdumpdir}/${fileNameBackupDb}"

if [ $? -eq 0 ]; then
    echo "Done"
else
    echo "failed to change to root dir. Restore failed"
exit 1
fi

echo
echo "Deleting old Nextcloud data directory..."
rm -r "${nextcloudDataDir}"
mkdir -p "${nextcloudDataDir}"
echo "Done"
echo

#
# Restore the files from borg archive
# 
echo "Restoring Borg Archive" $borg_archive
borg extract -v --list ::"${borg_archive}"

#
# Restore database
#
echo
echo "Dropping old Nextcloud DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "DROP DATABASE ${nextcloudDatabase}"
echo "Done"
echo

echo "Creating new DB for Nextcloud..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "CREATE DATABASE ${nextcloudDatabase}"
echo "Done"
echo

echo "Restoring backup DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" "${nextcloudDatabase}" < "${dbdumpdir}/${fileNameBackupDb}"
echo "Done"
echo

#
# Start web server
#
echo "Starting web server..."
service "${webserverServiceName}" start
echo "Done"
echo

#
# Set directory permissions
#
echo "Setting directory permissions..."
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudFileDir}"
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudDataDir}"
echo "Done"
echo

#
# Update the system data-fingerprint (see https://docs.nextcloud.com/server/12/admin_manual/configuration_server/occ_command.html#maintenance-commands-label)
#
echo "Updating the system data-fingerprint..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:data-fingerprint
cd ~
echo "Done"
echo

#
# Disable maintenance mode
#
echo "Switching off maintenance mode..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:mode --off
cd ~
#echo "Done"
#echo

echo
echo "DONE!"
echo "Backup ${restore} successfully restored."
