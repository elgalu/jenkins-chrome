# Build:
#   docker build -t elgalu/jenkins .
# Test:
#   docker run --rm -ti elgalu/jenkins chromedriver --version
#   #=> ChromeDriver 2.3.....
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
ENV CHROME_DRIVER_VERSION="2.38" \
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

#===============================
# Python3 with Selenium bindings
#===============================
RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
    python3 \
    python3-pip \
    python3-dev \
    python3-openssl \
    libssl-dev libffi-dev \
  && pip3 install --upgrade pip==9.0.3 \
  && pip3 install setuptools \
  && pip3 install numpy \
  && pip3 install selenium==3.11.0 \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qyy clean
RUN cd /usr/local/bin \
  && { [ -e easy_install ] || ln -s easy_install-* easy_install; } \
  && ln -s idle3 idle \
  && ln -s pydoc3 pydoc \
  && ln -s python3 python \
  && ln -s python3-config python-config \
  && ln -fs /usr/bin/python3 /usr/bin/python \
  && ln -fs /usr/bin/pip3 /usr/bin/pip \
  && python --version \
  && pip --version

# Go back to non-sudo user
USER jenkins
