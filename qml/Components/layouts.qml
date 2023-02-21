import QtQuick.Shapes 1.12

import QtQml 2.2
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Window {
    id: root
    width: 320
    height: 100
    visible: true
    color: "#232323"

    Row {
        anchors.centerIn: parent
        spacing: 8

        Shape {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16

            layer.enabled: true
            layer.smooth: true
            layer.samples: 4

            ShapePath {
                strokeColor: "#c4a469"
                strokeWidth: 1
                fillColor: "transparent"
                PathSvg { path: "M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z" }
                PathSvg { path: "M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z" }
            }
        }

        ThinProgressBar { id: progressBar }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            color: "white"
            text: Math.trunc(progressBar.value * 100) + "%"
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (progressBar.value < 1)
                progressBar.value += 0.01
            else
                progressBar.value = 0
        }
    }
}
