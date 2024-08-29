# PYTHON_VERSION to be used (version 3.12-slim-bookworm)
ARG PYTHON=python:3.12-slim

############################################################################
####                        BASE IMAGE SETUP                            ####
############################################################################
FROM ${PYTHON} AS base
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # common environment paths
    PYSETUP_PATH=/opt/pysetup \
    VENV_FOLDER=myenv
ENV VENV_PATH=${PYSETUP_PATH}/${VENV_FOLDER}
# Prepend env to path
ENV PATH="$VENV_PATH/bin:$PATH"


############################################################################
####                             BUILD STAGE                            ####
############################################################################
FROM base AS build
ARG HOME_FOLDER=./compose/app

# Copy build script for system optimized packages
COPY ${HOME_FOLDER}/buildpkgs.sh .
# Build pip-required system packages for installing pip wheels to be cached.
RUN sh ./buildpkgs.sh

# Move to set up directory and install
WORKDIR ${PYSETUP_PATH}
COPY ${HOME_FOLDER}/requirements requirements

# create virtual env
RUN python -m venv ${VENV_FOLDER}

# install packages from requirements.txt
# NOTE: use venv path pip to install into the requisite folder
RUN ${VENV_PATH}/bin/pip install --no-cache-dir --upgrade pip \
    && ${VENV_PATH}/bin/pip install --no-cache-dir -r requirements/dev.txt


############################################################################
####                             FINAL IMAGE                            ####
############################################################################
FROM base AS runtime
ARG HOME_FOLDER=./compose/app \
    APP_FOLDER=/app \
    APP_USER=l33tuser

# Copy build script for system optimized packages
COPY ${HOME_FOLDER}/installpkgs.sh .
# Build pip-required system packages for installing pip wheels to be cached.
RUN sh ./installpkgs.sh \
    # create pysetup folder (needed to create virtual env)
    && mkdir -p ${PYSETUP_PATH} \
    # go to pysetup folder and create virtual env
    && cd ${PYSETUP_PATH} \
    && python -m venv ${VENV_FOLDER} \
    # create a non-root user and group
    && groupadd -r ${APP_USER} \
    && useradd -r -g ${APP_USER} ${APP_USER}

# # Copy built packages from build-stage
WORKDIR ${VENV_PATH}
COPY --from=build ${VENV_PATH} .

# # Copy python code
WORKDIR ${APP_FOLDER}
COPY --chown=${APP_USER}:${APP_USER} ./app .

# Switch to the non-root user
USER ${APP_USER}

# # Run fastapi
CMD ["fastapi", "run", "app/main.py", "--port", "8080"]
