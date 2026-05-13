# ---------- Stage 1: Downloader ----------
FROM debian:bookworm-slim AS downloader

ARG MY_USER
ARG NODE_VERSION

ENV MY_USER=${MY_USER}
ENV DEBIAN_FRONTEND=noninteractive

# We don't care about cleaning up apt here, this stage is thrown away
RUN apt-get update && apt-get install -y curl xz-utils ca-certificates
RUN mkdir -p /opt/node && \
    curl -fsSL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz \
    | tar -xJ -C /opt/node --strip-components=1

# ---------- Stage 2: Final Image ----------
FROM debian:bookworm-slim

ARG MY_UID
ARG MY_GID
ARG MY_USER
ARG MY_GROUP

ENV MY_USER=${MY_USER}

# Install ONLY the runtime requirement
RUN apt-get update && apt-get install -y --no-install-recommends \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# ---- robust user creation ----
RUN set -eux; \
    if getent group ${MY_GID}; then groupdel $(getent group ${MY_GID} | cut -d: -f1); fi; \
    if getent passwd ${MY_UID}; then userdel -f $(getent passwd ${MY_UID} | cut -d: -f1); fi; \
    groupadd -g ${MY_GID} ${MY_GROUP}; \
    useradd -m -u ${MY_UID} -g ${MY_GROUP} -s /bin/bash ${MY_USER}; \
    mkdir -p /home/${MY_USER}/.local; \
    chown -R ${MY_USER}:${MY_GROUP} /home/${MY_USER}

# Copy the completely built Node directory from the downloader stage
COPY --from=downloader /opt/node /usr/local/

USER $MY_USER
WORKDIR /home/$MY_USER

CMD ["/bin/bash"]