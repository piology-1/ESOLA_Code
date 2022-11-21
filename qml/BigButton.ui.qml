import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    width: 200
    height: width
    QtObject {
        id: d
        readonly property double scaleFactor: 1 / 200 * root.width
    }

    property string iconSource: "qrc:/qtquickplugin/images/template_image.png"
    property alias text: label.text
    property color bgColor: Constants.buttonColor

    signal clicked
    signal pressed

    DropShadow {
        id: dropShadow
        opacity: 0.5
        radius: 3 * d.scaleFactor
        anchors.fill: rectangle
        source: rectangle
        verticalOffset: 1.5 * d.scaleFactor
        horizontalOffset: 1.5 * d.scaleFactor
        color: Qt.darker(parent.bgColor, 1.5)
    }

    Rectangle {
        id: rectangle
        width: parent.width - 3 * d.scaleFactor
        height: parent.height - 3 * d.scaleFactor
        color: parent.bgColor
        radius: 25 * d.scaleFactor
    }

    Image {
        id: image
        anchors.left: rectangle.left
        anchors.right: rectangle.right
        anchors.top: rectangle.top
        anchors.bottom: label.top
        source: iconSource
        fillMode: Image.PreserveAspectFit
        anchors.bottomMargin: 8 * d.scaleFactor
        anchors.topMargin: 24 * d.scaleFactor
        anchors.rightMargin: 24 * d.scaleFactor
        anchors.leftMargin: 24 * d.scaleFactor
    }

    ColorOverlay {
        id: colorOverlay
        visible: false
        anchors.fill: image
        source: image
        color: "#ffffff"
        opacity: 0.2
    }

    Text {
        id: label
        color: "#ffffff"
        text: "text"
        anchors.left: rectangle.left
        anchors.right: rectangle.right
        anchors.bottom: rectangle.bottom
        font.pixelSize: 26 * d.scaleFactor
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.Bold
        fontSizeMode: Text.HorizontalFit
        anchors.bottomMargin: 8 * d.scaleFactor
        anchors.leftMargin: 8 * d.scaleFactor
        anchors.rightMargin: 8 * d.scaleFactor
        font.family: Constants.fontFamily
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
                x: 2 * d.scaleFactor
                y: 2 * d.scaleFactor
                color: Qt.lighter(parent.bgColor, 1.25)
            }

            PropertyChanges {
                target: dropShadow
                visible: false
            }

            PropertyChanges {
                target: colorOverlay
                visible: true
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: rectangle
                x: 2 * d.scaleFactor
                y: 2 * d.scaleFactor
                color: "#aaaaaa"
            }

            PropertyChanges {
                target: dropShadow
                visible: false
            }

            PropertyChanges {
                target: colorOverlay
                visible: true
            }

            PropertyChanges {
                target: mouseArea
                enabled: false
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;height:400;width:400}
}
##^##*/

