#!/usr/bin/env python3
# Android Emulator (X11 vía xwayland-satellite) en niri:
#   - Pone flotantes todas sus ventanas. La regla open-floating de rules.kdl no
#     siempre aplica porque satellite fija el app-id después de abrir la ventana.
#   - Mantiene la barra lateral (ventana "Emulator", angosta) pegada a la derecha
#     del emulador, como en X11. Satellite no puede posicionarla en niri, y si al
#     arrancar el emulador el foco estaba en otra app X11, la cuelga de esa app.
import fcntl
import json
import os
import select
import subprocess
import sys

APP_ID = "Emulator"
GAP = 8  # px lógicos entre emulador y barra
DEBOUNCE = 0.08

lock = open(os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "niri-emulator-float.lock"), "w")
try:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    sys.exit(0)  # ya hay una instancia corriendo


def niri(*args):
    return subprocess.run(["niri", "msg", *args], capture_output=True, text=True)


def tick():
    out = niri("-j", "windows")
    if out.returncode != 0:
        return
    emu = [w for w in json.loads(out.stdout) if w.get("app_id") == APP_ID]
    for w in emu:
        if not w.get("is_floating"):
            niri("action", "move-window-to-floating", "--id", str(w["id"]))
            return  # el layout cambia; el siguiente evento hace el resto

    main = next((w for w in emu if (w.get("title") or "").startswith("Android Emulator")), None)
    bar = next((w for w in emu if w.get("title") == APP_ID and w["layout"]["tile_size"][0] < 120), None)
    if not main or not bar or main["workspace_id"] != bar["workspace_id"]:
        return
    mx, my = main["layout"]["tile_pos_in_workspace_view"] or (None, None)
    bx, by = bar["layout"]["tile_pos_in_workspace_view"] or (None, None)
    if mx is None or bx is None:
        return
    x = round(mx + main["layout"]["tile_size"][0] + GAP)
    y = round(my)
    if abs(bx - x) > 1 or abs(by - y) > 1:
        niri("action", "move-floating-window", "--id", str(bar["id"]),
             "-x", f"{x - bx:+.0f}", "-y", f"{y - by:+.0f}")


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
