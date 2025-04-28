ARG BASE_IMAGE="ubuntu"
ARG TAG="22.04"
FROM ${BASE_IMAGE}:${TAG}

COPY ./bin/*.deb /opt
COPY ./bin/amd64/ /usr/local/bin/
COPY ./bin/ftrex /opt/ftrex
COPY ./bin/cafta /opt/cafta
COPY ./bin/saphire8 /opt/saphire8

ENV DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FRONTEND=noninteractive
ENV BENCHEXEC_PACKAGES software-properties-common libcap2 udev
ARG WINE_BRANCH="stable"
ENV WINE_PACKAGES apt-transport-https ca-certificates cabextract git gnupg gosu gpg-agent locales p7zip pulseaudio \
        pulseaudio-utils sudo tzdata unzip wget winbind xvfb
ENV PYTHON_PACKAGES python3.9 python3-pip python3.9-distutils

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update \
    && apt install --no-install-recommends -y ${WINE_PACKAGES} ${BENCHEXEC_PACKAGES} \
    && dpkg --unpack /opt/*.deb \
    && rm -f /var/lib/dpkg/info/cpu-energy-meter.postinst \
    && dpkg --configure cpu-energy-meter \
    && chmod +x /usr/local/bin/* /usr/bin/* \
    && wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y --no-install-recommends winehq-${WINE_BRANCH} ${PYTHON_PACKAGES} \
    && wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks \
    && locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8

ENV USER_NAME=benchexec
RUN useradd -ms /bin/bash $USER_NAME && \
    usermod -aG sudo $USER_NAME && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USER_NAME
WORKDIR /home/$USER_NAME
ARG USER_UID=0
ARG USER_GID=0
ENV USER_HOME="/home/benchexec"

# Create working directory
WORKDIR /home/benchexec/build
COPY docker/benchexec-external/ /home/benchexec/build
RUN python3.9 -m pip install --upgrade pip setuptools distlib && \
    sudo python3.9 setup.py install && \
    sudo python3.9 setup.py sdist && \
    sudo python3.9 -m pip install --no-cache-dir dist/*.tar.gz

WORKDIR /home/benchexec
ENV UDEV=on
ENV RUN_AS_ROOT="yes"
ENV FORCED_OWNERSHIP="yes"
ENV TZ="UTC"
ENV USE_XVFB="yes"

## Copy payload

COPY docker/docker-wine/entrypoint.sh /usr/bin/wine-entrypoint
COPY docker/docker-wine/download_gecko_and_mono.sh /usr/bin/download_gecko_and_mono.sh
COPY docker/entrypoint.sh /usr/bin/entrypoint

RUN sudo mkdir -p /outputs /results /usr/share/wine/ && \
    sudo chown -R $USER_NAME:$USER_NAME /usr/share/wine/ /outputs /results && \
    sudo rm -rf /opt/wine-stable/share/wine/fonts/* && \
    sudo chmod +x /usr/bin/entrypoint /usr/bin/wine-entrypoint && \
    /usr/bin/wine-entrypoint && \
    WINEDEBUG=warn-all,err-all,fixme-all wineboot && \
    sudo chmod +x /usr/bin/download_gecko_and_mono.sh && \
    /usr/bin/download_gecko_and_mono.sh "$(wine --version | sed -E 's/^wine-//')"
    #wine --version

COPY docker/secrets/ftrex-key /run/secrets/ftrex-key
COPY docker/secrets/ftrex-serial /run/secrets/ftrex-serial

COPY models /models
COPY config /config
COPY tasks /tasks

WORKDIR /home/benchexec/ft-bench
RUN sudo chown -R $USER_NAME:$USER_NAME /tasks /config /models /opt/ftrex /opt/cafta /opt/saphire8 && \
    mkdir -p /home/benchexec/ft-bench && \
    ln -s /models /home/benchexec/ft-bench/models && \
    ln -s /config /home/benchexec/ft-bench/config && \
    ln -s /outputs /home/benchexec/ft-bench/outputs && \
    ln -s /results /home/benchexec/ft-bench/results

ENTRYPOINT ["/usr/bin/entrypoint"]