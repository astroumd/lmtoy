#
#



DATA_DIRS = IRC_data M31_data M51_data

all:   $(DATA_DIRS)
	/usr/bin/time ./irc_reduce.sh
	/usr/bin/time ./m31_reduce.sh obsnum=85776
	/usr/bin/time ./m31_reduce.sh obsnum=85778
	/usr/bin/time ./m31_reduce.sh obsnum=85824
	/usr/bin/time ./m51_reduce.sh
