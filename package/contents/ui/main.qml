import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.kicker 0.1 as Kicker

import org.kde.quickcharts 1.0 as Charts


Item {
    id: root

    Plasmoid.switchWidth: PlasmaCore.Units.gridUnit * 8
    Plasmoid.switchHeight: PlasmaCore.Units.gridUnit * 8

    property var stateVal: 1
    property var customIconSource: plasmoid.file( "", "icons/unknown.svg")  // will be replaced on first measure
    property var sessionBtnText: "Start"
    property var sessionBtnIconSource: "media-playback-start"
    property string tooltipText: "Network Health paused"
    property real yMaxValue: 100
    property string messageText: ""

    Plasmoid.status: PlasmaCore.Types.PassiveStatus
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: doPing()
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        
        onNewData: {
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            
            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout, stderr);
            }
            
            exited(sourceName, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        
        function exec(cmd, onNewDataCallback) {
            if (onNewDataCallback !== undefined){
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        
        signal exited(string sourceName, string stdout, string stderr)
    }

    Plasmoid.toolTipMainText: tooltipText

    Component.onCompleted: {
        start()
    }

    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        Layout.minimumWidth: PlasmaCore.Units.iconSizes.small
        Layout.minimumHeight: PlasmaCore.Units.iconSizes.small
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: Layout.minimumHeight
        Layout.preferredWidth: root.width

        property int wheelDelta: 0

        acceptedButtons: Qt.LeftButton
        onClicked: {
            plasmoid.expanded = !plasmoid.expanded
        }

        RowLayout {
            id: row
            Layout.margins: PlasmaCore.Units.smallSpacing

            Item {
                Layout.preferredHeight: compactRoot.height
                Layout.preferredWidth: compactRoot.height

                PlasmaCore.IconItem {
                    id: mainIcon
                    height: parent.height
                    width: parent.width
                    source: customIconSource
                    smooth: true
                }
            }
        }
    }

    ListModel {
        // this will be filled with ping information
        id: listModel
    }

    Plasmoid.fullRepresentation: Item {
        id: fullRoot

        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 12
        Layout.maximumWidth: PlasmaCore.Units.gridUnit * 18
        Layout.minimumHeight: PlasmaCore.Units.gridUnit * 11
        Layout.maximumHeight: PlasmaCore.Units.gridUnit * 18

        ColumnLayout {
            anchors.fill: parent
            spacing: PlasmaCore.Units.smallSpacing

            PlasmaComponents.Label {
                id: messageLabel
                Layout.fillWidth: true
                Layout.preferredHeight: text !== "" ? implicitHeight : 0
                visible: text !== ""
                
                text: root.messageText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                id: chartArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                Charts.GridLines {
                    id: verticalLines
                    anchors.fill: lineChart
                    chart: lineChart
                    direction: Charts.GridLines.Vertical;
                    major.count: 4
                    major.lineWidth: 2
                    major.color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
                    minor.count: 4
                    minor.lineWidth: 1
                    minor.color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
                }

                Charts.AxisLabels {
                    id: yAxisLabels
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    direction: Charts.AxisLabels.VerticalBottomTop
                    delegate: PlasmaComponents.Label { 
                        text: Charts.AxisLabels.label 
                    }
                    source: Charts.ChartAxisSource { 
                        chart: lineChart
                        axis: Charts.ChartAxisSource.YAxis
                        itemCount: 6 
                    }
                }

                Charts.LineChart {
                    id: lineChart
                    
                    anchors {
                        left: yAxisLabels.right
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    
                    antialiasing: true
                    colorSource: Charts.SingleValueSource { value: "#0000ff" }
                    nameSource: Charts.SingleValueSource { value: "Network Latency" }
                    
                    valueSources: [
                        Charts.ModelSource {
                            model: listModel  // Esto funciona porque está en el mismo scope
                            roleName: "value1"
                        }
                    ]
                    
                    xRange {
                        from: 0
                        to: 30
                        automatic: false
                    }
                    
                    yRange {
                        from: 0
                        to: root.yMaxValue
                        automatic: false
                    }
                }
            }


            PlasmaComponents.Button {
                id: sessionBtn
                Layout.alignment: Qt.AlignHCenter
                text: sessionBtnText
                implicitWidth: minimumWidth
                iconSource: sessionBtnIconSource
                onClicked: {
                    if (sessionBtnText == "Start") {
                        start()
                    } else {
                        pause()
                    }
                }
            }
        }
    }

    function start() {
        timer.start()
        sessionBtnText = "Pause"
        sessionBtnIconSource = "media-playback-pause"
        Plasmoid.status = PlasmaCore.Types.ActiveStatus

    }

    function pause() {
        timer.stop()
        tooltipText = "Network Health paused"
        sessionBtnText = "Start"
        customIconSource = plasmoid.file("", "icons/unknown.svg")  // will remain in "?" if not running
        sessionBtnIconSource = "media-playback-start"
    }

    function computeYMax() {
        var maxVal = 0
        for (var i = 0; i < listModel.count; i++) {
            if (listModel.get(i).value1 > maxVal) {
                maxVal = listModel.get(i).value1
            }
        }
        // round up to multiples of 5
        return Math.ceil(maxVal / 5) * 5
    }

    function refreshState(latency) {
        
        // add to the model and keep last 30
        listModel.append({value1: latency})
        while (listModel.count > 30) {
            listModel.remove(0)
        }
        yMaxValue = computeYMax()

        // set up icon according to levels
        if (latency == 0) {
            // special case of not connection at all
            tooltipText = "No connection"
            customIconSource = plasmoid.file("", "icons/health-broken.svg")
        }
        else if (latency < 10) {
            tooltipText = "Excellent: " + latency + " ms"
            customIconSource = plasmoid.file("", "icons/health-ok.svg")
        }
        else if (latency < 100) {
            tooltipText = "Poor: " + latency + " ms"
            customIconSource = plasmoid.file("", "icons/health-warning.svg")
        }
        else if (latency < 1000) {
            tooltipText = "Bad: " + latency + " ms"
            customIconSource = plasmoid.file("", "icons/health-problem.svg")
        }
        else {
            tooltipText = "Horrible: " + latency + " ms"
            customIconSource = plasmoid.file("", "icons/health-broken.svg")
        }

    }

    function doPing() {
        // execute ping script 
        var scriptPath = plasmoid.file("", "pinger.py")
        executable.exec("python3 " + scriptPath, function(stdout, stderr) {

            if (stderr && stderr.trim() !== "") {
                messageText = "Internal error, traceback in /tmp/nethealth-error.txt"
                var encoded = Qt.btoa(stderr)
                executable.exec("python3  -c \"import base64; open('/tmp/nethealth-error.txt', 'wb').write(base64.b64decode('" + encoded + "'.encode()))\" ")
                customIconSource = plasmoid.file("", "icons/error.svg")
                pause()
                return
            }

            var output = stdout.trim()
            var latency = parseInt(output)

            if (isNaN(latency)) {
                messageText = "Internal error, wasn't able to convert" + output
                customIconSource = plasmoid.file("", "icons/error.svg")
                pause()
                return
            }
            refreshState(latency)
        })
    }
}
