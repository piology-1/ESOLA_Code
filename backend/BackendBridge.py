from PySide6.QtCore import QObject, Slot

from .Compartments import Compartments


class _BackendBridge(QObject):
    '''
    This class connects the backend to the frontend.
    Getting all Data regarding the available Compartments and load it to the GUI.

    This methods gets called at App.qml at Line 93 etc.
    '''

    @Slot(str, result=list)
    def getAvailableComps(self, batteryType):
        return Compartments.get_available(batteryType)

    @Slot(str, result=list)
    def getOccupiedComps(self, batteryType):
        return Compartments.get_occupied(batteryType)

    @Slot(str, int, str, result=bool)
    def pinLock(self, batteryType, index, pin):
        return Compartments.pin_lock(batteryType, index, pin)

    @Slot(str, int, str, result=bool)
    def pinUnlock(self, batteryType, index, pin):
        return Compartments.pin_unlock(batteryType, index, pin)


BackendBridge = _BackendBridge()  # this instance gets called in gui_main.py
