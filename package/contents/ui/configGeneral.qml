import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
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

    QQC2.TextField {
        id: ip_to_ping
        Kirigami.FormData.label: "IP to ping:"
        placeholderText: "1.1.1.1"
    }

    QQC2.Label {
        visible: !isValidIP(ip_to_ping.text)
        text: "⚠  Invalid IP address"
        color: Kirigami.Theme.negativeTextColor
    }
}
