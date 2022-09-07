Usage
-----

1. Install dependencies with [Homebrew](https://brew.sh/).
```shell
brew bundle install --file path/to/dotfiles/brewfile
```

2. Start fish shell and install [fisher](https://github.com/jorgebucaran/fisher).

3. Stow dotfiles. Don't do this earlier or some may be overwritten.
```shell
cd path/to/dotfiles
stow fish binaries ...
```

4. Install fish plugins.
```shell
fish -c "fisher update"
```
