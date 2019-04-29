/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2016 Kai Uwe Broulik <kde@privat.broulik.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/

import QtQuick 2.5
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: mediaControl
    state: lockScreenRoot.uiVisible ? "mcon" : "mcoff"
    visible: mpris2Source.hasPlayer
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: controlsRow.height + controlsRow.y
    states: [
        State {
            name: "mcon"

            /* PropertyChanges { */
            /*     target: mediaControl */
            /*     y: 0 */
            /* } */

            PropertyChanges {
                target: mediaControl
                opacity: 1
            }
        },
        State {
            name: "mcoff"

            /* PropertyChanges { */
            /*     target: mediaControl */
            /*     y: 40 */
            /* } */

            PropertyChanges {
                target: mediaControl
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "mcoff"
            to: "mcon"
            /* PathAnimation { */
            /*     target: controlsRow */
            /*     easing.type: Easing.OutQuart */
            /*     duration: 550 */
            /*     path: Path { */
            /*         startY: controlsRow.y+10 */
            /*         PathLine {} */
            /*     } */
            /* } */
            SequentialAnimation {
                PauseAnimation {
                    duration: 450
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: mediaControl
                        property: "y"
                        duration: 500
                        from: 40
                        to: 0
                        /* easing.type: Easing.InOutQuad */
                        easing.type: Easing.OutQuart
                    }
                    NumberAnimation {
                        target: mediaControl
                        property: "opacity"
                        duration: 500
                        /* easing.type: Easing.InOutQuad */
                        easing.type: Easing.OutQuart

                    }
                }
            }
        },
        Transition {
            from: "mcon"
            to: "mcoff"
            /* PathAnimation { */
            /*     target: controlsRow */
            /*     easing.type: Easing.OutQuart */
            /*     duration: 500 */
            /*     path: Path { */
            /*         /\* startX: passwordBox.x; startY: passwordBox.y+10 *\/ */
            /*         PathLine {y: controlsRow.y+10} */
            /*     } */
            /* } */
            SequentialAnimation {
                PauseAnimation {
                    duration: 450
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: mediaControl
                        property: "y"
                        duration: 500
                        from: 0
                        to: -40
                        /* easing.type: Easing.InOutQuad */
                        easing.type: Easing.OutQuart

                    }
                    NumberAnimation {
                        target: mediaControl
                        property: "opacity"
                        duration: 500
                        /* easing.type: Easing.InOutQuad */
                        easing.type: Easing.OutQuart

                    }
                }
            }
        }
    ]

    RowLayout {
        id: controlsRow
        /* state: lockScreenRoot.uiVisible ? "mcon" : "mcoff" */
        /* anchors.bottom: parent.bottom */
        anchors.horizontalCenter: parent.horizontalCenter
        y: units.smallSpacing // some distance to the password field
        /* width: parent.width */
        width: units.gridUnit * 14
        height: units.gridUnit * 3
        spacing: 0

        enabled: mpris2Source.canControl


        PlasmaCore.DataSource {
            id: mpris2Source

            readonly property string source: "@multiplex"
            readonly property var playerData: data[source]

            readonly property bool hasPlayer: sources.length > 1 && !!playerData
            readonly property string identity: hasPlayer ? playerData.Identity : ""
            readonly property bool playing: hasPlayer && playerData.PlaybackStatus === "Playing"
            readonly property bool canControl: hasPlayer && playerData.CanControl
            readonly property bool canGoBack: hasPlayer && playerData.CanGoPrevious
            readonly property bool canGoNext: hasPlayer && playerData.CanGoNext

            readonly property var currentMetadata: hasPlayer ? playerData.Metadata : ({})

            readonly property string track: {
                var xesamTitle = currentMetadata["xesam:title"]
                if (xesamTitle) {
                    return xesamTitle
                }
                // if no track title is given, print out the file name
                var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
                if (!xesamUrl) {
                    return ""
                }
                var lastSlashPos = xesamUrl.lastIndexOf('/')
                if (lastSlashPos < 0) {
                    return ""
                }
                var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
                return decodeURIComponent(lastUrlPart)
            }
            readonly property string artist: currentMetadata["xesam:artist"] || ""
            readonly property string albumArt: currentMetadata["mpris:artUrl"] || ""

            engine: "mpris2"
            connectedSources: [source]

            function startOperation(op) {
                var service = serviceForSource(source)
                var operation = service.operationDescription(op)
                return service.startOperationCall(operation)
            }

            function goPrevious() {
                startOperation("Previous");
            }
            function goNext() {
                startOperation("Next");
            }
            function playPause(source) {
                startOperation("PlayPause");
            }
        }

        Image {
            id: albumArt
            Layout.preferredWidth: height
            Layout.fillHeight: true
            asynchronous: true
            source: mpris2Source.albumArt
            sourceSize: Qt.size(width, height)
            visible: status === Image.Loading || status === Image.Ready
        }

        Item { // spacer
            width: units.smallSpacing
            height: 1
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            PlasmaExtras.Heading {
                Layout.fillWidth: true
                level: 4
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                text: mpris2Source.track || i18n("No media playing")
                textFormat: Text.PlainText
            }

            PlasmaExtras.Heading {
                Layout.fillWidth: true
                level: 5
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                // if no artist is given, show player name instead
                text: mpris2Source.artist || mpris2Source.identity || ""
                textFormat: Text.PlainText
            }
        }

        PlasmaComponents.ToolButton {
            enabled: mpris2Source.canGoBack
            iconName: LayoutMirroring.enabled ? "media-skip-forward" : "media-skip-backward"
            onClicked: mpris2Source.goPrevious()
            visible: mpris2Source.canGoBack || mpris2Source.canGoNext
            Accessible.name: i18n("Previous track")
        }

        PlasmaComponents.ToolButton {
            Layout.fillHeight: true
            Layout.preferredWidth: height // make this button bigger
            iconName: mpris2Source.playing ? "media-playback-pause" : "media-playback-start"
            onClicked: mpris2Source.playPause()
            Accessible.name: i18n("Play or Pause media")
        }

        PlasmaComponents.ToolButton {
            enabled: mpris2Source.canGoNext
            iconName: LayoutMirroring.enabled ? "media-skip-backward" : "media-skip-forward"
            onClicked: mpris2Source.goNext()
            visible: mpris2Source.canGoBack || mpris2Source.canGoNext
            Accessible.name: i18n("Next track")
        }
    }
}
