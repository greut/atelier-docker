pages=workshop.html

all: $(pages)

%.html: %.md header.html
	pandoc -s -i \
		--mathjax \
		-H header.html \
		-f markdown \
		-t revealjs \
		--variable revealjs-url=. \
		--variable theme=night \
		--variable history=true \
		--variable showNotes=false \
		--variable controls=false \
		--variable slideServer=true \
		-o $@ $^
	cp $@ reveal.js/index.html
	cp -r images reveal.js

%.pdf: %.md
	pandoc --latex-engine=xelatex \
		-f markdown \
		-t latex \
		-o $@ \
		$^

clean:
	rm -r $(pages) *.pdf

server:
	node reveal.js/plugin/notes-server

.PHONY: clean
