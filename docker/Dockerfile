#
# docker build -f Dockerfile -t dustymugs/gdal-venv-deploy:latest .
#
# docker run --rm -e GITHUB_TOKEN=YOUR_GITHUB_TOKEN dustymugs/gdal-venv-deploy:latest version 3.4.2
#

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG GDAL_VENV_USER=gdal
ARG GDAL_VENV_PASSWORD=abc123

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git wget curl bzip2 unzip gnupg2 sudo && \
    echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd && \
    apt-get install -y lsb-release software-properties-common build-essential cmake autoconf && \
    apt-get install -y libproj-dev && \
    apt-get install -y python3-dev python3-pip python3-venv && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install -y gh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

# add user
RUN useradd -ms /bin/bash ${GDAL_VENV_USER} && \
    usermod -a -G sudo,users ${GDAL_VENV_USER} && \
    bash -c "echo ${GDAL_VENV_USER}:${GDAL_VENV_PASSWORD} | chpasswd"

#
# user stuff
#

USER ${GDAL_VENV_USER}

ENV USER_VENV="/home/${GDAL_VENV_USER}/venv"
ENV GITHUB_TOKEN=""

RUN git config --global user.email "dustymugs@gmail.com" && \
    git config --global user.name "Bborie Park (bot)"

RUN cd /home/${GDAL_VENV_USER} && \
    mkdir ${USER_VENV} && \
    python3 -m venv "${USER_VENV}" && \
    echo "source \"${USER_VENV}/bin/activate\"" >> /home/${GDAL_VENV_USER}/.bashrc && \
    . $USER_VENV/bin/activate && \
    pip install --upgrade pip packaging twine sh numpy && \
    pip cache purge

WORKDIR /home/${GDAL_VENV_USER}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
