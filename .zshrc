# https://github.com/NICHOLAS85/dotfiles/blob/xps_13_9365/.zshrc

ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-$HOME}/.zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-$ZPLG_BIN_DIR_NAME}:-bin}"
### Added by Zinit's installer
if [[ ! -f $ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$ZINIT_HOME" && command chmod g-rwX "$ZINIT_HOME"
    command git clone https://github.com/zdharma/zinit "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME" && \\
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \\
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

module_path+=( "${HOME}/.zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin &>/dev/null

if [[ ! -d "${ZINIT[PLUGINS_DIR]}/_local---config-files" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing local config-files…%f"
    curl https://codeload.github.com/NICHOLAS85/dotfiles/tar.gz/xps_13_9365 | \
    tar -xz --strip=3 dotfiles-xps_13_9365/.zinit/plugins/_local---config-files
    mv _local---config-files "${ZINIT[PLUGINS_DIR]}/"
fi

# Functions to make configuration less verbose
# zt() : First argument is a wait time and suffix, ie "0a". Anything that doesn't match will be passed as if it were an ice mod. Default ices depth'3' and lucid
# zct(): First argument provides $MYPROMPT value used in load'' and unload'' ices. Sources a config file with tracking for easy unloading using $MYPROMPT value. Small hack to function in for-syntax
zt()  { zinit depth'3' lucid ${1/#[0-9][a-c]/wait"$1"} "${@:2}"; }
zct() { .zinit-ice load"[[ \${MYPROMPT} = ${1} ]]" unload"[[ \${MYPROMPT} != ${1} ]]" \
        atinit'![ -f "${thmf}/${MYPROMPT}-pre" ] && source "${thmf}/${MYPROMPT}-pre"' \
        atload'![ -f "${thmf}/${MYPROMPT}-post" ] && source "${thmf}/${MYPROMPT}-post"'; \
        ZINIT_ICE+=("${(kv)ZINIT_ICES[@]}"); }

##################
# Initial Prompt #
# Config source  #
##################

zt for \
    pick'async.zsh' light-mode \
        mafredri/zsh-async \
    if'[[ ${MYPROMPT=spaceship-async2} = "spaceship-async2" ]]' pick'spacezsh.zsh' \
    compile'{presets/^(*.zwc),lib/**/^(*.zwc),sections/^(*.zwc)}' \
    atload'!source "../_local---config-files/themes/${MYPROMPT}-post"' silent \
        laggardkernel/spacezsh-prompt \
    blockf light-mode \
        _local/config-files

###########
# Annexes #
###########

zt light-mode compile'*handler' for \
        zinit-zsh/z-a-patch-dl \
        zinit-zsh/z-a-bin-gem-node \
        zinit-zsh/z-a-submods

############################
# Conditional themes block #
############################

zt pick'spaceship.zsh' compile'{lib/*,sections/*,tests/*.zsh}' for \
    if'zct spaceship-async' \
        maximbaz/spaceship-prompt \
    if'zct spaceship' \
        denysdovhan/spaceship-prompt \

zt pick'spacezsh.zsh' if'zct spaceship-async2' for \
    compile'{presets/^(*.zwc),lib/**/^(*.zwc),sections/^(*.zwc)}' \
        laggardkernel/spacezsh-prompt

zt pick"pure.zsh" patch"$pchf/%PLUGIN%.patch" nocompile'!' reset reset-prompt for \
    if'zct dolphin' \
        sindresorhus/pure

# Plugins

zt for  OMZ::lib/history.zsh

######################
# Trigger-load block #
######################

zt light-mode for \
    trigger-load'!x' \
        OMZ::plugins/extract/extract.plugin.zsh \
    trigger-load'!man' \
        ael-code/zsh-colored-man-pages \
    trigger-load'!ga;!gcf;!gclean;!gd;!glo;!grh;!gss' \
        wfxr/forgit \
    trigger-load'!zshz' blockf \
        agkozak/zsh-z \
    trigger-load'!updatelocal' blockf \
        NICHOLAS85/updatelocal \
    trigger-load'!gencomp' pick'zsh-completion-generator.plugin.zsh' blockf \
    atload'alias gencomp="zinit lucid nocd as\"null\" wait\"1\" atload\"zinit creinstall -q _local/config-files; zpcompinit\" for /dev/null; gencomp"' \
        RobSis/zsh-completion-generator

##################
# Wait'0a' block #
##################

zt 0a light-mode for \
    pick'fz.sh' patch"$pchf/%PLUGIN%.patch" nocompile'!' \
        changyuheng/fz \
        OMZ::lib/completion.zsh \
    as'completion' mv'*.zsh -> _git' \
        felipec/git-completion \
    has'systemctl' \
        OMZ::plugins/systemd/systemd.plugin.zsh \
        OMZ::plugins/sudo/sudo.plugin.zsh \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    compile'{src/*.zsh,src/strategies/*}' pick'zsh-autosuggestions.zsh' \
    atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions

##################
# Wait'0b' block #
##################

zt 0b light-mode for \
    pack'no-dir-color-swap' patch"$pchf/%PLUGIN%.patch" reset \
        trapd00r/LS_COLORS \
    compile'{hsmw-*,test/*}' \
        zdharma/history-search-multi-word \
        OMZ::plugins/command-not-found/command-not-found.plugin.zsh \
    pick'autopair.zsh' nocompletions \
        hlissner/zsh-autopair \
    pick'manydots-magic' nocompile \
        knu/zsh-manydots-magic \
    pick'autoenv.zsh' nocompletions \
        Tarrasch/zsh-autoenv \
    atinit'zicompinit_fast; zicdreplay' \
        zdharma/fast-syntax-highlighting \
    atload'bindkey "$terminfo[kcuu1]" history-substring-search-up;
    bindkey "$terminfo[kcud1]" history-substring-search-down' \
        zsh-users/zsh-history-substring-search \
    if'[[ ${isdolphin} != true ]]' patch"$pchf/%PLUGIN%.patch" nocompile'!' \
        desyncr/auto-ls

##################
# Wait'0c' block #
##################

zt 0c light-mode for \
    pack'bgn-binary' \
        junegunn/fzf \
    sbin from'gh-r' submods'sei40kr/zsh-fast-alias-tips -> plugin' pick'plugin/*.zsh' \
        sei40kr/fast-alias-tips-bin

zt 0c light-mode pick'/dev/null' for \
    sbin'fd*/fd; fd*/fd -> fdfind' from"gh-r" \
         @sharkdp/fd \
    sbin'bin/git-ignore' atload'export GI_TEMPLATE="$PWD/.git-ignore"; alias gi="git-ignore"' \
        laggardkernel/git-ignore

zt 0c light-mode as'null' for \
    sbin"bin/git-dsf;bin/diff-so-fancy" \
        zdharma/zsh-diff-so-fancy \
    sbin \
        paulirish/git-open \
    sbin'm*/micro' from"gh-r" ver'nightly' bpick'*linux64*' reset \
        zyedidia/micro \
    sbin'*/rm-trash' atload'alias rm="rm-trash ${rm_opts}"' reset \
    patch"$pchf/%PLUGIN%.patch" \
        nateshmbhat/rm-trash \
    id-as'Cleanup' nocd atinit'unset -f zct zt; SPACESHIP_PROMPT_ADD_NEWLINE=true' \
        zdharma/null

$isdolphin || {
dotscheck
[[ $PWD = ~ ]] && { cd "$(cat $TMPDIR/olddir)" } 2>/dev/null || true
trap @shexit EXIT
}
