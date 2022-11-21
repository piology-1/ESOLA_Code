import QtQuick 2.15
// for PySide6 import:
// import Qt5Compat.GraphicalEffects


Item {
    id: root
    width: 400
    height: 100
    property alias text: label.text
    property int textSize: 32
    property color bgColor: Constants.buttonColor
    property alias radius: rectangle.radius

    signal clicked
    signal pressed

    // DropShadow {
    //     id: dropShadow
    //     opacity: 0.5
    //     radius: 6
    //     anchors.fill: rectangle
    //     source: rectangle
    //     verticalOffset: 4
    //     horizontalOffset: 4
    //     color: Qt.darker(parent.bgColor, 1.5)
    // }

    Rectangle {
        id: rectangle
        color: parent.bgColor
        radius: parent.width > parent.height ? parent.height / 5 : parent.width / 5
        anchors.fill: parent
        anchors.rightMargin: 4
        anchors.bottomMargin: 4
    }

    Text {
        id: label
        color: "#ffffff"
        text: qsTr("text")
        anchors.fill: rectangle
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.Bold
        font.family: Constants.fontFamily
        fontSizeMode: Text.Fit
        font.pointSize: parent.textSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        Connections {
            target: mouseArea
            function onClicked(mouse) {
                root.clicked()
            }
        }

        Connections {
            target: mouseArea
            function onPressed(mouse) {
                root.pressed()
            }
        }
    }

    states: [
        State {
            name: "down"
            when: mouseArea.pressed

            PropertyChanges {
                target: rectangle
                anchors.leftMargin: 2
                anchors.topMargin: 2
                anchors.bottomMargin: 2
                anchors.rightMargin: 2
                color: Qt.lighter(parent.bgColor, 1.25)
            }

            // PropertyChanges {
            //     target: dropShadow
            //     visible: false
            // }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: rectangle
                color: "#aaaaaa"
                anchors.bottomMargin: 2
                anchors.leftMargin: 2
                anchors.topMargin: 2
                anchors.rightMargin: 2
            }

            // PropertyChanges {
            //     target: dropShadow
            //     visible: false
            // }

            PropertyChanges {
                target: mouseArea
                enabled: false
            }
        }
    ]
}
