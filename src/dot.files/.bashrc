# -*- mode: sh; sh-shell: bash -*-

# SPDX-License-Identifier: AGPL-3.0-or-later
# Author: Markus Heiser <markus.heiser@darmarit.de>
# Keywords: dot.bashrc bashrc

### Commentary:
#
# My local bash setup.
#
# Install::
#
#     $ cd <root of this repo>
#     $ ln -s "$PWD/src/dot.files/.bashrc" "$HOME/"
#     $ source $HOME/.bashrc  # or start a new shell
#
#     $ my.emacs.dotfile
#     $ my.git.setup
#     $ my.mise.install
#     $ my.hatch.completions
#
# Developer notes::
#
#     $ shfmt -i 4 -w .bashrc
#     $ shellcheck -s bash .bashrc

### Code:

_TEMPLATE_FOLDER="$(dirname "$(readlink "${BASH_SOURCE[0]}")")"

my.pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

my.dotfiles.init() {
    ln -s "$_TEMPLATE_FOLDER/.emacs" "$HOME/"
    my.git.setup
    my.mise.install
    my.hatch.completions
}

my.pathadd "/usr/sbin"
my.pathadd "$HOME/bin"
my.pathadd "$HOME/.local/bin"

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
xterm-color | *-256color)
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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

# if [[ $- == *i* ]]; then
#     if [ -f /usr/share/bash-completion/bash_completion ]; then
#         . /usr/share/bash-completion/bash_completion
#     elif [ -f /etc/bash_completion ]; then
#         . /etc/bash_completion
#     fi
# fi

# -----------------------------------------------------------------------
# --- sudo
# -----------------------------------------------------------------------

complete -cf sudo

# -----------------------------------------------------------------------
# --- https://mise.jdx.dev/installing-mise.html
# -----------------------------------------------------------------------
#
# [1] https://mise.jdx.dev/getting-started.html

if [ -f "${HOME}/.local/bin/mise" ]; then
    eval "$("${HOME}/.local/bin/mise" activate bash --shims)"
fi

my.mise.install() {
    # For the developer environment, "mise en place" [1] is recommended::
    if ! [ -f "${HOME}/.local/bin/mise" ]; then
        curl https://mise.run | sh
    fi

    # To install my mise configuration and its configured tools::
    mkdir -p "$HOME/.config/mise/"
    ln -s "$_TEMPLATE_FOLDER/.config/mise/config.toml" "$HOME/.config/mise/"
    pushd "$HOME" || exit
    mise install
    popd || exit
}

my.mise.uninstall() {
    # To fully uninstall mise:
    rm -rf "$HOME/.local/bin/mise" "$HOME/.local/share/mise" "$HOME/.local/state/mise" "$HOME/.config/mise" "$HOME/.cache/mise"
}

# -----------------------------------------------------------------------
# --- https://hatch.pypa.io/latest/cli/about/#tab-completion
# -----------------------------------------------------------------------

my.hatch.completions() {
    # Don't forget to install bash completions:
    _HATCH_COMPLETE=bash_source hatch >~/.local/share/bash-completion/completions/hatch
}

# -----------------------------------------------------------------------
# git
# -----------------------------------------------------------------------

my.git.setup() {
    local _DEFAULT
    local _MAIL
    local _setup

    echo

    _DEFAULT="$(git config --global user.name)"
    if [[ (-z "$_DEFAULT") && ($(which "getent")) ]]; then
        _DEFAULT="$(getent passwd "$USER" | cut -d ':' -f 5)"
        _DEFAULT="${_DEFAULT//,/}"
    fi

    read -r -p "Specify your (git) 'First-Name Last-Name': [$_DEFAULT]" _READ
    _NAME="${_READ:-$_DEFAULT}"
    git config --global user.name "${_NAME}"

    _DEFAULT=$(git config --global user.email)
    if [[ -z "$_DEFAULT" ]]; then
        _DEFAULT=$(id -un)@$(hostname -f)
    fi
    read -r -p "Specify your (git) e-Mail address: [$_DEFAULT] " _READ
    _MAIL=${_READ:-$_DEFAULT}
    git config --global user.email "${_MAIL}"
    git config --global core.autocrlf false
    git config --global core.symlinks true
    git config --global core.editor "emacsclient --create-frame --alternate-editor emacs"
    git config --global color.ui true
    git config --global push.default simple

    # Cache makes the most sense on Linux
    git config --global credential.helper cache

    # Alias 'git lg' ein log ohne graph
    git config --global alias.lg "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

    # Alias 'git graph'
    git config --global alias.graph "log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

    if [[ $(uname -s) != 'Darwin' ]]; then
        # https://stackoverflow.com/questions/5581857/git-and-the-umlaut-problem-on-mac-os-x
        git config --global core.precomposeunicode true
    fi

    echo
    git config --global -l
}
