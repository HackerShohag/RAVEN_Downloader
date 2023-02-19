import QtQml 2.2
import QtQuick 2.7
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('RAVEN Downloader')
        }

        ColumnLayout {
            spacing: units.gu(2)


            RowLayout {
                id: urlContainer
                Layout.margins: units.gu(1)

                TextField {
                    id: urlField
                    Layout.fillHeigth: true
                    Layout.alignment: Qt.AlignLeft
                    font.family: "Tahoma"
                    font.italic: true

                    placeholderText: qsTr("Enter your link")
                    focus: true
                    // Keys.onReturnPressed: root.getLinksQML(urlField.text)

                }
                Button {
                    id: submitButton
                    highlighted: true
                    text: "Submit"
                    // onClicked: root.getLinksQML(urlField.text)
                }
            }
        }
    }
}
