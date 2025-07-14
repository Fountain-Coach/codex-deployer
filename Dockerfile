FROM swift:5.8
RUN apt-get update && apt-get install -y git python3 python3-pip
WORKDIR /srv/deploy
COPY . /srv/deploy
