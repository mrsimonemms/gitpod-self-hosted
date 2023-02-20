FROM gitpod/workspace-full-vnc
USER root
RUN apt-get -q update \
  && apt-get install -yq chromium-browser \
  && rm -rf /var/lib/apt/lists/*
# Azure
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
USER gitpod
RUN curl -sfL gpm.simonemms.com | bash \
  && gpm install hcloud helm kubectl pre-commit tfenv yq \
  && mkdir -p $HOME/.kube \
  && tfenv install \
  && tfenv use \
  && go install github.com/terraform-docs/terraform-docs@latest
