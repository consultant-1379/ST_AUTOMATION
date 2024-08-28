#!/bin/bash

if [ $# -gt 0 ]
then
    if [ $1 == "-h" ] || [ $1 == "--help" ]
    then
        echo -e "Usage:"
        echo -e "\tget_latency.sh -h|--help | <NUM_SECONDS>\n"
        echo -e "Where:"
        echo -e "\t-h, --help"
        echo -e "\t\tShows this help message and exits.\n"
        echo -e "\t<NUM_SECONDS>"
        echo -e "\t\tIs the number of seconds that the script will collect the latency data of the traffic.\n"
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

#let UDP_PORT=`ps -ef | grep -i Diaproxy | awk ' {if ($11=="-udp") print $12} ' `
UDP_PORT=`ps -ef | grep -i Diaproxy | awk ' {if ($11=="-udp") {print $12; exit}} ' `
if [ -z "$UDP_PORT" ]
then
     echo "Diaproxy process is not running. Please make sure it is running before executing the script again"
     exit 1
fi
HOSTNAME=`hostname`
echo "Running command in $HOSTNAME for port $UDP_PORT"
RemoteControl -h $HOSTNAME -p $UDP_PORT -c "enable_report latency Lat"
echo `date "+%F %T" ` Starting collecting data for $INTERVAL seconds
RemoteControl -h $HOSTNAME -p $UDP_PORT -c "start_report latency "
sleep $INTERVAL
RemoteControl -h $HOSTNAME -p $UDP_PORT -c "stop_report latency "
echo `date "+%F %T"`  Data collected. File will be saved under the BAT directory with Lat_$HOSTNAME prefix 

