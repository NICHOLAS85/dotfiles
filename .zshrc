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
bindkey -e
setopt append_history
setopt hist_ignore_all_dups
setopt no_beep
setopt auto_cd
setopt multios
setopt prompt_subst

# Fuzzy matching of completions for when you mistype them:
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Functions to make configuration less verbose
zt_a() { zplugin ice wait"0a" lucid             "${@}"; } # Turbo a
zt_b() { zplugin ice wait"0b" lucid             "${@}"; } # Turbo b
zt_c() { zplugin ice wait"0c" lucid             "${@}"; } # Turbo c
zi()   { zplugin ice lucid                      "${@}"; } # zplugin ice
z()    { [ -z $2 ] && zplugin light "${@}" || zplugin "${@}"; } # zplugin

# Oh-my-zsh libs
zi
z snippet OMZ::lib/history.zsh

zt_a
z snippet OMZ::lib/directories.zsh

zt_a
z snippet OMZ::lib/git.zsh

zt_a
z snippet OMZ::lib/key-bindings.zsh

zt_a
z snippet OMZ::lib/completion.zsh

zt_a
z snippet OMZ::lib/grep.zsh

# Theme
z denysdovhan/spaceship-prompt

# Plugins
zt_b atclone"git reset --hard; sed -i '/DIR/c\DIR                   34;5;30' LS_COLORS; dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
z trapd00r/LS_COLORS

zt_a atload'unalias grv'
z snippet OMZ::plugins/git/git.plugin.zsh

zt_b
z zdharma/history-search-multi-word

zt_b
z ael-code/zsh-colored-man-pages

zt_a make
z sei40kr/zsh-fast-alias-tips

zt_a has'systemctl'
z snippet OMZ::plugins/systemd/systemd.plugin.zsh

zt_a has'flatpak'
z RogueScholar/flatpak-zsh-completion

zt_b has'git' as'command'
z paulirish/git-open

zt_b has'git'
z wfxr/forgit
#replaced gi with local git-ignore plugin

zt_a
z snippet OMZ::plugins/debian/debian.plugin.zsh

zt_a
z snippet OMZ::plugins/extract/extract.plugin.zsh

zt_a as'program' pick'wd.sh' mv'_wd.sh -> _wd' atload' wd() { source wd.sh }' blockf
z mfaerevaag/wd

zt_a as'program' pick'updatelocal' atload' updatelocal() { source updatelocal }'
z NICHOLAS85/updatelocal

zt_a has'git' \
atclone"git reset --hard; sed -i 's/git-ignore/cgit-ignore/g' init.zsh" \
mv'bin/git-ignore -> bin/cgit-ignore' atpull'%atclone' \
pick'init.zsh' atload'alias gi="cgit-ignore"' blockf
z laggardkernel/git-ignore

zi wait'[[ -n ${ZLAST_COMMANDS[(r)gcom*]} ]]' atload'gcomp(){ \gencomp $1 && zplugin creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
z RobSis/zsh-completion-generator
#loaded when needed via gcomp

zt_b has'thefuck' trackbinds bindmap'\e\e -> ^[OP^[OP' pick'init.zsh'
z laggardkernel/zsh-thefuck

zt_a
z snippet OMZ::plugins/sudo/sudo.plugin.zsh

zt_b
z snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

zt_a atload'unalias help; alias rm="rm -I"'
z snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh

zt_a as'program' pick'bin/git-dsf'
z zdharma/zsh-diff-so-fancy

zt_b
z hlissner/zsh-autopair

zt_a blockf
z zsh-users/zsh-completions

zi wait'[[ $isdolphin = false ]]'
z load desyncr/auto-ls

zt_a atload'_zsh_autosuggest_start'
z zsh-users/zsh-autosuggestions

zt_b atinit'zpcompinit; zpcdreplay'
z zdharma/fast-syntax-highlighting

zt_c id-as'Cleanup' atinit'unset -f zt_a zt_b zt_c zi z'
z zdharma/null 


source "${HOME}/.zplugin/user/variables"
source "${HOME}/.zplugin/user/aliases"
source "${HOME}/.zplugin/user/functions"

dotscheck
