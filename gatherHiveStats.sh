#!/bin/bash
hiveDir=/opt/mapr/hive/hive-2.1
lightPollingInterval=5
hiveMetaJstack=1
hiveMetaGstack=1
hiveServer2Jstack=1
hiveServer2Gstack=1
hiveBeelineJstack=1
hiveBeelineGstack=1

if [ `ps -ef | grep -w "gatherServerDiagnostics.sh daemon" | grep -v -w -e grep | tr -s '  ' ' ' | cut -f 2-3 -d " " | grep -v -w -e $$ | wc -l` -ne 0 ]; then
  echo ERROR: This script is already running!
  ps -ef | grep -w "gatherServerDiagnostics.sh daemon" | grep -v -w -e grep
  exit 1
fi

if [ "n$1" = "ndaemon" ]; then

nextLightPolling=0
nextHeavyPolling=0

while true; do
  now=`date +%s`
  if [ $now -ge $nextLightPolling ]; then
    nextLightPolling=$(( $now + $lightPollingInterval ))
    if [ $hiveMetaJstack -eq 1 ] && [ "n`cat $hiveDir/pids/hive-mapr-metastore.pid`" != "n" ] && [ -d /proc/`cat $hiveDir/pids/hive-mapr-metastore.pid` ]; then
      kill -3 `cat $hiveDir/pids/hive-mapr-metastore.pid`
    fi
    if [ $hiveMetaGstack -eq 1 ] && [ "n`cat $hiveDir/pids/hive-mapr-metastore.pid`" != "n" ] && [ -d /proc/`cat $hiveDir/pids/hive-mapr-metastore.pid` ]; then
      gstack `cat $hiveDir/pids/hive-mapr-metastore.pid` |awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' >> $hiveDir/logs/hivemeta.gstack.$HOSTNAME.out 2>&1 &
    fi
    if [ $hiveServer2Jstack -eq 1 ] && [ "n`cat $hiveDir/pids/hive-mapr-hiveserver2.pid`" != "n" ] && [ -d /proc/`cat $hiveDir/pids/hive-mapr-hiveserver2.pid` ]; then
      kill -3 `cat $hiveDir/pids/hive-mapr-hiveserver2.pid`
    fi
    if [ $hiveServer2Gstack -eq 1 ] && [ "n`cat $hiveDir/pids/hive-mapr-hiveserver2.pid`" != "n" ] && [ -d /proc/`cat $hiveDir/pids/hive-mapr-hiveserver2.pid` ]; then
      gstack `cat $hiveDir/pids/hive-mapr-hiveserver2.pid` |awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}'>> $hiveDir/logs/hs2.gstack.$HOSTNAME.out 2>&1 &
    fi
    if [ $hiveBeelineJstack -eq 1 ] && [ "n`ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'`" != "n" ] && [ -d /proc/`ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'` ]; then
      jstack -l `ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'` >> $hiveDir/logs/beeline.jstack.$HOSTNAME.out 2>&1 &
    fi
    if [ $hiveBeelineGstack -eq 1 ] && [ "n`ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'`" != "n" ] && [ -d /proc/`ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'` ]; then
      gstack `ps aux |grep '[o]rg.apache.hive.beeline.BeeLine' |awk '{print $2}'` |awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}'>> $hiveDir/logs/beeline.gstack.$HOSTNAME.out 2>&1 &
    fi
  fi
sleep 1
done
else 
  echo Launching collection daemon
  nohup $0 daemon < /dev/null > $hiveDir/logs/gatherHiveStats.$HOSTNAME.out 2>&1 &
fi
