#!/bin/ruby
#
# TAKE A LOOK AT PAUL IRISH
# https://github.com/paulirish/dotfiles

github_packages = [
  'https://github.com/square/maximum-awesome.git'
]

install_scripts = [
  'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash',
  '`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
]

brew_base_packages = [
  'mas',
  'caskroom/cask/brew-cask',
  'httpie',
  'ack',
  'ag',
  'wget',
  'pngcrush',
  'jpegoptim',
  'imagemagick',
  'graphicsmagick',
  'rbenv',
  'ruby-build',
  'tree',
  'zsh',
  'fzf'
]

brew_cask_packages = [
  '1password'
  'flux',
  'imageoptim',
  'alfred',
  'dropbox',
  'vlc',
  'virtualbox',
  'vagrant',
  'spotify',
  'google-chrome',
  'firefox',
  'iterm2',
]

def log(msg)
  puts '='*10
  puts msg
  puts '='*10
end

log 'Create temp directory && cd'
`mkdir -p ~/install-tmp`
`cd ~/install-tmp`


log 'Installing Homebrew...'

log 'Setting Up Homebrew...'
`brew doctor`
`brew update`
`brew upgrade`

log 'Setting up Git...'
`ssh-keygen -t rsa -C "peterpiekarczyk@gmail.com"
`pbcopy < ~/.ssh/id_rsa.pub`
`ssh -T git@github.com`

`git config --global user.name "Peter Piekarczyk`
`git config --global user.email "peterpiekarczyk@gmail.com`
`git config --global github.user ppiekarczyk`
`git config --global core.editor "vim"`
`git config --global color.ui true`
`git config --global push.default simple`
