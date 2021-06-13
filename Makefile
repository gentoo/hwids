
ifeq "$(V)" "0"
  STATUS = git status -s
  Q=@
else
  STATUS = git status
  Q=
endif

PKG_CONFIG ?= pkg-config
PYTHON ?= python3
GZIP ?= yes
NET ?= yes
PCI ?= yes
UDEV ?= no
USB ?= yes

COMPRESS_FILES-yes =
COMPRESS_FILES-$(PCI) += pci.ids.gz
COMPRESS_FILES-$(USB) += usb.ids.gz

DATA_FILES-yes =
DATA_FILES-$(GZIP) += $(COMPRESS_FILES-yes)
DATA_FILES-$(NET) += oui.txt iab.txt
DATA_FILES-$(PCI) += pci.ids
DATA_FILES-$(USB) += usb.ids

ALL_TARGETS-yes =
ALL_TARGETS-$(GZIP) += $(COMPRESS_FILES-yes)

INSTALL_TARGETS-yes = install-base
INSTALL_TARGETS-$(UDEV) += install-hwdb

SYSTEMD_SOURCE = https://github.com/systemd/systemd/raw/master/hwdb.d
UDEV_FILES = 20-acpi-vendor.hwdb
UDEV_FILES += 20-bluetooth-vendor-product.hwdb
UDEV_FILES += 20-dmi-id.hwdb
UDEV_FILES += 20-net-ifname.hwdb
UDEV_FILES += 20-vmbus-class.hwdb
UDEV_FILES += 60-autosuspend.hwdb
UDEV_FILES += 60-autosuspend-fingerprint-reader.hwdb
UDEV_FILES += 60-evdev.hwdb
UDEV_FILES += 60-input-id.hwdb
UDEV_FILES += 60-keyboard.hwdb
UDEV_FILES += 60-sensor.hwdb
UDEV_FILES += 70-joystick.hwdb
UDEV_FILES += 70-mouse.hwdb
UDEV_FILES += 70-pointingstick.hwdb
UDEV_FILES += 70-touchpad.hwdb
UDEV_FILES += 80-ieee1394-unit-function.hwdb

all: $(ALL_TARGETS-yes)

.PHONY: all install install-base install-hwdb fetch tag udev-hwdb compress

install: $(INSTALL_TARGETS-yes)

# OUI/IAB: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries
fetch:
	$(Q)curl -z pci.ids -o pci.ids -R http://pci-ids.ucw.cz/v2.2/pci.ids
	$(Q)curl -z usb.ids -o usb.ids -R http://www.linux-usb.org/usb.ids
	$(Q)curl -z oui.txt -o oui.txt -R http://standards-oui.ieee.org/oui/oui.txt
	$(Q)curl -z ma-medium.txt -o ma-medium.txt -R http://standards-oui.ieee.org/oui28/mam.txt
	$(Q)curl -z ma-small.txt -o ma-small.txt -R http://standards-oui.ieee.org/oui36/oui36.txt
	$(Q)curl -z iab.txt -o iab.txt -R http://standards-oui.ieee.org/iab/iab.txt
	$(Q)curl -L -z sdio.ids -o sdio.ids -R $(SYSTEMD_SOURCE)/sdio.ids
	$(Q)curl -L -z ids_parser.py -o ids_parser.py -R $(SYSTEMD_SOURCE)/ids_parser.py
	$(Q)for f in $(UDEV_FILES); do curl -L -z udev/$$f -o udev/$$f -R $(SYSTEMD_SOURCE)/$$f; done
	$(Q)$(STATUS)

PV ?= $(shell ( awk '$$2 == "Date:" { print $$3; nextfile }' pci.ids usb.ids; git log --format=format:%ci -1 -- oui.txt $(addprefix udev/,$(UDEV_FILES)) ids_parser.py | cut -d ' ' -f1; ) | sort | tail -n 1 | tr -d -)
P = hwids-$(PV)

tag:
	git tag -s $(P)

udev-hwdb:
	$(PYTHON) ids_parser.py
	$(PYTHON) make-autosuspend-rules.py > 60-autosuspend-chromiumos.hwdb
	mv *.hwdb udev/

compress: pci.ids.gz usb.ids.gz

%.gz: %
	gzip -c $< > $@

MISCDIR=/usr/share/misc
HWDBDIR=$(shell $(PKG_CONFIG) --variable=udevdir udev)/hwdb.d
DOCDIR=/usr/share/doc/hwids

install-base: $(DATA_FILES-yes)
	mkdir -p $(DESTDIR)$(DOCDIR)
	install -p -m 644 README.md $(DESTDIR)$(DOCDIR)
ifneq ($(strip $(DATA_FILES-yes)),)
	mkdir -p $(DESTDIR)$(MISCDIR)
	install -p -m 644 $(DATA_FILES-yes) $(DESTDIR)$(MISCDIR)
endif

install-hwdb:
	mkdir -p $(DESTDIR)$(HWDBDIR)
	install -p -m 644 udev/*.hwdb $(DESTDIR)$(HWDBDIR)
	udevadm hwdb --root $(DESTDIR) --update
