#!/usr/bin/env bash
set -euxo pipefail

export PYTHONUNBUFFERED=1
export APP_NAME="ComfyUI" # Renamed from APP to avoid conflict if APP is used by base scripts

COMFYUI_DIR="/workspace/${APP_NAME}"
COMFYUI_VENV_DIR="${COMFYUI_DIR}/venv"
TEMPLATE_VERSION_FILE="${COMFYUI_DIR}/template.json" # Tracks version of ComfyUI setup in workspace

LOG_DIR="/workspace/logs"
mkdir -p "${LOG_DIR}" # Ensure logs directory exists early

echo "PRE-START for ${APP_NAME}"

echo "Template Version (from build): ${TEMPLATE_VERSION}" # This is TEMPLATE_VERSION from base Dockerfile, usually RunPod template version
echo "ComfyUI Version to install (from ENV): ${COMFYUI_VERSION}"

echo "Torch Version to install (from ENV): ${TORCH_VERSION}"
echo "XFormers Version to install (from ENV): ${XFORMERS_VERSION}"
echo "Index URL for Torch/XFormers (from ENV): ${INDEX_URL}"

# Function to install ComfyUI and its dependencies into the workspace
setup_comfyui_in_workspace() {
    echo "Setting up ComfyUI in ${COMFYUI_DIR}..."

    echo "Cloning ComfyUI repository..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
    cd "${COMFYUI_DIR}"
    if [ -n "${COMFYUI_VERSION}" ]; then
        echo "Checking out ComfyUI version: ${COMFYUI_VERSION}"
        git checkout "${COMFYUI_VERSION}"
    else
        echo "Warning: COMFYUI_VERSION not set, using default branch."
    fi

    echo "Creating Python virtual environment in ${COMFYUI_VENV_DIR}..."
    python3 -m venv --system-site-packages "${COMFYUI_VENV_DIR}"

    echo "Activating venv to install ComfyUI requirements..."
    source "${COMFYUI_VENV_DIR}/bin/activate"

    echo "Installing PyTorch, torchvision, torchaudio..."
    pip3 install --no-cache-dir torch=="${TORCH_VERSION}" torchvision torchaudio --index-url "${INDEX_URL}"
    
    echo "Installing xformers..."
    pip3 install --no-cache-dir xformers=="${XFORMERS_VERSION}" --index-url "${INDEX_URL}"

    echo "Installing ComfyUI requirements from requirements.txt..."
    if [ -f "requirements.txt" ]; then
        pip3 install --no-cache-dir -r requirements.txt
    else
        echo "Warning: requirements.txt not found in ${COMFYUI_DIR}"
    fi

    echo "Installing accelerate and sageattention..."
    pip3 install --no-cache-dir accelerate sageattention
    
    echo "Installing specific numpy version (1.26.4)..."
    pip3 install --no-cache-dir numpy==1.26.4
    # pip cache purge # Consider if needed

    echo "Installing ComfyUI-Manager..."
    COMFYUI_MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/ComfyUI-Manager"
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git "${COMFYUI_MANAGER_DIR}"
    if [ -f "${COMFYUI_MANAGER_DIR}/requirements.txt" ]; then
        pip3 install --no-cache-dir -r "${COMFYUI_MANAGER_DIR}/requirements.txt"
    else
        echo "Warning: requirements.txt not found in ${COMFYUI_MANAGER_DIR}"
    fi

    echo "Deactivating venv."
    deactivate

    # Save a marker or version file to indicate successful setup for this version
    # This uses COMFYUI_VERSION from ENV, which is set from RELEASE in docker-bake.hcl by default
    echo "{\"template_name\": \"${APP_NAME}\", \"comfyui_version\": \"${COMFYUI_VERSION}\", \"setup_timestamp\": \"$(date +%s)\"}" > "${TEMPLATE_VERSION_FILE}"
    echo "ComfyUI setup complete in ${COMFYUI_DIR} for version ${COMFYUI_VERSION}"
}

# Check if ComfyUI is already set up for the current version
SHOULD_SETUP_COMFYUI=true
if [ -f "${TEMPLATE_VERSION_FILE}" ]; then
    EXISTING_SETUP_VERSION=$(jq -r '.comfyui_version // empty' "${TEMPLATE_VERSION_FILE}")
    echo "Found existing ComfyUI setup version in workspace: ${EXISTING_SETUP_VERSION}"
    if [ "${EXISTING_SETUP_VERSION}" == "${COMFYUI_VERSION}" ]; then
        if [ -d "${COMFYUI_VENV_DIR}" ]; then # Also check if venv dir exists
             echo "ComfyUI version ${COMFYUI_VERSION} already set up in workspace. Skipping setup."
             SHOULD_SETUP_COMFYUI=false
        else
            echo "ComfyUI version ${COMFYUI_VERSION} marker found, but venv missing. Proceeding with setup."
        fi
    else
        echo "ComfyUI version mismatch (found ${EXISTING_SETUP_VERSION}, want ${COMFYUI_VERSION}). Proceeding with setup."
        # Optionally, could add logic here to remove the old COMFYUI_DIR before setting up the new one
        # rm -rf "${COMFYUI_DIR}" # Be careful with this!
    fi
else
    echo "No existing ComfyUI setup version file found. Proceeding with setup."
fi

if [ "${SHOULD_SETUP_COMFYUI}" = true ] ; then
    # Before setting up, check if the directory exists from a previous failed/partial setup or different version
    if [ -d "${COMFYUI_DIR}" ]; then
        echo "Warning: ${COMFYUI_DIR} already exists. This might be a partial setup or a different version. Re-cloning into it."
        # A safer approach might be to rename/backup the old dir first, then clone.
        # For now, let's assume git clone into existing dir handles things or fails gracefully if not empty and not a git repo.
        # A more robust solution: rm -rf "${COMFYUI_DIR}" before git clone, but ensure it's the right thing to do.
    fi
    setup_comfyui_in_workspace
fi

# The old sync_apps and fix_venvs are no longer needed here as ComfyUI is directly set up in /workspace.

# Start application manager (from original pre_start.sh)
if [ -d "/app-manager" ]; then # app-manager is installed in the image at /app-manager by install_app_manager.sh
    echo "Starting Application Manager..."
    cd /app-manager
    nohup npm start &> "${LOG_DIR}/app-manager.log" &
    echo "Application Manager started. Log: ${LOG_DIR}/app-manager.log"
else
    echo "Application Manager not found at /app-manager, skipping its start."
fi

# DO NOT start ComfyUI here. post_start.sh (called by base start.sh) will handle it.
# The original pre_start.sh had logic to call /start_comfyui.sh based on DISABLE_AUTOLAUNCH and EXTRA_ARGS.
# That responsibility is now with post_start.sh for ComfyUI.

echo "PRE-START script for ${APP_NAME} finished."
