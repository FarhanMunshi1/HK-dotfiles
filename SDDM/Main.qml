// Test command:    QT_QPA_PLATFORM=xcb XDG_SEAT=seat0 XDG_SESSION_TYPE=x11 sddm-greeter --test-mode --theme {Path to directory}

import QtGraphicalEffects 1.15
import QtQuick 2.0
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import SddmComponents 2.0
import "components"

Rectangle {
    id: container

    property int sessionIndex: session.index

    function getFormattedDate() {
        const date = new Date();
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"];
        const dayName = days[date.getDay()];
        const dayNumber = date.getDate();
        const monthName = months[date.getMonth()];
        const suffix = getOrdinalSuffix(dayNumber);
        return `${dayName} ${dayNumber}${suffix} ${monthName}`;
    }

    function getOrdinalSuffix(n) {
        if (n >= 11 && n <= 13)
            return "th";

        switch (n % 10) {
        case 1:
            return "st";
        case 2:
            return "nd";
        case 3:
            return "rd";
        default:
            return "th";
        }
    }

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    Component.onCompleted: {
        if (name.text == "")
            name.focus = true;
        else
            password.focus = true;
    }

    TextConstants {
        id: textConstants
    }

    Connections {
        target: sddm
        onLoginSucceeded: {
            errorMessage.color = "steelblue";
            errorMessage.text = textConstants.loginSucceeded;
        }
        onLoginFailed: {
            password.text = "";
            errorMessage.color = "red";
            errorMessage.text = textConstants.loginFailed;
        }
        onInformationMessage: {
            errorMessage.color = "red";
            errorMessage.text = message;
        }
    }

    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground)
                source = config.defaultBackground;

        }
    }

    FontLoader {
        id: perpetua

        source: "fonts/perpetua.ttf"
    }

    Item {
        id: clock

        width: 200
        height: 100
        x: 1500
        y: 200

        Text {
            id: clockLabel

            font.family: perpetua.name
            text: Qt.formatDateTime(new Date(), "hh:mm")
            font.pixelSize: 120
            color: "white"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Timer {
            id: clockTimer

            interval: 60000
            running: true
            repeat: true
            onTriggered: {
                clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm");
            }
        }

    }

    Item {
        id: date

        width: 200
        height: 100
        x: 1500
        y: 250

        Text {
            anchors.centerIn: parent
            font.pixelSize: 30
            font.family: perpetua.name
            color: "white"
            text: getFormattedDate()
        }

    }

    TextBox {
        id: username

        width: 300
        height: 30
        text: userModel.lastUser
        radius: 5
        font.pixelSize: 15
        x: 1450
        y: 400
        KeyNavigation.backtab: rebootButton
        KeyNavigation.tab: password
        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sddm.login(username.text, password.text, sessionIndex);
                event.accepted = true;
            }
        }
    }

    PasswordBox {
        id: password

        width: 300
        height: 30
        font.pixelSize: 15
        radius: 5
        x: 1450
        y: 450
        KeyNavigation.backtab: name
        KeyNavigation.tab: session
        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sddm.login(username.text, password.text, sessionIndex);
                event.accepted = true;
            }
        }
    }

    Button {
        id: loginButton

        text: "Login"
        font.family: perpetua.name
        font.pixelSize: 16
        width: 300
        x: 1450
        y: 500
        onClicked: sddm.login(username.text, password.text, sessionIndex)
        KeyNavigation.backtab: layoutBox
        KeyNavigation.tab: shutdownButton
    }

    ComboBox {
        // KeyNavigation.backtab: password
        // KeyNavigation.tab: layoutBox

        id: session

        z: 100
        x: 1450
        y: 600
        width: 300
        height: 30
        font.pixelSize: 14
        arrowIcon: "angle-down.png"
        model: sessionModel
        index: sessionModel.lastIndex
    }

    Item {
        width: 55
        height: 55
        x: 1820
        y: 1000

        Image {
            id: powerImage

            source: "assets/power.png"
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            width: 55
            height: 55
        }

        MouseArea {
            anchors.fill: parent
            onClicked: sddm.powerOff()
            hoverEnabled: true
            onEntered: powerImage.opacity = 0.7
            onExited: powerImage.opacity = 1
            KeyNavigation.backtab: loginButton
            KeyNavigation.tab: rebootButton
        }

    }

    Item {
        width: 55
        height: 55
        x: 1750
        y: 1000

        Image {
            id: resartImage

            source: "assets/restart.png"
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            width: 55
            height: 55
        }

        MouseArea {
            anchors.fill: parent
            onClicked: sddm.reboot()
            hoverEnabled: true
            onEntered: resartImage.opacity = 0.7
            onExited: resartImage.opacity = 1
            KeyNavigation.backtab: loginButton
            KeyNavigation.tab: rebootButton
        }

    }

}
