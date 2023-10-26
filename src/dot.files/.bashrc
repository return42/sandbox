# ============================================================================
# ~/.bashrc
# ============================================================================

export EDITOR="emacsclient -nw --create-frame --alternate-editor emacs"
export PAGER="less -R"

# -----------------------------------------------------------------------
# --- Bash-History
# -----------------------------------------------------------------------

HISTIGNORE="pwd:ls:ls -la:ll:la:_h:_p:history:"
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# --- Alias

alias _p="ps --forest -e -o pid,ppid,user,%cpu,%mem,args"
alias _h="history | grep -i "

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

case "$TERM" in
    xterm-color|*-256color)
	# PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	;;
esac

# -----------------------------------------------------------------------
# --- https://github.com/scop/bash-completion#readme
# -----------------------------------------------------------------------

if [[ $- == *i* ]] ; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# -----------------------------------------------------------------------
# --- https://asdf-vm.com/
# -----------------------------------------------------------------------

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
    . "$HOME/.asdf/completions/asdf.bash"
fi
