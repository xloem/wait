.SECONDARY:

LDLIBS=-lrtlsdr -lusb-1.0

log2xmp: log2xmp.o readlogfile.o
log2pcm: log2pcm.o readlogfile.o

newplot-%: genplot.sh
	./genplot.sh "$*"

%logfile.flac:%logfile.raw log2pcm
	pv < $< | ./log2pcm | flac --sign=unsigned --bps=8 --channels=2 --sample-rate=655350 --endian=little - > $@

%logfile.xmp.gz:%logfile.raw log2xmp
	pv < $< | ./log2xmp | gzip > $@

%rtl_power.png:%rtl_power.csv heatmap.py
	./heatmap.py $< $@

%flatten_range.csv:%rtl_power.csv flatten_range.py
	./flatten_range.py $< > $@

%-attenuation_range.csv:
	both="$*"; left="$${both%--*}"; right="$${both#*--}"; ./attenuation.py "$$left"-flatten_range.csv "$$right"-flatten_range.csv > "$@"

%_range.png:%_range.csv Makefile
	{ \
echo 'set terminal png size 1024,512';\
echo 'set datafile separator ","';\
echo 'plot "$<" using 1:3 with lines';\
echo 'plot "$<" using 1:4 with lines';\
echo 'plot "$<" using 1:2 with lines';\
} | gnuplot > $@

%report.html:report_template.html Makefile %flatten_range.png %rtl_power.png %logfile.xmp.gz
	attenuation_contents="$$(for attenuation in *--$*attenuation_range.png $*-*attenuation_range.png;\
do if ! [ -e "$$attenuation" ]; then continue; fi; name="$${attenuation%-attenuation_range.png}"; name="$${name##*/}"; \
  sed 's!{left}!'"$${name%--*}"'!g; s!{right}!'"$${name#*--}"'!g' < attenuation_template.html;\
done)";\
pfx="$*"; pfx=$${pfx##*/}; attenuation_contents="$$(echo $${attenuation_contents})"; \
sed 's!{pfx}!'"$$pfx"'!g; s`{attenuation_template}`'"$${attenuation_contents//\&/\\&}"'`g' < report_template.html > $@



%/index.html: %/*report.html Makefile
	{ cd $*;\
for report in *report.html;\
do echo '<p>Individual log report: <a href="'"$$report"'">'"$${report%.html}"'</a></p>';\
done;\
} > $@
