#!/bin/sh
# Alterna la grabación de Screen Toolkit (Noctalia).
#   sin argumento → grabar una región (wf-recorder) · "full" → pantalla completa (gpu-screen-recorder)
# Si ya hay una grabación en curso, la detiene y Noctalia muestra Guardar MP4/GIF/Copiar/Descartar.
ST="noctalia msg plugin alexander/screen-toolkit:service all"
if pgrep -x 'wf-recorder|gpu-screen-reco' >/dev/null; then
    $ST recordStop
else
    if [ "$1" = full ]; then $ST recordFullscreenMp4; else $ST recordMp4; fi
fi
