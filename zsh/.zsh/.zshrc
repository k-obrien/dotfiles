export HISTSIZE=1000000000
export SAVEHIST=1000000000
export CLICOLOR=1
export LSCOLORS="ExGxFxDxCxHdxdHcxcHexe"
export VISUAL="code --wait --new-window"
export LESS="--IGNORE-CASE --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --window=-4"
export GREP_OPTIONS="--color=auto"
export HOMEBREW_NO_ANALYTICS=1
export GPG_TTY=$(tty)

# Append folders to path
path+=("${HOME}/bin")
path+=("${HOME}/.iterm2")
path+=("${HOME}/Library/Android/sdk/platform-tools")
path+=("${HOME}/Library/Android/sdk/tools/bin")
path+=("${HOME}/Library/Android/sdk/emulator")
path+=("/usr/local/sbin")
path+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")

# Append folders to search path
fpath+=("${ZDOTDIR}/functions")
fpath+=("${ZDOTDIR}/widgets")
fpath+=("${ZDOTDIR}/completions")
fpath+=("${ZDOTDIR}/prompts")

# Navigation
setopt AUTO_CD              # Automatically perform cd on commands that resolve to paths
setopt AUTO_PUSHD           # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS    # Don’t push multiple copies of the same directory onto the directory stack
setopt PUSHD_MINUS          # Exchanges the meanings of ‘+’ and ‘-’ when used with a number to specify a directory in the stack
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd

# Completion
setopt NO_MENU_COMPLETE     # Disable autoselection of first completion
setopt NO_FLOWCONTROL       # Disable output flow control via start/stop characters in shell's editor
setopt AUTO_MENU            # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD     # Enable completion from both ends of a word
setopt ALWAYS_TO_END        # Move cursor to end of word after performing completion

# Expansion / Globbing
setopt NO_CASE_GLOB         # Disable case-sensitive globbing
setopt DOTGLOB              # Include dotfiles in glob expressions
setopt NUMERIC_GLOB_SORT    # Sort extensions with numbers numerically

# I/O
setopt CORRECT              # Try to correct the spelling of commands
setopt CORRECT_ALL          # Try to correct the spelling of all arguments

# History
setopt EXTENDED_HISTORY     # Write the history file in the ‘:start:elapsed;command’ format
setopt INC_APPEND_HISTORY   # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY        # Share history between all sessions
setopt HIST_IGNORE_DUPS     # Do not record an event that was just recorded again
setopt HIST_FIND_NO_DUPS    # Do not display a previously found event
setopt HIST_IGNORE_SPACE    # Do not record an event starting with a space
setopt HIST_VERIFY          # Do not execute immediately upon history expansion
setopt HIST_REDUCE_BLANKS   # Remove blank lines

# Prompting
setopt PROMPT_SUBST         # Perform parameter/arithmetic expansion and command substitution in prompts

# redraw the prompt when the terminal is resized
TRAPWINCH() {
	zle reset-prompt
}

# Source plugins
for ZSH_FILE in "${ZDOTDIR}"/zsh.d/*.zsh(N); do
    source "${ZSH_FILE}"
done

# Async
if [ -f "${ZDOTDIR}/zsh.d/async/async.zsh" ]; then
    source "${ZDOTDIR}/zsh.d/async/async.zsh"
    async_init
fi

# Auto-suggestions
if [ -f "${ZDOTDIR}/zsh.d/autosuggestions/zsh-autosuggestions.zsh" ]; then
    export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50   # Disable autosuggestions when buffer exceeds twenty characters
    export ZSH_AUTOSUGGEST_USE_ASYNC=1          # Enable asynchronous fetching of suggestions
    source "${ZDOTDIR}/zsh.d/autosuggestions/zsh-autosuggestions.zsh"
fi

# Auto-pair
if [ -f "${ZDOTDIR}/zsh.d/autopair/autopair.zsh" ]; then
    source "${ZDOTDIR}/zsh.d/autopair/autopair.zsh"
    autopair-init
fi

# Load functions
autoload -U zmv         # Enable pattern matching for file moving
autoload -U zmc         # Enable pattern matching for file copying
autoload -U zln         # Enable pattern matching for file linking
autoload -Uz hist       # Print entire history or, optionally, search it for a given term
autoload -Uz shist      # Enable interactive history search
autoload -Uz vnc        # Establish a VNC session via Screen Sharing
autoload -Uz xmanpage   # Open man pages in separate terminal window
autoload -Uz aanimscl   # Set animation scale on Android device
autoload -Uz adbin      # Dispatch input to ADB
autoload -Uz adbtype    # Dispatch text input to ADB
autoload -Uz adbkey     # Dispatch key input to ADB
autoload -Uz adbtap     # Dispatch touch input to ADB
autoload -Uz abounds    # Toggle layout bounds visibility on Android device

# Enable prompt customisation
autoload -Uz promptinit && promptinit && prompt kilo

# Prepend the current command with sudo followed by a space
autoload -Uz prepend-sudo && prepend-sudo

# Insert the output from the previous command
autoload -Uz insert-last-command-output && insert-last-command-output

# Define words as alphanumerics only
autoload -U select-word-style && select-word-style bash

# Edit current command in default editor (Opt+E)
autoload -U edit-command-line && zle -N edit-command-line && bindkey "^[e" edit-command-line

bindkey "^q" push-line-or-edit      # Ctrl+Q
bindkey "^[[A" up-line-or-search    # Up arrow
bindkey "^[[B" down-line-or-search  # Down arrow

# Aliases
alias vdiff="studio diff"                   # Use Android Studio's visual diff tool
alias r="fc -e -"                           # Enable search and replace for previous command
alias man="xmanpage"                        # Open man pages in separate terminal window
alias help="${ZDOTDIR}/help.md"             # Display curated help
alias gpgreset="gpgconf --kill gpg-agent"   # Reload the GPG Agent

# Global Aliases
alias -g ll="ls -alhF"
alias -g l="ls -lhF"
alias -g G="| grep"                 # Pipe output to grep
alias -g L="| less"                 # Pipe output to less
alias -g W="| wc -l"                # Count lines in output
alias -g C="| tr -d '\n' | pbcopy"  # Pipe output to the pasteboard

# Suffix Aliases
alias -s log="open -a Console"  # Open log files in Console
alias -s md="mdcat"             # Pipe markdown files to mdcat

# >>> Completion
# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Enable color completion lists
zstyle ':completion:*' list-colors ''

# Enable selection menu when possible completions exceeds four
zstyle ':completion:*' menu select=5

# Enable cache for completions
zstyle ':completion::complete:*' use-cache 1

# Tell completion engine where to find configuration
zstyle :compinstall filename "${ZDOTDIR}/.zshrc"

autoload -Uz compinit && compinit -u
# <<< Completion
