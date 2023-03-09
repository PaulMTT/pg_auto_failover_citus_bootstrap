#!/bin/bash

sudo rm -rf /data
sudo mkdir /data
sudo chown -R postgres:postgres /var/run/postgresql
sudo chown -R postgres:postgres /data
sudo chmod -R 1777 /tmp

cat <<EOF | sudo tee /etc/systemd/system/citus.service >/dev/null
[Unit]
Description = pg_auto_failover coordinator

[Service]
WorkingDirectory = /
Environment = 'PGDATA=/data'
Environment = 'PGDATABASE=citus'

User = postgres
ExecStart = /usr/bin/pg_autoctl create coordinator --monitor "postgresql://autoctl_node@monitor/pg_auto_failover" --citus-cluster one --name coordinator1b --group 1 --ssl-self-signed --auth trust --run
Restart = always
StartLimitBurst = 0
ExecReload = /usr/bin/pg_autoctl reload

[Install]
WantedBy = multi-user.target
EOF

sudo systemctl start citus.service
sudo systemctl enable citus.service
