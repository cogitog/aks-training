FROM python:3.6.8-alpine3.10

ENV GLIBC_VER=2.31-r0
ENV AWSCLI_VERSION=1.18.53
ENV TERRAFORM_VERSION=0.13.5
ENV AZCLI_VERSION=2.14.2

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
        git \
        make \
        openssh \
        yarn \
        nodejs \ 
        bash \
    && apk add --no-cache --virtual .build-deps \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk 

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Install AWS CLI v.1.18.53
RUN apk -Uuv add groff less jq
RUN pip install awscli==${AWSCLI_VERSION}
RUN rm /var/cache/apk/*

# Install Azure CLI v2.14.2
RUN \
  apk update && \
  apk add bash py-pip && \
  apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make && \
  pip --no-cache-dir install -U pip && \
  pip --no-cache-dir install azure-cli==${AZCLI_VERSION} && \
  apk del --purge build
RUN az version

# Install terraform v0.13.5
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN mv terraform /usr/bin/terraform
RUN terraform version

#Clean up
RUN   apk --no-cache del \
        binutils \
        make \
        yarn \
        nodejs \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

# Setup profile 
RUN echo 'echo' >> ~/.bashrc && \
    echo 'echo "==========================="' >> ~/.bashrc && \
    echo 'terraform --version' >> ~/.bashrc && \
    echo 'echo "==========================="' >> ~/.bashrc && \
    echo 'echo' >> ~/.bashrc && \
    echo 'alias tf=terraform' >> ~/.bashrc && \
    echo 'echo' >> ~/.bashrc 

WORKDIR /project