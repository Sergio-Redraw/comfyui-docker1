ARG NVIDIA_IMAGE_TAG="12.1.1-cudnn8-devel-ubuntu22.04"
FROM nvidia/cuda:${NVIDIA_IMAGE_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# --- BEGIN INTERNALIZED BASE IMAGE CONSTRUCTION ---

ARG PYTHON_VERSION_BASE
ARG TORCH_VERSION_BASE # Format X.Y.Z, e.g., 2.5.1
ARG CU_VERSION_BASE    # Format XYZ, e.g., 121
ARG INDEX_URL_BASE
ARG XFORMERS_VERSION_BASE
ARG RUNPODCTL_VERSION_BASE
ARG REQUIRED_CUDA_VERSION_BASE

# 1. Install Ubuntu packages (packages.sh)
COPY base_image_src/build_base/packages.sh /packages.sh
RUN chmod +x /packages.sh && \
    env PYTHON_VERSION=${PYTHON_VERSION_BASE} /packages.sh && \
    rm /packages.sh

# 2. Install Torch and xformers for the base
RUN pip3 install --no-cache-dir torch==${TORCH_VERSION_BASE}+cu${CU_VERSION_BASE} torchvision torchaudio --index-url ${INDEX_URL_BASE} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION_BASE} --index-url ${INDEX_URL_BASE}

# 3. Install applications (apps.sh)
COPY base_image_src/code_server_base/vsix/*.vsix /tmp/
COPY base_image_src/code_server_base/settings.json /root/.local/share/code-server/User/settings.json
COPY base_image_src/build_base/apps.sh /apps.sh
RUN chmod +x /apps.sh && \
    env RUNPODCTL_VERSION=${RUNPODCTL_VERSION_BASE} /apps.sh && \
    rm /apps.sh

# 4. NGINX Proxy file from base
COPY base_image_src/nginx_base/502.html /usr/share/nginx/html/502.html

# 5. Copy base utility scripts and setup
WORKDIR /
COPY --chmod=755 base_image_src/scripts_base/* /scripts_base/
RUN mv /scripts_base/manage_venv.sh /usr/local/bin/manage_venv

# 6. Remove existing SSH host keys (as in the original base Dockerfile)
RUN rm -f /etc/ssh/ssh_host_*

# 7. Set REQUIRED_CUDA_VERSION for the base's start.sh
ENV REQUIRED_CUDA_VERSION=${REQUIRED_CUDA_VERSION_BASE}

# Make COMFYUI_VERSION available as an environment variable for runtime scripts
ARG COMFYUI_VERSION
ENV COMFYUI_VERSION=${COMFYUI_VERSION}

# Make Torch/Xformers related ARGS also available as ENVs for pre_start.sh
ARG TORCH_VERSION
ENV TORCH_VERSION=${TORCH_VERSION}
ARG XFORMERS_VERSION
ENV XFORMERS_VERSION=${XFORMERS_VERSION}
ARG INDEX_URL
ENV INDEX_URL=${INDEX_URL}

# --- END INTERNALIZED BASE IMAGE CONSTRUCTION ---

# --- BEGIN YOUR COMFYUI SPECIFIC SETUP ---
WORKDIR /
# Copy your ComfyUI build scripts AND the post_start.sh
COPY --chmod=755 build/* ./
COPY --chmod=755 post_start.sh ./
COPY --chmod=755 scripts/pre_start.sh /pre_start.sh

# Install ComfyUI -- THIS SECTION WILL BE REMOVED/COMMENTED
# # These ARGs (TORCH_VERSION, XFORMERS_VERSION, INDEX_URL) are now passed from docker-bake.hcl,
# # sourced from TORCH_VERSION_INSTALL and CU_VERSION_SUFFIX.
# ARG TORCH_VERSION
# ARG XFORMERS_VERSION
# ARG INDEX_URL
# ARG COMFYUI_COMMIT
# ARG COMFYUI_VERSION
# RUN /install_comfyui.sh 

# Install Application Manager
ARG APP_MANAGER_VERSION
RUN /install_app_manager.sh
COPY app-manager/config.json /app-manager/public/config.json
COPY --chmod=755 app-manager/*.sh /app-manager/scripts/

# Install CivitAI Model Downloader
ARG CIVITAI_DOWNLOADER_VERSION
RUN /install_civitai_model_downloader.sh

# Cleanup installation scripts (ComfyUI specific ones)
RUN rm -f /install_comfyui.sh /install_app_manager.sh /install_civitai_model_downloader.sh

# NGINX Proxy (Your main NGINX config for ComfyUI)
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version (your application's version)
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# VENV_PATH is not explicitly set here as the base scripts manage /venv
# If ComfyUI needs a *separate* venv, that needs to be handled.

# COPY --chmod=755 scripts/* ./  -- This line is now removed/commented.
# Ensure this doesn't overwrite /scripts_base or essential files if your `scripts` dir has conflicting names

# Start the container using the base image's start.sh
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/scripts_base/start.sh" ]