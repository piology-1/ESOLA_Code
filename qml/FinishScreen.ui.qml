import QtQuick 2.15

ScreenCommon {
    id: root
    height: Constants.height
    caption.y: 30

    property var cuLaterTexts: [qsTr("Bis später!"), qsTr(
            "Genießen Sie Ihren Aufenthalt an der DHBW!"), qsTr(
            "Bis Spätersilie!"), qsTr("Bis speda, Peda!"), qsTr(
            "Bis Baldrian!"), qsTr("Bis Dannzig!"), qsTr(
            "Man siebt sich!"), qsTr("Bis Dennis!"), qsTr(
            "Bis denn, Sven!"), qsTr("Bis denn, Sven!")]
    property var byeByeTexts: [qsTr("Bis zum nächsten Mal!"), qsTr(
            "Bitte beehren Sie uns bald wieder!"), qsTr(
            "Bitte kommen Sie bald wieder!"), qsTr(
            "Wir hoffen der Akku ist voll geworden!"), qsTr(
            "Wir wünschen eine angenehme Radfahrt!"), qsTr(
            "San Frantschüssko!"), qsTr("Tschüsseldorf!"), qsTr(
            "Tschö mit ö!"), qsTr("Tschau mit au!"), qsTr(
            "Tschüsli Müsli!"), qsTr("Sayonara Carbonara!"), qsTr(
            "Ciao Kakao!")]

    Image {
        id: image
        x: 289
        y: 172
        width: 600
    }

    Text {
        id: bottomText
        text: "BOTTOM TEXT"
        anchors.bottom: parent.bottom
        font.pixelSize: 64
        horizontalAlignment: Text.AlignHCenter
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Constants.fontFamily

        Connections {
            target: bottomText
            function onVisibleChanged() {
                if (visible) {
                    let texts = state === "deposit" ? cuLaterTexts : byeByeTexts
                    bottomText.text = texts[Math.floor(Math.random(
                                                           ) * texts.length)]
                }
            }
        }
    }

    states: [
        State {
            name: "deposit"

            PropertyChanges {
                target: root
                caption.text: qsTr("Bitte Akku anstecken und Türe schließen!")
            }

            PropertyChanges {
                target: image
                source: "../images/AkkuEinlegen.png"
            }
        },
        State {
            name: "retrieve"

            PropertyChanges {
                target: root
                caption.text: qsTr("Bitte Akku entnehmen und Türe schließen!")
            }

            PropertyChanges {
                target: image
                source: "../images/AkkuEntnehmen.png"
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.66}
}
##^##*/

