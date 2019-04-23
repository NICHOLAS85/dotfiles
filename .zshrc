# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
# End of lines configured by zsh-newuser-install

### Added by Zplugin's installer
source '/home/nicholas/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

setopt promptsubst
setopt append_history
setopt hist_ignore_all_dups
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_ignore_space      # ignore commands that start with space
setopt share_history          # share command history data
setopt no_beep

# Oh-my-zsh libs
zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/history.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/directories.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/git.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/key-bindings.zsh

zplugin ice wait"0" lucid atload"unalias grv"
zplugin snippet OMZ::plugins/git/git.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/completion.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/theme-and-appearance.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/grep.zsh

# Theme
zplugin light denysdovhan/spaceship-prompt

# Plugins
zplugin ice wait"0" lucid
zplugin light zdharma/history-search-multi-word

zplugin ice wait'0' if'[[ $(xdotool getwindowfocus getwindowname) != *Dolphin* ]]' lucid
zplugin load desyncr/auto-ls

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/systemd/systemd.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/sudo/sudo.plugin.zsh

zplugin ice wait"0" lucid make'!'
zplugin light sei40kr/zsh-fast-alias-tips

zplugin ice wait"0" lucid
zplugin light RogueScholar/flatpak-zsh-completion

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/extract/extract.plugin.zsh

zplugin ice wait'0' lucid
zplugin snippet OMZ::plugins/debian/debian.plugin.zsh

zplugin ice wait'0' lucid
zplugin light hlissner/zsh-autopair

#zplugin ice wait'0' lucid
#zplugin light RobSis/zsh-reentry-hook
#deleted, doesnt seem to be needed anymore?

#zplugin ice wait'0' if'[[ $(xdotool getwindowfocus getwindowname) != *Dolphin* ]]' lucid
#zplugin load gretzky/auto-color-ls
#deleted, replicated with auto-ls and functions

zplugin ice wait'0' lucid
zplugin light paulirish/git-open

zplugin ice lucid wait'0' atload'unalias gi'
zplugin load 'wfxr/forgit'
#replaced gi with local git-ignore plugin

#zplugin ice pick'init.zsh' blockf atload'alias gi="cgit-ignore"' wait'0' lucid
#zplugin light laggardkernel/git-ignore
#deleted, replaced with local git-ignore plugin

zplugin ice pick'_local-git-ignore.plugin.zsh' blockf atload'alias gi="cgit-ignore"' wait'0' lucid
zplugin light _local/_local-git-ignore

zplugin ice wait"0" lucid atload'unalias help; alias rm="rm -I"'
zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh

zplugin ice wait'0' lucid
zplugin light changyuheng/zsh-interactive-cd

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-completions

#zplugin ice from"gh" wait"0" silent pick"zsh-completion-generator.plugin.zsh" lucid
#zplugin light RobSis/zsh-completion-generator
#loaded when needed via function generatecomp

zplugin ice wait"0" atload"_zsh_autosuggest_start" lucid
zplugin light zsh-users/zsh-autosuggestions

zplugin ice wait"0" lucid atinit'zpcompinit; zpcdreplay'
zplugin light zdharma/fast-syntax-highlighting

source ~/.zplugin/user/aliases
source ~/.zplugin/user/variables
source ~/.zplugin/user/functions

if dots status | grep -q "Changes not staged" || dots status | grep -q "Changes to be committed"; then
    dots status
elif dots status | grep -q "ahead of"; then
    dots status
    dots push
fi
