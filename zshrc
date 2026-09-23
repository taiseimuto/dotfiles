export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8



# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------

typeset -U path PATH   # 重複を自動的に除去する
path=("$HOME/.local/bin" $path)




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
    export no_proxy="localhost,127.0.0.1"

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
# Oh-My-Zsh
# ---------------------------------------------------------------------------

ZSH_THEME="simple"
plugins=(git copypath copyfile github brew zsh-autosuggestions zsh-syntax-highlighting zsh-completions shrink-path)

source $ZSH/oh-my-zsh.sh

# PROMPT='%{$fg[green]%}$(shrink_path -f)%{$reset_color%} $ '
PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[green]%}$(shrink_path -f)%{$reset_color%}$(git_prompt_info) $ '


# ---------------------------------------------------------------------------
# Alias
# ---------------------------------------------------------------------------
export CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1

alias ls='eza --group-directories-first --color=auto --icons=always'
alias ll='eza -lah'
alias cat='bat --style=plain'
alias v='nvim'
alias memo='nvim ~/memo.md'
alias claude='caffeinate claude'


if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi



# ---------------------------------------------------------------------------
# NVM の遅延読み込み
# ---------------------------------------------------------------------------
#   [高速化] nvm.sh は内部で多数の関数定義や補完設定を行うため、
#   素直に source すると起動時間に数百ms〜1秒近く上乗せされることが多い。
#   nvm/node/npm/npx を「実際に使うときだけ」読み込むようにし、
#   使わないシェルの起動を高速に保つ。
#
#   使い方は今まで通り (`nvm use 18`, `node -v` など) で変わらない。
#   初回呼び出し時だけ少し待つが、2回目以降は通常通りの速度で動作する。
export NVM_DIR="$HOME/.nvm"

#   NOTE: ヘルパ名は先頭アンダースコアを付けない。Claude Code が非対話シェル用に
#   取得する shell snapshot は `_` 始まりの関数を «内部用» として除外するため、
#   `_nvm_lazy_load` だと wrapper だけが取り込まれてヘルパが失われ、
#   node/npm/npx が「command not found: _nvm_lazy_load」で全滅する。
nvm_lazy_load() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm()  { nvm_lazy_load; nvm "$@"; }
node() { nvm_lazy_load; node "$@"; }
npm()  { nvm_lazy_load; npm "$@"; }
npx()  { nvm_lazy_load; npx "$@"; }



# Added by codebase-memory-mcp install
export PATH="/Users/mt/.local/bin:$PATH"
