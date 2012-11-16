# can be replaced with `wget -q -O -` if you want
ifeq "$(V)" "0"
  HTTPCAT = curl -s
  STATUS = git status -s
  Q=@
else
  HTTPCAT = curl
  STATUS = git status
  Q=
endif

fetch:
	$(Q)$(HTTPCAT) http://pci-ids.ucw.cz/v2.2/pci.ids.bz2 | bzcat > pci.ids
	$(Q)$(HTTPCAT) http://www.linux-usb.org/usb.ids.bz2 | bzcat > usb.ids
	$(Q)$(STATUS)

PV ?= $(shell awk '$$2 == "Date:" { gsub("-", "", $$3); print $$3; nextfile }' pci.ids usb.ids | sort | tail -n 1)
P = hwids-$(PV)

tag:
	git tag $(P)
