#!/bin/bash

JAVA_HOME=${JAVA_HOME:-"/usr/java/latest"}
JAVA_BIN="${JAVA_HOME}/bin/java"

[ ! -x ${JAVA_BIN} ] && echo "Cannot find the java executable in JAVA_HOME: $JAVA_HOME" && exit 64

cd $(dirname ${0})
DIST_DIR=$PWD
cd - > /dev/null

JRUBY_DIST="${DIST_DIR}/libs/jruby-dist/jruby-complete-1.5.3.jar"

usage()
{
  echo "Usage: $(basename $0) <dump|import|purge> -c host:port [options]" && exit 32
}

[ -z "$1" ] && usage
cmd="${1}"

[ $cmd = "dump" -o $cmd = "import" -o $cmd = "purge" ] || usage
${JAVA_BIN} -jar ${JRUBY_DIST} ${DIST_DIR}/zk_${cmd}.rb $* 

