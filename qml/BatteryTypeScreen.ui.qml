import QtQuick 2.15

ScreenCommon {
    property alias bosch: bosch
    property alias panasonic: panasonic
    property alias panterra: panterra

    caption.text: qsTr("Wählen Sie ihren Akkutypen:")

    BigButton {
        id: bosch
        y: 200
        width: 360
        text: "Bosch"
        anchors.left: parent.left
        iconSource: "../images/logo_Bosch.png"
        anchors.leftMargin: 50
    }

    BigButton {
        id: panasonic
        y: 200
        width: 360
        text: "Panasonic"
        anchors.horizontalCenter: parent.horizontalCenter
        iconSource: "../images/logo_Panasonic.png"
    }

    BigButton {
        id: panterra
        x: 832
        y: 200
        width: 360
        text: "PanTerra"
        anchors.right: parent.right
        iconSource: "../images/logo_PanTerra.png"
        anchors.rightMargin: 50
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.75}
}
##^##*/

