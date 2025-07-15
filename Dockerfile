FROM swift:6.1.2-jammy
RUN apt-get update && \
    apt-get install -y git python3 python3-pip docker.io docker-compose-v2 && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /srv/deploy
COPY . /srv/deploy
