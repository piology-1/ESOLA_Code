import QtQuick 2.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor
    state: "welcome"

    property alias topBar: topBar
    property alias button_back: button_back
    property alias welcomeScreen: welcomeScreen
    property alias homeScreen: homeScreen
    property alias batteryTypeScreen: batteryTypeScreen
    property alias compartmentScreen: compartmentScreen
    property alias authorizeScreen: authorizeScreen
    property alias finishScreen: finishScreen
    property alias standbyResetMouseArea: standbyResetMouseArea

    TopBar {
        id: topBar
        x: 0
        y: 0
        z: 10
        state: root.state
    }

    ImageButton {
        id: button_back
        x: 16
        width: 96
        height: 96
        anchors.top: topBar.bottom
        source: "../images/button_back.png"
        anchors.topMargin: 12
    }

    WelcomeScreen {
        id: welcomeScreen
        x: 0
        y: 0
        visible: false
    }

    HomeScreen {
        id: homeScreen
        visible: false
        x: 0
        y: Constants.topBarHeight
    }

    BatteryTypeScreen {
        id: batteryTypeScreen
        visible: false
        x: 0
        y: Constants.topBarHeight
    }

    CompartmentScreen {
        id: compartmentScreen
        x: 0
        y: Constants.topBarHeight
        visible: false
    }

    AuthorizeScreen {
        id: authorizeScreen
        x: 0
        y: Constants.topBarHeight
        visible: false
    }

    FinishScreen {
        id: finishScreen
        x: 0
        visible: false
    }

    MouseArea {
        id: standbyResetMouseArea
        anchors.fill: parent
        z: 100
    }

    states: [
        State {
            name: "welcome"

            PropertyChanges {
                target: topBar
                visible: false
            }

            PropertyChanges {
                target: welcomeScreen
                visible: true
            }

            PropertyChanges {
                target: button_back
                visible: false
            }
        },
        State {
            name: "home"

            PropertyChanges {
                target: homeScreen
                visible: true
            }

            PropertyChanges {
                target: button_back
                visible: false
            }
        },
        State {
            name: "batterytype"
            PropertyChanges {
                target: batteryTypeScreen
                visible: true
            }
        },
        State {
            name: "compartment"

            PropertyChanges {
                target: batteryTypeScreen
                visible: false
            }

            PropertyChanges {
                target: compartmentScreen
                visible: true
            }
        },
        State {
            name: "authorize"

            PropertyChanges {
                target: authorizeScreen
                visible: true
            }
        },
        State {
            name: "finish"

            PropertyChanges {
                target: topBar
                visible: false
            }

            PropertyChanges {
                target: finishScreen
                visible: true
            }

            PropertyChanges {
                target: button_back
                visible: false
            }
        },
        State {
            name: "occupied"
        }
    ]
}
