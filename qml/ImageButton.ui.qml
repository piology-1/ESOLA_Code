import QtQuick 2.15
// import Qt5Compat.GraphicalEffects

Item {
    id: root
    property alias source: image.source

    signal clicked
    signal pressed

    Image {
        id: image
        width: parent.width
        height: parent.height
        source: "qrc:/qtquickplugin/images/template_image.png"
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
    }

    // ColorOverlay {
    //     id: colorOverlay
    //     visible: false
    //     anchors.fill: parent
    //     source: parent
    //     color: "#ffffff"
    //     opacity: 0.33
    // }

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

            // PropertyChanges {
            //     target: colorOverlay
            //     visible: true
            // }

            PropertyChanges {
                target: image
                x: 1
                y: 1
                width: parent.width - 1
                height: parent.height - 1
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.25;height:480;width:640}
}
##^##*/

