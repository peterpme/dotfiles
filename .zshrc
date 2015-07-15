if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

eval $(ssh-agent)

function cleanup {
  echo "Killing SSH-Agent"
  kill -9 $SSH_AGENT_PID
}

trap cleanup EXIT

. ~/dotfiles/z/z.sh
alias tmn="tmux new-session -s" 
alias tma="tmux attach -t"
alias tml="tmux ls"
alias tmk="tmux kill-session -t"
alias dir="echo 'fuck windows'"
export WORKON_HOME=~/.envs
source /usr/local/bin/virtualenvwrapper.sh
ulimit -n 2560
