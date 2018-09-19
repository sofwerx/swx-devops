FROM openjdk:8-jdk

ARG VERSION=0.3.0

ENV VERSION $VERSION

RUN groupadd --gid 1000 janusgraph \
 && useradd --uid 1000 --gid janusgraph --shell /bin/bash --create-home janusgraph

#RUN buildDeps='ant junit junit4 libaopalliance-java libapache-pom-java libasm-java \
#  libatinject-jsr330-api-java libbsh-java libcdi-api-java libcglib-java \
#  libclassworlds-java libcommons-cli-java libcommons-codec-java libcommons-httpclient-java \
#  libcommons-io-java libcommons-lang-java libcommons-lang3-java libcommons-logging-java \
#  libcommons-net-java libcommons-parent-java libdoxia-core-java libeasymock-java \
#  libeclipse-aether-java libgeronimo-interceptor-3.0-spec-java libguava-java \
#  libguice-java libhamcrest-java libhttpclient-java libhttpcore-java libjaxen-java \
#  libjaxp1.3-java libjdom1-java libjetty9-java libjsch-java libjsoup-java \
#  libjsr305-java libjzlib-java liblog4j1.2-java libmaven-parent-java libmaven2-core-java \
#  libmaven3-core-java libobjenesis-java libplexus-ant-factory-java libplexus-archiver-java \
#  libplexus-bsh-factory-java libplexus-cipher-java libplexus-classworlds-java \
#  libplexus-classworlds2-java libplexus-cli-java libplexus-component-annotations-java \
#  libplexus-component-metadata-java libplexus-container-default-java libplexus-container-default1.5-java \
#  libplexus-containers-java libplexus-containers1.5-java libplexus-interactivity-api-java \
#  libplexus-interpolation-java libplexus-io-java libplexus-sec-dispatcher-java \
#  libplexus-utils-java libplexus-utils2-java libqdox2-java libservlet3.1-java libsisu-inject-java \
#  libsisu-plexus-java libslf4j-java libwagon-java libwagon2-java libxalan2-java \
#  libxbean-java libxerces2-java libxml-commons-external-java libxml-commons-resolver1.1-java \
#  maven' \
#  && set -x \
#  && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
#  && rm -rf /var/lib/apt/lists/* \
#  && cd /home/janusgraph \
#  && git clone https://github.com/JanusGraph/janusgraph.git \
#  && cd janusgraph \
#  && git checkout $VERSION \
#  && mvn -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
#     -T $(getconf _NPROCESSORS_ONLN) clean install -Pjanusgraph-release -Dgpg.skip=true \
#     -DskipTests=true \
#  && cd .. && unzip janusgraph/janusgraph-dist/janusgraph-dist-hadoop-2/target/janusgraph-*-hadoop2.zip \
#  && rm -rf /root/.m2/ /home/janusgraph/janusgraph \ && mv janusgraph-*-hadoop2 janusgraph \
#  && chown janusgraph:janusgraph -R /home/janusgraph/janusgraph \
#  && apt-get purge -y --auto-remove $buildDeps

RUN apt-get update && apt-get install -y unzip wget
RUN cd /home/janusgraph \
 && wget https://github.com/JanusGraph/janusgraph/releases/download/v${VERSION}/janusgraph-${VERSION}-hadoop2.zip \
 && unzip janusgraph-${VERSION}-hadoop2.zip -d /home/janusgraph \
 && rm -f janusgraph-${VERSION}-hadoop2.zip \
 && mv /home/janusgraph/janusgraph-${VERSION}-hadoop2 /home/janusgraph/janusgraph \
 && chown -R janusgraph.janusgraph .

WORKDIR /home/janusgraph/janusgraph

ADD run.sh /run.sh

VOLUME /home/janusgraph/janusgraph/files

CMD /run.sh
