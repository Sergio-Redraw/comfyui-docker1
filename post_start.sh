#!/usr/bin/env bash
set -euxo pipefail

# set -euxo pipefail # Consider adding this for stricter error checking if desired

echo "POST-START: Starting ComfyUI specific services..."

COMFYUI_DIR="/workspace/ComfyUI"
LOG_DIR="/workspace/logs"
LOG_FILE="${LOG_DIR}/comfyui.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

if [ -d "${COMFYUI_DIR}" ]; then
    echo "Found ComfyUI at ${COMFYUI_DIR}, attempting to start..."
    cd "${COMFYUI_DIR}"

    # Activate ComfyUI's virtual environment if it exists
    if [ -f "venv/bin/activate" ]; then
        echo "Activating venv in ${COMFYUI_DIR}/venv..."
        source "venv/bin/activate"
    else
        echo "Warning: venv not found at ${COMFYUI_DIR}/venv/bin/activate. Using system Python."
    fi

    # Configure TCMalloc for performance, if available
    TCMALLOC_PATH=""
    if command -v ldconfig &> /dev/null; then
        TCMALLOC_CANDIDATE=$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)
        if [ -n "${TCMALLOC_CANDIDATE}" ]; then
            TCMALLOC_PATH="${TCMALLOC_CANDIDATE}"
            export LD_PRELOAD="${TCMALLOC_PATH}"
            echo "Using TCMalloc: ${TCMALLOC_PATH}"
        else
            echo "libtcmalloc.so not found by ldconfig. TCMalloc not enabled."
        fi
    else
        echo "ldconfig command not found. TCMalloc check skipped."
    fi
    
    # Base arguments. ComfyUI internal port should be 3001 for Nginx proxy.
    # Using /workspace for inputs/outputs from previous step.
    COMFYUI_BASE_ARGS="--listen --port 3001 --output-directory /workspace/comfyui_outputs --input-directory /workspace/comfyui_inputs"
    
    # Create I/O directories if they don't exist
    mkdir -p /workspace/comfyui_outputs
    mkdir -p /workspace/comfyui_inputs

    FINAL_ARGS="${COMFYUI_BASE_ARGS}"
    # Check for EXTRA_ARGS environment variable to append custom arguments passed to the container
    # Use ${EXTRA_ARGS-} to provide an empty string if EXTRA_ARGS is unbound, preventing script exit with set -u
    if [ -n "${EXTRA_ARGS-}" ]; then
        echo "Appending EXTRA_ARGS from environment: ${EXTRA_ARGS}"
        FINAL_ARGS="${FINAL_ARGS} ${EXTRA_ARGS}"
    else
        echo "EXTRA_ARGS is not set or is empty. No additional arguments will be appended."
    fi
    
    echo "Starting ComfyUI with args: ${FINAL_ARGS}"
    echo "Check log at ${LOG_FILE}"
    
    # Using python3, assuming it's correct after venv activation or system python.
    nohup python3 main.py ${FINAL_ARGS} &> "${LOG_FILE}" &
    
    # Deactivate venv if it was activated
    if [ -f "venv/bin/activate" ]; then # Check again in case activation failed
        if [[ "$(type -t deactivate)" == "function" ]]; then # Check if deactivate is a function
            echo "Deactivating venv."
            deactivate
        fi
    fi
else
    echo "ERROR: ComfyUI directory not found at ${COMFYUI_DIR}. Cannot start ComfyUI."
fi

echo "POST-START: ComfyUI specific services script finished." 