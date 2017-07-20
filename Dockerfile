# Build:
#   docker build -t elgalu/jenkins .
# Test:
#   docker run --rm -ti elgalu/jenkins chromedriver --version
#   #=> ChromeDriver 2.30.477691 (6ee44a7247c639c0703f291d320bdf05c1531b57)
FROM jenkins

# Set user root to allow us to install the rest of what's needed
USER root

#==============================
# Google Chrome Stable - Latest
#==============================
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google.list \
  && apt-get -qy update \
  && apt-get -qy install -y google-chrome-stable \
  && apt-get -qyy autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qyy clean \
  && echo google-chrome-stable --version

#==================
# Chrome webdriver
#==================
# Credits to https://github.com/elgalu/docker-selenium
ENV CHROME_DRIVER_VERSION="2.30" \
    CHROME_DRIVER_BASE="chromedriver.storage.googleapis.com" \
    CPU_ARCH="64"
ENV CHROME_DRIVER_FILE="chromedriver_linux${CPU_ARCH}.zip"
ENV CHROME_DRIVER_URL="https://${CHROME_DRIVER_BASE}/${CHROME_DRIVER_VERSION}/${CHROME_DRIVER_FILE}"
RUN  wget -nv -O chromedriver_linux${CPU_ARCH}.zip ${CHROME_DRIVER_URL} \
  && unzip chromedriver_linux${CPU_ARCH}.zip \
  && rm chromedriver_linux${CPU_ARCH}.zip \
  && chmod 755 chromedriver \
  && mv chromedriver /usr/local/bin/ \
  && chromedriver --version

# Go back to non-sudo user
USER jenkins
