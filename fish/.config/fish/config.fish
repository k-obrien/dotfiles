if status is-interactive
    set -gx GPG_TTY (tty)

    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    set -gx HOMEBREW_CELLAR {$HOMEBREW_PREFIX}/Cellar
    set -gx HOMEBREW_NO_ANALYTICS 1

    set -gx ANDROID_HOME ~/Library/Android/sdk

    fish_add_path -g ~/.local/bin {$HOMEBREW_PREFIX}/{bin,sbin} {$ANDROID_HOME}/platform-tools

    set -gx MANPATH (manpath)

    set -gx LESS --IGNORE-CASE --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --status-column --tabs=4 --window=-4

    type -q codium && set -gx VISUAL codium --wait

    type -q vivid && set -gx LS_COLORS (vivid generate jellybeans)
    
    fish_config theme choose "Tomorrow Night"

    set -g fish_greeting

    set -U tide_character_icon \u276f
    set -U tide_jobs_icon \u2699
    set -U tide_left_prompt_frame_enabled false
    set -U tide_left_prompt_items pwd git newline context character
    set -U tide_left_prompt_prefix
    set -U tide_left_prompt_suffix \x20
    set -U tide_prompt_add_newline_before true
    set -U tide_prompt_icon_connection \x20
    set -U tide_prompt_pad_items false
    set -U tide_pwd_icon_unwritable \x1d
    set -U tide_right_prompt_frame_enabled false
    set -U tide_right_prompt_items status cmd_duration jobs 
    set -U tide_right_prompt_prefix \x20
    set -U tide_right_prompt_suffix

    set -gx fzf_fd_opts --ignore-file .fzffdignore
    set -gx fzf_preview_dir_cmd exa --all --color=always --oneline

    type -q bat && alias cat bat
    type -q codium && alias edit codium
    type -q dust && alias du dust
    type -q gpgconf && alias gakill "gpgconf --kill gpg-agent"
    type -q procs && alias ps procs
    type -q rg && alias grep "rg --hidden -e"
    type -q studio && alias vdiff "studio diff"
    type -q xman && alias man xman

    if type -q fd
        alias fd "fd --hidden"
        alias find "fd --hidden"
    end

    if type -q exa
        alias ll "exa --all --group-directories-first --long --binary --group --time-style=long-iso --git"
        alias ls "exa --all --group-directories-first"
        alias tree "exa --all --group-directories-first --tree"
    end

    if test -f ~/.config.fish.local
        source ~/.config.fish.local
    end
end
