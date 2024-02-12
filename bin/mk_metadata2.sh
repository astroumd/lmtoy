#! /bin/bash
#
#  mk_metadata2.sh : loop over obsnums to add the metadata to a DB file
#
#

yaml=lmtmetadata.yaml


cd $WORK_LMT

db=$1
echo "# DB FILE: $db"
if [ ! -e $db ]; then
    echo "No $db file (or in $WORK_LMT)"    
    exit 0
else
    cp $db $db.bck
fi


shift
echo "# OBSNUMS: $*"

echo "cd $WORK_LMT"
for o in $*; do
    dir=$WORK_LMT/*/$o
    y=$dir/$yaml
    if [ -e $y ]; then
	echo mk_metadata.py -y /dev/null -f $db $dir
    else
	echo "# Missing obsnum=$o"
    fi
done
