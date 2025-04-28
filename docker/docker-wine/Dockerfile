#ARG BASE_IMAGE="scottyhardy/docker-remote-desktop"
#ARG TAG="latest"
ARG BASE_IMAGE="ubuntu"
ARG TAG="22.04"
FROM ${BASE_IMAGE}:${TAG}

ENV DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FRONTEND=noninteractive

ENV WINE_PACKAGES apt-transport-https ca-certificates cabextract git gnupg gosu gpg-agent locales p7zip pulseaudio \
        pulseaudio-utils sudo tzdata unzip wget winbind xvfb zenity

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update \
    && apt install --no-install-recommends -y $WINE_PACKAGES

# Install wine
ARG WINE_BRANCH="stable"
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && apt update \
    && apt install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks

# Download gecko and mono installers
COPY ./Docker/docker-wine/download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(wine --version | sed -E 's/^wine-//')"

# Configure locale for unicode
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

COPY ./Docker/docker-wine/pulse-client.conf /root/pulse/client.conf
#COPY ./Docker/docker-wine/entrypoint.sh /usr/bin/entrypoint
#ENTRYPOINT ["/usr/bin/entrypoint"]

COPY ./bin/amd64/ftrex /opt/ftrex
