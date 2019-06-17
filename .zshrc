# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTIGNORE='dots *'
bindkey -e
# End of lines configured by zsh-newuser-install

#Install zplugin if not installed
if [ ! -d "${HOME}/.zplugin" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
fi

### Added by Zplugin's installer
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

setopt append_history
setopt hist_ignore_all_dups
setopt no_beep

# Fuzzy matching of completions for when you mistype them:
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Oh-my-zsh libs
zplugin ice lucid
zplugin snippet OMZ::lib/theme-and-appearance.zsh

zplugin ice lucid
zplugin snippet OMZ::lib/history.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::lib/directories.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::lib/git.zsh

zplugin ice wait'0' lucid atload'unalias grv'
zplugin snippet OMZ::plugins/git/git.plugin.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::lib/key-bindings.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::lib/completion.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::lib/grep.zsh

# Theme
zplugin light denysdovhan/spaceship-prompt

# Plugins
zplugin ice wait'1' lucid
zplugin light zdharma/history-search-multi-word

zplugin ice wait'1' lucid
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zplugin ice wait'0' lucid make'!'
zplugin light sei40kr/zsh-fast-alias-tips

zplugin ice wait'0' has'systemctl' lucid
zplugin snippet OMZ::plugins/systemd/systemd.plugin.zsh

zplugin ice wait'0' has'flatpak' lucid
zplugin light RogueScholar/flatpak-zsh-completion

zplugin ice wait'0' lucid
zplugin snippet OMZ::plugins/debian/debian.plugin.zsh

zplugin ice wait'0' has'git' lucid
zplugin light paulirish/git-open

zplugin ice wait'0' has'git' atload'unalias gi' lucid
zplugin load 'wfxr/forgit'
#replaced gi with local git-ignore plugin

zplugin ice wait'0' as'program' pick'wd.sh' mv'_wd.sh -> _wd' atload' wd() { source wd.sh }' blockf lucid
zplugin light mfaerevaag/wd

zplugin ice wait'0' has'git' pick'init.zsh' blockf atload'alias gi="cgit-ignore"' lucid
zplugin light NICHOLAS85/_local-git-ignore

zplugin ice wait'[[ -n ${ZLAST_COMMANDS[(r)gcom*]} ]]' atload'gcomp(){ gencomp $1 && zplugin creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh' lucid
zplugin light RobSis/zsh-completion-generator
#loaded when needed

zplugin ice wait'0' lucid
zplugin snippet OMZ::plugins/extract/extract.plugin.zsh

zplugin ice wait'1' has'thefuck' trackbinds bindmap'\e\e -> ^[OP^[OP' pick'init.zsh'  lucid
zplugin light laggardkernel/zsh-thefuck

zplugin ice wait'0' lucid
zplugin snippet OMZ::plugins/sudo/sudo.plugin.zsh

zplugin ice wait'1' lucid
zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

zplugin ice wait'0' lucid atload'unalias help; alias rm="rm -I"'
zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh

zplugin ice wait'0' as'program' pick'bin/git-dsf' lucid
zplugin light zdharma/zsh-diff-so-fancy

zplugin ice wait'1' lucid
zplugin light hlissner/zsh-autopair

zplugin ice wait'0' blockf lucid
zplugin light zsh-users/zsh-completions

zplugin ice wait'[[ $isdolphin = false ]]' lucid
zplugin load desyncr/auto-ls

zplugin ice wait'0' atload'_zsh_autosuggest_start' lucid
zplugin light zsh-users/zsh-autosuggestions

zplugin ice wait'1' lucid atinit'zpcompinit; zpcdreplay'
zplugin light zdharma/fast-syntax-highlighting

source ~/.zplugin/user/variables
source ~/.zplugin/user/aliases
source ~/.zplugin/user/functions

dotscheck
