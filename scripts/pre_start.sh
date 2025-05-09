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

    echo "Installing custom ComfyUI nodes..."
    CUSTOM_NODES_DIR="${COMFYUI_DIR}/custom_nodes"
    # mkdir -p "${CUSTOM_NODES_DIR}" # ComfyUI-Manager clone already creates custom_nodes

    declare -a custom_node_urls=(
        "https://github.com/yolain/ComfyUI-Easy-Use.git"
        "https://github.com/stavsap/comfyui-ollama.git"
        "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
        "https://github.com/cubiq/ComfyUI_essentials.git"
        "https://github.com/sipherxyz/comfyui-art-venture.git"
        "https://github.com/jamesWalker55/comfyui-various.git"
        "https://github.com/evanspearman/ComfyMath.git"
        "https://github.com/lldacing/comfyui-easyapi-nodes.git"
        "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"
        "https://github.com/Fannovel16/comfyui_controlnet_aux.git"
        "https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git"
        "https://github.com/kijai/ComfyUI-SUPIR.git"
        "https://github.com/city96/ComfyUI-GGUF.git"
        "https://github.com/pydn/ComfyUI-to-Python-Extension.git"
        "https://github.com/shadowcz007/comfyui-mixlab-nodes.git"
        "https://github.com/Lightricks/ComfyUI-LTXVideo.git"
        "https://github.com/kijai/ComfyUI-IC-Light.git"
        "https://github.com/Acly/comfyui-inpaint-nodes.git"
        "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch.git"
        "https://github.com/crystian/ComfyUI-Crystools.git"
        "https://github.com/bash-j/mikey_nodes.git"
        "https://github.com/chrisgoringe/cg-use-everywhere.git"
        "https://github.com/jags111/efficiency-nodes-comfyui.git"
        "https://github.com/kijai/ComfyUI-KJNodes.git"
        "https://github.com/rgthree/rgthree-comfy.git"
        "https://github.com/shiimizu/ComfyUI_smZNodes.git"
        "https://github.com/WASasquatch/was-node-suite-comfyui.git"
        "https://github.com/cubiq/ComfyUI_InstantID.git"
        "https://github.com/cubiq/PuLID_ComfyUI.git"
        "https://github.com/Gourieff/ComfyUI-ReActor.git"
        "https://github.com/huchenlei/ComfyUI-layerdiffuse.git"
        "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
        "https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git"
        "https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git"
        "https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git"
        "https://github.com/storyicon/comfyui_segment_anything.git"
        "https://github.com/twri/sdxl_prompt_styler.git"
        "https://github.com/FizzleDorf/ComfyUI_FizzNodes.git"
        "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
        "https://github.com/melMass/comfy_mtb.git"
        "https://github.com/pythongosssss/ComfyUI-WD14-Tagger.git"
        "https://github.com/SLAPaper/ComfyUI-Image-Selector.git"
        "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
        "https://github.com/nihedon/ComfyUI_LCM.git"
        "https://github.com/lshqqytiger/ComfyUI-BRIA_AI-RMBG.git"
    )

    # Ensure venv is active for installing requirements.
    # The venv should already be active from earlier in this function.
    # If not, uncomment:
    # echo "Ensuring ComfyUI venv is active for custom node requirements installation..."
    # source "${COMFYUI_VENV_DIR}/bin/activate"

    for url in "${custom_node_urls[@]}"; do
        repo_name=$(basename "$url" .git)
        target_dir="${CUSTOM_NODES_DIR}/${repo_name}"
        echo "Processing custom node: ${repo_name}"
        if [ -d "${target_dir}" ]; then
            echo "Directory ${target_dir} already exists. Pulling latest changes..."
            cd "${target_dir}"
            git pull
            # Go back to the original directory just in case, though CUSTOM_NODES_DIR should be safe
            cd "${CUSTOM_NODES_DIR}" 
        else
            echo "Cloning ${repo_name} from ${url} into ${target_dir}..."
            git clone "$url" "${target_dir}"
        fi

        if [ -f "${target_dir}/requirements.txt" ]; then
            echo "Found requirements.txt for ${repo_name}, installing..."
            pip3 install --no-cache-dir -r "${target_dir}/requirements.txt"
        else
            echo "No requirements.txt found for ${repo_name}."
        fi
        echo "Finished processing ${repo_name}."
        echo # Add a blank line for better log readability
    done
    # The venv will be deactivated later by the main function script.

    echo "Downloading ComfyUI models..."
    COMFYUI_MODELS_DIR="${COMFYUI_DIR}/models"
    COMFYUI_CHECKPOINTS_DIR="${COMFYUI_MODELS_DIR}/checkpoints"
    COMFYUI_IPADAPTER_DIR="${COMFYUI_MODELS_DIR}/ipadapter"
    COMFYUI_CLIP_VISION_DIR="${COMFYUI_MODELS_DIR}/clip_vision"
    COMFYUI_CONTROLNET_DIR="${COMFYUI_MODELS_DIR}/controlnet"
    COMFYUI_CONTROLNET_LFS_REPOS_DIR="${COMFYUI_CONTROLNET_DIR}/lfs_clones" # Para clonar repositórios LFS

    mkdir -p "${COMFYUI_CHECKPOINTS_DIR}"
    mkdir -p "${COMFYUI_IPADAPTER_DIR}"
    mkdir -p "${COMFYUI_CLIP_VISION_DIR}"
    mkdir -p "${COMFYUI_CONTROLNET_DIR}"
    mkdir -p "${COMFYUI_CONTROLNET_LFS_REPOS_DIR}"

    # Função auxiliar para download de modelos
    download_model() {
        local url="$1"
        local target_dir="$2"
        local filename="$3"

        if [ -z "$filename" ]; then
            filename=$(basename "$url")
            filename="${filename%%\?*}" # Remove query string
        fi

        local target_file="${target_dir}/${filename}"

        echo "Checking for model: ${target_file}"
        if [ ! -f "${target_file}" ]; then
            echo "Downloading ${filename} to ${target_dir} from ${url}..."
            wget -c -nv -O "${target_file}.tmp" "$url"
            if [ $? -eq 0 ]; then
                mv "${target_file}.tmp" "${target_file}"
                echo "${filename} downloaded successfully."
            else
                echo "Warning: Failed to download ${url}. wget exit code: $?. Deleting tmp file if any."
                rm -f "${target_file}.tmp"
            fi
        else
            echo "${filename} already exists in ${target_dir}. Skipping."
        fi
    }

    # --- Checkpoints ---
    echo "Downloading Checkpoint models..."
    download_model "https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors" "${COMFYUI_CHECKPOINTS_DIR}" "flux1-schnell-fp8.safetensors"
    download_model "https://huggingface.co/sam749/Photon-v1/resolve/main/photon_v1.safetensors" "${COMFYUI_CHECKPOINTS_DIR}" "photon_v1.safetensors"
    download_model "https://huggingface.co/SG161222/RealVisXL_V5.0_Lightning/resolve/main/RealVisXL_V5.0_Lightning_fp16.safetensors" "${COMFYUI_CHECKPOINTS_DIR}" "RealVisXL_V5.0_Lightning_fp16.safetensors"
    download_model "https://huggingface.co/TheImposterImposters/tamePony_v25/resolve/main/tamePonyThe_v25.safetensors" "${COMFYUI_CHECKPOINTS_DIR}" "tamePonyThe_v25.safetensors"
    download_model "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors" "${COMFYUI_CHECKPOINTS_DIR}" "RealVisXL_V5.0_fp16.safetensors"

    # --- IPAdapter ---
    echo "Downloading IPAdapter models..."
    download_model "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors" "${COMFYUI_IPADAPTER_DIR}" "ip-adapter_sd15.safetensors"

    # --- CLIP Vision (para IPAdapter Plus) ---
    echo "Downloading CLIP Vision models..."
    download_model "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors" "${COMFYUI_CLIP_VISION_DIR}" "CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"

    # --- ControlNet ---
    echo "Downloading ControlNet models..."
    download_model "https://huggingface.co/xinsir/controlnet-canny-sdxl-1.0/resolve/main/diffusion_pytorch_model_V2.safetensors" "${COMFYUI_CONTROLNET_DIR}" "controlnet-canny-sdxl-1.0.safetensors"
    download_model "https://huggingface.co/xinsir/controlnet-depth-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" "${COMFYUI_CONTROLNET_DIR}" "controlnet-depth-sdxl-1.0.safetensors"
    download_model "https://huggingface.co/xinsir/controlnet-scribble-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" "${COMFYUI_CONTROLNET_DIR}" "controlnet-scribble-sdxl-1.0.safetensors"
    download_model "https://huggingface.co/xinsir/controlnet-tile-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" "${COMFYUI_CONTROLNET_DIR}" "controlnet-tile-sdxl-1.0.safetensors"

    # --- Git LFS Repositórios para ControlNet ---
    echo "Processing Git LFS ControlNet repositories..."

    # Repositório: ControlNet-v1-1_fp16_safetensors
    LFS_CN11_REPO_URL="https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors"
    LFS_CN11_REPO_NAME=$(basename "${LFS_CN11_REPO_URL}")
    LFS_CN11_CLONE_DIR="${COMFYUI_CONTROLNET_LFS_REPOS_DIR}/${LFS_CN11_REPO_NAME}"

    echo "Processing LFS repository: ${LFS_CN11_REPO_NAME}"
    if [ ! -d "${LFS_CN11_CLONE_DIR}/.git" ]; then # Check for .git to see if it's a valid clone
        echo "Cloning LFS repository ${LFS_CN11_REPO_URL} into ${LFS_CN11_CLONE_DIR}..."
        git clone "${LFS_CN11_REPO_URL}" "${LFS_CN11_CLONE_DIR}" || echo "Warning: Failed to clone ${LFS_CN11_REPO_URL}."
        if [ -d "${LFS_CN11_CLONE_DIR}/.git" ]; then
            (cd "${LFS_CN11_CLONE_DIR}" && git lfs pull || echo "Warning: git lfs pull failed for ${LFS_CN11_REPO_NAME}.")
        fi
    else
        echo "Repository ${LFS_CN11_REPO_NAME} already cloned. Attempting to update..."
        (cd "${LFS_CN11_CLONE_DIR}" && git pull && git lfs pull || echo "Warning: Update/LFS pull failed for ${LFS_CN11_REPO_NAME}.")
    fi

    if [ -d "${LFS_CN11_CLONE_DIR}" ]; then
        echo "Searching for .safetensors in ${LFS_CN11_CLONE_DIR} to link to ${COMFYUI_CONTROLNET_DIR}..."
        find "${LFS_CN11_CLONE_DIR}" -name "*.safetensors" -type f -print0 | while IFS= read -r -d $\'\\0\' model_file_path; do
            model_file_name=$(basename "$model_file_path")
            link_target_path="${COMFYUI_CONTROLNET_DIR}/${model_file_name}"
            
            # Check if link already exists and points to the correct file
            if [ -L "${link_target_path}" ] && [ "$(readlink "${link_target_path}")" = "${model_file_path}" ]; then
                echo "Correct link ${link_target_path} already exists. Skipping."
            elif [ -e "${link_target_path}" ]; then # File or incorrect link exists
                echo "File or other link ${link_target_path} already exists. Skipping link creation for ${model_file_name} to avoid overwrite."
            else # Link does not exist or broken link was implicitly handled by -e failing
                 echo "Creating symbolic link for ${model_file_name} at ${link_target_path}"
                 ln -s "$model_file_path" "$link_target_path" || echo "Warning: Failed to create symbolic link for ${model_file_name}."
            fi
        done
    else
        echo "Warning: Clone directory ${LFS_CN11_CLONE_DIR} not found. Skipping linking for ${LFS_CN11_REPO_NAME}."
    fi

    # Repositório: controlnet-union-sdxl-1.0
    LFS_CNUNION_REPO_URL="https://huggingface.co/xinsir/controlnet-union-sdxl-1.0"
    LFS_CNUNION_REPO_NAME=$(basename "${LFS_CNUNION_REPO_URL}")
    LFS_CNUNION_CLONE_DIR="${COMFYUI_CONTROLNET_LFS_REPOS_DIR}/${LFS_CNUNION_REPO_NAME}"
    LFS_CNUNION_MODEL_FILENAME="controlnet-union-sdxl-1.0_model.safetensors" # Custom name for the linked model

    echo "Processing LFS repository: ${LFS_CNUNION_REPO_NAME}"
    if [ ! -d "${LFS_CNUNION_CLONE_DIR}/.git" ]; then
        echo "Cloning LFS repository ${LFS_CNUNION_REPO_URL} into ${LFS_CNUNION_CLONE_DIR}..."
        git clone "${LFS_CNUNION_REPO_URL}" "${LFS_CNUNION_CLONE_DIR}" || echo "Warning: Failed to clone ${LFS_CNUNION_REPO_URL}."
        if [ -d "${LFS_CNUNION_CLONE_DIR}/.git" ]; then
             (cd "${LFS_CNUNION_CLONE_DIR}" && git lfs pull || echo "Warning: git lfs pull failed for ${LFS_CNUNION_REPO_NAME}.")
        fi
    else
        echo "Repository ${LFS_CNUNION_REPO_NAME} already cloned. Attempting to update..."
        (cd "${LFS_CNUNION_CLONE_DIR}" && git pull && git lfs pull || echo "Warning: Update/LFS pull failed for ${LFS_CNUNION_REPO_NAME}.")
    fi
    
    if [ -d "${LFS_CNUNION_CLONE_DIR}" ]; then
        original_model_path="${LFS_CNUNION_CLONE_DIR}/diffusion_pytorch_model.safetensors"
        link_target_path="${COMFYUI_CONTROLNET_DIR}/${LFS_CNUNION_MODEL_FILENAME}"
        if [ -f "$original_model_path" ]; then
            if [ -L "${link_target_path}" ] && [ "$(readlink "${link_target_path}")" = "${original_model_path}" ]; then
                 echo "Correct link ${link_target_path} already exists. Skipping."
            elif [ -e "${link_target_path}" ]; then
                 echo "File or other link ${link_target_path} already exists. Skipping link creation for ${LFS_CNUNION_MODEL_FILENAME}."
            else
                 echo "Creating symbolic link for ${LFS_CNUNION_MODEL_FILENAME} at ${link_target_path}"
                 ln -s "$original_model_path" "$link_target_path" || echo "Warning: Failed to create symbolic link for ${LFS_CNUNION_MODEL_FILENAME}."
            fi
        else
            echo "Warning: Expected model file ${original_model_path} not found in ${LFS_CNUNION_CLONE_DIR}. Cannot create link."
        fi
    else
        echo "Warning: Clone directory ${LFS_CNUNION_CLONE_DIR} not found. Skipping linking for ${LFS_CNUNION_REPO_NAME}."
    fi
    echo "Finished downloading and processing models."

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
