# SPDX-License-Identifier: AGPL-3.0-or-later

TOPTARGETS := all clean test build

# wrap ./run script
# -----------------

RUN += help clean spamhaus.ASN-DROP
PHONY += $(RUN)
$(RUN):
	@./run $@

test:
	@shellcheck -x -s bash run
	@./run test.all

# sudo -H journalctl -u "uwsgi@searxng" | grep -o 'BLOCK: .* SUSPICIOUS_IP_WINDOW' > out.log
# sudo journalctl --vacuum-time=2d

searxng.add.ipv4:
	LOG_FILES='log/ipv4/*' \
	BOT_NETWORKS=searxng/ipv4_botnet.lst \
	./run botnet.add

searxng.add.ipv6:
	LOG_FILES='log/ipv6/*' \
	BOT_NETWORKS=searxng/ipv4_botnet.lst \
	./run botnet.add

.PHONY: $(RUN) $(TOPTARGETS)
