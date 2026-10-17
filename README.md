# dotfiles

Mi escritorio en **CachyOS**: [niri](https://github.com/YaLTeR/niri) (compositor scrollable en Wayland) + [Noctalia v5](https://docs.noctalia.dev) (barra, launcher, control center, notificaciones, lockscreen y greeter). Colores generados desde el fondo de pantalla (`m3-tonal-spot`, modo oscuro).

## Qué hay aquí

```
home/                     → espejo de $HOME
  .config/niri/           compositor: config.kdl + cfg/{keybinds,rules,input,display,...}.kdl
  .config/noctalia/       config.toml (barra, panels, OSD, plugins)
  .local/state/noctalia/  settings.toml (lo que guarda la UI de ajustes; tiene prioridad sobre config.toml)
  .config/kitty, nvim, yazi, btop, gtk-3.0/4.0, fontconfig, easyeffects, ...
  .zshrc, .p10k.zsh, .gitconfig
etc/                      → archivos de /etc (greetd + noctalia-greeter, módulo evdi para Orbiscreen)
packages/core.txt         → paquetes mínimos para llegar a esta configuración
packages/*.txt            → lista completa de paquetes instalados (pacman / AUR)
files.txt                 → qué rutas de $HOME se versionan
```

Los archivos `noctalia.*` (`niri/noctalia.kdl`, `kitty/themes/noctalia.conf`, `gtk-*/noctalia.css`, `btop/themes/noctalia.theme`, flavor de yazi) los **genera Noctalia** a partir del wallpaper; se incluyen para que todo funcione desde el primer arranque y se regeneran solos.

## Instalación

```sh
git clone git@github.com:sberrcamacho/dotfiles.git ~/Documents/code/repos/dotfiles
cd ~/Documents/code/repos/dotfiles

paru -S --needed - < <(grep -v '^#' packages/core.txt)
./install.sh            # copia a $HOME (respaldo en ~/.dotfiles-backup/<fecha>)
./install.sh --system   # además /etc: greetd + evdi (pide sudo)

sudo systemctl enable greetd   # (deshabilita antes sddm/gdm si los tienes)
```

`./install.sh --link` usa symlinks en vez de copias (excepto `settings.toml`, porque Noctalia lo reescribe).

Después:
- Pon wallpapers en `~/Pictures/Wallpapers` y elige uno desde Noctalia (los colores salen de ahí).
- Plugins de Noctalia: se activan solos según `settings.toml` → `[plugins] enabled`; si no, instálalos desde Ajustes → Plugins.
- `~/.face` = avatar del lockscreen/greeter.
- `etc/greetd`: el greeter guarda su estado en `/var/lib/noctalia-greeter/greeter.toml` (se sincroniza solo con `[shell.greeter_sync] auto_sync = true`).

## Actualizar el repo

```sh
./sync.sh        # copia la config actual del sistema al repo
git diff && git commit -am "..." && git push
```

## Atajos principales (niri)

| Atajo | Acción |
|---|---|
| `Super+Enter` | Kitty |
| `Super+Space` | Launcher |
| `Super+A` | Control center |
| `Super+I` | Ajustes de Noctalia |
| `Super+B` | Zen Browser |
| `Super+E` | Nautilus |
| `Super+Alt+L` | Bloquear |
| `Super+N` | Notas |
| `Super+Alt+T` / `O` / `M` | Tareas / Pomodoro / Temporizador |
| `Super+Alt+R` (`+Shift`) | Grabar región (pantalla completa) |
| `Super+Shift+T` / `C` | OCR / cuentagotas |
| `Super+/` | Todos los atajos |

Teclado `us,latam`, Caps Lock → Esc, Alt y Super intercambiados (`cfg/input.kdl`).
