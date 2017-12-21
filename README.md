# nextcloud-backup-restore
Nextcloud backup and restore scripts using BorgBackup (short: Borg) Borg is a deduplicating backup program. 

Scripts to automate backup and restore of Nextcloud 12.x 
Each individual archive will contain the nextcloud config folder, nextcloud theme folder, nextcloud data folder and the db dump. As such, an archive contains a snapshot in time and can be used to restore via the included ncrestore.sh script.

Credit: https://github.com/DecaTec/Nextcloud-Backup-Restore

Credit: https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/restore.html

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/backup.html

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/restore.html

Dependency: Install Borg Backup http://borgbackup.readthedocs.io/en/stable/quickstart.html

To use the scripts:
Before running the scripts, enter your archive location at the top of the script and change the Variables to suit your environment.
See borg prune documentation to learn how to adjust the number of archives to retain.

To backup:
1. copy the 2 scripts to a folder
2. Go to that folder
3. Run the backup: sudo bash ./ncbackup.sh

To restore:
1. List the Borg archives to retrieve the name of the archive you want to restore: sudo borg list /path-to-archive
2. Copy the archive name you want to restore and paste to notepad
3. List the contents of the archive to retrieve the name of the db dump file: sudo borg list --short /path-to-archive::'<archive-name from step 2>' The db dump file will be the last file listed
4. Copy the db dump file name to notepad
5. Go to the folder which contains the scripts
6. Run restore: sudo bash ./ncrestore.sh -a '<archive-name-from-step 2>' -d '<db-dump-file-name-from-step 4>'
7. If the restore completes without errors, run the set strong permissions script which can be found here: https://docs.nextcloud.com/server/9/admin_manual/installation/installation_wizard.html#strong-perms-label

