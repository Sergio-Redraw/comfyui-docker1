#!/usr/bin/env bash
set -euxo pipefail
ARGS=("$@" --listen 0.0.0.0 --port 3001)

export PYTHONUNBUFFERED=1
echo "Starting ComfyUI"
cd /workspace/ComfyUI
source venv/bin/activate
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
python3 main.py "${ARGS[@]}" > /workspace/logs/comfyui.log 2>&1 &
echo "ComfyUI started"
echo "Log file: /workspace/logs/comfyui.log"
deactivate
