function ll --wraps='ls --long --binary --group --time-style=long-iso --git' --description 'alias ll ls --long --binary --group --time-style=long-iso --git'
  ls --long --binary --group --time-style=long-iso --git $argv; 
end
