# musescore-todo-list
Todo-list plugin for MuseScore. You can never have too many todos.

In software development, TODOs are commonly added into source code as reminders to the poor developers toiling away writing code. TODOs come in many forms: bugs to be fixed, issues to be resolved, feature requests, etc. Sometimes when composing, one may also find themselves lost in a sea of to-dos.

This plugin aims to increase the composer's quality of life. The typical usage would be to add `TODO`s/`FIXME`s via Ctrl+T (or Cmd+T), noting down your thoughts and ideas before they disappear. The plugin will then automatically refresh and display the curated list of `TODO`s on a dock.

<!-- TODO insert screenshot -->

The plugin is configurable in multiple ways:

* **Continuous Refresh**. Set true for the plugin to update the to-do list whenever the score is updated. May be slow for humongous scores.
* **Filter Regex**. A [regular expression][regex] to filter text elements. Case-insensitive. By default, the regex is `^(todo|fixme)`. This matches texts that start with `todo` or `fixme`.
* **Filter Elements**. The MuseScore Element Types to filter. By default, only Staff Text (42) and System Text (43) are filtered.

Here's a list of text element types from the MuseScore API:

+------+--------+
| Type | Name   |
+------+--------+
| 41   | Tempo Text |
| 42   | Staff Text |
| 43   | System Text |
| 44   | Rehearsal Mark |
| 45   | Instrument Change |
| 46   | Staff Type Change |
+------+--------+

[regex]: https://www.regular-expressions.info/
