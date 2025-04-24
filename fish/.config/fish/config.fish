if status is-interactive
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR {$HOMEBREW_PREFIX}/Cellar
    set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    set -gx HOMEBREW_NO_ANALYTICS 1

    set -gx ANDROID_HOME ~/Library/Android/sdk

    fish_add_path -g ~/.local/bin {$HOMEBREW_PREFIX}/{bin,sbin} {$ANDROID_HOME}/platform-tools

    set -gx JAVA_HOME (/usr/libexec/java_home -a arm64)
    set -gx STUDIO_JDK $JAVA_HOME
    set -gx STUDIO_GRADLE_JDK $JAVA_HOME

    set -gx MANPATH (manpath)
    set -gx INFOPATH {$HOMEBREW_PREFIX}/share/info {$INFOPATH}

    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
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

    set -gx fzf_fd_opts --ignore-file ~/.config/fzffd/fzffdignore
    set -gx fzf_preview_dir_cmd eza --color=always --oneline

    type -q bat && abbr -a cat bat
    type -q dust && abbr -a du dust
    type -q procs && abbr -a ps procs
    type -q rg && abbr -a grep "rg -e"

    if type -q codium
        abbr -a edit codium
        abbr -a diff codium --diff
        abbr -a merge codium --merge
    end

    if type -q fd
        abbr -a find fd --full-path
        abbr -a find! fd --no-ignore --hidden --full-path
    end

    if type -q eza
        abbr -a ls eza --group-directories-first
        abbr -a ls! eza --group-directories-first --all
        abbr -a ll eza --group-directories-first --long --binary --group --time-style=long-iso --git
        abbr -a ll! eza --group-directories-first --long --binary --group --time-style=long-iso --git --all
        abbr -a tree eza --group-directories-first --tree
        abbr -a tree! eza --group-directories-first --tree --all
    end

    if test -f ~/.config/fish/config.fish.local
        source ~/.config/fish/config.fish.local
    end

    bind --user \eb push-line
end
