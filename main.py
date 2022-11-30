import usb.core


RFID_device = usb.core.find(idVendor=0x072f, idProduct=0x2200)
endpoint = RFID_device[0].interfaces()[0].endpoints()[0]
i = RFID_device[0].interfaces()[0].bInterfaceNumber

RFID_device.reset()

if RFID_device.is_kernel_driver_active():
    RFID_device.detach_kernel_driver()

RFID_device.set_configuration()

eaddr = endpoint.bEndpointAddress

r = RFID_device.read(eaddr, 100)
# print(RFID_device[0].interfaces())
