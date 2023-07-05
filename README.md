# check_qnap1655_qad
These are "quick and dirty" scripts to check a QNAP 1655 via check_by_ssh. If MIBS work for you, you should rather use them instead of these scripts...  
The scripts might also work on other QNAPs as long as you can execute "/sbin/getsysinfo" as "admin" via shell.  
As of today (05.07.2023) they all work fine on a "QNAP 1655" with OS "QTS 5.0.1 (20230421)"

***Prerequisites***

- You need a user (like "monitoring") to connect via ssh, to be able to execute the checkscripts and gather infos. This user should be able to connect via ssh-key (passwordless)
  
***Usage***

The script "check_qnap1655_qad.sh" has to be executed by "admin" because it needs elevated rights.  
Log in as "admin", create the script, make it executeable (chmod 770 check_qnap1655_qad.sh) and create a cronjob (crontab -e)
```
# example to run the script every 5 minutes
*/5 * * * * /share/homes/admin/check_qnap1655_qad.sh
```

All other scripts should be placed inside the new users home (example: monitoring => /share/homes/monitoring/)  
They can then be executed via "check_by_ssh" from your monitoringserver
```
# example
# /usr/lib/nagios/plugins/check_by_ssh -H 192.168.178.123 -l monitoring -C "/share/homes/monitoring/check_infofiles.sh"
All files have been modified in the last hour.
```

Currently all scripts point to "/share/homes/monitoring/monitoring" as path for infofiles, if you want to use another user you need to edit this path which is always at the top of the script.

***ToDo***

I want to change the following things:
- add more comments
- add optional variables ( -c, -w ) via script execution for "temp warning", "temp critical", "diskspace warning", "diskspace critical", ...
- currently the scripts are not checking any PCI disks (like QM2: M.2 Expansion Cards) because "/sbin/getsysinfo" doesnt provide these infos, Iam looking for a workaround
