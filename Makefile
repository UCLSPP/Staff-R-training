RSCRIPT = Rscript
SCRIPT_FILE = ./R/build.R

all: build

build clean open publish:
	$(RSCRIPT) $(SCRIPT_FILE) $@ 

test: build open

clean-all: clean
	@find -E . -regex "^\./week[0-9]{1,2}/(index|seminar|solutions)[0-9]{0,2}\.(html|md|pdf|R)$$" -exec rm {} \;
