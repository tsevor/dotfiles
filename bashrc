shopt -s cdspell autocd
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

PS1errcode() {
	local ecode=$?
	if [ $ecode -ne 0 ]; then
		echo -e " \e[92m$ecode"
	fi
}

PS1='\e[96m\h\e[95m$PWD/$(PS1errcode)\e[m\n\$ '

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export EDITOR='vim'
export VISUAL='vim'

# let the server monitor know the truth
if ! [ "$TERM" = "linux" ]; then
	export TERM='xterm-256color'
	export COLORTERM='truecolor'
fi

. /usr/share/bash-completion/bash_completion

. ~/.bash_aliases

if [ -e ~/.bash_secret ]; then
	. ~/.bash_secret
fi
