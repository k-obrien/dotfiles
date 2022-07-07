function ls --wraps='exa --all --group-directories-first' --description 'alias ls exa --all --group-directories-first'
  exa --all --group-directories-first $argv; 
end
