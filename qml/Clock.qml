import QtQuick 2.15

ClockForm {
    function updateTime() {
        time.text = Qt.formatTime(new Date(), "hh:mm")
        date.text = Qt.formatDateTime(new Date(), "dddd, dd.MM.yyyy")
    }

    Timer {
        id: nextMinuteTimer
        running: false
        triggeredOnStart: true
        repeat: true
        onTriggered: function() {
            var nowMillisec = new Date()
            var nowMinute = new Date(nowMillisec)
            nowMinute.setSeconds(0)
            nowMinute.setMilliseconds(0)

            var millisecToNextMinute = 60000 - (nowMillisec - nowMinute)

            // 20 msec Verzögerung, damit Qt-Uhr dann auch sicher schon auf nächster Minute steht
            interval = millisecToNextMinute + 20

            updateTime()
        }
    }

    Component.onCompleted: function() {
        nextMinuteTimer.start()
    }
}

/*##^##
Designer {
    D{i:0;height:200;width:500}
}
##^##*/
