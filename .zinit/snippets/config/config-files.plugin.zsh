#Let Atom highlight this: -*- shell-script -*-

# According to the Zsh Plugin Standard:
# http://zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Then ${0:h} to get plugin's directory

# Autoload personal functions
fpath=("${0:h}/functions" "${fpath[@]}")
autoload -Uz $fpath[1]/*(.:t)

_zsh_autosuggest_strategy_dir_history(){ # Avoid Zinit picking this up as a completion
    emulate -L zsh
    if $_per_directory_history_is_global && [[ -r "$_per_directory_history_path" ]]; then
        setopt EXTENDED_GLOB
        local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
        local pattern="$prefix*"
        if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
        pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
        fi
        [[ "${dir_history[(r)$pattern]}" != "$prefix" ]] && \
        typeset -g suggestion="${dir_history[(r)$pattern]}"
    fi
}

_zsh_autosuggest_strategy_custom_history () {
        emulate -L zsh
        setopt EXTENDED_GLOB
        local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
        local pattern="$prefix*"
        if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]
        then
                pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
        fi
        [[ "${history[(r)$pattern]}" != "$prefix" ]] && \
        typeset -g suggestion="${history[(r)$pattern]}"
}

[[ $MYPROMPT != dolphin ]] && add-zsh-hook chpwd chpwd_ls

#########################
#       Variables       #
#########################

[[ -z ${fpath[(re)/usr/share/zsh/site-functions]} && -d /usr/share/zsh/site-functions ]] && fpath=( "${fpath[@]}" /usr/share/zsh/site-functions )
[[ -z ${path[(re)$HOME/bin]} && -d "$HOME/bin" ]] && path=( "$HOME/bin" "${path[@]}" )
[[ -z ${path[(re)$HOME/.local/bin]} && -d "$HOME/.local/bin" ]] && path=( "$HOME/.local/bin" "${path[@]}" )
ZINIT[ZCOMPDUMP_PATH]="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache/zinit}}/zcompdump-${HOST/.*/}-${ZSH_VERSION}"
#WORDCHARS=' *?_-.~\'
pchf="${0:h}/patches"
thmf="${0:h}/themes"
GENCOMPL_FPATH="${0:h}/completions"
GENCOMP_DIR="${0:h}/completions"
ZSHZ_DATA="${ZPFX}/z"
AUTOENV_AUTH_FILE="${ZPFX}/autoenv_auth"
PER_DIRECTORY_HISTORY_BASE="${ZPFX}/per-directory-history"
export HISTSIZE=501000
export SAVEHIST=500000
export HISTFILE="${XDG_DATA_HOME}/zsh/history"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export LESS="-FiMRSW -x4"
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"
export TMPPREFIX="${TMPDIR%/}/zsh"

# Directory checked for locally built projects (plugin NICHOLAS85/updatelocal)
UPDATELOCAL_GITDIR="${HOME}/Github/public"

ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c100,)" # Do not consider 100 character entries
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="[[:space:]]*"   # Ignore leading whitespace
ZSH_AUTOSUGGEST_MANUAL_REBIND=set
ZSH_AUTOSUGGEST_STRATEGY=(dir_history custom_history completion)
HISTORY_SUBSTRING_SEARCH_FUZZY=set
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=set
AUTOPAIR_CTRL_BKSPC_WIDGET=".backward-kill-word"
chwpd_dir_history_funcs=("_dircycle_update_cycled" ".zinit-cd")

export GI_TEMPLATE="${ZPFX}/git-ignore-template"
export OPENCV_LOG_LEVEL=ERROR # Hide nonimportant errors for howdy
export rm_opts=(-I -v)
export EDITOR=micro
export SYSTEMD_EDITOR=${EDITOR}
export GIT_DISCOVERY_ACROSS_FILESYSTEM=true # etckeeper on bedrock

FZF_DEFAULT_OPTS="
--border
--height 80%
--extended
--reverse
--cycle
--bind ctrl-s:toggle-sort
--bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
"
# --preview '(bat --color=always {} || ls --color=always \$(x={}; echo \"\${x/#\~/\$HOME}\")) 2>/dev/null | head -200'
# --preview-window right:65%:wrap
FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git 2>/dev/null"

FZ_HISTORY_CD_CMD=zshz
ZSHZ_CMD=" " # Do not set the alias, fz will cover that
ZSHZ_UNCOMMON=1
forgit_ignore="/dev/null" #replaced gi with local git-ignore plugin

# Strings to ignore when using dotscheck, escape stuff that could be wild cards (../)
dotsvar=( gtkrc-2.0 kwinrulesrc '\.\./' \.config/gtk-3\.0/settings\.ini )

# Export variables when connected via SSH
if [[ -n $SSH_CONNECTION ]]; then
    export DISPLAY=:0
    alias ls="lsd --group-dirs=first --icon=never"
else
    alias ls='lsd --group-dirs=first'
fi

# Set variables if on ac mode
#if [[ $(cat /run/tlp/last_pwr 2>/dev/null) = 0 ]]; then
    alias micro="micro -fastdirty false"
#fi

#########################
#       Aliases         #
#########################

# Access zsh config files
alias zshconf="(){ setopt extendedglob local_options; $EDITOR ${0:h}/config-files.plugin.zsh ${0:h}/themes/\${MYPROMPT}-*~*.zwc }"

alias t='tail -f'
alias g='git'
alias gi="git-ignore"
alias open='xdg-open'
alias atom='atom --disable-gpu'
alias ..='cd .. 2>/dev/null || cd "$(dirname $PWD)"' # Allows leaving from deleted directories
# Aesthetic function for Dolphin, clear -x if cd while in Dolphin
[[ $MYPROMPT = dolphin ]] && alias cd='clear -x; cd'

# dot file management
alias dots='DOTBARE_DIR="$HOME/.local/share/dotfiles/home" DOTBARE_TREE="$HOME" DOTBARE_BACKUP="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/home-backup" dotbare'
export DOTBARE_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"
export DOTBARE_DIFF_PAGER=delta

(( ${+commands[brl]} )) && {
(){ local stratum strata=( /bedrock/run/enabled_strata/* local)
for stratum in ${strata:t}; do
hash -d "${stratum}"="/bedrock/strata/${stratum}"
[[ "${stratum}" = "local" ]] && continue
alias "${stratum}"="strat ${stratum}"
alias "r${stratum}"="strat -r ${stratum}"
[[ -d "/bedrock/strata/${stratum}/etc/.git" ]] && \
alias "${stratum:0:1}edots"="command sudo strat -r ${stratum} git --git-dir=/etc/.git --work-tree=/etc"
done }
alias bedots="DOTBARE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/root DOTBARE_TREE=/bedrock DOTBARE_BACKUP=${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/root-backup dotbare"
}

#########################
#         Other         #
#########################

bindkey -e                  # EMACS bindings
#setopt inc_append_history       # Allow multiple terminal sessions to all append to one zsh command history
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

setopt no_beep              # do not beep on error
setopt auto_cd              # If you type foo, and it is not a command, and it is a directory in your cdpath, go there
setopt multios              # perform implicit tees or cats when multiple redirections are attempted
setopt prompt_subst         # enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)
setopt pushd_ignore_dups    # don't push multiple copies of the same directory onto the directory stack
setopt auto_pushd           # make cd push the old directory onto the directory stack
setopt pushdminus           # swapped the meaning of cd +1 and cd -1; we want them to mean the opposite of what they mean
setopt pushd_silent         # Silence pushd
setopt glob_dots            # Show dotfiles in completions
setopt extended_glob

# Fuzzy matching of completions for when you mistype them:
zstyle ':completion:*' completer _complete _match _list _ignored _correct _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Pretty completions
#zstyle ':completion:*:matches' group 'yes'
#zstyle ':completion:*:options' description 'yes'
#zstyle ':completion:*:options' auto-description '%d'
#zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
#zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:descriptions' format '[%d]'
#zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
#zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
#zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR
# do not include pwd after ../
zstyle ':completion:*' ignore-parents parent pwd
# Hide nonexistant matches, speeds up completion a bit
zstyle ':completion:*' accept-exact '*(N)'
# divide man pages by sections
zstyle ':completion:*:manuals' separate-sections true

# fzf-tab
zstyle ':fzf-tab:*' fzf-bindings 'space:accept,backward-eof:abort'   # Space as accept, abort when deleting empty space
zstyle ':fzf-tab:*' print-query ctrl-c        # Use input as result when ctrl-c
zstyle ':fzf-tab:*' accept-line enter         # Accept selected entry on enter
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' prefix ''                 # No dot prefix
zstyle ':fzf-tab:*' single-group color header # Show header for single groups
zstyle ':fzf-tab:*' switch-group ';' "'"      # Switch groups using ; and single quote
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man ${${=group}[4]} $word | col -bx | bat -l man -p --color always'
zstyle ':fzf-tab:complete:(cd|ls|lsd):*' fzf-preview '[[ -d $realpath ]] && ls -1 --color=always -- $realpath'
zstyle ':fzf-tab:complete:((micro|cp|rm|bat):argument-rest|kate:*)' fzf-preview 'bat --color=always -- $realpath 2>/dev/null || ls --color=always -- $realpath'
zstyle ':fzf-tab:complete:micro:argument-rest' fzf-flags --preview-window=right:65%
zstyle ':fzf-tab:complete:updatelocal:argument-rest' fzf-preview "git --git-dir=$UPDATELOCAL_GITDIR/\${word}/.git log --color --date=short --pretty=format:'%Cgreen%cd %h %Creset%s %Cred%d%Creset ||%b' ..FETCH_HEAD 2>/dev/null"
zstyle ':fzf-tab:complete:updatelocal:argument-rest' fzf-flags --preview-window=down:5:wrap
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap


bindkey '^[[1;5C' forward-word   # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word  # [Ctrl-LeftArrow]  - move backward one word
bindkey -s '^[[5~' ''            # Do nothing on pageup and pagedown. Better than printing '~'.
bindkey -s '^[[6~' ''
bindkey '^[[3;5~' kill-word      # ctrl+del   delete next word
bindkey '^I' expand-or-complete-prefix # Fix autopair completion within brackets
bindkey '^H' backward-kill-word
#bindkey '^h' _complete_help
