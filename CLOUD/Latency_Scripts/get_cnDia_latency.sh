#!/bin/bash

if [ $# -gt 0 ]
then
    if [ $1 == "-h" ] || [ $1 == "--help" ]
    then
        echo -e "Usage:"
	echo -e "\tget_cnDia_latency.sh -h|--help | <NUM_SECONDS>\n"
	echo -e "Script to generate data file with latency info from the cnDiaproxy."
        echo -e "Traffic must be running since it is the cnDiaproxy who will collect the data." 
        echo -e "It will save the latency file under /opt/hss/<user-id>/titansim_HSS_BAT_Diaproxy_x "
	echo -e "while run_titansim command is being executed and once the traffic is over,"
	echo -e "you can see the file under the traffic directory"
        echo -e "Parameters:"
        echo -e "\t-h, --help"
        echo -e "\t\tShows this help message and exits.\n"
        echo -e "\t<NUM_SECONDS>"
        echo -e "\t\tIs the number of seconds that the script will collect the latency data of the traffic."
        echo -e "\t\tA high value will impact in cnDiaproxy performance."
        echo -e "\t\tIt is optional. By default it will be just 10 seconds.\n"
        exit 0
    fi

    INTERVAL=$1  
    echo "Interval is $INTERVAL"
    if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]
        then
            echo "Sorry, the parameter must be an integer to indicate the numbers of the seconds for the collection of data"
            exit 1
    fi
else
    INTERVAL=10  # by default, the interval is 10 seconds
fi

# CHecking the 4 possible UDM ports for cnDiaProxy depending on the traffic
EPC_SYNC_UDP_PORT=`ps -ef | grep -i cnDiaProxy | grep  EPC_SYNC | awk ' {if ($13=="-udp") {print $14; exit}} ' `
EPC_ASYNC_UDP_PORT=`ps -ef | grep -i cnDiaProxy | grep EPC_ASYNC | awk ' {if ($13=="-udp") {print $14; exit}} ' `
IMS_SYNC_UDP_PORT=`ps -ef | grep -i cnDiaProxy | grep  IMS_SYNC | awk ' {if ($13=="-udp") {print $14; exit}} ' `
IMS_ASYNC_UDP_PORT=`ps -ef | grep -i cnDiaProxy | grep IMS_ASYNC | awk ' {if ($13=="-udp") {print $14; exit}} ' `
if [ -z "$EPC_SYNC_UDP_PORT" ]  && [ -z "$EPC_ASYNC_UDP_PORT" ] && [ -z "$IMS_SYNC_UDP_PORT" ]  && [ -z "$IMS_ASYNC_UDP_PORT" ]
then
     echo "Not UDP ports found for cnDiaproxy processes. Please make sure cnDiaproxy is running before executing the script again"
     exit 1
fi
HOSTNAME=`hostname`
if [ ! -z "$EPC_SYNC_UDP_PORT" ]
then
    echo "Running command in $HOSTNAME for port $EPC_SYNC_UDP_PORT  (BAT_EPC_SYNC traffic)"
    RemoteControl -h $HOSTNAME -p $EPC_SYNC_UDP_PORT -c "enable_report latency LAT_EPC_SYNC"
    echo "`date "+%F %T" ` Starting collecting data for $INTERVAL seconds"
    RemoteControl -h $HOSTNAME -p $EPC_SYNC_UDP_PORT -c "start_report latency "
    sleep $INTERVAL
    echo "`date "+%F %T" ` Stopping collecting data"
    RemoteControl -h $HOSTNAME -p $EPC_SYNC_UDP_PORT -c "stop_report latency "
    echo "`date "+%F %T"`  Data collected. File will be saved under the BAT directory with LAT_EPC_SYNC_$HOSTNAME prefix"
fi

if [ ! -z "$EPC_ASYNC_UDP_PORT" ]
then
    echo "Running command in $HOSTNAME for port $EPC_ASYNC_UDP_PORT  (BAT_EPC_ASYNC traffic)"
    RemoteControl -h $HOSTNAME -p $EPC_ASYNC_UDP_PORT -c "enable_report latency LAT_EPC_ASYNC"
    echo "`date "+%F %T" ` Starting collecting data for $INTERVAL seconds"
    RemoteControl -h $HOSTNAME -p $EPC_ASYNC_UDP_PORT -c "start_report latency "
    sleep $INTERVAL
    echo "`date "+%F %T" ` Stopping collecting data"
    RemoteControl -h $HOSTNAME -p $EPC_ASYNC_UDP_PORT -c "stop_report latency "
    echo "`date "+%F %T"`  Data collected. File will be saved under the BAT directory with LAT_EPC_ASYNC_$HOSTNAME prefix"
fi

if [ ! -z "$IMS_SYNC_UDP_PORT" ]
then
    echo "Running command in $HOSTNAME for port $IMS_SYNC_UDP_PORT  (BAT_IMS_SYNC traffic)"
    RemoteControl -h $HOSTNAME -p $IMS_SYNC_UDP_PORT -c "enable_report latency LAT_IMS_SYNC"
    echo "`date "+%F %T" ` Starting collecting data for $INTERVAL seconds"
    RemoteControl -h $HOSTNAME -p $IMS_SYNC_UDP_PORT -c "start_report latency "
    sleep $INTERVAL
    echo "`date "+%F %T" ` Stopping collecting data"
    RemoteControl -h $HOSTNAME -p $IMS_SYNC_UDP_PORT -c "stop_report latency "
    echo "`date "+%F %T"`  Data collected. File will be saved under the BAT directory with LAT_IMS_SYNC_$HOSTNAME prefix"
fi

if [ ! -z "$IMS_ASYNC_UDP_PORT" ]
then
    echo "Running command in $HOSTNAME for port $IMS_ASYNC_UDP_PORT  (BAT_IMS_ASYNC traffic)"
    RemoteControl -h $HOSTNAME -p $IMS_ASYNC_UDP_PORT -c "enable_report latency LAT_IMS_ASYNC"
    echo "`date "+%F %T" ` Starting collecting data for $INTERVAL seconds"
    RemoteControl -h $HOSTNAME -p $IMS_ASYNC_UDP_PORT -c "start_report latency "
    sleep $INTERVAL
    echo "`date "+%F %T" ` Stopping collecting data"
    RemoteControl -h $HOSTNAME -p $IMS_ASYNC_UDP_PORT -c "stop_report latency "
    echo "`date "+%F %T"`  Data collected. File will be saved under the BAT directory with LAT_IMS_ASYNC_$HOSTNAME prefix"
fi

