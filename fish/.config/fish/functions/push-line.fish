function push-line
    commandline -f kill-inner-line
    function on-next-prompt --on-event fish_prompt
        commandline -f yank
        functions --erase on-next-prompt
    end
end
