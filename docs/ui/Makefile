

GUI = lmtoy_01_sessions.py lmtoy_02_sources.py  lmtoy_03_obsnums.py \
	lmtoy_04_beams.py lmtoy_05_baseline.py  lmtoy_06_calibration.py \
	lmtoy_07_gridding.py lmtoy_08_output.py


all:  $(GUI)

$(GUI): %.py: %.ui
	pyuic5 -x $< -o $@
	@echo python $@
