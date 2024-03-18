function keys
   function decorate
      set_color --bold blue; printf $argv[1]; set_color normal; printf ": "; set_color --italics; echo $argv[2]
   end

   decorate "   ⌥B" "Belay current command"
   decorate "   ⌥S" "Prepend sudo to current or previous command"
   decorate "   ⌥E" "Edit command in editor"
   decorate "   ⌥C" "Capitalise first letter of word under cursor"
   decorate "   ⌥U" "Capitalise word under cursor"
   decorate "   ^T" "Transpose current and previous character"
   decorate "   ⌥T" "Tranpose current and previous word"
   decorate "   ^Z" "Undo most recent line edit"
   decorate "   ⌥/" "Revert most recent undo of line edit"
   echo
   decorate "^[AE]" "Move cursor to start/end of line"
   decorate "⌥[←→]" "Move cursor one inclusive word OR navigate directory stack"
   decorate "⇧[←→]" "Move cursor one exclusive word OR accept big word of autosuggestion"
   echo
   decorate "   ⌥W" "Show short description of app under cursor"
   decorate "   ⌥H" "Show manpage for app under cursor"
   decorate "   ⌥L" "List contents of directory under cursor or current directory"
   echo
   decorate "   ^R" "Search command history"
   decorate "⌥[↑↓]" "Search command history for instances of original token under cursor"
   decorate "   ^V" "Search environment variables"
   decorate "  ^⌥F" "Search current directory"
   decorate "  ^⌥L" "Search git log"
   decorate "  ^⌥S" "Search git status"
   decorate "  ^⌥P" "Search processes"

   functions --erase decorate
end
