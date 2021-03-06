/*
  Copyright (C) 2014 Marcus Soll
  Copyright (C) 2013 Jolla Ltd.
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: test

    Item {
        id: variable
        property int questions: 0
        property int correct: 0
        property int rightanswer: 0
        property bool started: false
        property bool enableButton: true
        property bool first: true
        property string picture: "Hiragana/empty.png"
        property string valuecorrect: ""
        property int sumCorrect: save.getInt("FreeTestCorrect")
        property int sumQuestions: save.getInt("FreeTestQuestions")
    }

    Item {
        id: handleQuestions

        function start(){
            if(!variable.started || (save.getBool("CorrectDisabled") && save.getBool("NextAfterCorrect")))
            {
                variable.started = true
                variable.enableButton = false
                variable.first = false
                testclass.newQuestion()
                variable.picture = testclass.picture()
                variable.valuecorrect = testclass.valuecorrect()
                input.placeholderText = "answer"
                input.text = ""
                input.forceActiveFocus()
            }

        }


        function end(){
            variable.questions++
            variable.sumQuestions++
            var correct = false
            if(testclass.sameString(variable.valuecorrect, input.text))
            {
                variable.correct++
                variable.sumCorrect++
                correct = true
            }
            save.saveInt("FreeTestQuestions",variable.sumQuestions)
            save.saveInt("FreeTestCorrect",variable.sumCorrect)
            if(correct)
            {
                if(save.getBool("CorrectDisabled"))
                {
                    if(save.getBool("NextAfterCorrect"))
                    {
                        handleQuestions.start()
                    }
                    else
                    {
                        variable.started = false
                        variable.enableButton = true
                    }
                }
                else
                {
                    variable.started = false
                    correctPanel.show()
                }
            }
            else
            {
                if(save.getBool("WrongDisabled"))
                {
                    variable.started = false
                    variable.enableButton = true
                }
                else
                {
                    variable.started = false
                    falsePanel.show()
                }
            }
        }
    }

    SilicaFlickable {

        PullDownMenu {
            visible: false
        }

        anchors.fill: parent

        contentHeight: mainColumn.height

        Column {
            id: mainColumn

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: "Free Test"
            }

            Row {
                Label {
                    text: "Questions: " + variable.questions + "   "
                }

                Label {
                    text: "Correct: " + variable.correct + "   "
                }

                Label{
                    text: "Ratio: " + (variable.questions === 0?0:(Math.round(100.0/variable.questions*variable.correct))) + "%"
                }
            }

            Row {
                Label {
                    text: "Overall Questions: " + variable.sumQuestions + "   "
                    font.pixelSize: Theme.fontSizeTiny
                }

                Label {
                    text: "Overall Correct: " + variable.sumCorrect + "   "
                    font.pixelSize: Theme.fontSizeTiny
                }

                Label{
                    text: "Ratio: " + (variable.sumQuestions === 0?0:(Math.round(100.0/variable.sumQuestions*variable.sumCorrect))) + "%"
                    font.pixelSize: Theme.fontSizeTiny
                }
            }

            Row {
                x: parent.width/2 - (target.width + target2.width)/2
                Image {
                    id: target
                    source: variable.picture
                }
                Label {
                    id: target2
                    visible: !variable.started
                    text: variable.valuecorrect
                    font.pixelSize: Theme.fontSizeHuge
                }
            }

            TextField {
                id: input
                placeholderText: ""
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: handleQuestions.end()
                width: mainColumn.width
                enabled: variable.started
                font.capitalization: Font.AllLowercase
                inputMethodHints: Qt.ImhNoPredictiveText
            }

            Button {
                id: newQuestion
                width: parent.width
                enabled: variable.enableButton
                text: variable.first?"Start":"Continue"
                onClicked: handleQuestions.start()
            }
        }
    }

    UpperPanel {
        id: correctPanel
        time: save.getInt("TimeCorrect") === 0 ? 2000: save.getInt("TimeCorrect")
        color: "green"
        text: "Correct"
        onTriggered: save.getBool("NextAfterCorrect")? handleQuestions.start() : variable.enableButton = true
    }

    UpperPanel {
        id: falsePanel
        time: save.getInt("TimeWrong") === 0 ? 2000 : save.getInt("TimeWrong")
        color: "red"
        text: "Wrong"
        onTriggered: variable.enableButton = true
    }
}

