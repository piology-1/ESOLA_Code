import QtQuick 2.15
import QtQuick.Timeline 1.0

ScreenCommon {
    id: root
    property alias pinPad: pinPad
    property alias wrongPinAnimation: wrongPinAnimation

    signal pinConfirmed(var pin)

    caption.anchors.horizontalCenter: undefined
    caption.anchors.left: left
    caption.anchors.right: pinPad.left
    caption.anchors.leftMargin: 80

    Rectangle {
        id: input
        y: 264
        width: 212
        height: 80
        color: "#b6b9a7"
        radius: 12
        border.width: 4
        anchors.horizontalCenter: caption.horizontalCenter

        TextInput {
            id: inputLine
            x: 0
            anchors.fill: parent
            anchors.rightMargin: 16
            anchors.leftMargin: 16
            echoMode: TextInput.Password
            passwordCharacter: "*"
            passwordMaskDelay: 333
            maximumLength: 4
            font.pixelSize: 72
            horizontalAlignment: Text.AlignLeft
            anchors.bottomMargin: -12
            anchors.topMargin: 0
            font.family: Constants.monoFont.name

            activeFocusOnPress: false
        }
    }

    PinPad {
        id: pinPad
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16
        confirmable: true // <- sollte false sein, aber wegen QML-Bug nach onVisibleChanged verschoben...

        Connections {
            target: pinPad
            function onNumberPressed(number) {
                if (inputLine.length < 4) {
                    inputLine.insert(inputLine.length, number)
                    pinPad.confirmable = inputLine.length == 4
                }
            }
            function onBackspacePressed() {
                inputLine.remove(inputLine.length - 1, inputLine.length)
                pinPad.confirmable = false
                returnAnimation.running = true
            }
            function onConfirmClicked() {
                pinConfirmed(inputLine.text)
            }
        }
    }

    Connections {
        target: root
        function onVisibleChanged() {
            if (visible) {
                // Das sollte eigentlich schon oben gesetzt werden. Es gibt aber einen Bug, durch
                // den der DropShadow nur zurückkommt, wenn im Moment, zu dem der Button das
                // erste Mal sichtbar wird, der Base-State aktiv ist. Deswegen können wir den
                // Bestätigen-Button frühestens hier auf "disabled" setzen...
                pinPad.confirmable = false

                inputLine.clear()
                timeline.currentFrame = 0
            }
        }
    }

    Timeline {
        id: timeline
        animations: [
            TimelineAnimation {
                id: wrongPinAnimation
                duration: 500
                from: 0
                to: 300
            },
            TimelineAnimation {
                id: returnAnimation
                duration: 167
                to: 400
            }
        ]
        startFrame: 0
        endFrame: 400
        currentFrame: 400
        enabled: true

        KeyframeGroup {
            target: input
            property: "color"
            Keyframe {
                easing.type: Easing.OutQuad
                value: "#b6b9a7"
                frame: 375
            }

            Keyframe {
                value: "#cca3ad"
                frame: 300
            }

            Keyframe {
                easing.type: Easing.OutQuad
                value: "#cca3ad"
                frame: 75
            }

            Keyframe {
                value: "#b6b9a7"
                frame: 0
            }
        }

        KeyframeGroup {
            target: input
            property: "border.color"
            Keyframe {
                easing.type: Easing.InSine
                value: "#000000"
                frame: 400
            }
            Keyframe {
                easing.type: Easing.OutSine
                value: "#cc0000"
                frame: 300
            }
            Keyframe {
                easing.type: Easing.InSine
                value: "#000000"
                frame: 200
            }
            Keyframe {
                easing.type: Easing.OutSine
                value: "#cc0000"
                frame: 100
            }
            Keyframe {
                value: "#000000"
                frame: 0
            }
        }
    }
    states: [
        State {
            name: "deposit"

            PropertyChanges {
                target: root
                caption.text: qsTr("Legen Sie bitte eine\nvierstellige PIN fest:")
            }
        },
        State {
            name: "retrieve"

            PropertyChanges {
                target: root
                caption.text: qsTr(
                                  "Geben Sie bitte ihre\nvierstellige PIN ein:")
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.66;height:680;width:1280}
}
##^##*/

