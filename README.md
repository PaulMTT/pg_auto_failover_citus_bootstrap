# pg_auto_failover_citus_bootstrap
## Install

Run setup.sh on every node.
This will pull in postgres built-deps and build pg_autoctl from source.

Run the other scripts on specific nodes, but remember to change the "--monitor "postgresql://autoctl_node@monitor/pg_auto_failover" to point to the real monitor