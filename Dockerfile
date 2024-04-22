ARG BASE_IMAGE
FROM $BASE_IMAGE

# Prepare for Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

RUN wget -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list

RUN wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/postgres.list

# Install additional OS packages.
RUN apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y install --no-install-recommends \
  software-properties-common terraform gh libvips42 postgresql-client-15 python3-pip watchman

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws

RUN curl -fsSL https://get.docker.com | sh

RUN . /usr/local/share/nvm/nvm.sh \
  && nvm install 18

RUN npm install -g heroku

RUN gem install rails pull-request

RUN pip install weasyprint

RUN npx playwright install-deps && npx playwright install chromium
