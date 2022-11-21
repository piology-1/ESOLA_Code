import QtQuick 2.15

Item {
    id: root
    width: Constants.width
    height: Constants.topBarHeight
    property alias button_x: button_x
    property alias button_help: button_help
    property alias helpOverlay: helpOverlay

    Clock {
        id: clock
        height: 55
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: dhbwlogo
        height: 72
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        source: "../images/DHBW-Logo.png"
        anchors.leftMargin: 20
        fillMode: Image.PreserveAspectFit
    }

    ImageButton {
        id: button_x
        width: 96
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        source: "../images/button_x.png"
        anchors.rightMargin: 16
    }

    ImageButton {
        id: button_help
        width: button_x.width
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: button_x.left
        source: "../images/button_help.png"
        z: 2
        anchors.rightMargin: 10

        Connections {
            target: button_help
            function onClicked(mouse) {
                helpOverlay.state = helpOverlay.state == "collapsed" ? root.state : "collapsed"
            }
        }
    }

    HelpOverlay {
        id: helpOverlay
    }
}
