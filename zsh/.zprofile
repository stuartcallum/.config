eval "$(/opt/homebrew/bin/brew shellenv)"

alias vi='nvim'
alias vim='nvim'
alias ll='ls -lah'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias history='history 1'
# export PS1="%~ $ "
autoload -U colors && colors
export PS1=" %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%} "

export HISTSIZE=10000
# eval "$(starship init zsh)"

# export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
# export JAVA_HOME="/run/current-system/sw/bin/java"

bindkey ";3C" forward-word
bindkey ";3D" backward-word

