#!/usr/bin/env bash
# Instala los dotfiles (repo → sistema). Lo que se reemplace queda en ~/.dotfiles-backup/<fecha>/.
#   ./install.sh            copia los archivos de usuario a $HOME
#   ./install.sh --link     igual, pero con symlinks hacia el repo
#                           (ojo: Noctalia reescribe settings.toml y rompe el symlink; ese siempre se copia)
#   ./install.sh --system   además copia etc/ a /etc con sudo (greetd, evdi)
set -euo pipefail
cd "$(dirname "$0")"
REPO="$PWD"
LINK=0 SYSTEM=0
for a in "$@"; do
    case "$a" in
        --link) LINK=1 ;;
        --system) SYSTEM=1 ;;
        *) echo "opción desconocida: $a" >&2; exit 1 ;;
    esac
done

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

while IFS= read -r p; do
    [[ -z "$p" || "$p" == \#* ]] && continue
    src="$REPO/home/$p" dst="$HOME/$p"
    [[ -e "$src" ]] || continue
    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP/$(dirname "$p")"
        mv "$dst" "$BACKUP/$p"
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ $LINK == 1 && "$p" != .local/state/* ]]; then
        ln -s "$src" "$dst"
    else
        cp -a "$src" "$dst"
    fi
    echo "✓ ~/$p"
done < files.txt

if [[ $SYSTEM == 1 ]]; then
    while IFS= read -r p; do
        [[ -z "$p" || "$p" == \#* ]] && continue
        sudo install -Dm644 "$REPO/etc/${p#/etc/}" "$p"
        echo "✓ $p"
    done < etc-files.txt
fi

[[ -d "$BACKUP" ]] && echo "Respaldo de lo reemplazado: $BACKUP"
