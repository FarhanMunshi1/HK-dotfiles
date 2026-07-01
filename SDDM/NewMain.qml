import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0
import "components"

Rectangle {
    id: root

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: config.backgroundColor ? config.backgroundColor : "#000000"

    property int sessionIndex: session.currentIndex

    function ordinalSuffix(n) {
        if (n >= 11 && n <= 13)
            return "th";

        switch (n % 10) {
        case 1: return "st";
        case 2: return "nd";
        case 3: return "rd";
        default: return "th";
        }
    }

    function formattedDate() {
        var d = new Date();
        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return days[d.getDay()] + " " + d.getDate() + ordinalSuffix(d.getDate()) + " " + months[d.getMonth()];
    }

    TextConstants {
        id: textConstants
    }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "steelblue";
            errorMessage.text = textConstants.loginSucceeded;
        }

        function onLoginFailed() {
            password.text = "";
            errorMessage.color = "red";
            errorMessage.text = textConstants.loginFailed;
            password.forceActiveFocus();
        }

        function onInformationMessage(message) {
            errorMessage.color = "red";
            errorMessage.text = message;
        }
    }

    Background {
        id: bg
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop

        onStatusChanged: {
            if (status === Image.Error && source !== config.defaultBackground)
                source = config.defaultBackground;
        }
    }

    FontLoader {
        id: perpetua
        source: "fonts/perpetua.ttf"
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm");
            dateLabel.text = formattedDate();
        }
    }

    Item {
        id: clockArea
        x: 1500
        y: 200
        width: 300
        height: 180

        Text {
            id: clockLabel
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: perpetua.name
            font.pixelSize: 120
            color: "white"
            text: Qt.formatDateTime(new Date(), "hh:mm")
        }

        Text {
            id: dateLabel
            anchors.top: clockLabel.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: perpetua.name
            font.pixelSize: 30
            color: "white"
            text: formattedDate()
        }
    }

    TextBox {
        id: username
        width: 300
        height: 30
        x: 1450
        y: 400
        text: userModel.lastUser
        radius: 5
        font.pixelSize: 15
        KeyNavigation.backtab: session
        KeyNavigation.tab: password
        onAccepted: sddm.login(username.text, password.text, sessionIndex)
    }

    PasswordBox {
        id: password
        width: 300
        height: 30
        x: 1450
        y: 450
        radius: 5
        font.pixelSize: 15
        focus: userModel.lastUser === ""
        KeyNavigation.backtab: username
        KeyNavigation.tab: loginButton
        onAccepted: sddm.login(username.text, password.text, sessionIndex)
    }

    Button {
        id: loginButton
        x: 1450
        y: 500
        width: 300
        text: "Login"
        font.family: perpetua.name
        font.pixelSize: 16
        onClicked: sddm.login(username.text, password.text, sessionIndex)
        KeyNavigation.backtab: password
        KeyNavigation.tab: session
    }

    ComboBox {
        id: session
        x: 1450
        y: 560
        width: 300
        height: 30
        font.pixelSize: 14
        model: sessionModel
        index: sessionModel.lastIndex
        arrowIcon: "angle-down.png"
        focus: false
        KeyNavigation.backtab: loginButton
        KeyNavigation.tab: shutdownButton
    }

    Text {
        id: errorMessage
        x: 1450
        y: 610
        width: 300
        height: 30
        color: "red"
        font.pixelSize: 14
        wrapMode: Text.WordWrap
        text: ""
    }

    Item {
        id: shutdownButton
        x: 1820
        y: 1000
        width: 55
        height: 55

        Image {
            id: powerImage
            anchors.centerIn: parent
            width: 55
            height: 55
            fillMode: Image.PreserveAspectFit
            source: "assets/power.png"
            opacity: 1.0
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: sddm.powerOff()
            onEntered: powerImage.opacity = 0.7
            onExited: powerImage.opacity = 1.0
        }
    }

    Item {
        id: rebootButton
        x: 1750
        y: 1000
        width: 55
        height: 55

        Image {
            id: restartImage
            anchors.centerIn: parent
            width: 55
            height: 55
            fillMode: Image.PreserveAspectFit
            source: "assets/restart.png"
            opacity: 1.0
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: sddm.reboot()
            onEntered: restartImage.opacity = 0.7
            onExited: restartImage.opacity = 1.0
        }
    }

    Component.onCompleted: {
        if (username.text === "")
            username.forceActiveFocus();
        else
            password.forceActiveFocus();
    }
}
