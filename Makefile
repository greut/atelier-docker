pages=workshop.html

all: $(pages)

%.html: %.md header.html
	pandoc -s -i \
		--mathjax \
		-H header.html \
		-f markdown \
		-t revealjs \
		--variable theme=night \
		--variable history=true \
		--variable showNotes=true \
		-o $@ $^

%.pdf: %.md
	pandoc --latex-engine=xelatex \
		-f markdown \
		-t latex \
		-o $@ \
		$^

clean:
	rm $(pages)

.PHONY: clean
