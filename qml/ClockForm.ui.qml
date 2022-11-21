import QtQuick 2.15

Item {
    id: root
    width: 400 * d.scaleFactor
    height: 160
    QtObject {
        id: d
        readonly property double scaleFactor: 1 / (showDate ? 160 : 110) * root.height
        readonly property double clockTextSize: 150 * d.scaleFactor
    }

    property alias time: time
    property alias date: date

    property bool showDate: false

    Text {
        id: date
        visible: parent.showDate
        text: Qt.formatDateTime(new Date(), "dddd, dd.MM.yyyy")
        anchors.top: time.bottom
        font.pixelSize: 32 * d.scaleFactor
        anchors.topMargin: -25 * d.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Constants.fontFamily
    }

    Text {
        id: time
        width: parent.width
        y: -62 * d.scaleFactor
        text: Qt.formatTime(new Date(), "hh:mm")
        anchors.horizontalCenter: parent.horizontalCenter

        font.family: Constants.clockFont.name
        font.pixelSize: d.clockTextSize
        horizontalAlignment: Text.AlignHCenter
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/

