#!/bin/bash

JAVA_HOME=${JAVA_HOME:-"/usr/java/latest"}
JAVA_BIN="${JAVA_HOME}/bin/java"

[ ! -x ${JAVA_BIN} ] && echo "Cannot find the java executable in JAVA_HOME: $JAVA_HOME" && exit 64

cd $(dirname ${0})
DIST_DIR=$PWD
cd - > /dev/null

JRUBY_DIST="${DIST_DIR}/libs/jruby-dist/jruby-complete-1.5.3.jar"

${JAVA_BIN} -jar ${JRUBY_DIST} ${DIST_DIR}/zk_dump.rb $* 

