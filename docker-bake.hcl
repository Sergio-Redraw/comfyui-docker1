// No seu docker-bake.hcl do comfyui-docker1

variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "redrawproarch" // Ou seu usuário
}

variable "APP" {
    default = "comfyui"
}

variable "RELEASE" {
    // Versão do seu app ComfyUI, não da imagem base
    default = "v0.3.33"
}

// Variáveis para construir a "base" dentro do Dockerfile
variable "NVIDIA_IMAGE_TAG" { // Ex: 12.1.1-cudnn8-devel-ubuntu22.04
    default = "12.1.1-cudnn8-devel-ubuntu22.04"
}
variable "PYTHON_VERSION_BASE" { // Python para a base
    default = "3.12"
}
variable "TORCH_VERSION_INSTALL" { // Torch para a base, ex: 2.5.1
    default = "2.5.1"
}
variable "CU_VERSION_SUFFIX" { // Versão CUDA para sufixo do Torch e INDEX_URL, ex: 121
    default = "121"
}
variable "XFORMERS_VERSION_INSTALL" { // Xformers para a base
    default = "0.0.29.post1"
}
variable "RUNPODCTL_VERSION_BASE" {
    default = "v1.14.4" // Verificar a última versão se necessário
}
variable "REQUIRED_CUDA_VERSION_START" { // Usado pelo start.sh da base
    default = "12.1"
}


target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}"]
    args = {
        // ARGS para a construção da base
        NVIDIA_IMAGE_TAG = "${NVIDIA_IMAGE_TAG}"
        PYTHON_VERSION_BASE = "${PYTHON_VERSION_BASE}"
        TORCH_VERSION_BASE = "${TORCH_VERSION_INSTALL}"
        CU_VERSION_BASE = "${CU_VERSION_SUFFIX}"
        INDEX_URL_BASE = "https://download.pytorch.org/whl/cu${CU_VERSION_SUFFIX}"
        XFORMERS_VERSION_BASE = "${XFORMERS_VERSION_INSTALL}"
        RUNPODCTL_VERSION_BASE = "${RUNPODCTL_VERSION_BASE}"
        REQUIRED_CUDA_VERSION_BASE = "${REQUIRED_CUDA_VERSION_START}"

        // Suas ARGS existentes para o ComfyUI
        // Cuidado para não conflitar nomes se forem diferentes em escopo/propósito
        RELEASE = "${RELEASE}" // Este é o release do ComfyUI app
        // BASE_IMAGE = ... <-- ESTA LINHA SERÁ REMOVIDA/ALTERADA
        // TORCH_VERSION = ... <-- Se for diferente da _BASE, precisará de um nome diferente ou ser a mesma
        // XFORMERS_VERSION = ... <-- Idem
        // INDEX_URL = ... <-- Idem
        COMFYUI_VERSION = "${RELEASE}" // Ou uma ARG específica COMFYUI_RELEASE
        APP_MANAGER_VERSION = "1.2.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
        // COMFYUI_COMMIT = "seu_commit_hash" // Se você usa commit específico

        // Pass the same installation versions to ComfyUI's install script ARGs
        // Your install_comfyui.sh expects TORCH_VERSION, XFORMERS_VERSION, INDEX_URL
        TORCH_VERSION = "${TORCH_VERSION_INSTALL}+cu${CU_VERSION_SUFFIX}" // Full version string for pip
        XFORMERS_VERSION = "${XFORMERS_VERSION_INSTALL}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION_SUFFIX}"
    }
    platforms = ["linux/amd64"]
}
