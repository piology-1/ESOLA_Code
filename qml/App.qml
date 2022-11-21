import QtQuick 2.15

AppScreen {
    id: root

    BackendBridge {
       id: mockBackendBridge
    }
    // Wird von Python aus zur Laufzeit mit "echter" BackendBridge ersetzt
    property QtObject backendBridge: mockBackendBridge

    property string batteryType
    property int compartmentIndex

    Timer {
        id: finishScreenTimer
        interval: Constants.finishScreenDuration
        onTriggered: function() {
            root.state = "home"
        }
    }

    Timer {
        id: standbyTimer
        running: true
        interval: Constants.standbyTimeout
        onTriggered: function() {
            topBar.helpOverlay.state = "collapsed"
            root.state = "welcome"
        }
    }

    property var backFrom: {
        "batterytype": function() {
            root.state = "home"
        },
        "compartment": function() {
            root.state = "batterytype"
        },
        "authorize": function() {
            root.state = "compartment"
        }
    }

    topBar.button_x.onClicked: function(mouse) {
        if (root.state == "home"){
            root.state = "welcome"
        } else {
            root.state = "home"
        }


    }

    button_back.onClicked: function(mouse) {
        backFrom[root.state]()
    }

    welcomeScreen.onClicked: function(mouse) {
        root.state = "home"
    }

    homeScreen.einlagern.onClicked: function(mouse) {
        root.state = "batterytype";
        batteryTypeScreen.state = "deposit"
        compartmentScreen.state = "deposit"
        authorizeScreen.state = "deposit"
        finishScreen.state = "deposit"
    }
    homeScreen.entnehmen.onClicked: function(mouse) {
        root.state = "batterytype"
        batteryTypeScreen.state = "retrieve"
        compartmentScreen.state = "retrieve"
        authorizeScreen.state = "retrieve"
        finishScreen.state = "retrieve"
    }

    batteryTypeScreen.bosch.onClicked: function(mouse) {
        onBatteryTypeSelected("bosch")
    }
    batteryTypeScreen.panasonic.onClicked: function(mouse) {
        onBatteryTypeSelected("panasonic")
    }
    batteryTypeScreen.panterra.onClicked: function(mouse) {
        onBatteryTypeSelected("panterra")
    }
    function onBatteryTypeSelected(type) {
        batteryType = type
        maskCompartments(batteryTypeScreen.state)
        root.state = "compartment"
    }

    // Belegte Fächer abfragen und Buttons im CompartmentScreen entsprechend ausgrauen.
    // Bei Einlagern außerdem in occupied-State versetzen, wenn alle belegt.
    function maskCompartments(state) {
        let enableMask = state === "deposit" ? backendBridge.getAvailableComps(batteryType) : backendBridge.getOccupiedComps(batteryType)
        let allOccupied = state === "deposit"
        compartmentScreen.buttons.forEach(b => {
            b.state = "disabled"
            b.visible = false
        })
        for (let i = 0; i < Math.min(enableMask.length, compartmentScreen.buttons.length); i++)  {
            compartmentScreen.buttons[i].visible = true
            if (enableMask[i]) {
                allOccupied = false
                compartmentScreen.buttons[i].state = ""
            }
        }
        compartmentScreen.state = allOccupied ? "occupied" : state
    }

    compartmentScreen.onCompartmentSelected: function(number) {
        compartmentIndex = number - 1
        root.state = "authorize"
    }

    authorizeScreen.onPinConfirmed: function(pin) {
        var funcByState = {
            "deposit": backendBridge.pinLock,
            "retrieve": backendBridge.pinUnlock
        }
        if(funcByState[authorizeScreen.state](batteryType, compartmentIndex, pin)) {
            root.state = "finish"
            finishScreenTimer.start()
        } else {
            authorizeScreen.wrongPinAnimation.running = true
            authorizeScreen.pinPad.confirmable = false
        }
    }

    standbyResetMouseArea.onPressed: function(mouse) {
        standbyTimer.restart()
        mouse.accepted = false
    }
}
