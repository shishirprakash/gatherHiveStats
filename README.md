# gatherHiveStats
This script is to collect jstack and gstack of hiveserver2, hivemeta and beeline process running on mapr node.


To start the script 
./gatherHiveStats.sh


To stop the script
./stopHiveStats.sh


Note: 
- by default this script will collect logs at every 5 seconf interval.  You can change the frequency by editing "lightPollingInterval".
- You can also choose to whether or not collect jstack or gstack for hiveserver2 or beeline or hivemetastore.  You can just on and off below switches.

- hiveMetaJstack=1
- hiveMetaGstack=1
- hiveServer2Jstack=1
- hiveServer2Gstack=1
- hiveBeelineJstack=1
- hiveBeelineGstack=1

