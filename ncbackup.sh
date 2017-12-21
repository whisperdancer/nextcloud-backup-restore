#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/path-to-your-archive

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
# nextcloud vars
#
# nextcloudFileDir = the folder of your nextcloud installation
nextcloudFileDir="/var/www/nextcloud"
nextcloudDataDir="/var/nextcloud/data"
# dbdumpdir = the temp folder for db dumps
dbdumpdir="/home/pi/dbdump"
# dbdumpfilename = the name of the db dump file
dbdumpfilename=$(hostname)-nextcloud-db.sql-$(date +"%Y-%m-%d %H:%M:%S")

#
# database vars, substitute your own values here
#
dbUser="nextcloud"
dbPassword="nextcloud"
nextcloudDatabase="nextcloud"
#
# webserver vars
#
webserverUser="www-data"
webserverServiceName="apache2"

info "Starting backup"

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
# Backup DB
#
echo "Backup Nextcloud database..."
mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${nextcloudDatabase}" > "${dbdumpdir}/${dbdumpfilename}"
echo "mysql dump successful. Dump folder ${dbdumpdir}"
echo "Listing dump file..."
ls -l ${dbdumpdir}
echo "Done"
echo

# Backup the 4 mandatory nextcloud directories into an archive named after
# the machine this script is currently running on:

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    ::'{hostname}-{now}'            \
    $nextcloudFileDir/config        \
    $nextcloudFileDir/themes        \
    $nextcloudDataDir               \
    $dbdumpdir                      \
    --exclude-caches                \
    --exclude '*.log'               \
    --exclude '*.log.*'

backup_exit=$?

info "Remove the db backup file"
rm  ${dbdumpdir}/*
echo "Done"

info "Pruning repository"

# Use the `prune` subcommand to maintain 5 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    -v                              \
    --prefix '{hostname}-'          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

#
# Start web server
#
echo
echo "Starting web server..."
service "${webserverServiceName}" start
echo "Done"
echo


#
# Disable maintenance mode
#
echo "Switching off maintenance mode..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:mode --off
cd ~
echo "Done"
echo

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

#
#send email. Uncomment the below line to send an email. To send mail, setup your cron script
# like this: 55 23 * * * /root/backup.sh > /home/<user>/backup.txt 2>&1
#
# mail -s "Nextcloud Backup" youremail@yourdomain.com < /home/<user>/backup.txt

exit ${global_exit}

echo "DONE!"
