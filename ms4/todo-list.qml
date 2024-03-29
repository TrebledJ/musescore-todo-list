import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0

MuseScore {
    id: plugin
    description: "Scans the score for TODO and FIXME text elements."
    version: "4.0.0"
    menuPath: "Plugins.To-Do List"
    
    title: qsTr("To-Do List")
    categoryCode: "composing-arranging-tools"

    pluginType: "dialog"
    // dockArea: "right"
    requiresScore: false

    width: 400
    height: 600

    property bool continuousRefresh: true

    // Filter properties.
    property var filterRegexp: /^(todo|fixme)/i
    property bool filterCaseInsensitive: true
    property var filterElements: [Element.STAFF_TEXT, Element.SYSTEM_TEXT]

    property var prevScore: null
    property var prevLayoutTick: null

    onRun: {
        if (!curScore)
            return;

        prevScore = curScore;
        analyseTodos();
    }

    onScoreStateChanged: {
        // console.log(JSON.stringify(state));
        var reanalyse = false;
        if (!curScore.is(prevScore)) {
            // Caveat: only triggered when something is clicked, not when the score is changed.
            prevScore = curScore;
            reanalyse = true;
        } else {
            if (continuousRefresh) {
                if (state.selectionChanged)
                    reanalyse = true;
                else if (state.startLayoutTick === state.endLayoutTick) {
                    if (state.startLayoutTick === -1 && state.startLayoutTick != prevLayoutTick)
                        reanalyse = true;
                    prevLayoutTick = state.startLayoutTick;
                }
            }
        }
        
        if (reanalyse) {
            analyseTodos();
        }
    }

    /**
     * Find and filter all text elements according to the filter properties.
     */
    function analyseTodos()
    {
        todosModel.clear();

        var cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);

        for (var mIndex = 0, m = cursor.measure; m; m = m.nextMeasure, mIndex++) {
            for (var segIndex = 0, seg = m.firstSegment; seg; seg = seg.nextInMeasure, segIndex++) {
                for (var i = 0; i < seg.annotations.length; i++) {
                    var e = seg.annotations[i];
                    if (filterTodo(e)) {
                        // Found a match, push into list.
                        var record = {
                            todoText: processTodo(e.text),
                            todoSegmentIndex: segIndex,
                            todoMeasureIndex: mIndex,
                            todoPart: e.staff.part.partName,
                            // todoElement: e, // See Note [Storing Element Objects]
                        };
                        todosModel.append(record);

                        console.log("text: %1  /  %2 - mm. %3 /  tick: %4".arg(record.todoText).arg(record.todoPart).arg(record.todoMeasureIndex + 1).arg(seg.tick));
                        // console.log("tick: %1,  time: %2,   tempo: %3".arg(cursor.tick).arg(cursor.time).arg(cursor.tempo));
                    }
                }
            }
        }
    }

    /**
     * Returns true if the given element should be labelled as a TODO.
     */
    function filterTodo(element)
    {
        return element.text && element.text.match(plugin.filterRegexp) 
                && includes(plugin.filterElements, element.type);
    }

    /**
     * Strip any meta text. We'll keep it simple and just try to chop off the first word.
     */
    function processTodo(text)
    {
        return text.split(" ").slice(1).join(" ") || text;
    }

    /**
     * Jump to a todo element at a given index.
     */
    function gotoTodo(index)
    {
        console.log("going to todo", index);
        var item = todosModel.get(index);
        curScore.selection.clear();
        var element = findTodo(item);
        if (!continuousRefresh && !element) {
            // We should only need to try rediscover it if continuousRefresh is turned off.
            console.warn("could not recover element!");
            console.warn("reanalysing and retrying...");
            analyseTodos();
            element = findTodo(item);
        }
        if (!element) {
            console.warn("could not recover element :(");
            return;
        }
        var result = curScore.selection.select(element);
        console.log("selection result:", result);
        cmd("reset"); // Repaint canvas.
        cmd("note-input"); // Janky code. X(
        cmd("note-input");
    }

    function findTodo(item)
    {
        var cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        for (var i = 0; i < item.todoMeasureIndex; cursor.nextMeasure(), i++);
        var seg = cursor.measure.firstSegment;
        for (var i = 0; i < item.todoSegmentIndex; seg = seg.nextInMeasure, i++);
        for (var i = 0; i < seg.annotations.length; i++) {
            var e = seg.annotations[i];
            if (e.text && e.text.endsWith(item.todoText)) {
                return e;
            }
        }
        return null;
    }

    function includes(array, element)
    {
        for (var i = 0; i < array.length; i++) {
            if (array[i] === element)
                return true;
        }
        return false;
    }

    ListModel {
        id: todosModel
    }

    // SystemPalette { id: palette; colorGroup: SystemPalette.Active }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            Layout.fillWidth: true
            text: qsTr("No items were found! Your to-do list is clean!")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            visible: todosModel.count === 0
        }

        ListView {
            id: todosView
            // anchors.fill: parent
            // width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 15

            model: todosModel

            delegate: Component {
                Rectangle {
                    width: parent.width
                    height: itemColumnLayout.childrenRect.height
                    color: "transparent"

                    RowLayout {
                        width: parent.width

                        ColumnLayout {
                            id: itemColumnLayout
                            spacing: 5
                            width: parent.width

                            Label {
                                Layout.fillWidth: true
                                text: todoText || "(empty)"
                                wrapMode: Text.Wrap
                                font.pixelSize: 12
                                // TODO: limit to 15? words. Put rest into a tooltip.
                                // color: palette.windowText
                                // elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: "%1 - mm. %2".arg(todoPart).arg(todoMeasureIndex + 1)
                                font.pixelSize: 11
                                // wrapMode: Text.Wrap
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: btn
                            text: qsTr("Jump")
                            onClicked: gotoTodo(index)
                        }
                    }
                }
            }
        }

        RowLayout {
            width: parent.width

            Button {
                Layout.fillWidth: true
                text: qsTr("Refresh")
                onClicked: analyseTodos()
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Settings")
                onClicked: {
                    // Fill in existing values.
                    dRefreshCheckbox.checkedState = settings.refresh ? Qt.Checked : Qt.Unchecked;
                    dRegexp.text = settings.regexp.source;
                    dCaseInsensitiveCheckBox.checkedState = settings.caseInsensitive ? Qt.Checked : Qt.Unchecked;
                    dElements.text = settings.elements.join(",");
                    dWidth.text = settings.width;
                    dHeight.text = settings.height;
                    dialog.open();
                }
            }
        }
    }

    Dialog {
        id: dialog
        title: qsTr("Settings")
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            console.log("settings accepted")

            // Update settings with dialog values.
            settings.refresh = dRefreshCheckbox.checkedState === Qt.Checked;
            
            var i = dCaseInsensitiveCheckBox.checkedState == Qt.Checked;
            settings.caseInsensitive = i;

            var regexp = dRegexp.text || dRegexp.placeholderText;
            settings.regexp = new RegExp(regexp, i ? 'i' : '');

            var elements = dElements.text || dElements.placeholderText;
            settings.elements = elements.split(",").map(function (n) { return Number(n.trim()); });

            settings.width = dWidth.text;
            settings.height = dHeight.text;

            analyseTodos(); // Refresh.
        }
        onRejected: console.log("settings cancelled")

        GridLayout {
            anchors.fill: parent
            columns: 2
            columnSpacing: 10

            Item {
                Layout.columnSpan: 2
                Layout.fillHeight: true
            }
            
            Label {
                text: qsTr("Continuous Refresh")
            }
            
            CheckBox {
                id: dRefreshCheckbox
            }
            
            Label {
                text: qsTr("Filter RegExp")
            }
            
            TextInput {
                id: dRegexp
                Layout.fillWidth: true
                // placeholderText: "^(todo|fixme)"
            }
            
            Label {
                text: qsTr("Filter Case Insensitive")
            }
            
            CheckBox {
                id: dCaseInsensitiveCheckBox
            }
            
            Label {
                text: qsTr("Filter Elements")
            }
            
            TextInput {
                id: dElements
                Layout.fillWidth: true
                // placeholderText: `${Element.STAFF_TEXT},${Element.SYSTEM_TEXT}`
            }
            
            Label {
                text: qsTr("Dialog Width")
            }
            
            TextInput {
                id: dWidth
                Layout.fillWidth: true
                // placeholderText: "400"
            }

            Label {
                text: qsTr("Dialog Height")
            }
            
            TextInput {
                id: dHeight
                Layout.fillWidth: true
                // placeholderText: "600"
            }

            Item {
                Layout.columnSpan: 2
                Layout.fillHeight: true
            }
        }
    }

    Settings {
        id: settings
        category: "plugin.todo-list"
        property alias refresh: plugin.continuousRefresh
        property alias regexp: plugin.filterRegexp
        property alias caseInsensitive: plugin.filterCaseInsensitive
        property alias elements: plugin.filterElements
        property alias width: plugin.width
        property alias height: plugin.height
    }
}

/**
 * Note [Storing Element Objects]
 * 
 * To those familiar with the MS API, it may seem like the gotoTodo function could be made more
 * efficient. Instead of calling findTodo to iterate across the vast expanse of the score to find
 * the TODO element, we could've simply stored the element object in the ListModel, retrieve it in 
 * gotoTodo, then select it and viola.
 * 
 * However when I was testing, I encountered some head-scratching bug where the element object would
 * quite literally disappear. When I do console.log(record.todoElement) in the while loop in
 * analyseTodos, it prints the element object as expected. However, when I do the same in gotoTodo,
 * it more often than not prints null!
 * 
 * Even more preposterous is that, if I do console.log(record.todoElement) in analyseTodos, after the 
 * while loop, the element objects also randomly print null...
 * 
 * My guess is that the GC (not sure if one is used) and memory management is ~~stupid~~ eager so deallocates 
 * the objects after a while. This totally sucks, so for now, I've settled with an additional iteration
 * in gotoTodo. Urgh.
 * 
 */

