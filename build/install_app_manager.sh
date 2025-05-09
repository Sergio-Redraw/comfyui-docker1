#!/usr/bin/env bash
set -e
set -euxo pipefail
git clone https://github.com/ashleykleynhans/app-manager.git /app-manager
cd /app-manager
git checkout tags/${APP_MANAGER_VERSION}
npm install
