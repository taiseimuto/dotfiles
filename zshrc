export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8



# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------

typeset -U path PATH   # 重複を自動的に除去する
path=("$HOME/bin" "$HOME/.local/bin" $path)




# ---------------------------------------------------------------------------
# 関数
# ---------------------------------------------------------------------------

# --- Python 仮想環境 ---------------------------------------------------------

# カレントディレクトリから上に遡って .venv を探し、有効化する
activate() {
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            source "$dir/.venv/bin/activate"
            echo "venv を有効化しました: $dir/.venv"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    echo "activate: .venv が見つかりませんでした ($PWD より上の階層を探索)" >&2
    return 1
}


# --- Codex ---------------------------------------------------------------
# 会社用 Codex
codex-work() {
  CODEX_HOME="$HOME/.codex-work" command codex "$@"
}

# 個人用 Codex
codex-personal() {
  CODEX_HOME="$HOME/.codex-personal" command codex --yolo "$@"
}

alias codex="codex-work --yolo"

# --- プロキシ ---------------------------------------------------------------

readonly PROXY_HOST="po.cc.ibaraki-ct.ac.jp"
readonly PROXY_PORT="3128"
readonly PROXY_URL="http://${PROXY_HOST}:${PROXY_PORT}"

proxy() {
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
    export ftp_proxy="$PROXY_URL"
    export HTTP_PROXY="$PROXY_URL"
    export HTTPS_PROXY="$PROXY_URL"
    export FTP_PROXY="$PROXY_URL"
    export no_proxy="localhost,127.0.0.1,0.0.0.0"

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.system.proxy mode 'manual'
        gsettings set org.gnome.system.proxy.http host "$PROXY_HOST"
        gsettings set org.gnome.system.proxy.http port "$PROXY_PORT"
        gsettings set org.gnome.system.proxy.https host "$PROXY_HOST"
        gsettings set org.gnome.system.proxy.https port "$PROXY_PORT"
        gsettings set org.gnome.system.proxy.ftp host "$PROXY_HOST"
        gsettings set org.gnome.system.proxy.ftp port "$PROXY_PORT"
    fi

    echo "プロキシを有効化しました: $PROXY_URL"
}

proxyoff() {
    unset http_proxy https_proxy ftp_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY no_proxy

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.system.proxy mode 'none'
    fi

    echo "プロキシを無効化しました"
}


# ---------------------------------------------------------------------------
# nvm & brew
# ---------------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"
zstyle ':omz:plugins:nvm' lazy yes

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# ---------------------------------------------------------------------------
# Oh-My-Zsh
# ---------------------------------------------------------------------------

zstyle ':omz:compinit' use-cache yes

ZSH_THEME="simple"
plugins=(git copypath copyfile gh brew zsh-autosuggestions zsh-syntax-highlighting shrink-path nvm)

source $ZSH/oh-my-zsh.sh

# PROMPT='%{$fg[green]%}$(shrink_path -f)%{$reset_color%} $ '
PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[green]%}$(shrink_path -f)%{$reset_color%}$(git_prompt_info) $ '


# ---------------------------------------------------------------------------
# Alias
# ---------------------------------------------------------------------------

#alias ls='eza --group-directories-first --color=auto --icons=always'
alias ls='eza --group-directories-first --color=auto --icons=auto'
alias ll='eza -lah'
alias cat='bat --style=plain'
alias v='nvim'
alias memo='nvim ~/memo.md'
alias oc=opencode


if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi



# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
# 
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
