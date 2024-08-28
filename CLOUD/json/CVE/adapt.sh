#bin/bash

directorios=("NoTraffic" "30" "50" "MAX")

for k in "${directorios[@]}"
do
mkdir -p $k/LATENCY
mkdir -p $k/TOP_MEASURES
mkdir -p $k/TRAFFIC
echo *${k}_load
cp *${k}_load/EXECUTION/ACTION_HANDLER/* $k/TOP_MEASURES
cp -r *${k}_load $k/TRAFFIC
done


directorios=("30" "50" "MAX")


origen=`pwd`
for k in "${directorios[@]}"
do
echo *${k}_load
file=`ls -ltr *${k}_load/EXECUTION/BAT_EPC_ASYNC/ |grep ESM |grep stat |awk '{ print $9 }'`
echo file $file
check_BAT_errorRate *${k}_load/EXECUTION/BAT_EPC_ASYNC/$file all > $k/TRAFFIC/Error_Rate.output 
cd *${k}_load/EXECUTION/BAT_EPC_ASYNC/
check_TTCN_errors > $origen/$k/TRAFFIC/TTCN_Errors.output
cd $origen
filelatency=`ls -ltr *${k}_load/EXECUTION/BAT_EPC_ASYNC/ |grep latency |awk '{ print $9 }'`
echo latencyfile $filelatency
ST_AUTOMATION/CLOUD/Latency_Scripts/check_latency.sh *${k}_load/EXECUTION/BAT_EPC_ASYNC/$filelatency > $k/LATENCY/latency.output
cp *${k}_load/EXECUTION/BAT_EPC_ASYNC/$filelatency $k/LATENCY/
cd $origen
sleep 5
done

