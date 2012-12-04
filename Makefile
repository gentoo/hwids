ifeq "$(V)" "0"
  STATUS = git status -s
  Q=@
else
  STATUS = git status
  Q=
endif

fetch:
	$(Q)curl -z pci.ids -o pci.ids -R http://pci-ids.ucw.cz/v2.2/pci.ids
	$(Q)curl -z usb.ids -o usb.ids -R http://www.linux-usb.org/usb.ids
	$(Q)curl -z oui.txt -o oui.txt -R http://standards.ieee.org/develop/regauth/oui/oui.txt
	$(Q)curl -z iab.txt -o iab.txt -R http://standards.ieee.org/develop/regauth/iab/iab.txt
	$(Q)curl -z udev/20-acpi-vendor.hwdb -o udev/20-acpi-vendor.hwdb -R http://cgit.freedesktop.org/systemd/systemd/plain/hwdb/20-acpi-vendor.hwdb
	$(Q)curl -z udev-hwdb-update.pl -o udev-hwdb-update.pl -R http://cgit.freedesktop.org/systemd/systemd/plain/hwdb/ids-update.pl
	$(Q)$(STATUS)

PV ?= $(shell ( awk '$$2 == "Date:" { print $$3; nextfile }' pci.ids usb.ids; git log --format=format:%ci -1 -- oui.txt hwdb/20-acpi-vendor.hwdb udev-hwdb-update.pl | cut -d ' ' -f1; ) | sort | tail -n 1 | tr -d -)
P = hwids-$(PV)

tag:
	git tag $(P)

udev-hwdb:
	perl ./udev-hwdb-update.pl && mv *.hwdb udev/
