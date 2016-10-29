if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

unalias run-help
autoload run-help
HELPDIR=/usr/local/share/zsh/help

. ~/dotfiles/z/z.sh

alias vi="nvim"
alias vim="nvim"
alias tmn="tmux new-session -s"
alias tma="tmux attach -t"
alias tml="tmux ls"
alias tmk="tmux kill-session -t"
alias dir="echo 'fuck windows'"

export WORKON_HOME=~/.envs
source /usr/local/bin/virtualenvwrapper.sh
ulimit -n 2560
export KEYTIMEOUT=1

export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

trap cleanup EXIT

fixUnicode() {
  echo 'fixing unicode package'
  npm remove unicode && npm install unicode
}

cleanNpm() {
  echo 'cleaning npm modules'
  rm -rf node_modules && npm cache clean -f && npm install
}

alias zcp='zmv -C'
alias zln='zmv -L'
# setup tmux autossh
 if [ -z "$TMUX" ]; then
   if [ ! -z "$SSH_TTY" ]; then
     if [ -z "$SSH_AUTH_SOCK" ]; then
       export SSH_AUTH_SOCK="$HOME/.ssh/.auth_socket"
     fi
     if [ ! -S "$SSH_AUTH_SOCK" ]; then
       `ssh-agent -a $SSH_AUTH_SOCK` > /dev/null 2>&1
       echo $SSH_AGENT_PID > $HOME/.ssh/.auth_pid
     fi
     if [ -z $SSH_AGENT_PID ]; then
       export SSH_AGENT_PID=`cat $HOME/.ssh/.auth_pid`
     fi
     ssh-add 2>/dev/null
     tmux attach
   fi
 fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# tabtab source for yo package
# uninstall by removing these lines or running `tabtab uninstall yo`
[[ -f /Users/peter/.nvm/versions/node/v6.2.0/lib/node_modules/yo/node_modules/tabtab/.completions/yo.zsh ]] && . /Users/peter/.nvm/versions/node/v6.0.0/lib/node_modules/yo/node_modules/tabtab/.completions/yo.zsh

export ANDROID_HOME=~/Library/Android/sdk
export PATH="/Users/peter/Library/Android/sdk/tools:/Users/peter/Library/Android/sdk/platform-tools:${PATH}"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(hub alias -s)"

export PATH="$HOME/.yarn/bin:$PATH"
