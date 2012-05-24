WWWDIR = ~/Sites/matija.pretnar.info/latex
WWWFILES = izpit.zip vzorec.pdf vzorec-arhiv.pdf

ZIPFILE = izpit.zip
ZIPFILES = izpit.cls vzorec.tex vzorec-win.tex

default: $(WWWFILES)
	cp $(WWWFILES) $(WWWDIR)

$(ZIPFILE): $(ZIPFILES)
	zip $(ZIPFILE) $(ZIPFILES)

%.pdf: %.tex
	pdflatex $<

vzorec-win.tex: vzorec.tex
	echo "\\documentclass[sumniki]{izpit}" > vzorec-win.tex
	sed 1d vzorec.tex | iconv -f utf8 -t cp1250 >> vzorec-win.tex

vzorec-arhiv.tex: vzorec.tex
	echo "\\documentclass[arhiv]{izpit}" > vzorec-arhiv.tex
	sed 1d vzorec.tex >> vzorec-arhiv.tex

clean:
	rm -rf *.aux *.log *.pdf *.fdb_latexmk vzorec-* *.zip

.PHONY: default version clean
