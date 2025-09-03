FROM jenkins/jenkins:lts-jdk17

USER root

# Install Maven (compatible with JDK 17)
ENV MAVEN_VERSION=3.8.8
ENV MAVEN_HOME=/opt/maven/apache-maven-${MAVEN_VERSION}
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$MAVEN_HOME/bin:$PATH

RUN apt-get update && \
    apt-get install -y curl unzip && \
    mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
      | tar -xz -C /opt/maven && \
    rm -rf /var/lib/apt/lists/*

USER jenkins

# Copy plugins.txt into the image
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Auto-install plugins at build time
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
