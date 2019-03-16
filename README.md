# nextcloud-backup-restore
Nextcloud backup and restore scripts using BorgBackup (short: Borg) Borg is a deduplicating backup program. 

Scripts to automate backup and restore of Nextcloud 12.x 
Each individual archive will contain the nextcloud config folder, nextcloud theme folder, nextcloud data folder and the db dump. As such, an archive contains a snapshot in time and can be used to restore via the included ncrestore.sh script.

Credit: https://github.com/DecaTec/Nextcloud-Backup-Restore

Credit: https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/restore.html

Credit: https://docs.nextcloud.com/server/12/admin_manual/maintenance/backup.html

Dependency: Install Borg Backup http://borgbackup.readthedocs.io/en/stable/quickstart.html

To use the scripts:
Before running the scripts, enter your repo location at the top of the script and change the Variables to suit your environment.
See borg prune documentation to learn how to adjust the number of archives to retain.

To backup:
1. Set your repo location at the top of the script export BORG_REPO=/path-to-your-repo
2. Set the Variables to suit your environment
3. copy the 2 scripts to a folder of your choice. i.e. scripts/backup
2. Go to that folder i.e. scripts/backup
3. Run the backup: sudo bash ./ncbackup.sh

To restore:

1. List the Borg archives to retrieve the name of the archive you want to restore: sudo borg list /path-to-repo
2. Extract the database into working folder. sudo borg extract /path/to-archive::'archive name' /home/work Do a ls-l to get db name.
3. Change to scripts folder i.e. cd scripts/backup
4. Run restore: sudo bash ./ncrestore.sh -a '<archive-name-from-step 1>' -d '<db-dump-file-name-from-step 2>' Ensure you use single quotes around the parameter names

Note, I assume you will be restoring into a new nextcloud install. When you create the new nextcloud install, ensure you use the same db password as the password to the db you're restoring.

7. If the restore completes without errors, run the set strong permissions script which can be found here: https://docs.nextcloud.com/server/9/admin_manual/installation/installation_wizard.html#strong-perms-label

