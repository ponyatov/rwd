
CWD     = $(CURDIR)
MODULE  = $(notdir $(CWD))
OS     ?= $(shell uname -s)

NOW = $(shell date +%d%m%y)
REL = $(shell git rev-parse --short=4 HEAD)

.PHONY: install update

MERGE   = Makefile README.md .gitignore .vscode apt.txt

NIMBLE  = $(HOME)/.nimble/bin/nimble
NIM     = $(HOME)/.nimble/bin/nim


.PHONY: all nim
all: nim
nim: $(MODULE) $(MODULE).ini
	./$^

SRC = $(shell find $(CWD)/src -type f -regex ".+\.nim$$")

$(MODULE): $(SRC) $(MODULE).nimble Makefile
	echo $(SRC) | xargs -n1 -P0 nimpretty --indent:2
	nimble build


install: $(OS)_install $(NIMBLE)
update:  $(OS)_update  $(NIMBLE)
	choosenim update self
	choosenim update stable

$(NIMBLE):
	curl https://nim-lang.org/choosenim/init.sh -sSf | sh


.PHONY: Linux_install Linux_update

Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`



.PHONY: master shadow release

master:
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)

shadow:
	git checkout $@
	git pull -v

release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	$(MAKE) shadow

