FROM eclipse-temurin:11-jdk-focal

ARG MAVEN_VERSION=3.8.7
# https://downloads.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz.sha512
ARG MAVEN_SHA512=21c2be0a180a326353e8f6d12289f74bc7cd53080305f05358936f3a1b6dd4d91203f4cc799e81761cf5c53c5bbe9dcc13bdb27ec8f57ecf21b2f9ceec3c8d27
ARG TARGETARCH
RUN curl -sLf https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${MAVEN_SHA512}  /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz" >/tmp/maven_sha512 \
  && sha512sum -c --strict /tmp/maven_sha512 \
  && tar -C /opt -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && rm -fv /tmp/maven_sha512 /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

RUN apt-get update && \
  apt-get install -y git gpg tini && \
  apt-get clean

# Cloning + "warming" up the maven local cache/repository for the latest Jenkins version
RUN git clone https://github.com/jenkinsci/jenkins && \
    cd jenkins && \
    java -XshowSettings:properties -version 2>&1 | grep os.arch && \
    java -XshowSettings:properties -version 2>&1 | grep os.version && \
    mvn clean package -B --show-version --no-transfer-progress -DskipTests && \
    mvn clean

WORKDIR jenkins

ADD checkout-and-start.sh /checkout-and-start.sh
RUN chmod +x /checkout-and-start.sh

EXPOSE 8080


RUN  git config --global user.email "core-pr-tester-noreply@jenkins.io" && \
     git config --global user.name "Core PR Tester"

ENTRYPOINT ["/usr/bin/tini", "--", "/checkout-and-start.sh"]

