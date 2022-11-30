import usb.core
import usb.util

#   idVendor           0x072f Advanced Card Systems, Ltd
#   idProduct          0x2200 ACR122U

# type: <class 'usb.core.Device'>
RFID_device = usb.core.find(idVendor=0x072f, idProduct=0x2200)

# print(RFID_device.configurations()) # <CONFIGURATION 1: 400 mA>,)
print(RFID_device.get_active_configuration())
print(type(RFID_device.get_active_configuration()))


RFID_device.reset()

# bEndpointAddress     0x81  EP 1 IN
bEndpointAddress = 0x81
data = RFID_device.read(endpoint=bEndpointAddress, size_or_buffer=9)
print(data)


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
