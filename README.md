# Nagios Plugins

This is a repo for custom / enhanced nagios plugins I've written.

---

### check_galera_node.sh

```
Usage: check_galera_node.sh -u <user> -p <pass> -H <node> [OPTIONS]...

  -u            MySQL/MariaDB user          (REQUIRED)
  -p            MySQL/MariaDB password      (REQUIRED)
  -H            MySQL/MariaDB host to check (REQUIRED)
  -P            MySQL/MariaDB port          (OPTIONAL; defaults to 3306)
  -w            # of nodes before WARNING   (OPTIONAL; defaults to -c)
  -c            # of nodes before CRITIAL   (OPTIONAL; defaults to 2)
  -h            Display this message

Examples:
  ./check_galera_node.sh -u clusteradmin -p supersekrit -H thor.internal
```

### check_cpu_snmp.sh

Polls a remote machine (linux only?) using SNMP for it's current CPU usage and returns appropriate alerts.

```
Usage: check_cpu_snmp.sh -H <host> -t <test-type> -c 5 [OPTIONS]...

  -h            help! Display this message.
  -H            Hostname/IP address          (REQUIRED)
  -C            SNMP Community String        (OPTIONAL; defaults to PUBLIC)
  -V            SNMP Version                 (OPTIONAL; defaults to 2c)
  -t            Value to test                (REQUIRED; 1 (1 minute load))
  -w            Warn value                   (OPTIONAL; defaults to -c)
  -c            Critical value               (REQUIRED)

Examples:
  ./check_cpu_snmp.sh -H joker.batcave -c 2 -t 1 -C hahaha
```
