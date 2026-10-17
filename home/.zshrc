source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Enviorment Variables
export PROTON_FSR4_UPGRADE=1
export PROTON_FSR4_RDNA3_UPGRADE=1
export PROTON_XESS_UPGRADE=1

export PROTON_ENABLE_WAYLAND=1
export PROTON_NO_WM_DECORATION=1

export PROTON_NO_NTSYNC=1
export PROTON_LOCAL_SHADER_CACHE=1

export PROTON_PREFER_SDL=1

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export PATH=$PATH:/home/sbcamacho/.spicetify

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Created by `pipx` on 2026-07-20 21:20:12
export PATH="$PATH:/home/sbcamacho/.local/bin"

export PATH=/home/sbcamacho/bin:$PATH

[[ -e "/home/sbcamacho/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/sbcamacho/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh"
