PERL := perl
PERL_FLAGS := -Ilib
LIB := lib
SCRIPT := script/stronghold.pl
APP := stronghold
PACKED_DIR := packed
PLATFORM := $(shell uname -s)-$(shell uname -m)
PACKED_APP := $(PACKED_DIR)/$(APP)-$(PLATFORM)

.PHONY: help check format critic test run deps pack clean-packed

.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  deps    Install project dependencies"
	@echo "  check   Check Perl syntax"
	@echo "  format  Format code with perltidy"
	@echo "  critic  Run Perl::Critic"
	@echo "  test    Run tests"
	@echo "  run     Run the game"
	@echo "  pack          Build standalone executable"
	@echo "  clean-packed  Remove packaged executables"	

deps:
	cpanm --installdeps .

check:
	$(PERL) $(PERL_FLAGS) -c $(SCRIPT)
	find $(LIB) -name '*.pm' -exec $(PERL) $(PERL_FLAGS) -c {} \;

format:
	perltidy -b -bext='/' $(SCRIPT) $(shell find $(LIB) -name '*.pm')

critic:
	perlcritic $(SCRIPT) $(LIB)

test:
	prove -l t

run:
	$(PERL) $(PERL_FLAGS) $(SCRIPT)

pack:
	mkdir -p $(PACKED_DIR)
	pp -Ilib -o $(PACKED_APP) $(SCRIPT)

clean-packed:
	rm -rf $(PACKED_DIR)
