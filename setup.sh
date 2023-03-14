#!/bin/bash

PGVERSION=14
CITUS=postgresql-14-citus-11.1
RELEASE=$(lsb_release -cs)

sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
  ca-certificates \
  gnupg \
  make \
  curl \
  sudo \
  tmux \
  watch \
  lsof \
  psutils \
  postgresql-common \
  libpq-dev \
  && sudo rm -rf /var/lib/apt/lists/*

curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt ${RELEASE}-pgdg main ${PGVERSION}" | sudo tee /etc/apt/sources.list.d/pgdg.list >/dev/null

echo "deb-src http://apt.postgresql.org/pub/repos/apt ${RELEASE}-pgdg main ${PGVERSION}" | sudo tee /etc/apt/sources.list.d/pgdg.src.list >/dev/null

echo 'create_main_cluster = false' | sudo tee -a /etc/postgresql-common/createcluster.conf >/dev/null

sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
  postgresql-${PGVERSION} \
  postgresql-server-dev-${PGVERSION} \
  && sudo rm -rf /var/lib/apt/lists/*

curl -s https://packagecloud.io/install/repositories/citusdata/community/script.deb.sh | sudo bash

sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
  postgresql-${PGVERSION} \
  ${CITUS} \
  && sudo rm -rf /var/lib/apt/lists/*

# Might need to delete something from /etc/apt/sources.list.d/ if you get "Conflicting values set for option Signed-By regarding source"
sudo apt-get update \
  && sudo apt-get build-dep -y --no-install-recommends postgresql-${PGVERSION} \
  && sudo rm -rf /var/lib/apt/lists/*

git clone https://github.com/citusdata/pg_auto_failover.git

sudo make -s clean -C pg_auto_failover/ && sudo make -s -C pg_auto_failover/ install -j8

sudo cp /usr/lib/postgresql/${PGVERSION}/bin/pg_autoctl /usr/local/bin

sudo rm -rf /data
sudo mkdir /data
sudo chown -R postgres:postgres /data
sudo rm -rf /backup
sudo mkdir /backup
sudo chown -R postgres:postgres /backup
sudo chown -R postgres:postgres /var/run/postgresql
sudo chmod -R 1777 /tmp

sudo -u postgres sh -c 'cd /data && pg_conftool set listen_addresses "*"'