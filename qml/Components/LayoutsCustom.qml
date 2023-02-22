import QtQuick 2.5
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import Lomiri.Components 1.1

GroupBox {
    id: boderShadow
    property string buttonValue
    visible: true

    background: Rectangle {
        y: boderShadow.topPadding - boderShadow.bottomPadding
        width: parent.width
        height: parent.height - boderShadow.topPadding + boderShadow.bottomPadding
        color: "white"
        border.color: "transparent"
        radius: units.gu(1)
    }

    Rectangle
    {
        id:img
        anchors.centerIn: parent
        height: parent.height
        width: parent.width
        radius: units.gu(2)
        color: "grey"
        border.color: "white"
        border.width: units.gu(1.75)
        visible: false

    }

    FastBlur
    {
        anchors.fill: parent
        source: img
        radius: units.gu(2)
    }

    Rectangle
    {
        id:rect
        height: parent.height - units.gu(3)
        width: parent.width - units.gu(3)
        anchors.centerIn: parent
        color:"white"
        radius: units.gu(1)
        Text {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            text: buttonValue
        }
    }
}
