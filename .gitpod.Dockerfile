FROM gitpod/workspace-full-vnc
USER root
RUN apt-get -q update \
  && apt-get install -yq chromium-browser \
  && rm -rf /var/lib/apt/lists/*
USER gitpod
