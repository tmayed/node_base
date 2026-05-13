# ---------- Stage 1: build Python ----------
FROM debian:bookworm-slim AS builder

ARG MY_UID
ARG MY_GID
ARG MY_USER
ARG MY_GROUP
ARG PYTHON_V

ENV MY_USER=${MY_USER}
ENV DEBIAN_FRONTEND=noninteractive

# 1. We can drop C-compilers and dev headers because uv uses pre-built binaries.
# We mostly just need ca-certificates to securely download Python.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- robust user creation ----
RUN set -eux; \
    if getent group ${MY_GID}; then groupdel $(getent group ${MY_GID} | cut -d: -f1); fi; \
    if getent passwd ${MY_UID}; then userdel -f $(getent passwd ${MY_UID} | cut -d: -f1); fi; \
    groupadd -g ${MY_GID} ${MY_GROUP}; \
    useradd -m -u ${MY_UID} -g ${MY_GROUP} -s /bin/bash ${MY_USER}; \
    mkdir -p /home/${MY_USER}/.local; \
    chown -R ${MY_USER}:${MY_GROUP} /home/${MY_USER}

# ---- Copy uv directly from Astral's official image (recommended Docker workflow) ----
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# ---- Tell uv exactly where to store the downloaded Python versions ----
ENV UV_PYTHON_INSTALL_DIR="/opt/python"

# ---- Install Python and symlink it to the system PATH so it acts like a global install ----
RUN uv python install ${PYTHON_V} && \
    ln -sf $(uv python find ${PYTHON_V}) /usr/local/bin/python && \
    ln -sf /usr/local/bin/python /usr/local/bin/python3
