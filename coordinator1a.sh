#!/bin/bash

sudo systemctl stop citus.service >/dev/null

cat <<EOF | sudo tee /etc/systemd/system/citus.service >/dev/null
[Unit]
Description = pg_auto_failover coordinator

[Service]
WorkingDirectory = /var/lib/postgresql
Environment = 'PGDATA=/data'
Environment = 'PGUSER=citus'
Environment = 'PGDATABASE=citus'

User = postgres
ExecStart = /usr/local/bin/pg_autoctl create coordinator --monitor "postgresql://autoctl_node@monitor/pg_auto_failover" --citus-cluster one --name coordinator1a --ssl-self-signed --auth trust --run --pgdata="/data" --dbname="citus"
Restart = always
StartLimitBurst = 0
ExecReload = /usr/local/bin/pg_autoctl reload

[Install]
WantedBy = multi-user.target
EOF

sudo rm -rf /var/lib/postgresql/.config/pg_autoctl/
sudo systemctl daemon-reload

sudo systemctl start citus.service
sudo systemctl enable citus.service
