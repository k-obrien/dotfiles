function keys
echo "\
⌥B: Belay current command
⌥S: Prepend sudo to current or previous command
⌥E: Edit command in editor
⌥C: Capitalise first letter of word under cursor
⌥U: Capitalise word under cursor
^T: Transpose current and previous character
⌥T: Tranpose current and previous word
^Z: Undo most recent line edit
⌥/: Revert most recent undo of line edit

^[AE]: Move cursor to start/end of line
⌥[←→]: Move cursor one inclusive word OR navigate directory stack
⇧[←→]: Move cursor one exclusive word OR accept big word of autosuggestion

⌥W: Show short description of app under cursor
⌥H: Show manpage for app under cursor
⌥L: List contents of directory under cursor or current directory

   ^R: Search command history
⌥[↑↓]: Search command history for instances of original token under cursor
   ^V: Search environment variables
  ^⌥F: Search current directory
  ^⌥L: Search git log
  ^⌥S: Search git status
  ^⌥P: Search processes"
end