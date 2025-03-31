FROM debian:bullseye-20230411-slim

ARG DEFAULT_TERRAFROM_VERSION=1.11.3
ARG TFENV_VERSION=v3.0.0
ARG TFLINT_VERSION=v0.55.1
ARG TFDOCS_VERSION=v0.19.0
ARG NODE_VERSION=node_20.x
ARG PNPM_VERSION=8.15.7

RUN apt-get update -y && \
    apt-get install -y curl git unzip gnupg2 build-essential && \
    # 日本語化
    apt-get install -y locales && \
    sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL ja_JP.UTF-8
    # jqインストール
RUN apt-get install -y jq
    # nodejsインストール
ENV NODE_VERSION="${NODE_VERSION}"
ENV NODE_KEYRING=/usr/share/keyrings/nodesource.gpg
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "${NODE_KEYRING}" >/dev/null
RUN gpg --no-default-keyring --keyring "${NODE_KEYRING}" --list-keys
RUN chmod a+r "${NODE_KEYRING}"
RUN . /etc/os-release && \
    DISTRO="${VERSION_CODENAME}" && \
    echo "deb [signed-by=${NODE_KEYRING}] https://deb.nodesource.com/${NODE_VERSION} ${DISTRO} main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src [signed-by=${NODE_KEYRING}] https://deb.nodesource.com/${NODE_VERSION} ${DISTRO} main" | tee -a /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -y && \
    apt-get install -y nodejs
    # azコマンドのインストール
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    # tfenvインストール
ENV TFENV_HOME=/usr/local/tfenv
ENV TFENV_TAR_URL=https://github.com/tfutils/tfenv/archive/refs/tags/${TFENV_VERSION}.tar.gz
ENV PATH=$PATH:${TFENV_HOME}/bin
RUN mkdir -p "${TFENV_HOME}" && \
    curl -fSL "${TFENV_TAR_URL}" | tar zxf - --strip-components=1 -C "${TFENV_HOME}"
    # デフォルトのterraformインストール
RUN tfenv install "${DEFAULT_TERRAFROM_VERSION}"
    # tflintインストール
ENV TFLINT_VERSION="${TFLINT_VERSION}"
RUN curl -fSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    # tfdocインストール
ENV TFDOCS_HOME=/usr/local/tfdocs
ENV PATH=$PATH:${TFDOCS_HOME}/bin
ENV TFDOCS_TAR_URL=https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-Linux-amd64.tar.gz
RUN mkdir -p "${TFDOCS_HOME}/bin" && \
    curl -fSL "${TFDOCS_TAR_URL}" | tar zxf - -C "${TFDOCS_HOME}" && \
    chmod +x "${TFDOCS_HOME}/terraform-docs" && \
    mv "${TFDOCS_HOME}/terraform-docs" "${TFDOCS_HOME}/bin/"
