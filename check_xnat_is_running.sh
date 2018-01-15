#!/bin/bash

SCP=`lsof | grep xnat | grep 8104`


if [ -z "$SCP" ]; then
    echo "XNAT SCP node is not listening, restarting tomcat"
    /etc/init.d/tomcat7 sse
else
    echo "XNAT is up and running, no action needed."
fi 
