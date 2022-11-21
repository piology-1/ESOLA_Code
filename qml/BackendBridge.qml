import QtQuick 2.15

// ACHTUNG: Nur Mockup-Implementierung, damit die QML-Oberfläche auch ohne
// Python getestet werde kann!
// Die "echte" BackendBridge befindet sich in backend/BackendBridge.py

QtObject {
    function getAvailableComps(batteryType) {
        return {
            "bosch": [false, false, false, false, true, false, false, false],
            "panasonic": [false, false, false, false, false, false, false, false],
            "panterra": [true, false, false, false]
        }[batteryType]
    }

    function getOccupiedComps(batteryType) {
        return {
            "bosch": [true, false, false, false, false, false, false, false],
            "panasonic": [true, false, false, false, true, false, false, false],
            "panterra": [false, false, false, false]
        }[batteryType]
    }

    function pinLock(batteryType, index, pin) {
        return true
    }

    function pinUnlock(batteryType, index, pin) {
        if(pin === "1337")
            return true
        else
            return false
    }
}
