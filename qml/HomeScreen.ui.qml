import QtQuick 2.15

ScreenCommon {
    property alias einlagern: einlagern
    property alias entnehmen: entnehmen

    caption.text: qsTr("Was möchten Sie tun?")

    BigButton {
        id: einlagern
        y: 180
        width: 400
        text: "Einlagern"
        anchors.left: parent.left
        anchors.leftMargin: 180
        iconSource: "../images/einlagern.png"
    }

    BigButton {
        id: entnehmen
        y: 180
        width: 400
        text: "Entnehmen"
        anchors.right: parent.right
        anchors.rightMargin: 180
        iconSource: "../images/entnehmen.png"
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.66}
}
##^##*/

