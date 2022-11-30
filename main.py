import usb.core
import usb.util

#   idVendor           0x072f Advanced Card Systems, Ltd
#   idProduct          0x2200 ACR122U

RFID_device = usb.core.find(idVendor=0x072f, idProduct=0x2200)


# RFID_device = usb.core.find(idVendor=0x072f, idProduct=0x2200)
# endpoint = RFID_device[0].interfaces()[0].endpoints()[0]
# interface = RFID_device[0].interfaces()[0].bInterfaceNumber

# RFID_device.reset()

# if RFID_device.is_kernel_driver_active(interface):
#     RFID_device.detach_kernel_driver(interface)

# RFID_device.set_configuration()

# eaddr = endpoint.bEndpointAddress

# r = RFID_device.read(eaddr, 100)
# # print(RFID_device[0].interfaces())
