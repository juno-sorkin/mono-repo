FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Common tools needed by Pants, pre-commit, and Terraform tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    jq \
    ca-certificates \
    bash \
    tar \
    wget \
    gnupg \
  && rm -rf /var/lib/apt/lists/*

# Install Terraform
ARG TF_VERSION=1.13.0
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm /tmp/terraform.zip \
  && terraform -version

# Install tflint
ARG TFLINT_VERSION=0.53.0
RUN curl -fsSL https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -o /tmp/tflint.zip \
  && unzip /tmp/tflint.zip -d /usr/local/bin \
  && rm /tmp/tflint.zip \
  && tflint --version

# Install terraform-docs
ARG TF_DOCS_VERSION=0.20.0
RUN curl -fsSL https://github.com/terraform-docs/terraform-docs/releases/download/v${TF_DOCS_VERSION}/terraform-docs-v${TF_DOCS_VERSION}-linux-amd64.tar.gz -o /tmp/td.tar.gz \
  && tar -xzf /tmp/td.tar.gz -C /tmp \
  && mv /tmp/terraform-docs /usr/local/bin/ \
  && rm /tmp/td.tar.gz \
  && terraform-docs --version

# Install Pants
COPY ditty-bag/get-pants.sh /tmp/
RUN chmod +x /tmp/get-pants.sh && /tmp/get-pants.sh && rm /tmp/get-pants.sh

# Pre-commit used by workflows
RUN pip install --no-cache-dir pre-commit==4.3.0

# Useful defaults for Pants cache inside container
ENV PANTS_CONFIG_FILES=pants.toml
ENV PANTS_ENABLE_PANTSD=false

WORKDIR /work
