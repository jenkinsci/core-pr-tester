FROM eclipse-temurin:11-jdk-focal

ARG MAVEN_VERSION=3.8.6
ARG TARGETARCH
#RUN curl -sLf https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -C /opt -xz
RUN curl -sLf https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -C /opt -xz
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

RUN apt-get update && \
  apt-get install -y git gpg && \
  apt-get clean

# Cloning + "warming" up the maven local cache/repository for the latest Jenkins version
RUN git clone https://github.com/jenkinsci/jenkins && \
    cd jenkins && \
    java -XshowSettings:properties -version 2>&1 | grep os.arch && \
    java -XshowSettings:properties -version 2>&1 | grep os.version && \
    mvn clean package -B --show-version --no-transfer-progress -DskipTests && \
    mvn clean

WORKDIR jenkins

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.19.0
COPY tini_pub.gpg "/tmp/tini_pub.gpg"
RUN curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TARGETARCH}" -o /sbin/tini \
  && curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TARGETARCH}.asc" -o /sbin/tini.asc \
  && gpg --no-tty --import "/tmp/tini_pub.gpg" \
  && gpg --verify /sbin/tini.asc \
  && rm -rf /sbin/tini.asc /root/.gnupg \
  && rm -f /tmp/tini_pub.gpg \
  && chmod +x /sbin/tini

ADD checkout-and-start.sh /checkout-and-start.sh
RUN chmod +x /checkout-and-start.sh

EXPOSE 8080


RUN  git config --global user.email "core-pr-tester-noreply@jenkins.io" && \
     git config --global user.name "Core PR Tester"

ENTRYPOINT ["/sbin/tini", "--", "/checkout-and-start.sh"]

