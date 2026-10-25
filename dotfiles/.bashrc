PS1='\[\e[38;2;168;85;247m\][\u@\h \[\e[38;2;192;132;252m\]\W\[\e[38;2;168;85;247m\]]\$ \[\e[0m\]'
alias ls='ls --color=auto'
fastfetch

# Machine-specific settings (API tokens, PATH tweaks, ...) deliberately live
# outside this repo. Create ~/.bashrc.local on each machine.
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
