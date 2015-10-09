if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

trap cleanup EXIT

. ~/dotfiles/z/z.sh

alias tmn="tmux new-session -s" 
alias tma="tmux attach -t"
alias tml="tmux ls"
alias tmk="tmux kill-session -t"
alias dir="echo 'fuck windows'"

# alias unalias run-help
# alias autoload run-help
# HELPDIR=/usr/local/share/zsh/help

export WORKON_HOME=~/.envs
source /usr/local/bin/virtualenvwrapper.sh
ulimit -n 2560
export KEYTIMEOUT=1

source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
