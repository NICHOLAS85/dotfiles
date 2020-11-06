# https://github.com/NICHOLAS85/dotfiles/blob/xps_13_9365_refresh/.zshrc

# Used to programatically disable plugins when opening the terminal view in dolphin
if [[ $MYPROMPT = dolphin ]]; then
    isdolphin=true
else
    isdolphin=false
    autoload -Uz chpwd_recent_dirs add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':chpwd:*' recent-dirs-file "${TMPDIR}/chpwd-recent-dirs"
    dirstack=($(awk -F"'" '{print $2}' ${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null))
    [[ ${PWD} = ~ ]] && { cd -q ${dirstack[1]} 2>/dev/null || true }
    dirstack=("${dirstack[@]:1}")
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-${HOME}}/.zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-${ZPLG_BIN_DIR_NAME}}:-bin}"
### Added by Zinit's installer
if [[ ! -f ${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
    command git clone https://github.com/zdharma/zinit "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

ZINIT[ZCOMPDUMP_PATH]="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache/zinit}}/zcompdump-${HOST/.*/}-${ZSH_VERSION}"
module_path+=( "${HOME}/.zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin &>/dev/null

# Functions to make configuration less verbose
# zt() : First argument is a wait time and suffix, ie "0a". Anything that doesn't match will be passed as if it were an ice mod. Default ices depth'3' and lucid
zt(){ zinit depth'3' lucid ${1/#[0-9][a-c]/wait"${1}"} "${@:2}"; }

##################
# Initial Prompt #
#    Annexes     #
# Config source  #
##################

zt light-mode compile'*handler' for \
        zinit-zsh/z-a-patch-dl \
        zinit-zsh/z-a-bin-gem-node \
        zinit-zsh/z-a-submods

zt light-mode blockf svn id-as for \
        https://github.com/NICHOLAS85/dotfiles/trunk/.zinit/snippets/config

(){
    if [[ -f ${thmf}/${1}-pre.zsh || -f ${thmf}/${1}-post.zsh ]] && {
        zt light-mode for \
                romkatv/powerlevel10k \
            id-as"${1}-theme" \
            atinit"[[ -f ${thmf}/${1}-pre.zsh ]] && source ${thmf}/${1}-pre.zsh" \
            atload"[[ -f ${thmf}/${1}-post.zsh ]] && source ${thmf}/${1}-post.zsh" \
                zdharma/null
    } || print -P "%F{220}Theme \"${1}\" not found%f"
} "${MYPROMPT=p10k}"

###########
# Plugins #
###########

######################
# Trigger-load block #
######################

zt light-mode for \
    trigger-load'!x' svn \
        OMZ::plugins/extract \
    trigger-load'!man' \
        ael-code/zsh-colored-man-pages \
    trigger-load'!ga;!grh;!glo;!gd;!gcf;!gclean;!gss;!gcp' \
        wfxr/forgit \
    trigger-load'!zshz' blockf \
        agkozak/zsh-z \
    trigger-load'!updatelocal' blockf compile'f*/*' \
        NICHOLAS85/updatelocal \
    trigger-load'!zhooks' \
        agkozak/zhooks \
    trigger-load'!gcomp' blockf \
    atclone'command rm -rf lib/*;git ls-files -z lib/ |xargs -0 git update-index --skip-worktree' \
    submods'RobSis/zsh-completion-generator -> lib/zsh-completion-generator;
    nevesnunes/sh-manpage-completions -> lib/sh-manpage-completions' \
    atload'gcomp(){gencomp "${@}" && zinit creinstall -q _local/config-files 1>/dev/null}' \
         Aloxaf/gencomp

##################
# Wait'0a' block #
##################

zt 0a light-mode for \
        OMZL::history.zsh \
        OMZL::completion.zsh \
        OMZP::systemd/systemd.plugin.zsh \
        OMZP::sudo/sudo.plugin.zsh \
    as'completion' blockf \
        zsh-users/zsh-completions \
    as'completion' mv'*.zsh -> _git' patch"${pchf}/%PLUGIN%.patch" reset \
        felipec/git-completion \
    pick'zsh-autosuggestions.zsh' ver'develop' atpull'zinit cclear' \
    atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions

##################
# Wait'0b' block #
##################

zt 0b light-mode for \
    autoload'#manydots-magic' \
        knu/zsh-manydots-magic \
    atinit'zicompinit_fast; zicdreplay' atload'FAST_HIGHLIGHT[chroma-man]=' \
    atclone'(){local f;cd -q →*;for f in *~*.zwc; do zcompile -Uz -- ${f};done}' \
    compile'.*fast*' nocompletions atpull'%atclone' \
        zdharma/fast-syntax-highlighting \
    pick'autopair.zsh' atload'bindkey "^H" backward-kill-word;ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
        hlissner/zsh-autopair \
    pick'autoenv.zsh' nocompletions \
        Tarrasch/zsh-autoenv \
    atload'bindkey "${terminfo[kcuu1]}" history-substring-search-up;
    bindkey "${terminfo[kcud1]}" history-substring-search-down' \
        zsh-users/zsh-history-substring-search

zt 0b light-mode patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' for \
    pick'fz.sh' atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(__fz_zsh_completion)' \
        changyuheng/fz \
    pack'no-dir-color-swap' atload"zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}" \
        trapd00r/LS_COLORS \
    pick'per-directory-history.zsh' \
        kadaan/per-directory-history \
    compile'h*' \
        zdharma/history-search-multi-word \
    pick'dircycle.zsh' trackbinds \
    bindmap'\e[1\;6D -> ^[[1\;5B; \e[1\;6C -> ^[[1\;5A' \
        michaelxmcbride/zsh-dircycle \
    blockf nocompletions compile'functions/*' atload'cdpath(){:}' \
        marlonrichert/zsh-edit \
    pick'fzf-tab.zsh' blockf compile'lib/*f*~*.zwc' \
        Aloxaf/fzf-tab

##################
# Wait'0c' block #
##################

zt 0c light-mode for \
    pack'bgn-binary' \
        junegunn/fzf

zt 0c light-mode binary for \
    sbin'fd*/fd;fd*/fd -> fdfind' from"gh-r" mv'**/fd.1 -> ${ZPFX}/man/man1' atpull'%atclone' \
        @sharkdp/fd \
    sbin'bat*/bat' from"gh-r" atclone'mv -f **/*.zsh _bat; mv -u **/bat.1 ${ZPFX}/man/man1' atpull'%atclone' \
        @sharkdp/bat \
    sbin'*/git-ignore' atload'export GI_TEMPLATE="${PWD}/.git-ignore"; alias gi="git-ignore"' \
        laggardkernel/git-ignore \
    sbin from"gh-r" mv'just.1 -> ${ZPFX}/man/man1' atclone'./just --completions zsh > _just' atpull'%atclone' \
        casey/just \
    sbin'lsd*/lsd' from"gh-r" \
        Peltoche/lsd \
    sbin \
        kazhala/dotbare

zt 0c light-mode null for \
    sbin"*/git-dsf;*/diff-so-fancy" \
        zdharma/zsh-diff-so-fancy \
    sbin \
        paulirish/git-open \
    sbin'm*/micro' from"gh-r" bpick'*linux64*' mv'**/micro.1 -> ${ZPFX}/man/man1' \
        zyedidia/micro \
    sbin'*/rm-trash' reset patch"${pchf}/%PLUGIN%.patch" mv'**/rm-trash.1 -> ${ZPFX}/man/man1' \
        nateshmbhat/rm-trash \
    id-as'Cleanup' nocd atinit'unset -f zt; _zsh_autosuggest_bind_widgets' \
        zdharma/null
