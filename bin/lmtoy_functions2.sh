# interactive helpers for those who need it

lmtoy_version2="10-nov-2024"

echo "LMTOY>> lmtoy_functions2 $lmtoy_version2 via $0"
echo "LMTOY>> useful aliases loaded:"
echo "   lmtoy_run [projectID]"

function lmtoy_run {
    if [ -z $1 ]; then
	(cd $WORK_LMT/lmtoy_run/; ls -d lmtoy_* | sed s/lmtoy_//g | pr -4 -t)
    else
	cd $WORK_LMT/lmtoy_run/lmtoy_$1
    fi
}
