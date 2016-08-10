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

clean:
	rm $(pages)

.PHONY: clean
