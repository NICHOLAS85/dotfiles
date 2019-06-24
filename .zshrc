# https://github.com/NICHOLAS85/dotfiles/blob/master/.zshrc

# Install zplugin if not installed
if [ ! -d "${HOME}/.zplugin" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
fi

### Added by Zplugin's installer
source "${HOME}/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

HISTFILE="${HOME}/.histfile"
bindkey -e                  # EMACS bindings
setopt append_history       # Allow multiple terminal sessions to all append to one zsh command history
setopt hist_ignore_all_dups # delete old recorded entry if new entry is a duplicate.
setopt no_beep              # don't beep on error
setopt auto_cd              # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt multios              # perform implicit tees or cats when multiple redirections are attempted
setopt prompt_subst         # enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)
setopt pushd_ignore_dups    # don't push multiple copies of the same directory onto the directory stack
setopt auto_pushd           # make cd push the old directory onto the directory stack
setopt pushdminus           # swapped the meaning of cd +1 and cd -1; we want them to mean the opposite of what they mean

# Fuzzy matching of completions for when you mistype them:
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' rehash true

bindkey '^[[1;5C' forward-word   # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word  # [Ctrl-LeftArrow] - move backward one word

sourcefiles(){
    source "${HOME}/.zplugin/user/variables"
    source "${HOME}/.zplugin/user/aliases"
    source "${HOME}/.zplugin/user/functions"
}
# Functions to make configuration less verbose
zt() { zplugin ice wait"${1}" lucid               "${@:2}"; } # Turbo
z()  { [ -z $2 ] && zplugin light "${@}" || zplugin "${@}"; } # zplugin

# Theme
zt "" pick'spaceship.zsh' compile'{spaceship.zsh-theme,lib/*,sections/*,tests/*.zsh}'
z denysdovhan/spaceship-prompt

# Oh-my-zsh libs
zt "" atinit'ZSH_CACHE_DIR="$HOME/.zcompcache"'
z snippet OMZ::lib/history.zsh

zt 0a
z snippet OMZ::lib/completion.zsh

sourcefiles

# Plugins
#zt "" atload'ZSH_EVALCACHE_DIR="$PWD/.zsh-evalcache"'
#z mroth/evalcache

zt 0b atclone"git reset --hard; sed -i '/DIR/c\DIR                   34;5;30' LS_COLORS; dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
z trapd00r/LS_COLORS

zt 0a has'systemctl'
z snippet OMZ::plugins/systemd/systemd.plugin.zsh

zt 0a
z snippet OMZ::plugins/extract/extract.plugin.zsh

zt 0b compile'{hsmw-*,test/*}'
z zdharma/history-search-multi-word

zt 0b
z ael-code/zsh-colored-man-pages

zt 0a make
z sei40kr/zsh-fast-alias-tips

zt 0b has'git' as'command'
z paulirish/git-open

zt 0b has'git'
z wfxr/forgit
#replaced gi with local git-ignore plugin

zt 0b has'git' pick'init.zsh' atload'alias gi="git-ignore"' blockf
z laggardkernel/git-ignore

zt 0a as'program' atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$PWD/.warprc"' blockf
z mfaerevaag/wd

zt 0a as'command' pick'updatelocal' atload'updatelocal() { source updatelocal }'
z NICHOLAS85/updatelocal

zt '[[ -n ${ZLAST_COMMANDS[(r)gcom*]} ]]' atload'gcomp(){ \gencomp $1 && zplugin creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
z RobSis/zsh-completion-generator
#loaded when needed via gcomp

zt 0b as'program' pick'rm-trash/rm-trash' atclone"git reset --hard; sed -i '2 i [[ \$EUID = 0 ]] && { echo \"Root detected, running builtin rm\"; command rm -I -v \"\${@}\"; exit; }' rm-trash/rm-trash" atpull'%atclone' atload'alias rm="rm-trash ${rm_opts}"' \
compile'rm-trash/rm-trash' nocompile'!'
z nateshmbhat/rm-trash

zt 0b has'thefuck' trackbinds bindmap'\e\e -> ^[OP^[OP' pick'init.zsh'
z laggardkernel/zsh-thefuck

zt 0a
z snippet OMZ::plugins/sudo/sudo.plugin.zsh

zt 0b
z snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

zt 0a atload'unalias help; unalias rm'
z snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh

zt 0a as'program' pick'bin/git-dsf'
z zdharma/zsh-diff-so-fancy

zt 0b nocompletions
z hlissner/zsh-autopair

zt 0a blockf atpull'zplugin creinstall -q .'
z zsh-users/zsh-completions

zt '[[ $isdolphin = false ]]'
z load desyncr/auto-ls

zt 0c atload'bindkey "$terminfo[kcuu1]" history-substring-search-up; bindkey "$terminfo[kcud1]" history-substring-search-down'
z zsh-users/zsh-history-substring-search

zt 0b compile'{src/*.zsh,src/strategies/*}' atload'_zsh_autosuggest_start' 
z zsh-users/zsh-autosuggestions

zt 0b pick'manydots-magic' compile'manydots-magic'
z knu/zsh-manydots-magic

zt 0b atinit'_zpcompinit_fast; zpcdreplay'
z zdharma/fast-syntax-highlighting

zt 0c id-as'Cleanup' atinit'unset -f zt z'
z zdharma/null 

dotscheck
