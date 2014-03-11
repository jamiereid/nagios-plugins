#!/bin/bash
SCRIPTNAME=`basename $0`
VERSION="v1.0"
AUTHOR="Jamie Reid <jamie@jre.id.au>"

OK=0
WARN=1
CRIT=2
OTHER=3

print_help() {
  echo ""
  echo "Usage: $SCRIPTNAME -u <user> -p <pass> -H <node> [OPTIONS]..."
  echo ""
  echo "  -u            MySQL/MariaDB user          (REQUIRED)"
  echo "  -p            MySQL/MariaDB password      (REQUIRED)"
  echo "  -H            MySQL/MariaDB host to check (REQUIRED)"
  echo "  -P            MySQL/MariaDB port          (OPTIONAL; defaults to 3306)"
  echo "  -w            "
  echo "  -c            "
  echo ""
  echo "Examples:"
  echo "  $SCRIPTNAME -u clusteradmin -p supersekrit -H thor"
  echo ""
  echo "Report bugs on github: https://github.com/jamiereid/nagios-plugins"
  exit $OTHER
}

print_help