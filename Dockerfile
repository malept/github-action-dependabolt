FROM debian:buster
LABEL "repository"="https://github.com/malept/github-action-dependabolt"
LABEL "maintainer"="Mark Lee <https://github.com/malept>"

RUN echo "deb https://deb.nodesource.com/node_14.x buster main" | tee /etc/apt/sources.list.d/nodesource.list && apt-get update && apt-get install -y --no-install-recommends ca-certificates git nodejs openssh-client && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN ssh-keyscan -t rsa github.com >> /etc/ssh/ssh_known_hosts

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
