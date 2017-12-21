# nextcloud-backup-restore
Borg backup nextcloud backup and restore scripts

Scripts to automate backup and restore of Nextcloud 12.x 

These scripts have been tested and work very well. I've been using them in my production environment for some time with no issues. I highly enrouage the backup script be scheduled via a cron job under the root user. sudo crontab -u root -e

The script can send a system generated email with the details of the backup. For this feature, you will need to setup a MTA on your device and a mail utility to send the mail. It is an optional, but highly recommended feature. It is commented out by default.

Credit: https://github.com/DecaTec/Nextcloud-Backup-Restore

Credit: https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/restore.html

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/backup.html

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/restore.html

These scripts require the installation of borg backup to function.

First, enter your archive and change the variables to your environment before running the scripts. 
See borg prune to adjust how many archives you want to retain.

To backup:
1. copy the 2 scripts to a folder
2. Go to that folder
3. Run the backup: sudo bash ./ncbackup.sh

To restore:
1. Get the archive name: sudo borg list /path-to-archive
2. Copy the archive name you want to restore
3. List the contents of the archive to get the name of the db dump file: sudo borg list /path-to-archive::'<archive-name from step 2>' The db dump file will be the last file listed
4. Copy the db dump file name
5. Go to the folder which contains the scripts
6. Run restore: sudo bash ./ncrestore.sh -a '<archive-name-from-step 2>' -d '<db-dump-file-name-from-step 4>'
7. If the restore completes without errors, run the permissions.sh script which can be found here: https://docs.nextcloud.com/server/9/admin_manual/installation/installation_wizard.html#strong-perms-label

