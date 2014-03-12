#!/bin/bash
SCRIPTNAME=`basename $0`
VERSION="v1.0"
AUTHOR="Jamie Reid <jamie@jre.id.au>; based on a script by Guillaume Coré <g@fridim.org>"

OK=0
WARN=1
CRIT=2
OTHER=3

print_help() {
  echo "Usage: $SCRIPTNAME -u <user> -p <pass> -H <node> [OPTIONS]..."
  echo ""
  echo "  -u            MySQL/MariaDB user          (REQUIRED)"
  echo "  -p            MySQL/MariaDB password      (REQUIRED)"
  echo "  -H            MySQL/MariaDB host to check (REQUIRED)"
  echo "  -P            MySQL/MariaDB port          (OPTIONAL; defaults to 3306)"
  echo "  -w            # of nodes before WARNING   (OPTIONAL; defaults to -c)"
  echo "  -c            # of nodes before CRITIAL   (OPTIONAL; defaults to 2)"
  echo "  -h            Display this message"
  echo ""
  echo "Examples:"
  echo "  ./$SCRIPTNAME -u clusteradmin -p supersekrit -H thor.internal"
  echo ""
  echo "Report bugs on github: https://github.com/jamiereid/nagios-plugins"
  exit $OTHER
}

# Set some defaults
DBPORT=3306
CRITVAL=2

# Cycle through arguments
while getopts “hu:p:H:P:w:c:f:” OPTION; do
  case $OPTION in
    h) print_help; exit $OTHER;;
    u) DBUSER=$OPTARG;;
    p) DBPASS=$OPTARG;;
    H) DBHOST=$OPTARG;;
    P) DBPORT=$OPTARG;;
    w) WARNVAL=$OPTARG;;
    c) CRITVAL=$OPTARG;;
    f) fcp=$OPTARG;;
    ?) echo "Unknown argument: $1"; print_help; exit $OTHER;;
  esac
done

# Check for mandatory arguments
if [ -z "$DBUSER" ]; then
  echo "argument -u missing"
  print_help; exit $OTHER
fi

if [ -z "$DBPASS" ]; then
  echo "argument -p missing"
  print_help; exit $OTHER
fi

if [ -z "$DBHOST" ]; then
  echo "argument -H missing"
  print_help; exit $OTHER
fi

# Set WARNVAL
if [ -z "$WARNVAL" ]; then
  WARNVAL=$CRITVAL
fi

# Gather results
CLUSTERSIZE=$(mysql -h$mysqlhost -P$port -u$mysqluser -p$password -B -N -e "show status like 'wsrep_cluster_size'" | cut -f 2)
NODESTATUS=$(mysql -h$mysqlhost -P$port -u$mysqluser -p$password -B -N -e "show status like 'wsrep_cluster_status'" | cut -f 2)
NODEREADY=$(mysql -h$mysqlhost -P$port -u$mysqluser -p$password -B -N -e "show status like 'wsrep_ready'" | cut -f 2)
NODECONNECTED=$(mysql -h$mysqlhost -P$port -u$mysqluser -p$password -B -N -e "show status like 'wsrep_connected'" | cut -f 2)
NODESTATE=$(mysql -h$mysqlhost -P$port -u$mysqluser -p$password -B -N -e "show status like 'wsrep_local_state_comment'" | cut -f 2)

# Check NODESTATUS is Primary
if [ "$NODESTATUS" != 'Primary' ]; then
  echo "CRITICAL: node is not primary"
  FINALEXIT=$CRIT
fi

# Check WSREP is ON
if [ "$NODEREADY" != 'ON' ]; then
  echo "CRITICAL: node is not ready"
  FINALEXIT=$CRIT
fi

# Check Node is connected to cluster
if [ "$NODECONNECTED" != 'ON' ]; then
  echo "CRITICAL: node is not connected"
  FINALEXIT=$CRIT
fi

# Check that node is in sync
if [ "$NODESTATE" != 'Synced' ]; then
  echo "CRITICAL: node is not synced"
  FINALEXIT=$CRIT
fi

# Check size of cluster and return appropriately
if [ $CLUSTERSIZE -gt $WARNVAL ]; then
  echo "OK: number of NODES = $CLUSTERSIZE"
  FINALEXIT=${FINALEXIT-$OK}
elif [ $CLUSTERSIZE -le $CRITVAL ]; then
  echo "CRITICAL: number of NODES = $CLUSTERSIZE"
  FINALEXIT=$CRITVAL
elif [ $CLUSTERSIZE -le $WARNVAL ]; then
  echo "WARNING: number of NODES = $CLUSTERSIZE"
  FINALEXIT=${FINALEXIT-$WARNVAL}
else
  exit $OTHER
fi

exit $FINALEXIT