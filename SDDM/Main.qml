/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtGraphicalEffects 1.15
import QtQuick 2.0
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import SddmComponents 2.0
import "components"

Rectangle {
    // Button {
    //     id: shutdownButton
    //     anchors.bottom: parent.bottom
    //     x: 1550
    //     text: "&#xf011;"
    //     onClicked: sddm.powerOff()
    //     KeyNavigation.backtab: loginButton
    //     KeyNavigation.tab: rebootButton
    // }
    // Button {
    //     id: rebootButton
    //     anchors.bottom: parent.bottom
    //     x: 900
    //     text: textConstants.reboot
    //     onClicked: sddm.reboot()
    //     KeyNavigation.backtab: shutdownButton
    //     KeyNavigation.tab: name
    // }

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

    width: 640
    height: 480
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

        source: "fonts/perpetua.ttf" // Relative path to your font
    }

    Item {
        id: clock

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.rightMargin: 190
        width: 200
        height: 100

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

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 250
        anchors.rightMargin: 190
        width: 200
        height: 100

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

        width: 250
        height: 30
        text: userModel.lastUser
        radius: 5
        font.pixelSize: 15
        x: 1190
        y: 350
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

        width: 250
        height: 30
        font.pixelSize: 14
        radius: 5
        x: 1190
        y: 400
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
        width: 250
        x: 1190
        y: 450
        onClicked: sddm.login(username.text, password.text, sessionIndex)
        KeyNavigation.backtab: layoutBox
        KeyNavigation.tab: shutdownButton
    }

    ComboBox {
        // KeyNavigation.backtab: password
        // KeyNavigation.tab: layoutBox

        id: session

        z: 100
        x: 1190
        y: 550
        width: 250
        height: 30
        font.pixelSize: 14
        arrowIcon: "angle-down.png"
        model: sessionModel
        index: sessionModel.lastIndex
    }

    Item {
        width: 55
        height: 55
        x: 1530
        y: 830

        Image {
            id: powerImage

            source: "/home/farhan/HollowKnightProject/LoginPage/HK/assets/power.png"
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
        x: 1460
        y: 831

        Image {
            id: resartImage

            source: "/home/farhan/HollowKnightProject/LoginPage/HK/assets/restart.png"
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

    Rectangle {
        id: content

        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: rectangle

            color: "transparent"
            //anchors.centerIn: parent
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(320, mainColumn.implicitWidth + 300)
            height: Math.max(320, mainColumn.implicitHeight + 50)

            Column {
                id: mainColumn

                anchors.centerIn: parent
                spacing: 12

                Row {
                    property int btnWidth: Math.max(loginButton.implicitWidth, shutdownButton.implicitWidth, rebootButton.implicitWidth, 80) + 8

                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    // Column {
                    //     z: 100
                    //     width: parent.width * 1.3
                    //     spacing: 4
                    //     anchors.bottom: parent.bottom
                    //     Text {
                    //         id: lblSession
                    //         width: parent.width
                    //         text: textConstants.session
                    //         wrapMode: TextEdit.WordWrap
                    //         font.bold: true
                    //         font.pixelSize: 12
                    //     }
                    //     ComboBox {
                    //         id: session
                    //         width: parent.width
                    //         height: 30
                    //         font.pixelSize: 14
                    //         arrowIcon: "angle-down.png"
                    //         model: sessionModel
                    //         index: sessionModel.lastIndex
                    //         KeyNavigation.backtab: password
                    //         KeyNavigation.tab: layoutBox
                    //     }
                    // }

                    spacing: 4
                    width: parent.width / 2
                    z: 100
                }

            }

        }

    }

}
