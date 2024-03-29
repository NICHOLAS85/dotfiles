# https://github.com/NICHOLAS85/dotfiles/blob/xps_13_9365_refresh/.zshrc
export TMP=${TMP:-${TMPDIR:-/tmp}}
export TMPDIR=$TMP
# Change shell behavior when opening the terminal view in dolphin. MYPROMPT set by konsole profile
if ! [[ $MYPROMPT = dolphin ]]; then
    # Use chpwd_recent_dirs to start new sessions from last working dir
    # Populate dirstack with chpwd history
    autoload -Uz chpwd_recent_dirs add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':chpwd:*' recent-dirs-file "${TMPDIR}/chpwd-recent-dirs"
    touch "${TMPDIR}/chpwd-recent-dirs"
    dirstack=("${(u)^${(@fQ)$(<${TMPDIR}/chpwd-recent-dirs 2>/dev/null)}[@]:#(\.|${TMPDIR:A}/*)}"(N-/))
    [[ ${PWD} = ${HOME}  || ${PWD} = "." ]] && (){
        local dir
        for dir ($dirstack){
            [[ -d "${dir}" ]] && { cd -q "${dir}"; break }
        }
    } 2>/dev/null
fi

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-${HOME}}/.zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-${ZPLG_BIN_DIR_NAME}}:-bin}"
### Added by Zinit's installer
if [[ ! -f "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
    command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME" && \\
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# A binary Zsh module which transparently and automatically compiles sourced scripts
module_path+=( "${HOME}/.zinit/module/Src" )
zmodload zdharma_continuum/zinit

# Functions to make configuration less verbose
# zt() : First argument is a wait time and suffix, ie "0a". Anything that doesn't match will be passed as if it were an ice mod. Default ices depth'3' and lucid
zt(){ zinit depth'3' lucid "${@}"; }

#################
#    Annexes    #
# Config source #
#     Prompt    #
#################

zt light-mode blockf svn id-as for \
        https://github.com/NICHOLAS85/dotfiles/trunk/.zinit/snippets/config

# zcompile doesn't support Unicode file names, planned on using compile'*handler' ice.
# https://www.zsh.org/mla/workers/2020/msg01057.html
zt light-mode for \
        zdharma-continuum/z-a-patch-dl \
        zdharma-continuum/z-a-submods \
        NICHOLAS85/z-a-linkman \
        NICHOLAS85/z-a-linkbin \
        atinit'Z_A_USECOMP=1' \
        NICHOLAS85/z-a-eval

(){ # Load $MYPROMPT configuration and powerlevel10k
    if [[ -f "${thmf}/${1}-pre.zsh" || -f "${thmf}/${1}-post.zsh" ]] && {
        zt light-mode for \
                romkatv/powerlevel10k \
            id-as"${1}-theme" \
            atinit"[[ -f ${thmf}/${1}-pre.zsh ]] && source ${thmf}/${1}-pre.zsh" \
            atload"[[ -f ${thmf}/${1}-post.zsh ]] && source ${thmf}/${1}-post.zsh" \
                zdharma-continuum/null
    } || print -P "%F{220}Theme \"${1}\" not found%f"
} "${MYPROMPT=p10k}"

###########
# Plugins #
###########

######################
# Trigger-load block #
######################

zt wait light-mode for \
    trigger-load'!x' svn \
        OMZ::plugins/extract \
    trigger-load'!ga;!grh;!grb;!glo;!gd;!gcf;!gclean;!gss;!gcp;!gcb' \
        wfxr/forgit \
    trigger-load'!ugit' \
        Bhupesh-V/ugit \
    trigger-load'!updatelocal' blockf compile'f*/*~*.zwc' \
        NICHOLAS85/updatelocal \
    trigger-load'!zhooks' \
        agkozak/zhooks \
    trigger-load'!gcomp' blockf \
    atclone'command rm -rf lib/*;git ls-files -z lib/ |xargs -0 git update-index --skip-worktree' \
    submods'RobSis/zsh-completion-generator -> lib/zsh-completion-generator;
    nevesnunes/sh-manpage-completions -> lib/sh-manpage-completions' \
    atload' gcomp(){gencomp "${@}" && zinit creinstall -q ${ZINIT[SNIPPETS_DIR]}/config 1>/dev/null}' \
         Aloxaf/gencomp

##################
# Wait'0a' block #
##################
zt light-mode for \
    atload'FAST_HIGHLIGHT[chroma-man]=' \
    atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- ${f}};}' \
    compile'.*fast*~*.zwc' nocompletions atpull'%atclone' \
        zdharma-continuum/fast-syntax-highlighting \
    atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions \
    compile'h*~*.zwc' \
        zdharma-continuum/history-search-multi-word \
    as'completion' atpull'zinit cclear' blockf \
        zsh-users/zsh-completions \
    as'completion' nocompile mv'*.zsh -> _git' patch"${pchf}/%PLUGIN%.patch" reset \
        felipec/git-completion \
    blockf \
        agkozak/zsh-z

##################
# Wait'0b' block #
##################

zt light-mode patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' for \
    blockf nocompletions compile'functions/*~*.zwc' \
        marlonrichert/zsh-edit \
    atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
        hlissner/zsh-autopair \
    atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(__fz_zsh_completion)' \
        changyuheng/fz \
    eval'dircolors -b LS_COLORS' atload"zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}" \
        trapd00r/LS_COLORS \
    atload'add-zsh-hook chpwd @chwpd_dir-history-var;
    add-zsh-hook zshaddhistory @append_dir-history-var; @chwpd_dir-history-var now' \
        kadaan/per-directory-history \
    trackbinds bindmap'\e[1\;6D -> ^[[1\;5B; \e[1\;6C -> ^[[1\;5A' \
        michaelxmcbride/zsh-dircycle

zt light-mode for \
    blockf compile'lib/*f*~*.zwc' \
        Aloxaf/fzf-tab \
    autoload'#manydots-magic' \
        knu/zsh-manydots-magic \
        RobSis/zsh-reentry-hook \
    pick'autoenv.zsh' nocompletions \
        Tarrasch/zsh-autoenv \
    atload'bindkey "^[[A" history-substring-search-up;
    bindkey "^[[B" history-substring-search-down' \
        zsh-users/zsh-history-substring-search \
        OMZP::systemd/systemd.plugin.zsh \
        OMZP::sudo/sudo.plugin.zsh

##################
# Wait'0c' block #
##################

zt light-mode binary from'gh-r' lman lbin for \
    bpick'*linux64*' \
        zyedidia/micro \
    atclone'mv -f **/*.zsh _bat' atpull'%atclone' \
        @sharkdp/bat \
        @sharkdp/hyperfine \
        @sharkdp/fd

zt light-mode binary for \
    lbin \
        laggardkernel/git-ignore \
    lbin from'gh-r' \
        Peltoche/lsd \
    lbin'!' patch"${pchf}/%PLUGIN%.patch" reset \
        kazhala/dotbare \
    lbin'antidot* -> antidot' from'gh-r' atclone'./**/antidot* update 1>/dev/null; ./**/antidot* completion zsh > _antidot' atpull'%atclone' eval'antidot init' \
        doron-cohen/antidot

zt light-mode null for \
    make lbin'build/*' \
        zdharma-continuum/zshelldoc \
    lbin'*d.sh;*n.sh' \
        bkw777/notify-send.sh \
    lbin from'gh-r' bpick'*gnu*' \
        rapiz1/catp \
    lbin from'gh-r' bpick'*x_x86*' \
        charmbracelet/glow \
    lbin \
        paulirish/git-open \
    lbin'*/delta;git-dsf' from'gh-r' patch"${pchf}/%PLUGIN%.patch" \
        dandavison/delta \
    lbin lman patch"${pchf}/%PLUGIN%.patch" reset \
        nateshmbhat/rm-trash \
    lbin from'gh-r' dl'https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1' lman \
        junegunn/fzf \
    id-as'Cleanup' nocd atinit'unset -f zt; zicompinit_fast; zicdreplay; _zsh_highlight_bind_widgets; _zsh_autosuggest_bind_widgets' \
        zdharma-continuum/null

