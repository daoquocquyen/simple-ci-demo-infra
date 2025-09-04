FROM jenkins/jenkins:lts-jdk17

USER root

# Install Maven
ENV MAVEN_VERSION=3.8.8
RUN apt-get update && \
    apt-get install -y curl unzip apt-transport-https ca-certificates gnupg lsb-release && \
    mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
      | tar -xz -C /opt/maven && \
    chown -R jenkins:jenkins /opt/maven && \
    # Install Docker CLI only
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

ENV MAVEN_HOME=/opt/maven/apache-maven-3.8.8
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH

USER jenkins

# Copy plugins.txt into the image
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Auto-install plugins at build time
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
