import usb.core


RFID_device = usb.core.find(idVendor=0x072f, idProduct=0x2200)
