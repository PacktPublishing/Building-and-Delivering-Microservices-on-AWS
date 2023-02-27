#!/bin/bash
killall java
rm -f /home/root/aws-code-pipeline*.jar
rm -f /home/root/appspec.yml
rm -f /home/root/app.log
rm -f /home/root/*.sh
exit 0