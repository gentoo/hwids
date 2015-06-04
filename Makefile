
ifeq "$(V)" "0"
  STATUS = git status -s
  Q=@
else
  STATUS = git status
  Q=
endif

PKG_CONFIG ?= pkg-config
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
ALL_TARGETS-$(UDEV) += udev-hwdb

INSTALL_TARGETS-yes = install-base
INSTALL_TARGETS-$(UDEV) += install-hwdb

SYSTEMD_SOURCE = https://github.com/systemd/systemd/raw/master/hwdb

all: $(ALL_TARGETS-yes)

install: $(INSTALL_TARGETS-yes)

fetch:
	$(Q)curl -z pci.ids -o pci.ids -R http://pci-ids.ucw.cz/v2.2/pci.ids
	$(Q)curl -z usb.ids -o usb.ids -R http://www.linux-usb.org/usb.ids
	$(Q)curl -z oui.txt -o oui.txt -R http://standards-oui.ieee.org/oui.txt
	$(Q)curl -z iab.txt -o iab.txt -R http://standards.ieee.org/develop/regauth/iab/iab.txt
	$(Q)curl -L -z sdio.ids -o sdio.ids -R $(SYSTEMD_SOURCE)/sdio.ids
	$(Q)curl -L -z udev/20-acpi-vendor.hwdb -o udev/20-acpi-vendor.hwdb -R $(SYSTEMD_SOURCE)/20-acpi-vendor.hwdb
	$(Q)curl -L -z udev/20-bluetooth-vendor-product.hwdb -o udev/20-bluetooth-vendor-product.hwdb -R $(SYSTEMD_SOURCE)/20-bluetooth-vendor-product.hwdb
	$(Q)curl -L -z udev/20-net-ifname.hwdb -o udev/20-net-ifname.hwdb -R $(SYSTEMD_SOURCE)/20-net-ifname.hwdb
	$(Q)curl -L -z udev/60-keyboard.hwdb -o udev/60-keyboard.hwdb -R $(SYSTEMD_SOURCE)/60-keyboard.hwdb
	$(Q)curl -L -z udev/70-mouse.hwdb -o udev/70-mouse.hwdb -R $(SYSTEMD_SOURCE)/70-mouse.hwdb
	$(Q)curl -L -z udev/70-pointingstick.hwdb -o udev/70-pointingstick.hwdb -R $(SYSTEMD_SOURCE)/70-pointingstick.hwdb
	$(Q)curl -L -z udev/70-touchpad.hwdb -o udev/70-touchpad.hwdb -R $(SYSTEMD_SOURCE)/70-touchpad.hwdb
	$(Q)curl -L -z udev-hwdb-update.pl -o udev-hwdb-update.pl -R $(SYSTEMD_SOURCE)/ids-update.pl
	$(Q)$(STATUS)

PV ?= $(shell ( awk '$$2 == "Date:" { print $$3; nextfile }' pci.ids usb.ids; git log --format=format:%ci -1 -- oui.txt udev/20-acpi-vendor.hwdb udev/20-bluetooth-vendor-product.hwdb udev/20-net-ifname.hwdb udev/60-keyboard.hwdb udev/70-mouse.hwdb udev/70-pointingstick.hwdb udev/70-touchpad.hwdb udev-hwdb-update.pl | cut -d ' ' -f1; ) | sort | tail -n 1 | tr -d -)
P = hwids-$(PV)

tag:
	git tag $(P)

udev-hwdb:
	perl ./udev-hwdb-update.pl && mv *.hwdb udev/

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
