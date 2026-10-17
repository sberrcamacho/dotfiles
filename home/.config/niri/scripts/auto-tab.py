#!/usr/bin/env python3
# Máximo 2 ventanas apiladas por columna en niri.
#   Columna pasa de 2 a 3+ ventanas → se pone en modo pestañas.
#   Una columna que este script puso en pestañas baja a 2 o menos → vuelve a apilada.
# niri solo cambia el modo de la columna enfocada, así que el cambio se aplica
# cuando la columna tiene el foco (al apilar con Mod+[ / Mod+, ya lo tiene).
# Un Mod+W manual no se pelea: solo se actúa en la transición, no en cada evento.
import fcntl
import json
import os
import select
import subprocess
import sys

MAX_STACK = 2
DEBOUNCE = 0.08  # segundos: los eventos de layout llegan en ráfagas

lock = open(os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "niri-auto-tab.lock"), "w")
try:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    sys.exit(0)  # ya hay una instancia corriendo


def niri_json(*args):
    out = subprocess.run(["niri", "msg", "-j", *args], capture_output=True, text=True)
    return json.loads(out.stdout) if out.returncode == 0 else None


def set_display(mode):
    subprocess.run(["niri", "msg", "action", "set-column-display", mode], capture_output=True)


prev_size = {}  # ventana → tamaño de su columna en la pasada anterior
auto_tabbed = set()  # ventanas en columnas que este script puso en pestañas
pending = {}  # ventana → "tabbed" | "normal", a aplicar cuando su columna tenga el foco


def tick():
    windows = niri_json("windows")
    if windows is None:
        return
    columns, focused = {}, None
    for w in windows:
        pos = (w.get("layout") or {}).get("pos_in_scrolling_layout")
        if w.get("is_floating") or not pos:
            continue
        columns.setdefault((w["workspace_id"], pos[0]), []).append(w["id"])
        if w.get("is_focused"):
            focused = w["id"]

    alive = set()
    for ids in columns.values():
        size = len(ids)
        alive.update(ids)
        before = max((prev_size.get(i, 0) for i in ids), default=0)
        if size > MAX_STACK and before <= MAX_STACK:
            for i in ids:
                pending[i] = "tabbed"
        elif size <= MAX_STACK and any(i in auto_tabbed for i in ids):
            for i in ids:
                pending[i] = "normal"
        for i in ids:
            prev_size[i] = size

    for d in (prev_size, pending):
        for i in [i for i in d if i not in alive]:
            del d[i]
    auto_tabbed.intersection_update(alive)

    if focused in pending:
        col = next(ids for ids in columns.values() if focused in ids)
        mode = pending[focused]
        set_display(mode)
        for i in col:
            pending.pop(i, None)
            (auto_tabbed.add if mode == "tabbed" else auto_tabbed.discard)(i)


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
