#!/usr/bin/env python3
# Android Emulator (X11 vía xwayland-satellite) en niri: mantiene la barra lateral
# (ventana "Emulator", angosta) en su propia columna justo a la derecha del
# emulador, para que se desplacen juntos en el scrolling como en X11.
# Satellite no puede posicionar la barra, y si al arrancar el emulador el foco
# estaba en otra app X11, la cuelga de esa app (ver Spotify en Wayland).
# niri abre la barra flotante (tamaño fijo): al verla por primera vez se pasa a
# mosaico. Si después alguna de las dos se pone flotante a mano, no se toca.
import fcntl
import json
import os
import select
import subprocess
import sys

APP_ID = "Emulator"
DEBOUNCE = 0.08

lock = open(os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "niri-emulator-toolbar.lock"), "w")
try:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    sys.exit(0)  # ya hay una instancia corriendo


def niri(*args):
    return subprocess.run(["niri", "msg", *args], capture_output=True, text=True)


def niri_json(*args):
    out = niri("-j", *args)
    return json.loads(out.stdout) if out.returncode == 0 else None


seen = set()  # ventanas del emulador ya vistas (solo se fuerza mosaico al abrir)


def tick():
    windows = niri_json("windows")
    if windows is None:
        return
    emu = [w for w in windows if w.get("app_id") == APP_ID]
    main = next((w for w in emu if (w.get("title") or "").startswith("Android Emulator")), None)
    bar = next((w for w in emu if w.get("title") == APP_ID and w["layout"]["tile_size"][0] < 120), None)
    for w in (main, bar):
        if w and w["id"] not in seen:
            seen.add(w["id"])
            if w.get("is_floating"):
                niri("action", "move-window-to-tiling", "--id", str(w["id"]))
                return  # el layout cambia; el siguiente evento hace el resto
    if not main or not bar or main.get("is_floating") or bar.get("is_floating"):
        return
    focused = next((w["id"] for w in windows if w.get("is_focused")), None)

    if bar["workspace_id"] != main["workspace_id"]:
        ws = next((s for s in niri_json("workspaces") or [] if s["id"] == main["workspace_id"]), None)
        if ws:
            niri("action", "move-window-to-workspace", "--window-id", str(bar["id"]),
                 "--focus", "false", str(ws["idx"]))
        return  # el siguiente evento la acomoda en su columna

    mcol = main["layout"]["pos_in_scrolling_layout"][0]
    bcol, brow = bar["layout"]["pos_in_scrolling_layout"]
    if bcol == mcol + 1 and brow == 1:
        return
    niri("action", "focus-window", "--id", str(bar["id"]))
    if bcol == mcol:
        niri("action", "expel-window-from-column")
        return
    # move-column-to-index usa el índice final (1-based); si la barra está a la
    # izquierda, al sacarla el emulador corre una posición.
    niri("action", "move-column-to-index", str(mcol if bcol < mcol else mcol + 1))
    if focused is not None and focused != bar["id"]:
        niri("action", "focus-window", "--id", str(focused))


stream = subprocess.Popen(["niri", "msg", "-j", "event-stream"], stdout=subprocess.PIPE, bufsize=0)
fd = stream.stdout.fileno()
tick()
dirty = False
while True:
    ready, _, _ = select.select([fd], [], [], DEBOUNCE if dirty else None)
    if ready:
        if not os.read(fd, 65536):
            break  # niri se cerró
        dirty = True
    elif dirty:
        dirty = False
        tick()
