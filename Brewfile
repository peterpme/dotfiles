if OS.mac?
  # Taps
  tap "homebrew/cask"
  tap "homebrew/cask-fonts"

  brew "trash" # rm, but faster since it goes in the trash
  # https://github.com/kcrawford/dockutil/issues/127#issuecomment-1118733013
  # Broken until the owner wants to support this
  # brew "dockutil" # https://github.com/kcrawford/dockutil
  cask "hpedrorodrigues/tools/dockutil"

  # Apps
  cask "kitty" # better terminal
  cask "imageoptim" # image optimization tool
  cask "hammerspoon" # automation https://www.hammerspoon.org/
  cask "1password/tap/1password-cli"

  # Fonts
  cask "font-iosevka"
  # cask "font-3270-nerd-font"

elsif OS.linux?
  brew "xclip" # access to clipboard (similar to pbcopy/pbpaste)
end

tap "homebrew/bundle"
tap "homebrew/core"

brew "bat" # modern cat https://github.com/sharkdp/bat
brew "bit-git" # modern git cli https://github.com/chriswalz/bit#how-to-install
brew "curl" # https://github.com/curl/curl
brew "exa" # ls replacement https://github.com/ogham/exa
brew "fzf" # fuzzy-finder https://github.com/junegunn/fzf
brew "fd" # modern find https://github.com/sharkdp/fd
brew "gh" # github CLI https://github.com/cli/cli
brew "git" # latest

brew "git-delta" # better git diff https://github.com/dandavison/delta
brew "jq" #jq shell scripts

brew "lazydocker" # cli gui https://github.com/jesseduffield/lazydocker
brew "lazygit" # cli gui https://github.com/jesseduffield/lazygit
brew "libpq" # psql postgres cli
brew "mas" # Mac automation https://github.com/mas-cli/mas
brew "neovim" # better vim

brew "pigz" # better tar https://github.com/madler/pigz
brew "python" # latest

brew "ruby"
brew "redis"
brew "ripgrep" # Modern grep https://github.com/BurntSushi/ripgrep
brew "fnm" # fast node manager
brew "shellcheck" # https://github.com/koalaman/shellcheck
brew "flyctl" # https://github.com/superfly/fly
brew "sd" # Modern sed https://github.com/chmln/sd

# Simplified and community-driven man pages
# https://github.com/tldr-pages/tldr
# brew "tldr" use global npm package
brew "tmux"
brew "trash" # https://hasseg.org/trash/
brew "tree"

brew "wget"
brew "wifi-password"
brew "watchman" # file watcher, used by coc
brew "youtube-dl"
brew "zoxide" # Modern z https://github.com/ajeetdsouza/zoxide
brew "zsh" # zsh (latest)

## Casks - actual visual software

cask "appcleaner"
cask "alfred"
cask "backblaze"
cask "battle-net"
cask "brave-browser"
cask "calibre"
cask "charles"
cask "chromium"
cask "docker"
cask "discord"
cask "focus"
cask "iterm2"
cask "licecap"
cask "notion"
cask "postico"
cask "postman"
cask "sublime-text"
cask "signal"
cask "spotify"
cask "steam"
cask "visual-studio-code"
cask "zoom"

# Mac App Store Installations
mas "Numbers", id: 409203825
# mas "1Password 7", id: 1333542190 download from their site
mas "Xcode", id: 497799835
mas "NextDNS", id: 1464122853
mas "DaisyDisk", id: 411643860
mas "Fantastical", id: 975937182
mas "Slack", id: 803453959
mas "Telegram", id: 747648890
