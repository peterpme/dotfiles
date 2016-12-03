# Copy and paste bit by bit
echo "do not run this script in one go. hit ctrl-c NOW"
read -n 1

##############################################################################################################
### XCode Command Line Tools
#      thx https://github.com/alrra/dotfiles/blob/ff123ca9b9b/os/os_x/installs/install_xcode.sh

###
##############################################################################################################

##############################################################################################################
### homebrew!

# alternative to /usr/local to avoid sudo and lock down /usr/local
mkdir $HOME/.homebrew && curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
export PATH=$HOME/.homebrew/bin:$HOME/.homebrew/sbin:$PATH

# install all the things
./brew.sh
./brew-cask.sh

### end of homebrew
##############################################################################################################

# node version manager
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

# github.com/thebitguru/play-button-itunes-patch
# disable itunes opening on media keys
git clone https://github.com/thebitguru/play-button-itunes-patch ~/code/play-button-itunes-patch

# github.com/rupa/z   - oh how i love you
git clone https://github.com/rupa/z.git ~/dotfiles/z
# consider reusing your current .z file if possible. it's painful to rebuild :)
# z is hooked up in .zshrc

# github.com/jamiew/git-friendly
# the `push` command which copies the github compare URL to my clipboard is heaven
bash < <( curl https://raw.github.com/jamiew/git-friendly/master/install.sh)

########

# Disable Gatekeeper (unidentified developer)
sudo spctl --master-disable

# Neovim has an issue with ctrl + h escape key (READ THIS)
# https://github.com/neovim/neovim/issues/2048#issuecomment-98307896

###  Instructions:

# Edit -> Preferences -> Keys
# Press +
# Press Ctrl+h as Keyboard Shortcut
# Choose Send Escape Sequence as Action
# Type [104;5u for Esc+
