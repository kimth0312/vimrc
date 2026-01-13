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

# fzf-git.sh 로드
source ~/fzf-git.sh/fzf-git.sh

# 리눅스 터미널 색상 활성화
alias ls='ls --color=auto'
export LS_COLORS="di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

# Vi mode 활성화 (이미 있다면 생략)
bindkey -v

# Ctrl+a (Home), Ctrl+e (End) 매핑
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
