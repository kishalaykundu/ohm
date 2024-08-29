# PYTHON_VERSION to be used (version 3.12-slim-bookworm)
ARG PYTHON=python:3.12-slim

############################################################################
####                        BASE IMAGE SETUP                            ####
############################################################################
FROM ${PYTHON} AS base
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # add app directory to python path
    PYTHONPATH=/app \
    # common environment paths
    PYSETUP_PATH=/opt/pysetup \
    VENV_FOLDER=py312

# Prepend virtual env path to path
ENV VENV_PATH=${PYSETUP_PATH}/${VENV_FOLDER}
ENV PATH="$VENV_PATH/bin:$PATH"


############################################################################
####                             BUILD STAGE                            ####
############################################################################
FROM base AS build

# temporary var's for this set (will not be copied in image)
ARG HOME_FOLDER=compose/app

    # pip settings
ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # make poetry install to this location
    POETRY_HOME=/opt/poetry \
    # specify poetry virtual env path
    POETRY_VIRTUALENVS_PATH=${VENV_PATH} \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1

# Prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$PATH"

COPY ${HOME_FOLDER}/buildpkgs.sh .
# Build pip-required system packages for installing pip wheels to be cached.
RUN sh ./buildpkgs.sh \
    # install poetry - respects $POETRY_HOME
    && curl -sSL https://install.python-poetry.org | python

# Copy project requirement files here to ensure they will be cached.
WORKDIR ${PYSETUP_PATH}
COPY ${HOME_FOLDER}/pyproject.toml ./

# Install pip wheels - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install


############################################################################
####                             FINAL IMAGE                            ####
############################################################################
FROM base AS runtime

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
COPY --from=build ${VENV_PATH} ${VENV_PATH}

# Copy python code
WORKDIR ${APP_FOLDER}
COPY --chown=${APP_USER}:${APP_USER} app .

# Switch to the non-root user
USER ${APP_USER}

# # Run fastapi
CMD ["fastapi", "run", "app/main.py", "--port", "8080"]
