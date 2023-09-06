# musescore-todo-list
A todo-list plugin for MuseScore. You can never have too many todos.

> **MuseScore 4 Update**: See [the note for MuseScore 4](#musescore-4). ❤️

In short this plugin helps you:

* Organise your score-editing workflow.
* Find `TODO`s and `FIXME`s easily.
* Navigate to the points of trouble without hassle—well, except having to insert text at said points in the first place.

In software development, todos are commonly added to source code as reminders to the poor developers toiling away writing code. Todos come in many forms: bugs to be fixed, issues to be resolved, feature requests, etc. Sometimes when composing, one may also find oneself lost in a sea of todos, struggling to remember what one wanted to change in a particular measure. 

Examples of todos:

* TODO: Explore different chord progressions for this transition.
* TODO: More brass to this section.
* FIXME: Playback sounds wonky.
* TODO: Revise counterpoint.
* TODO: Add bowing articulation to strings.
* TODO: Confirm with friend if this part is playable.

This plugin aims to increase the quality of life of composers, arrangers, transcribers, and well—anybody who edits scores. The typical usage would be to add `TODO`s/`FIXME`s as staff text via <kbd>Ctrl</kbd>+<kbd>T</kbd> or <kbd>Cmd</kbd>+<kbd>T</kbd>, noting down your thoughts and ideas before they disappear. The plugin will then automatically refresh and display the curated list of `TODO`s on a dock.

![](img.png)

### Installation

Either...

1. Obtain the QML plugin file directly ([MS3][file v3] / [MS4][file v4]), OR 
2. Download a [zip of the project](https://github.com/TrebledJ/musescore-todo-list/archive/main.zip) and locate the appropriate subfolder (`ms3/` or `ms4/`, depending on your version).

Then move the file/folder to your MuseScore plugins directory. Refer to the MuseScore Handbook ([MS3][handbook v3] / [MS4][handbook v4]) for detailed a guide on installing plugins.

[file v3]: https://github.com/TrebledJ/musescore-todo-list/raw/main/ms3/todo-list.qml
[file v4]: https://github.com/TrebledJ/musescore-todo-list/raw/main/ms4/todo-list.qml
[handbook v3]: https://musescore.org/en/handbook/3/plugins
[handbook v4]: https://musescore.org/en/handbook/4/plugins

### Usage

1. To add TODOs, first create a text element using one of the following methods:
    1. drag from the palette,
    2. select the option from the menu (Add > Text > Staff/System Text), or
    3. use the shortcut; Ctrl + T / Ctrl + Shift + T on Windows/Linux; Cmd + T / Cmd + Shift + T on Mac.
  
    By default, only Staff Text and System Text are checked for TODOs. This can be modified in the [settings](#settings).
  
2. Begin the text with a pattern such as `TODO`, `todo`, `FIXME`, or `fixme`. The plugin will only display texts which have this prefix.

    By default, only the words TODO and FIXME will match.  This can be modified in the [settings](#settings).

3. Keep typing the rest of your TODO. The display panel on the right should update automagically with your text.

    The automagic may be disabled by unchecking the [Continuous Refresh](#settings) option.

### Settings

The plugin is configurable in multiple ways:

* **Continuous Refresh**. Set true for the plugin to update the to-do list whenever the score is updated. May be slow for humongous scores.

  **Note**: If you're encountering immense lag when modifying text on large scores, try turning off the _Continuous Refresh_ option, and manually pressing **Refresh** to update the display.
  
* **Filter Regex**. A [regular expression][regex] to filter text elements. Case-insensitive. By default, the regex is `^(todo|fixme)`. This matches texts that start with `todo` or `fixme`.
* **Filter Case Sensitivity**. Whether the matching should be case-sensitive.
* **Filter Elements**. Comma-separated list of MuseScore Element Types to filter. By default, only Staff Text (42) and System Text (43) are filtered.

For reference, here's a list of text element types from the MuseScore API:

| Name              | MS3 Code | MS4 Code |
| ----------------- | -------- | -------- |
| Tempo Text        | 41       | 46       |
| Staff Text        | 42       | 47       |
| System Text       | 43       | 48       |
| Rehearsal Mark    | 44       | 52       |
| Instrument Change | 45       | 53       |
| Staff Type Change | 46       | 54       |

<!-- MS4: refer to https://github.com/musescore/MuseScore/blob/master/src/engraving/types/types.h. -->

(Todos in lyrics are currently not supported.)

This plugin should (in theory) work in MuseScore versions 3.5 and up.

### MuseScore 4

As of writing, the MuseScore 4 (MS4) plugin environment is still a work in progress. Nevertheless, a version for MS4 is available, with the following limitations:

* Dialog. Docked plugins are currently unavailable, forcing the plugin to be a dialog.
* Fixed dimensions. Currently, the dialog width/height are fixed. On some resolutions, the dialog box may be too small or big. I've added a couple options to modify the dimensions. You may need to reload the plugin afterwards.
* Jank text input UI in settings. QML `TextField` doesn't work for now, so please bear with it.

Also, FYI note that the `ElementType` codes have changed between MS4 and MS3. See the above table.

### Development
Pull requests, translations, and bug reports are welcome.


[regex]: https://www.regular-expressions.info/
