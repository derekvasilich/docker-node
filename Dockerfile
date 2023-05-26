FROM alpine:3.17

LABEL Description="Cutting-edge Node stack with Cypress and Chromium for testing Vue, Angular and React UIs with Protractor and Cypress" \
    Author="Derek Williams <info@derekwilliams.biz>" \
    License="" \
    Usage="" \
    Version="1.0"

# Installs latest Chromium package.
RUN apk upgrade --no-cache --available \
    && apk add --no-cache \
      chromium-swiftshader \
      ttf-freefont \
      font-noto-emoji \
    && apk add --no-cache \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
      font-wqy-zenhei

# Install node
RUN apk add --no-cache \
    tini make gcc g++ python3 git nodejs npm yarn

COPY local.conf /etc/fonts/local.conf

EXPOSE 8080
EXPOSE 8081
EXPOSE 4200

# Add Chrome as a user
RUN mkdir -p /usr/src/app \
    && adduser -D chrome \
    && chown -R chrome:chrome /usr/src/app

# Run Chrome as non-privileged
USER chrome
WORKDIR /usr/src/app    

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

# Autorun chrome headless
ENV CHROMIUM_FLAGS="--disable-software-rasterizer --disable-dev-shm-usage"
ENTRYPOINT ["chromium-browser", "--headless"]