# SPDX-License-Identifier: AGPL-3.0-or-later

TOPTARGETS := all clean test build

# wrap ./run script
# -----------------

RUN += help clean
PHONY += $(RUN)
$(RUN):
	@./run $@

test:
	@shellcheck -x -s bash run
	@./run test.all

.PHONY: $(RUN) $(TOPTARGETS)
