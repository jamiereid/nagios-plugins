#!/bin/bash
SCRIPTNAME=`basename $0`
VERSION="v1.0"
AUTHOR="Jamie Reid <jamie@jre.id.au>"

OK=0
WARN=1
CRIT=2
OTHER=3

MIB_1MINLOAD=".1.3.6.1.4.1.2021.10.1.3.1"
MIB_5MINLOAD=".1.3.6.1.4.1.2021.10.1.3.2"
MIB_15MINLOAD=".1.3.6.1.4.1.2021.10.1.3.3"
MIB_USRTIMEPER=".1.3.6.1.4.1.2021.11.9.0"
MIB_USRTIMERAW=".1.3.6.1.4.1.2021.11.50.0"
MIB_SYSTIMEPER=".1.3.6.1.4.1.2021.11.10.0"
MIB_SYSTIMERAW=".1.3.6.1.4.1.2021.11.52.0"
MIB_IDLETIMEPER=".1.3.6.1.4.1.2021.11.11.0"
MIB_IDLETIMERAW=".1.3.6.1.4.1.2021.11.53.0"
MIB_NICETIMERAW=".1.3.6.1.4.1.2021.11.51.0"

function print_help() {
  echo "Usage: $SCRIPTNAME  [OPTIONS]..."
  echo ""
  echo "  -h            help! Display this message."
  echo "  -H            Hostname/IP address          (REQUIRED)"
  echo "  -C            SNMP Community String        (OPTIONAL; defaults to PUBLIC)"
  echo "  -V            SNMP Version                 (OPTIONAL; defaults to 2c)"
  echo "  -t            Value to test                (REQUIRED; 1 (1 minute load))"
  echo "  -w            Warn value                   (OPTIONAL; defaults to -c)"
  echo "  -c            Critical value               (REQUIRED)"
  echo ""
  echo "Examples:"
  echo "  ./$SCRIPTNAME "
  echo ""
  echo "Report bugs on github: https://github.com/jamiereid/nagios-plugins"
  exit $OTHER
}

function func_1minuteload() {
  RET=$(snmpget -Oqv -v$OPT_VERSION -c$OPT_COMMUNITY $OPT_HOST $MIB_1MINLOAD)

  if [ $? -ne "0" ]; then
    echo "Unknown error with snmp request.  Exit code was $?"; exit $OTHER
  fi

  # Scale up values so we can compare in bash
  $SCALED_CRITVAL = $("echo $CRITVAL\*100 | bc")
  $SCALED_WARNVAL = $("echo $WARNVAL\*100 | bc")
  $SCALED_RET = $("echo $RET\*100 | bc")

  if [ $SCALED_RET -gt $SCALED_CRITVAL ]; then
    echo "CRITIAL: 1 minute load at $RETVAL"; exit $CRIT
  elif [ $SCALED_RET -gt $SCALED_WARNVAL ]; then
    echo "WARNING: 1 minute load at $RETVAL"; exit $WARN
  else
    echo "OK: 1 minute load at $RETVAL"; exit $OK
  fi
}

# Set some defaults
OPT_COMMUNITY="PUBLIC"
OPT_VERSION="2c"

# Cycle through arguments
while getopts “hH:C:V:t:w:c:” OPTION; do
  case $OPTION in
    h) print_help; exit $OTHER;;
    H) OPT_HOST=$OPTARG;;
    C) OPT_COMMUNITY=$OPTARG;;
    V) OPT_VERSION=$OPTARG;;
    t) OPT_TEST=$OPTARG;;
    w) WARNVAL=$OPTARG;;
    c) CRITVAL=$OPTARG;;
    ?) echo "Unknown argument: $1"; print_help; exit $OTHER;;
  esac
done

# Check for mandatory arguments
if [ -z "$OPT_HOST" ]; then
  echo "argument -H missing"
  print_help; exit $OTHER
fi

if [ -z "$OPT_TEST" ]; then
  echo "argument -t missing"
  print_help; exit $OTHER
fi

if [ -z "$CRITVAL" ]; then
  echo "argument -c missing"
  print_help; exit $OTHER
fi

# Set WARNVAL
if [ -z "$WARNVAL" ]; then
  WARNVAL=$CRITVAL
fi

# Work out what test we're doing
case $OPT_TEST in
  1) func_1minuteload;;
  ?) echo "Unknown test: $OPT_TEST"; print_help; exit $OTHER;;
esac
