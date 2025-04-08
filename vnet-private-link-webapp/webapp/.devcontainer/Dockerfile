FROM mcr.microsoft.com/devcontainers/javascript-node:18

# 追加のパッケージをインストール
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    curl \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# グローバルなNode.jsパッケージをインストール
RUN npm install -g typescript @types/node