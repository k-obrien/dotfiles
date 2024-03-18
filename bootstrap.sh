#!/usr/bin/env bash

set -o errexit  # exit immediately upon error
set -o pipefail # surface errors in pipes
set -o nounset  # prohibit undefined variables
IFS=$'\n\t'     # split on newline or tab by default

function _show_usage() {
    echo "usage: $(basename "$0") email_address company_name"
    exit 1
}

printf "Email address: "
read -r email

[[ ${email:-} =~ ^.+@.+\..+$ ]] || _show_usage

printf "Company or host name: "
read -r name

[[ -n ${name:-} ]] || _show_usage

echo -e "\nInstalling Homebrew..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
[[ -x "$(command -v /opt/homebrew/bin/brew)" ]] || exit 1
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
brew analytics off

echo -e "\nInstalling apps..."
git clone --recurse-submodules https://github.com/k-obrien/dotfiles.git ~/.dotfiles
brew bundle install --file ~/.dotfiles/brewfile

echo
fish -Pc "$(curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish) | source && fisher install jorgebucaran/fisher"

mkdir -p ~/{.config/{git,zsh},.dotfiles,.local/bin}
rm ~/.config/fish/config.fish ~/.config/fish/fish_plugins &> /dev/null || true
cd ~/.dotfiles
git update-index --skip-worktree ~/.dotfiles/hammerspoon/.hammerspoon/init.lua
stow binaries codium fish fzffdignore git hammerspoon iterm2 zsh
cd ~/

echo -e "\nInstalling fish plugins..."
fish -Pc "fisher update"

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$email"
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519

git config --file ~/.config/git/config.local --add user.email "$email"
git config --file ~/.config/git/config.local --add user.signingKey ~/.ssh/id_ed25519.pub
awk '{ print $3, $1, $2 }' ~/.ssh/id_ed25519.pub > ~/.config/git/allowed_signers

echo -e "\nConfiguring GitHub CLI and keys..."
gh auth login --git-protocol https --hostname github.com --web --scopes admin:public_key,write:ssh_signing_key,user
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$name" --type authentication
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$name" --type signing
gh api --method POST -H "Accept: application/vnd.github+json" /user/emails -f "emails[]=${email}" > /dev/null
gh auth refresh --reset-scopes
