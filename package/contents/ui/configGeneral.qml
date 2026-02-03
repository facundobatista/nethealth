import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
    id: configPage

    property alias cfg_ip_to_ping: ip_to_ping.text

    function isValidIP(ip) {
        if (!ip || ip.trim() === "") {
            return false
        }
        
        var ipv4Regex = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
        var match = ip.match(ipv4Regex)
        
        if (!match) {
            return false
        }
        
        for (var i = 1; i <= 4; i++) {
            var octet = parseInt(match[i])
            if (octet < 0 || octet > 255) {
                return false
            }
        }
        
        return true
    }

    GroupBox {
        Layout.fillWidth: true

        ColumnLayout {
            width: parent.width

            RowLayout {
                Label {
                    text: "IP to ping: "
                }

                TextField {
                    id: ip_to_ping
                    Layout.fillWidth: true
                    enabled: true
                    placeholderText: "1.1.1.1"
                }

                Label {
                    Layout.fillWidth: true
                    visible:  !isValidIP(ip_to_ping.text)
                    text: "⚠  Invalid IP address"
                    color: "red"
                }
            }
        }
    }
}
