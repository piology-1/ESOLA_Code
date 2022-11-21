import QtQuick 2.15
import QtQuick.Window 2.15
import "./qml"

Window {
    width: Constants.width
    height: Constants.height
    visible: true
    title: "Solartankstelle"

    App {
        id: app
        objectName: "app"
    }
}
