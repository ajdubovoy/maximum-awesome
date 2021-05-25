ZSH=$HOME/.oh-my-zsh

# You can change the theme with another one:
#   https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"
plugins=(zsh-syntax-highlighting)

# ZPlug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh
source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/gitfast", from:oh-my-zsh
zplug "plugins/last-working-dir", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "plugins/sublime", from:oh-my-zsh
zplug "plugins/history-substring-search", from:oh-my-zsh
zplug "plugins/zsh-nvm", from:oh-my-zsh
zplug "plugins/wd", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/yarn", from:oh-my-zsh
zplug "plugins/httpie", from:oh-my-zsh
zplug "mafredri/zsh-async", from:"github"
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
# Then, source plugins and add commands to $PATH
zplug load

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

export EDITOR="nvim"

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)

# Load rbenv if installed (To manage your Ruby versions)
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# Load pyenv (To manage your Python versions)
export PATH="${HOME}/.pyenv/bin:${PATH}" # Needed for Linux/WSL
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"

# Load nvm if installed (To manage your Node versions)
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
function load-nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
async_start_worker nvm_worker -n
async_register_callback nvm_worker load-nvm
async_job nvm_worker sleep 0.1

# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Load 'lewagon' virtualenv for the Data Bootcamp. You can comment these 2 lines to disable this behavior.
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
pyenv activate lewagon 2>/dev/null && echo "🐍 Loading 'lewagon' virtualenv"

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# VIM
alias vi='nvim'
alias vim='nvim'
bindkey -v

# Aliases
alias digitalocean='mosh ajdubovoy@159.89.141.100'

alias ngrokstart='ngrok http 3000'
alias tmuxk='tmux kill-session'
alias gupdate='gco master && git pull origin master && git fetch && git sweep && bundle install && yarn install && rails db:migrate'

alias lvh='rails s -p 3000 -b lvh.me'
alias wpds='webpack-dev-server'
alias herokudeploy='git push heroku master'
alias herokustage='git push staging master'

alias groupmuse-s='concurrently "rails s" "redis-server" "bundle exec guard -i" "stripe listen --latest --events payment_intent.created,payment_intent.succeeded,payment_intent.payment_failed,invoice.paid,invoice.created --forward-to localhost:3000/stripe/events/webhook --forward-connect-to localhost:3000/stripe/events/webhook" -n "rails,redis,guard,stripe" -c "red,yellow,cyan,magenta" --handle-input --kill-others'
alias rails-full-s='concurrently "rails s" "webpack-dev-server" "sidekiq" -n "rails,webpack,sidekiq" -c "red,green,yellow" --handle-input --kill-others'
alias lvh-full-s='concurrently "rails s -p 3000 -b lvh.me" "webpack-dev-server" "sidekiq" -n "rails,webpack,sidekiq" -c "red,green,yellow" --handle-input --kill-others'

# Hub
alias git=hub
alias gpr='gh pr create'
alias gprm='gh pr merge -m -d && ggpull && git sweep'
alias ghv='gh repo view --web'

# ccat
alias cat=ccat

alias chromedriver-unshim='rm ~/.rbenv/shims/chromedriver'

function tmux-cwd {
  tmux command-prompt -I $PWD -p "New session dir:" "attach -c %1"
}

# NVM
export NVM_LAZY_LOAD=true

# Based on official autoload for ZSH https://github.com/nvm-sh/nvm#zsh
autoload -U add-zsh-hook
load-nvmrc() {
  if [ -f ".nvmrc" ]; then
    if ! typeset -f nvm_find_nvmrc > /dev/null; then 
      [ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh" --no-use 
    fi

    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      echo "Reverting to nvm default version"
      nvm use default
    fi
  fi
}
load-nvmrc-async() {
  async_register_callback nvm_worker load-nvmrc
  async_job nvm_worker sleep 0.1
}
add-zsh-hook chpwd load-nvmrc-async
load-nvmrc-async

alias rndb='open "rndebugger://set-debugger-loc?host=localhost&port=8081"'
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
