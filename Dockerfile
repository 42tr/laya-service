# syntax=docker/dockerfile:1
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Non-root runtime user (HF cache lives under its home)
ARG UID=10001
ARG GID=10001
RUN groupadd --gid ${GID} laya \
    && useradd --uid ${UID} --gid ${GID} --create-home laya

RUN pip install "laya[serve]"

USER laya
WORKDIR /home/laya

ENV LAYA_HOST=0.0.0.0 \
    LAYA_PORT=8000 \
    LAYA_DEVICE=cpu \
    LAYA_PRELOAD=1 \
    OMP_NUM_THREADS=4 \
    HF_HOME=/home/laya/.cache/huggingface

EXPOSE 8000

# Server config is env-driven:
#   LAYA_MODELS    router aliases, e.g. "auto" / "english,multilingual,typed-decisions"
#   LAYA_API_KEY   optional bearer auth
#   LAYA_THREADS   worker threads
#   HF_TOKEN       optional Hugging Face credential for gated checkpoints
CMD ["laya-serve"]
