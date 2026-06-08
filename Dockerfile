ARG RUBY_IMAGE
FROM mcr.microsoft.com/devcontainers/${RUBY_IMAGE}

ARG NODE_VERSION

# Prepare for Terraform
RUN echo "deb [trusted=yes] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

RUN echo "deb [arch=$(dpkg --print-architecture) trusted=yes] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list

RUN echo "deb [trusted=yes] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/postgres.list

# Remove yarn apt source with expired signing key (yarn is available via corepack)
RUN rm -f /etc/apt/sources.list.d/yarn.list

# Install additional OS packages.
RUN apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y install --no-install-recommends terraform gh libvips42t64 postgresql-client-17 python3-pip

# Install AWS CLI based on the architecture
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws && \
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
  dpkg -i session-manager-plugin.deb && \
  rm session-manager-plugin.deb; \
  else \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws; \
  fi

RUN curl -fsSL https://get.docker.com | sh

RUN . /usr/local/share/nvm/nvm.sh \
  && nvm install $NODE_VERSION

RUN npm install -g heroku

RUN gem install rails pull-request

COPY vendor/ngserver /opt/ngserver
RUN cd /opt/ngserver \
  && bundle install \
  && printf '#!/usr/bin/env bash\nexec /opt/ngserver/ngserver "$(pwd)" "$@"\n' > /usr/local/bin/ngserver \
  && chmod +x /usr/local/bin/ngserver

RUN pip install --break-system-packages weasyprint

RUN npx playwright install-deps
