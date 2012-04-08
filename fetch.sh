#!/bin/sh

curl http://pci-ids.ucw.cz/v2.2/pci.ids.bz2 | bzcat > pci.ids
curl http://www.linux-usb.org/usb.ids.bz2 | bzcat > usb.ids
