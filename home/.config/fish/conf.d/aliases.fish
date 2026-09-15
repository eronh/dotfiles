# conf.d runs for scripts too; these aliases only matter at a prompt.
status is-interactive; or return

alias c 'clear; printf "\e[3J"'
alias vi 'command vim'
alias vim nvim
alias jw 'cd $HOME/Workbench/'
command -q eza; and alias ls 'eza --color=always --long --git --icons=always --header'
alias l 'ls -lAh'
alias ll 'ls -lh'
alias la 'ls -lah'
