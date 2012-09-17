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

PV ?= $(shell date +%Y%m%d)
P = hwids-$(PV)

tag:
	git tag $(P)
