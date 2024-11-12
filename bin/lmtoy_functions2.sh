# interactive helpers for those who need it

lmtoy_version2="12-nov-2024"

echo "LMTOY>> lmtoy_functions2 $lmtoy_version2 via $0"
echo "LMTOY>> useful aliases loaded:"
echo "   cdrun [projectID]     --  cd to where an lmtoy_PID is"


function cdrun {
    if [ -z $1 ]; then
	(cd $WORK_LMT/lmtoy_run/; ls -d lmtoy_* | sed s/lmtoy_//g | pr -4 -t)
    else
	cd $WORK_LMT/lmtoy_run/lmtoy_$1
    fi
}
