#!/bin/bash
/bin/rm -rf /tmp/checkdv
url="https://dp.lmtgtm.org/api/access/datafiles/765"
file="project: 2014ARSRCommissioning obsnum: 32992 datatype: SRDP"
users="mpound@umd.edu teuben@umd.edu souccar@umass.edu zhiyuanma@umass.edu"
wget --quiet --tries=3 -O /tmp/checkdv $url
exit_code=$?
#exit_code=255
if [ $exit_code -ne 0 ]; then
   /bin/mailx -r "Dataverse Watcher <mpound@umd.edu>" \
              -s "LMT Dataverse download check failed" \
              $users << EOT

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
