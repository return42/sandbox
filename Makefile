# SPDX-License-Identifier: AGPL-3.0-or-later

.DEFAULT_GOAL=help

# wrap ./prj script
# -----------------

PRJ += help env.build
PHONY += $(PRJ)
$(PRJ):
	@./prj $@

# local TOPTARGETS
test clean::
	@./prj $@


# run make in subdirectories
# --------------------------

# Makefiles in subdirs needs to define TOPTARGETS::
#    .PHONY: all clean test build

TOPTARGETS := all clean test build
SUBDIRS := $(dir $(wildcard */Makefile))
PHONY += $(TOPTARGETS)

$(TOPTARGETS)::
	@for dir in $(SUBDIRS); do \
	    $(MAKE) -C $$dir $@ || exit $$?; \
	done; \

.PHONY: $(PHONY)
