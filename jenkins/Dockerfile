FROM jenkins/jenkins:lts-jdk17

USER root

# Install docker
RUN apt-get update && \
    apt-get install -y curl unzip apt-transport-https ca-certificates gnupg lsb-release && \
    # Install Docker CLI only
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 989 docker && \
    usermod -aG docker jenkins

USER jenkins

# Copy plugins.txt into the image
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Auto-install plugins at build time
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
