FROM ppc64le/debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    if ! command -v gpg > /dev/null; then \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            gnupg2 \
            dirmngr \
        ; \
        rm -rf /var/lib/apt/lists/*; \
    fi

# gcc for cgo
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        libc6-dev \
        make \
        pkg-config \
        wget \
        ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.1

RUN set -eux; \
    \
# this "case" statement is generated via "update.sh"
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) goRelArch='linux-amd64'; goRelSha256='07d81c6b6b4c2dcf1b5ef7c27aaebd3691cdb40548500941f92b221147c5d9c7' ;; \
        armhf) goRelArch='linux-armv6l'; goRelSha256='65a0495a50c7c240a6487b1170939586332f6c8f3526abdbb9140935b3cff14c' ;; \
        arm64) goRelArch='linux-arm64'; goRelSha256='d31ecae36efea5197af271ccce86ccc2baf10d2e04f20d0fb75556ecf0614dad' ;; \
        i386) goRelArch='linux-386'; goRelSha256='2cea1ce9325cb40839601b566bc02b11c92b2942c21110b1b254c7e72e5581e7' ;; \
        ppc64el) goRelArch='linux-ppc64le'; goRelSha256='de57b6439ce9d4dd8b528599317a35fa1e09d6aa93b0a80e3945018658d963b8' ;; \
        s390x) goRelArch='linux-s390x'; goRelSha256='9adf03574549db82a72e0d721ef2178ec5e51d1ce4f309b271a2bca4dcf206f6' ;; \
        *) goRelArch='src'; goRelSha256='a84afc9dc7d64fe0fa84d4d735e2ece23831a22117b50dafc75c1484f1cb550e'; \
            echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
    esac; \
    \
    url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
    wget -O go.tgz "$url"; \
    echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    \
    if [ "$goRelArch" = 'src' ]; then \
        echo >&2; \
        echo >&2 'error: UNIMPLEMENTED'; \
        echo >&2 'TODO install golang-any from jessie-backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
        echo >&2; \
        exit 1; \
    fi; \
    \
    export PATH="/usr/local/go/bin:$PATH"; \
    go version

ENV GOPATH /go

ENV PATH $PATH:$GOPATH/bin:/usr/local/go/bin

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

WORKDIR $GOPATH

ENV TRAEFIK_PATH github.com/containous/traefik
ENV TRAEFIK_REPO https://${TRAEFIK_PATH}.git
ENV TRAEFIK_BRANCH master

WORKDIR /root

RUN apt-get update
RUN apt-get install -y bash nodejs python git
RUN go get -u github.com/Masterminds/glide
RUN go get github.com/jteeuwen/go-bindata/... \
 && go get github.com/golang/lint/golint \
 && go get github.com/kisielk/errcheck \
 && go get github.com/client9/misspell/cmd/misspell \
 && go get github.com/mattfarina/glide-hash \
 && go get github.com/sgotti/glide-vc

RUN git clone -b ${TRAEFIK_BRANCH} \
      ${TRAEFIK_REPO} \
      ${GOPATH}/src/${TRAEFIK_PATH}

WORKDIR ${GOPATH}/src/${TRAEFIK_PATH}
RUN glide install --strip-vendor

RUN groupadd --gid 1000 node \
 && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
 && for key in \
      9554F04D7259F04124DE6B476D5A82AC7E37093B \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
    ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.7.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
 && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
 esac \
 && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
 && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
 && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
 && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
 && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 \
 && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
 && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.2.0

RUN set -ex \
 && for key in \
   6A010C5166006599AA17F08146C2130DFD2497F5 \
 ; do \
   gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
   gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
   gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
 done \
 && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
 && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
 && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
 && mkdir -p /opt/yarn \
 && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
 && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

WORKDIR ${GOPATH}/src/${TRAEFIK_PATH}/webui

RUN apt-get install -y curl gnupg gnupg2 apt-transport-https lsb-release

##RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
#RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
#RUN echo 'deb https://deb.nodesource.com/node_8.x stretch main' > /etc/apt/sources.list.d/nodesource.list
#RUN echo 'deb-src https://deb.nodesource.com/node_8.x stretch main' >> /etc/apt/sources.list.d/nodesource.list
#RUN apt-get update

#RUN apt-get install -y nodejs
#RUN dpkg --list nodejs \
# && dpkg --listfiles nodejs | grep npm
RUN apt-get install -y jq
RUN set -x ; npm install $( jq -r '.devDependencies | keys | join(" ")' package.json | sed -e 's/phantomjs-prebuilt //' -e 's/karma-phantomjs-shim //' -e 's/karma-phantomjs-launcher //' )
RUN npm run build

#RUN apt-get install -y build-essential g++ flex bison gperf ruby perl \
#  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
#  libpng-dev libjpeg-dev python libx11-dev libxext-dev qtbase5-dev
#
#RUN git clone git://github.com/ariya/phantomjs.git
#RUN cd phantomjs \
# && git checkout 2.1.1 \
# && git submodule init \
# && git submodule update \
# && python build.py

#RUN yarn install
#RUN make generate-webui

WORKDIR ${GOPATH}/src/${TRAEFIK_PATH}

RUN glide install --strip-vendor
RUN go generate
RUN go build -v ./cmd/traefik
RUN cp -af traefik /go/bin/traefik

ADD entrypoint.sh /entrypoint.sh
ADD run.sh /run.sh

ENTRYPOINT /run.sh

CMD traefik
