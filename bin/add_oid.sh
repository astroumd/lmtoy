#! /bin/bash
#
#


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage:  $0 OID dir1 dir2 ..."
    echo "Renames diorectories dir1 to dir1__OID"
    echo ""
    exit 0
fi

oid=$1
echo oid=$oid
shift

for d in $*; do
    if [ ! -d $d ]; then
	echo "$d : no directory with that name"
    else
	echo renaming $d to ${d}__${oid}
    fi
done

