<div align="center">

# Docker image for ComfyUI: The most powerful and modular stable diffusion GUI, api and backend with a graph/nodes interface.

[![GitHub Repo](https://img.shields.io/badge/github-repo-green?logo=github)](https://github.com/ashleykleynhans/comfyui-docker)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/ashleykza/comfyui?logo=docker&label=dockerhub&color=blue)](https://hub.docker.com/repository/docker/ashleykza/comfyui)
[![RunPod.io Template](https://img.shields.io/badge/runpod_template-deploy-9b4ce6?logo=linuxcontainers&logoColor=9b4ce6)](https://runpod.io/console/deploy?template=9eqyhd7vs0&ref=2xxro4sy)
<br>
![Docker Pulls](https://img.shields.io/docker/pulls/ashleykza/comfyui?style=for-the-badge&logo=docker&label=Docker%20Pulls&link=https%3A%2F%2Fhub.docker.com%2Frepository%2Fdocker%2Fashleykza%2Fcomfyui%2Fgeneral)
![Template Version](https://img.shields.io/github/v/tag/ashleykleynhans/comfyui-docker?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBHZW5lcmF0b3I6IEFkb2JlIElsbHVzdHJhdG9yIDI2LjUuMywgU1ZHIEV4cG9ydCBQbHVnLUluIC4gU1ZHIFZlcnNpb246IDYuMDAgQnVpbGQgMCkgIC0tPgo8c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IgoJIHZpZXdCb3g9IjAgMCAyMDAwIDIwMDAiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDIwMDAgMjAwMDsiIHhtbDpzcGFjZT0icHJlc2VydmUiPgo8c3R5bGUgdHlwZT0idGV4dC9jc3MiPgoJLnN0MHtmaWxsOiM2NzNBQjc7fQo8L3N0eWxlPgo8Zz4KCTxnPgoJCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0xMDE3Ljk1LDcxMS4wNGMtNC4yMiwyLjM2LTkuMTgsMy4wMS0xMy44NiwxLjgyTDM4Ni4xNyw1NTUuM2MtNDEuNzItMTAuNzYtODYuMDItMC42My0xMTYuNiwyOS43MwoJCQlsLTEuNCwxLjM5Yy0zNS45MiwzNS42NS0yNy41NSw5NS44LDE2Ljc0LDEyMC4zbDU4NC4zMiwzMjQuMjNjMzEuMzYsMTcuNCw1MC44Miw1MC40NSw1MC44Miw4Ni4zMnY4MDYuNzYKCQkJYzAsMzUuNDktMzguNDEsNTcuNjctNjkuMTUsMzkuOTRsLTcwMy4xNS00MDUuNjRjLTIzLjYtMTMuNjEtMzguMTMtMzguNzgtMzguMTMtNjYuMDJWNjY2LjYzYzAtODcuMjQsNDYuNDUtMTY3Ljg5LDEyMS45Mi0yMTEuNjYKCQkJTDkzMy44NSw0Mi4xNWMyMy40OC0xMy44LDUxLjQ3LTE3LjcsNzcuODMtMTAuODRsNzQ1LjcxLDE5NC4xYzMxLjUzLDguMjEsMzYuOTksNTAuNjUsOC41Niw2Ni41N0wxMDE3Ljk1LDcxMS4wNHoiLz4KCQk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMTUyNy43NSw1MzYuMzhsMTI4Ljg5LTc5LjYzbDE4OS45MiwxMDkuMTdjMjcuMjQsMTUuNjYsNDMuOTcsNDQuNzMsNDMuODIsNzYuMTVsLTQsODU3LjYKCQkJYy0wLjExLDI0LjM5LTEzLjE1LDQ2Ljg5LTM0LjI1LDU5LjExbC03MDEuNzUsNDA2LjYxYy0zMi4zLDE4LjcxLTcyLjc0LTQuNTktNzIuNzQtNDEuOTJ2LTc5Ny40MwoJCQljMC0zOC45OCwyMS4wNi03NC45MSw1NS4wNy05My45Nmw1OTAuMTctMzMwLjUzYzE4LjIzLTEwLjIxLDE4LjY1LTM2LjMsMC43NS00Ny4wOUwxNTI3Ljc1LDUzNi4zOHoiLz4KCQk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMTUyNC4wMSw2NjUuOTEiLz4KCTwvZz4KPC9nPgo8L3N2Zz4K&logoColor=%23ffffff&label=Template%20Version&color=%23673ab7)

</div>

## Installs

* Ubuntu 22.04 LTS
* CUDA 12.4
* Python 3.12.9
* Torch 2.6.0
* xformers 0.0.29.post3
* [Jupyter Lab](https://github.com/jupyterlab/jupyterlab)
* [code-server](https://github.com/coder/code-server)
* [ComfyUI](https://github.com/comfyanonymous/ComfyUI) v0.3.33
* [runpodctl](https://github.com/runpod/runpodctl)
* [OhMyRunPod](https://github.com/kodxana/OhMyRunPod)
* [RunPod File Uploader](https://github.com/kodxana/RunPod-FilleUploader)
* [croc](https://github.com/schollz/croc)
* [rclone](https://rclone.org/)
* [Application Manager](https://github.com/ashleykleynhans/app-manager)
* [CivitAI Downloader](https://github.com/ashleykleynhans/civitai-downloader)

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/console/deploy?template=9eqyhd7vs0&ref=2xxro4sy)
to launch it on RunPod.

## Directory Structure

```tree
.
├── .editorconfig                # Editor configuration for consistent coding styles.
├── .gitattributes               # Defines attributes for paths in Git (e.g., line endings).
├── .github/                     # GitHub-specific files.
│   └── FUNDING.yml              # Project funding information.
├── .gitignore                   # Specifies intentionally untracked files that Git should ignore.
├── app-manager/                 # Scripts and configuration for the Application Manager.
│   ├── config.json              # Configuration for managed applications (e.g., ComfyUI).
│   ├── start_comfyui.sh         # Script to start ComfyUI (likely legacy/old, now handled by post_start.sh).
│   └── stop_comfyui.sh          # Script to stop ComfyUI.
├── base_image_src/              # Source files for building the internalized base Docker image.
│   ├── build_base/              # Scripts to install packages and applications in the base image.
│   │   ├── apps.sh              # Installs applications like Jupyter, code-server, etc.
│   │   └── packages.sh          # Installs system and Python packages for the base image.
│   ├── code_server_base/        # Configuration and extensions for code-server in the base image.
│   │   ├── settings.json        # Default settings for code-server.
│   │   └── vsix/                # Placeholder for VSIX extension files for code-server.
│   │       └── README.md        # README placeholder for VSIX files.
│   ├── nginx_base/              # Nginx-related files for the base image.
│   │   └── 502.html             # Custom 502 error page for Nginx.
│   └── scripts_base/            # Utility scripts for the base image runtime.
│       ├── fix_venv.sh          # Script to fix Python virtual environment paths.
│       ├── manage_venv.sh       # Script to backup/restore virtual environments.
│       └── start.sh             # Main entrypoint script for the Docker container (from the base image).
├── docker-bake.hcl              # Docker Bake file to define build targets and arguments.
├── Dockerfile                   # Main Dockerfile for building the ComfyUI application image, internalizing the base.
├── LICENSE                      # Project license file (GNU General Public License v3).
├── log-build.txt                # Log file from a Docker build process.
├── nginx/                       # Nginx configuration specific to the ComfyUI application.
│   └── nginx.conf               # Nginx configuration to proxy ComfyUI.
├── post_start.sh                # Script executed after the base start.sh, responsible for starting ComfyUI.
├── README.md                    # Project README with information on installation, usage, etc.
└── scripts/                     # Scripts for the ComfyUI application layer.
    ├── pre_start.sh             # Script executed by the base start.sh before post_start.sh; sets up ComfyUI in /workspace.
    └── start_comfyui.sh         # Original script to start ComfyUI (likely legacy/old, functionality moved to pre_start.sh and post_start.sh).
```

## Building the Docker image

> [!NOTE]
> You will need to edit the `docker-bake.hcl` file and update `REGISTRY_USER`,
> and `RELEASE`.  You can obviously edit the other values too, but these
> are the most important ones.

> [!IMPORTANT]
> In order to cache the models, you will need at least 32GB of CPU/system
> memory (not VRAM) due to the large size of the models.  If you have less
> than 32GB of system memory, you can comment out or remove the code in the
> `Dockerfile` that caches the models.

```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/comfyui-docker.git

# Log in to Docker Hub
docker login

# Build the image, tag the image, and push the image to Docker Hub
docker buildx bake -f docker-bake.hcl --push

# Same as above but customize registry/user/release:
REGISTRY=ghcr.io REGISTRY_USER=myuser RELEASE=my-release docker buildx \
    bake -f docker-bake.hcl --push
```

## Running Locally

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 2999:2999 \
  -p 3000:3001 \
  -p 7777:7777 \
  -p 8000:8000 \
  -p 8888:8888 \
  -e JUPYTER_PASSWORD=Jup1t3R! \
  -e EXTRA_ARGS=--lowvram \
  ashleykza/comfyui:latest
```

You can obviously substitute the image name and tag with your own.

### Ports

| Connect Port | Internal Port | Description          |
|--------------|---------------|----------------------|
| 3000         | 3001          | ComfyUI              |
| 7777         | 7777          | Code Server          |
| 8000         | 8000          | Application Manager  |
| 8888         | 8888          | Jupyter Lab          |
| 2999         | 2999          | RunPod File Uploader |

### Environment Variables

| Variable             | Description                                                       | Default               |
|----------------------|-------------------------------------------------------------------|-----------------------|
| JUPYTER_LAB_PASSWORD | Set a password for Jupyter lab                                    | not set - no password |
| DISABLE_AUTOLAUNCH   | Disable application from launching automatically                  | (not set)             |
| DISABLE_SYNC         | Disable syncing if using a RunPod network volume                  | (not set)             |
| EXTRA_ARGS           | Specify extra command line arguments for ComfyUI, eg. `--lowvram` | (not set)             |

## Logs

ComfyUI creates a log file, and you can tail it instead of
killing the service to view the logs

| Application | Log file                    |
|-------------|-----------------------------|
| ComfyUI     | /workspace/logs/comfyui.log |

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/comfyui-docker)
are welcome. Bug fixes and new features are encouraged.

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
