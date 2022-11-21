import QtQuick 2.15

Item {
    id: root
    width: Constants.width
    height: Constants.height

    signal clicked

    Clock {
        id: clock
        y: 200
        height: 200
        anchors.horizontalCenter: parent.horizontalCenter
        showDate: true
    }

    Text {
        id: caption
        y: 540
        text: qsTr("Bitte den Bildschirm berühren, um zu starten…")
        font.pixelSize: 40
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Constants.fontFamily
    }

    MouseArea {
        id: mouseArea
        width: parent.width
        height: parent.height

        Connections {
            target: mouseArea
            function onClicked(mouse) {
                root.clicked()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.66}
}
##^##*/

