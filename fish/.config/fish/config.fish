if status is-interactive
    set -gx GPG_TTY (tty)

    set -gx ANDROID_HOME ~/Library/Android/sdk

    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR {$HOMEBREW_PREFIX}/Cellar
    set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    set -gx HOMEBREW_NO_ANALYTICS 1

    fish_add_path -g ~/.local/bin "$HOMEBREW_PREFIX"/{bin,sbin} "$ANDROID_HOME"/platform-tools

    set -gx LESS --IGNORE-CASE --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --status-column --tabs=4 --window=-4
  
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

    alias cat bat
    alias grep rg
    alias ls 'exa --all --group-directories-first'
    alias ll 'ls --long --binary --group --time-style=long-iso --git'
    alias tree 'ls --tree'
end
