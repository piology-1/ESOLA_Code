import QtQuick 2.15

ScreenCommon {
    id: root

    readonly property var buttons: [comp1, comp2, comp3, comp4, comp5, comp6, comp7, comp8]
    readonly property var easterEggTexts: [qsTr(
            'Das tut uns leid. Alle Plätze für Ihren Akkutyp sind bereits belegt.'), qsTr(
            'Diese Ladestation ist besser belegt als die Seelen in der Seezeit!'), qsTr(
            'Die Kapazität ist leider genauso beschränkt wie so mancher Erdbewohner…'), qsTr(
            'Die Anlage ist belegt. Sie können gerne eine Nachricht hinterlassen. Sprechen sie nach dem Piieeep…'), qsTr(
            'Sorry, aber jetzt musch halt strampla!'), qsTr(
            'Sorry, but we are fully booked out.'), qsTr(
            'O je, sieht aus als müsste hier mal noch nachgerüstet werden…'), qsTr(
            'Hab ein Brötchen angerufen.\n…\nWar belegt.'), qsTr(
            'Seit Professoren hier tanken ist diese Anlage wissenschaftlich belegt.'), qsTr(
            '"Zwei Dinge sind unendlich, das Universum und die Solartankstelle, aber bei der Solartankstelle bin ich mir noch nicht ganz sicher."\n- Alfred Zweistein')]

    signal compartmentSelected(var number)

    Item {
        id: compGrid
        y: 160

        TextButton {
            id: comp1
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "1"
            anchors.left: parent.left
            anchors.leftMargin: (1280 - (4 * Constants.compButtonSize + 3
                                         * Constants.compButtonSpace)) / 2

            Connections {
                target: comp1
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp2
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "2"
            anchors.left: comp1.right
            anchors.top: comp1.top
            anchors.leftMargin: Constants.compButtonSpace

            Connections {
                target: comp2
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp3
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "3"
            anchors.left: comp2.right
            anchors.top: comp2.top
            anchors.leftMargin: Constants.compButtonSpace

            Connections {
                target: comp3
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp4
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "4"
            anchors.left: comp3.right
            anchors.top: comp3.top
            anchors.leftMargin: Constants.compButtonSpace

            Connections {
                target: comp4
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp5
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "5"
            anchors.left: comp1.left
            anchors.top: comp1.bottom
            anchors.topMargin: Constants.compButtonSpace

            Connections {
                target: comp5
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp6
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "6"
            anchors.left: comp2.left
            anchors.top: comp2.bottom
            anchors.topMargin: Constants.compButtonSpace

            Connections {
                target: comp6
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp7
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "7"
            anchors.left: comp3.left
            anchors.top: comp3.bottom
            anchors.topMargin: Constants.compButtonSpace

            Connections {
                target: comp7
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }

        TextButton {
            id: comp8
            width: Constants.compButtonSize
            height: Constants.compButtonSize
            text: "8"
            anchors.left: comp4.left
            anchors.top: comp4.bottom
            anchors.topMargin: Constants.compButtonSpace

            Connections {
                target: comp8
                function onClicked(mouse) {
                    root.compartmentSelected(target.text)
                }
            }
        }
    }

    Text {
        id: easterEggText
        width: 1000
        anchors.centerIn: parent
        anchors.verticalCenterOffset: height / 10
        font: root.caption.font
        visible: false
        text: "easterEggText"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    Connections {
        target: root
        function onStateChanged(state) {
            if (state === "occupied") {
                // Jede Stunde einen der Texte zufällig auswählen
                // (Pseudozufallsgenerator auf Wish bestellt...)
                let now = new Date()
                let prand = 85 * (now.getMonth() + 1) % 163 ^ 2042 * now.getDate(
                        ) % 9851 ^ 3874 * (now.getHours() + 1) % 8663
                easterEggText.text = easterEggTexts[prand % easterEggTexts.length]
            }
        }
    }

    states: [
        State {
            // Weil sonst aus irgendeinem weirden Grund die Buttons unsichtbar bleiben,
            // wenn der State einmal nach occupied gewechselt hat, muss hier explizit
            // visible auf true gesetzt werden und alle anderen States diesen extenden...
            name: "base"

            PropertyChanges {
                target: compGrid
                visible: true
            }
        },
        State {
            name: "deposit"
            extend: "base"

            PropertyChanges {
                target: root
                caption.text: qsTr("Wählen Sie ein freies Fach:")
            }
        },
        State {
            name: "retrieve"
            extend: "base"

            PropertyChanges {
                target: root
                caption.text: qsTr("In welchem Fach ist Ihr Akku?")
            }
        },
        State {
            name: "occupied"

            PropertyChanges {
                target: root
                caption.text: qsTr("Kein passendes Fach verfügbar")
            }

            PropertyChanges {
                target: compGrid
                visible: false
            }

            PropertyChanges {
                target: easterEggText
                visible: true
            }
        }
    ]
}
