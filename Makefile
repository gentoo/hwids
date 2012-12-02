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
	$(Q)$(HTTPCAT) http://standards.ieee.org/develop/regauth/oui/oui.txt > oui.txt
	$(Q)$(STATUS)

PV ?= $(shell ( awk '$$2 == "Date:" { print $$3; nextfile }' pci.ids usb.ids; git log --format=format:%ci -1 -- oui.txt | cut -d ' ' -f1; ) | sort | tail -n 1 | tr -d -)
P = hwids-$(PV)

tag:
	git tag $(P)
