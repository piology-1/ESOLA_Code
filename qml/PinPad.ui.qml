import QtQuick 2.15

Item {
    id: root
    width: 456
    height: 611

    property bool confirmable: true

    signal numberPressed(var number)
    signal backspacePressed
    signal confirmClicked

    TextButton {
        id: p1
        x: 0
        y: 0
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "1"

        Connections {
            target: p1
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p2
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "2"
        anchors.left: p1.right
        anchors.top: p1.bottom
        anchors.topMargin: -Constants.pinButtonSize
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p2
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p3
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "3"
        anchors.left: p2.right
        anchors.top: p2.bottom
        anchors.topMargin: -Constants.pinButtonSize
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p3
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p4
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "4"
        anchors.left: p1.right
        anchors.top: p1.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: -Constants.pinButtonSize

        Connections {
            target: p4
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p5
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "5"
        anchors.left: p4.right
        anchors.top: p1.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p5
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p6
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "6"
        anchors.left: p5.right
        anchors.top: p1.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p6
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p7
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "7"
        anchors.left: p4.right
        anchors.top: p4.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: -Constants.pinButtonSize

        Connections {
            target: p7
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p8
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "8"
        anchors.left: p7.right
        anchors.top: p4.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p8
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p9
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "9"
        anchors.left: p8.right
        anchors.top: p4.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p9
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: p0
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "0"
        anchors.left: p7.right
        anchors.top: p7.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace

        Connections {
            target: p0
            function onPressed(mouse) {
                root.numberPressed(target.text)
            }
        }
    }

    TextButton {
        id: backspace
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "⌫"
        anchors.left: p7.right
        anchors.top: p7.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: -Constants.pinButtonSize

        Connections {
            target: backspace
            function onPressed(mouse) {
                root.backspacePressed()
            }
        }
    }

    TextButton {
        id: confirm
        width: Constants.pinButtonSize
        height: Constants.pinButtonSize
        text: "✓"
        anchors.left: p0.right
        anchors.top: p7.bottom
        anchors.topMargin: Constants.pinButtonSpace
        anchors.leftMargin: Constants.pinButtonSpace
        state: confirmable ? "" : "disabled"

        Connections {
            target: confirm
            function onClicked(mouse) {
                root.confirmClicked()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/

