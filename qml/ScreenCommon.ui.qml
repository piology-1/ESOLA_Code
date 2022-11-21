import QtQuick 2.15

Item {
    id: root
    width: Constants.width
    height: Constants.height - Constants.topBarHeight
    property alias caption: caption

    Text {
        id: caption
        y: 12
        text: "caption"
        font.pixelSize: 64
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Constants.fontFamily
    }
}
