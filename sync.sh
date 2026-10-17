#!/usr/bin/env bash
# Copia la configuración actual del sistema al repo (sistema → repo).
# Uso: ./sync.sh   y luego revisa `git diff` antes de hacer commit.
set -euo pipefail
cd "$(dirname "$0")"

EXCLUDES=(--exclude '*.bak*' --exclude '*.backup' --exclude '.git')

while IFS= read -r p; do
    [[ -z "$p" || "$p" == \#* ]] && continue
    src="$HOME/$p"
    [[ -e "$src" ]] || { echo "falta: ~/$p" >&2; continue; }
    mkdir -p "home/$(dirname "$p")"
    if [[ -d "$src" ]]; then
        rsync -a --delete "${EXCLUDES[@]}" "$src/" "home/$p/"
    else
        rsync -a "$src" "home/$p"
    fi
done < files.txt

while IFS= read -r p; do
    [[ -z "$p" || "$p" == \#* ]] && continue
    [[ -r "$p" ]] || { echo "no se puede leer: $p" >&2; continue; }
    mkdir -p "etc/$(dirname "${p#/etc/}")"
    cp "$p" "etc/${p#/etc/}"
done < etc-files.txt

pacman -Qqe > packages/pacman-explicit.txt
pacman -Qqm > packages/aur.txt
echo "Listo. Revisa: git status && git diff"
