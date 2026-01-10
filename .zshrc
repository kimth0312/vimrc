# [중요] 만약 이 위에 p10k 관련 if문이 있다면 반드시 지우세요!

# 1. 기본 환경 변수 설정
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 2. Oh My Zsh 설정
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="" # Starship 사용을 위해 반드시 비워둠
# plugins=(git) # 에러 나는 플러그인은 여기서 제외

# source $ZSH/oh-my-zsh.sh

# 3. Alias 및 경로 설정
alias vim='nvim'
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

# alias ls='eza --icons --git'

# 4. 외부 도구 초기화 (순서가 중요합니다)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh           # fzf 로드
eval "$(zoxide init zsh --cmd cd)"              # zoxide 로드
eval "$(atuin init zsh)"                       # atuin (fzf보다 뒤에 와야 Ctrl+R 선점)
eval "$(starship init zsh)"                    # starship (프롬프트 최종 결정)

# 5. 플러그인 수동 로드 (Homebrew 설치분)
# zsh-autosuggestions도 brew로 설치했다면 아래처럼 추가하세요.
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

export EDITOR="nvim"

function yz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
