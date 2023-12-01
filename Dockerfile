FROM eclipse-temurin:17-jdk-focal

ARG MAVEN_VERSION=3.9.6
# https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz.sha512
ARG MAVEN_SHA512=706f01b20dec0305a822ab614d51f32b07ee11d0218175e55450242e49d2156386483b506b3a4e8a03ac8611bae96395fd5eec15f50d3013d5deed6d1ee18224
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

