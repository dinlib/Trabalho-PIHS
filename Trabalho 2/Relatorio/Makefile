clear: compile
	@rm sbc-template.synctex.gz
	@rm sbc-template.log
	@rm sbc-template.blg
	@rm sbc-template.aux
	@rm sbc-template.bbl
	

compile:
	@pdflatex -synctex=1 -interaction=nonstopmode sbc-template.tex
	@pdflatex -synctex=1 -interaction=nonstopmode sbc-template.tex
	@bibtex sbc-template.aux
	@bibtex sbc-template.aux
	@pdflatex -synctex=1 -interaction=nonstopmode sbc-template.tex
	@pdflatex -synctex=1 -interaction=nonstopmode sbc-template.tex
	@clear
