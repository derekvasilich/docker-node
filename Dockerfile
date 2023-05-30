FROM ubuntu:focal

ENV NODE_VERSION 16.20.0
ENV YARN_VERSION 1.22.19

# prevent apt from asking questions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  libgtk2.0-0 \
  libgtk-3-0 \
  libnotify-dev \
  libgconf-2-4 \
  libgbm-dev \
  libnss3 \
  libxss1 \
  libasound2 \
  libxtst6 \
  xauth \
  xvfb \
  curl \
  # install emoji font
  fonts-noto-color-emoji \
  # install chinese font
  ttf-wqy-zenhei \  
  # clean up
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

RUN apt-get update && \ 
  apt-get install --no-install-recommends -y \
  gnupg \ 
  ca-certificates

RUN update-ca-certificates

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.gz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-$ARCH.tar.gz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.gz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  # smoke test
  && yarn --version

ENV TERM=xterm \
  # avoid million NPM install messages
  npm_config_loglevel=warn \
  # allow installing when the main user is root
  npm_config_unsafe_perm=true

RUN npm --version \
  && npm install -g yarn@latest --force \
  && yarn --version \
  && node -p process.versions \
  && node -p 'module.paths'

# Install dependencies
RUN apt-get update && \
  apt-get install -y \
  fonts-liberation \
  libcurl4 \
  libcurl3-gnutls \
  libcurl3-nss \
  procps \
  xdg-utils \
  wget \
  # clean up
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install libappindicator3-1 - not included with Debian 11
RUN wget --no-verbose /usr/src/libappindicator3-1_0.4.92-7_amd64.deb "http://ftp.us.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb" && \
  dpkg -i /usr/src/libappindicator3-1_0.4.92-7_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/libappindicator3-1_0.4.92-7_amd64.deb

# install Chrome browser
RUN wget --no-verbose -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_99.0.4844.51-1_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb

# install git
RUN apt-get update && \
    apt-get install -y \
    git \
    # clean up
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# # Add Chrome as a user
# RUN mkdir -p /usr/src/app \
#     && adduser chrome \
#     && chown -R chrome:chrome /usr/src/app

# # Run Chrome as non-privileged
# USER chrome
# ENV HOME /usr/src/app
# WORKDIR /usr/src/app

RUN echo  \
  "node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "chrome version:  $(google-chrome --version) \n" \
  "git version:     $(git --version) \n" \
  "whoami:          $(whoami) \n"
