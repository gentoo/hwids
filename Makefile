# can be replaced with `wget -q -O -` if you want
HTTPCAT = curl

fetch:
	$(HTTPCAT) http://pci-ids.ucw.cz/v2.2/pci.ids.bz2 | bzcat > pci.ids
	$(HTTPCAT) http://www.linux-usb.org/usb.ids.bz2 | bzcat > usb.ids

PV ?= $(shell date +%Y%m%d)
P = hwids-$(PV)

dist: $(P).tar.xz

$(P).tar.xz:
	git tag $(P)
	git archive --prefix=$(P)/ $(P) | xz -9e > $(P).tar.xz
