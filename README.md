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

2. Copy the archive name you want to restore and paste to notepad

3. List the contents of the selected archive to retrieve the name of the db dump file: sudo borg list --short /path-to-repo::'<archive-name from step 2>' The db dump file will be the last file listed. When you run this command, it will display all the files contained within the archive so depending on how many files it may take a while to run. The last 2 lines are the ones of interest and will look something like this:

home/<user>/dbdump
  
home/<user>/dbdump/hostname-ncdb.sql-2017-10-11 01:00:01

You only want to copy 'hostname-ncdb.sql-2017-11-21 01:00:01' which is the name of the db dump file. The path is set in a variable in the ncresotre.sh script
(Note, I beleive there is a way to tweak the output of borg list command to only display files included in the path of the db dump file, but I haven't figured out how to do this. This would be faster as it would only list the one file name needed rather than displaying all the files in the archive. If anyone knows how to do this, please show me)

4. Copy the db dump file name to notepad

5. Go to the folder which contains the scripts. i.e. scripts/backup

6. Run restore: sudo bash ./ncrestore.sh -a '<archive-name-from-step 2>' -d '<db-dump-file-name-from-step 4>' Ensure you use single quotes around the parameter names

7. If the restore completes without errors, run the set strong permissions script which can be found here: https://docs.nextcloud.com/server/9/admin_manual/installation/installation_wizard.html#strong-perms-label

