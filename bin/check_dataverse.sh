#!/bin/bash
#--------------------------------------------------------------------------------------------------
# This script is meant to be run as a daily crontab to make sure that files can be fetched
# from the LMT dataverse via wget.  This was a problem earlier that files could be downloaded
# by clicking in a browser but wget or the lmstsearch web app python script would fail with
# Error 500.   The fix was to restart the http server that runs the LMT dataverse.
#
# Example crontab:
#     30 3 * * * /home/mpound/check_dataverse.sh >> /home/mpound/dataverse_check.log 2>&1
#
# At UMD, the crontab is installed as user mpound on the machine
# 'sol' with a local copy of this file (to avoid NFS issues).
#--------------------------------------------------------------------------------------------------
/bin/rm -rf /tmp/checkdv
url="https://dp.lmtgtm.org/api/access/datafiles/765" file="project:
2014ARSRCommissioning obsnum: 32992 datatype: SRDP" users="mpound@umd.edu
teuben@umd.edu souccar@umass.edu zhiyuanma@umass.edu" wget --quiet --tries=3
-O /tmp/checkdv $url exit_code=$?  #exit_code=255 if [ $exit_code -ne 0
]; then
   /bin/mailx -r "Dataverse Watcher <mpound@umd.edu>" \
              -s "LMT Dataverse download check failed" \ $users << EOT

This message is from the cronjob on sol.astro.umd.edu which checks daily that files
can be downloaded from LMT dataverse.  The command

   wget --quiet --tries=3 -O /tmp/checkdv $url

has failed with exit status $exit_code.  The file description is $file.

Note wget may fail even if http acceess through a browser succeeds. In this case, the server
should be restarted.

Please investigate and fix if necessary!

EOT
fi
/bin/rm -rf /tmp/checkdv
