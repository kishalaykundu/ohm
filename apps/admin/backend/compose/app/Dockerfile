# PYTHON DOCKER IMAGE (UV PROVIDES PRE-INSTALLED VERSION USED IN BUILD STAGE)
ARG PYTHON_VERSION=python3.12
ARG PYTHON_DOCKER_IMAGE=${PYTHON_VERSION}-bookworm-slim

############################################################################
####                    BUILD STAGE - uv pre-installed                  ####
############################################################################
FROM ghcr.io/astral-sh/uv:${PYTHON_DOCKER_IMAGE} AS build

# temporary var's for this set (will not be copied in image)
ARG HOME_FOLDER=compose/app

# uv settings (from https://hynek.me/articles/docker-uv/)
# - Silence uv complaining about not being able to use hard links,
# - tell uv to byte-compile packages for faster application startups,
# - prevent uv from accidentally downloading isolated Python builds,
# - pick a Python (use `/usr/bin/python3.12` on uv 0.5.0 and later),
# - and finally declare `/app` as the target for `uv sync`.
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=${PYTHON_VERSION} \
    UV_PROJECT_ENVIRONMENT=/app

# Compile and build dependent non-python packages and libraries
# Build pip-required system packages for installing cached pip wheels.
COPY ${HOME_FOLDER}/buildpkgs.sh .
RUN sh ./buildpkgs.sh

# Since there's no point in shipping lock files, we move them
# into a directory that is NOT copied into the runtime image.
# The trailing slash makes COPY create `/_lock/` automagically.
# The uv.lock format is so that it is copied only if it exists
COPY pyproject.toml u[v].lock /_lock/

# Build and install pip wheels to be copied in final stage
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


############################################################################
####                        FINAL IMAGE - sans uv                       ####
############################################################################
FROM ${PYTHON_DOCKER_IMAGE}

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# temporary var's for this set (will not be copied in image)
ARG HOME_FOLDER=compose/app \
    APP_FOLDER=/app \
    APP_USER=l33tuser

# Copy build script for system optimized packages
COPY ${HOME_FOLDER}/installpkgs.sh .

# Build pip-required system packages for cached pip wheels from build-stage.
RUN sh ./installpkgs.sh \
    # create a non-root user and group
    && groupadd -r ${APP_USER} \
    && useradd -r -g ${APP_USER} ${APP_USER}

# Copy venv from build-stage
COPY --from=build --chown=${APP_USER}:${APP_USER} ${VENV_PATH} ${VENV_PATH}

# Switch to the non-root user
USER ${APP_USER}

# # Run fastapi
CMD ["fastapi", "run", "app/main.py", "--port", "8080"]
