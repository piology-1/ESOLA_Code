pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int topBarHeight: 120

    readonly property int pinButtonSize: 140
    readonly property int pinButtonSpace: 15

    readonly property int compButtonSize: 220
    readonly property int compButtonSpace: 20

    readonly property int finishScreenDuration: 15 * 1000
    readonly property int standbyTimeout: 60 * 1000

    readonly property FontLoader mainFont:  FontLoader { source: "../fonts/TitilliumWeb-Light.ttf"; id: mainFont }
    readonly property FontLoader clockFont: FontLoader { source: "../fonts/Jura-Regular.ttf" }
    readonly property FontLoader monoFont: FontLoader { source: "../fonts/OverpassMono-Regular.ttf" }
    readonly property alias fontFamily: mainFont.name

    readonly property color backgroundColor: "#cad5d2"
    readonly property color buttonColor: "#dd3b51"
}
