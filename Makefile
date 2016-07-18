all: workshop.html

%.html: %.md
	pandoc -s -i --mathjax -H header.html -f markdown -t revealjs -o $@ $^
