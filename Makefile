
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
UDEV_FILES = 20-acpi-vendor.hwdb 20-bluetooth-vendor-product.hwdb
UDEV_FILES += 20-net-ifname.hwdb 60-evdev.hwdb 60-keyboard.hwdb 60-sensor.hwdb
UDEV_FILES += 70-joystick.hwdb 70-mouse.hwdb 70-pointingstick.hwdb 70-touchpad.hwdb

UDEV_PATHS = $(addprefix udev/,$(UDEV_FILES))

all: $(ALL_TARGETS-yes)

.PHONY: all install install-base install-hwdb fetch tag udev-hwdb compress
.PHONY: pci.ids usb.ids oui.txt ma-medium.txt ma-small.txt iab.txt sdio.ids ids_parser.py
.PHONY: $(UDEV_PATHS)

install: $(INSTALL_TARGETS-yes)

curl-get = $(Q)curl -s -L -z $@ -o $@ -R $1

pci.ids:
	$(call curl-get,http://pci-ids.ucw.cz/v2.2/pci.ids)

usb.ids:
	$(call curl-get,http://www.linux-usb.org/usb.ids)

# OUI/IAB: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries
oui.txt:
	$(call curl-get,http://standards-oui.ieee.org/oui/oui.txt)

ma-medium.txt:
	$(call curl-get,http://standards-oui.ieee.org/oui28/mam.txt)

ma-small.txt:
	$(call curl-get,http://standards-oui.ieee.org/oui36/oui36.txt)

iab.txt:
	$(call curl-get,http://standards-oui.ieee.org/iab/iab.txt)

sdio.ids:
	$(call curl-get,$(SYSTEMD_SOURCE)/sdio.ids)

ids_parser.py:
	$(call curl-get,$(SYSTEMD_SOURCE)/ids_parser.py)

$(UDEV_PATHS):
	$(call curl-get,$(SYSTEMD_SOURCE)/$(notdir $@))

fetch: pci.ids usb.ids oui.txt ma-medium.txt ma-small.txt iab.txt sdio.ids ids_parser.py $(UDEV_PATHS)
	$(Q)$(STATUS)

PV ?= $(shell ( awk '$$2 == "Date:" { print $$3; nextfile }' pci.ids usb.ids; git log --format=format:%ci -1 -- oui.txt $(addprefix udev/,$(UDEV_FILES)) ids_parser.py | cut -d ' ' -f1; ) | sort | tail -n 1 | tr -d -)
P = hwids-$(PV)

tag:
	git tag -s $(P)

udev-hwdb:
	$(PYTHON) ids_parser.py && mv *.hwdb udev/

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
