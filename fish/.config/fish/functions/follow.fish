function follow
    tail -f $argv | bat --paging=never --language=log
end
