#! /bin/bash
#
#  create nice looking index.html for results of mars_continuum processing
#

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage:  $0 "
    echo ""
    echo "Expects to be in the obsnum directory , then makes a README.html file"
    exit 0
fi



echo "<A HREF=mars.log> mars.log</A>"
echo "<hr>"

for i in $(seq 0 1 31); do
    for f in mars_${i}_0.png mars_${i}_1.png; do
	if [ -e $f ]; then
	    echo "<A HREF=$f> <IMG SRC=$f> </A>"
	fi
    done
done

exit 0

