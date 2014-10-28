newplot-%: genplot.sh
	./genplot.sh "$*"

%logfile.gz:%logfile.raw
	gzip < $< > $@

%rtl_power.png:%rtl_power.csv heatmap.py
	./heatmap.py $< $@

%flatten_range.csv:%rtl_power.csv flatten_range.py
	./flatten_range.py $< > $@

%flatten_range.png:%flatten_range.csv Makefile
	{ \
echo 'set terminal png';\
echo 'set datafile separator comma';\
echo 'plot "-" with yerrorlines';\
cat "$<";\
echo e;\
} | gnuplot > $@

%report.html:report_template.html Makefile %flatten_range.png %rtl_power.png %logfile.gz
	pfx="$*"; pfx=$${pfx##*/};\
	sed 's!{pfx}!'"$$pfx"'!g' < report_template.html > $@

%/index.html: %/*report.html Makefile
	{ cd $*;\
for report in *report.html;\
do echo '<p>Individual log report: <a href="'"$$report"'">'"$${report%.html}"'</a></p>';\
done; } > $@
