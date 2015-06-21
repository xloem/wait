.SECONDARY:

LDLIBS=-lrtlsdr -lusb-1.0
DATADIR=../web/data
FNWEBDIR=../freenet

log2xmp: log2xmp.o readlogfile.o
log2pcm: log2pcm.o readlogfile.o

newplot-%: genplot.sh
	touch $(DATADIR)/$*-report.html
	sh genplot.sh "$*"

LOGGEDSETS=$(patsubst $(DATADIR)/%-logfile.raw,%,$(wildcard $(DATADIR)/*-logfile.raw))
DATASETS=$(patsubst $(DATADIR)/%-rtl_power.csv,%,$(wildcard $(DATADIR)/*-rtl_power.csv))

show-reports:
	#$(DATASETS)

report-all: $(patsubst %,$(DATADIR)/%-report.html,$(DATASETS))
data-all: $(patsubst %,$(DATADIR)/%-logfile.flac,$(LOGGEDSETS)) $(patsubst %,$(DATADIR)/%-logfile.xmp,$(LOGGEDSETS))

freenet-prep-main: $(patsubst %,%-freenet-data,$(LOGGEDSETS)) $(patsubst %,%-freenet-putsskdir,$(DATASETS))
	mkdir -p $(FNWEBDIR)/web-main/data
	cp $(DATADIR)/index.html $(FNWEBDIR)/web-main/data/index.html
	#for ssk in $(DATASETS); do sed -ie "s!$$ssk!$$(sed -ne 's/.*Request URI: \(SSK.*\/\)/\1/p')$$ssk/!g" $(FNWEBDIR)/web-main/data/index.html; done
	for chk in $(DATASETS); do sed -ie "s!$${chk}!$$(sed -ne 's/.*URI: \(CHK.*\/\).*/\1/p')!g" $(FNWEBDIR)/web-main/data/index.html; done

%-freenet: %-freenet-data %-freenet-report

%-freenet-report: $(DATADIR)/%-report.html %-freenet-data
	mkdir -p "$(FNWEBDIR)/report-$*"
	for component in $(DATADIR)/$*-*.png $(DATADIR)/$*-*.csv; do ln -sf "$$(readlink -f "$*")" "$(FNWEBDIR)/report-$*"; done
	cp "$(DATADIR)/$*-report.html" "$(FNWEBDIR)/report-$*-report.html"
	for component in $$(cd $(DATADIR); echo $*-*.chk.putfile); do chk=$$(sed -ne 's/^URI: \(CHK.*\)/\/\1/p' $(DATADIR)/$$component); sed -ie 's/$${component%.chk.putfile}/$${chk}/g' $(FNWEBDIR)/report-$*-report.html; done

#%-freenet-data: $(DATADIR)/%-logfile.xmp.chk.putfile $(DATADIR)/%-logfile.flac.chk.putfile
%-freenet-data: $(DATADIR)/%-logfile.xmp.chk.putfile
	echo

%/index.html: report-all Makefile
	{ cd $*;\
for report in *report.html;\
do echo '<p>Individual log report: <a href="'"$$report"'">'"$${report%.html}"'</a></p>';\
done;\
} > $@

%-freenet-putsskdir: $(FNWEBDIR)/%.ssk %-freenet-report
	{ echo "PUTSSKDIR:$$(sed -ne 's/.*Insert URI: \(SSK.*\/\)/\1/p')$*#$$(readlink -f $(FNWEBDIR)/report-$*)"; echo QUIT; } | nc 127.0.0.1 2323

%-freenet-putdir: %-freenet-report %(FNWEBDIR)/%.chk.putdir

%.ssk: %/*
	{ echo MAKESSK; echo QUIT; } | nc 127.0.0.1 2323 | tee /dev/stderr | tail -n 10 > "$@" && [ -s $@ ]

%.chk.putfile: %
	{ echo PUTFILE:$$(readlink -f "$*"); echo QUIT; } | nc 127.0.0.1 2323 | tee /dev/stderr | tail -n 5 > "$@" && grep "URI: CHK" "$@"

%.chk.putdir: %/*
	{ echo PUTDIR:$$(readlink -f "$*"); echo QUIT; } | nc 127.0.0.1 2323 | tee /dev/stderr | tail -n 3 > "$@" && grep "URI: CHK" "$@"

%.csv.gz: %.csv
	gzip > "$@" < "$<"


%logfile.flac:%logfile.raw %logfile.xmp log2pcm
	pv < $< | ./log2pcm | flac --best --sign=unsigned --bps=8 --channels=2 --sample-rate=655350 --endian=little - > $@

%logfile.xmp:%logfile.raw log2xmp
	pv < $< | ./log2xmp > $@

%rtl_power.png:%rtl_power.csv heatmap.py
	python heatmap.py $< $@

%downsample_range.csv:%rtl_power.csv downsample_power.py
	python3 downsample_power.py $< > $@

%flatten_range.csv:%rtl_power.csv flatten_range.py Makefile
	python flatten_range.py $< > $@

#%flatten_range.csv:%rtl_power.csv downsample_power.py
#	python3 downsample_power.py $< > $@

%-attenuation_range.csv: Makefile attenuation.py downsample_power.py
	both="$*"; left="$${both%--*}-downsample_range.csv"; right="$${both%/*}/$${both#*--}-downsample_range.csv"; $(MAKE) "$$left" "$$right" && python attenuation.py "$$left" "$$right" > "$@"

%-attenuation_gnuplot_test: Makefile
	both="$*"; left="$${both%--*}-flatten_range.csv"; right="$${both%/*}/$${both#*--}-flatten_range.csv"; $(MAKE) "$$left" "$$right" && { \
echo 'set terminal qt size 7200,400';\
echo 'set datafile separator ","';\
echo 'set grid back';\
echo 'set xtics 50000000';\
echo 'left="'"$$left"'"';\
echo 'right="'"$$right"'"';\
echo 'plot left using 1:3 with lines lt rgb "red", left using 1:4 with lines lt rgb "red", right using 1:3 with lines lt rgb "blue", right using 1:4 with lines lt rgb "blue"';\
} | gnuplot -persist -

%_range.png:%_range.csv Makefile
	{ \
echo 'set terminal png size 1024,512';\
echo 'set datafile separator ","';\
echo 'set grid back';\
echo 'file="$<"';\
echo 'plot file using 1:3 ps 0 title "min" with points, file using 1:4 ps 0 title "max" with points, file using 1:2 lw 2 title "avg" with lines';\
} | gnuplot > $@

%report.html:report_template.html %downsample_range.png %rtl_power.png %*.png Makefile
	attenuation_contents="$$(item="$*"; itempath=$${item%/*}; item=$${item##*/}; for attenuation in $$itempath/*--$${item}attenuation_range.png $$itempath/$${item}-*attenuation_range.png;\
do if ! [ -e "$$attenuation" ]; then continue; fi; $(MAKE) "$$attenuation" 1>&2; name="$${attenuation%-attenuation_range.png}"; name="$${name##*/}"; \
  sed 's!{left}!'"$${name%--*}"'!g; s!{right}!'"$${name#*--}"'!g' < attenuation_template.html || exit 1;\
done)";\
pfx="$*"; pfx=$${pfx##*/}; attenuation_contents="$$(echo $${attenuation_contents})"; \
sed 's!{pfx}!'"$$pfx"'!g; s`{attenuation_template}`'"$${attenuation_contents//\&/\\&}"'`g' < report_template.html > $@


