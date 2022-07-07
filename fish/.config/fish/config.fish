if status is-interactive
    set -gx LS_COLORS "$(vivid generate jellybeans)"
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
end
