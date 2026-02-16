if OS.mac?
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
  # NOTE: Using plain Iosevka + separate Nerd Font symbols (symbolmap.conf in kitty config).
  # A future simplification could be switching to font-iosevka-term-nerd-font to get
  # built-in nerd font symbols, but the current setup works — don't change without testing.
  cask "font-iosevka"
  # cask "font-3270-nerd-font"

elsif OS.linux?
  brew "xclip" # access to clipboard (similar to pbcopy/pbpaste)
end

brew "bat" # modern cat https://github.com/sharkdp/bat
brew "curl" # https://github.com/curl/curl
brew "eza" # ls replacement https://github.com/eza-community/eza
brew "fzf" # fuzzy-finder https://github.com/junegunn/fzf
brew "fd" # modern find https://github.com/sharkdp/fd
brew "gh" # github CLI https://github.com/cli/cli
brew "git" # latest

brew "git-delta" # better git diff https://github.com/dandavison/delta
brew "jq" #jq shell scripts

brew "lazydocker" # cli gui https://github.com/jesseduffield/lazydocker
brew "lazygit" # cli gui https://github.com/jesseduffield/lazygit
brew "libpq" # psql postgres cli
brew "neovim" # better vim

brew "pigz" # better tar https://github.com/madler/pigz
brew "python" # latest

brew "ruby"
brew "ripgrep" # Modern grep https://github.com/BurntSushi/ripgrep
brew "fnm" # fast node manager
brew "shellcheck" # https://github.com/koalaman/shellcheck
brew "flyctl" # https://github.com/superfly/fly
brew "sd" # Modern sed https://github.com/chmln/sd

# Simplified and community-driven man pages
# https://github.com/tldr-pages/tldr
# brew "tldr" use global npm package
brew "tmux"
brew "tree"

brew "wget"
brew "watchman" # file watcher, used by coc
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
cask "docker"
cask "discord"
cask "focus"
cask "notion"
cask "postico"
cask "sublime-text"
cask "signal"
cask "spotify"
cask "steam"
cask "visual-studio-code"
cask "zoom"
