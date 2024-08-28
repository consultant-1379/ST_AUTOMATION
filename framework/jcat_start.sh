#!/bin/bash

# **********************************************************************************************************
# This script is for running Jcat via CLI in HSS development automated testing 
#
# Main purpose for this script is to run java jar file for running stability, robustness testcases and upgrade (smooth
# and redundand)
#
#  2014-09-03 -    pa1 - ebozvuk - added switch logic
#  2014-12-11 -    pa2 - ebozvuk - updated script to be used with Hss St Fw Bundle
#
#  HOW TO USE
#  Aim of this script is to simplify running TC through CLI for HSS System Test.
#  PLEASE ENTER ALL INFO INTO VARIABLES (OR VIA SCRIPT PARAMETERS) FOR VM ARGUMENTS THAT ARE MANDATORY
#  
# **********************************************************************************************************
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
# Location of latest build of HSS ST Automation code==============================================================
jarfile=./HssStFw-0.4.4.jar

#Check mandatory parameters
mand=0

#VM arguments=====================================================================================================
#Location of suite (MANDATORY). Suite is xml configuration file containing list of TCs to be executed in one run.
#EXAMPLE: suite="../configuration_TSP/tspMonolithicSuite.xml"
suite=""

#-Dtestconf.config (MANDATORY) - Path to test case parameters definition
#EXAMPLE: TCconfiguration="../configuration_TSP/tspMonolithicConfiguration.xml"
TCconfiguration=""

#-Dtopology.config (MANDATORY) - Path to topology XML file
#EXAMPLE: topology="../networks/vTSP_02_MO.xml"
topology=""

#-Djcat.logging (optional) - This parameter determines JCAT logging level. Default value is info
#EXAMPLE: jcatlogging="info"
jcatlogging="info"

#-Dlogdir (optional) - JCAT logs location directory (if not set default will be in your /home directory)
#EXAMPLE: logdir="/tmp/MyJcatLogs"
logdir="/tmp/${USER}/JcatLogs/"

#-Dname (optional) -Your name of the suite for log directory naming 
#EXAMPLE: name="myName"
name="${USER}_Test"

#-Dswrepo.config (optional) - Path to software repository parameters definitions
#EXAMPLE: swRepo="configs/sw_repository/CorrectValues.xml"
swRepo=""

#-Dloadplotter.udp (optional) – If set to true, Load plotter will use UDP solution to fetch HSS node load values. Otherwise (value is false or not present) – Load plotter will use SSH (RemoteControl script) solution
loadplotter="false"

#Both arguments must be set with integer (bash restrictions), but with Eclipse & DSM execution can be set to integer or double positive value (e.g. 12, 10.5...)


#Switch & Usage/Help logic
#============================================================================================================================================================================================#
#PRINT HELP MESSAGE
__print_help_message()
{
  echo -e "\n\e[1mExecution date:  `date`\e[0m\n"
  echo -e "======================================================================================"
  echo -e "  JCat HSS ST Start Script (jcat_start.sh) \e[0m"
  echo -e "  Please read comments inside script for Script Usage \e[0m"
  echo -e "======================================================================================"
  

  printf "Running java jar file which runs test cases\n"
  printf "\nFormat:  /sh jcat_start.sh [ -l | --logdir ][ -u | --username ] \n"
  printf "\nWhere:\n"
  printf "\nScript needs lab user name to be added as parameters\n"
  printf "\t -u  | --username   username\n"
  printf "\nArguments that can be added by parameters or with script editing\n"
  printf "\t -s  | --suite             Path to suite xml file(MANDATORY - enter within script or via this parameter)\n"  
  printf "\t -c  | --config            TC Configuration xml file(MANDATORY - enter within script or via this parameter)\n"
  printf "\t -t  | --topology          Path to network topology file(MANDATORY - enter within script or via this parameter)\n"
  printf "\t -r  | --repo              Path to SW repository xml file\n"
  printf "\t -o  | --loadplotter       LoadPlotter use UDP solution to fetch HSS node load values (true|false)\n"
  printf "\t -l  | --logdir            Enter full path where log files will be stored\n"  
  printf "\t -L  | --logging           JCat logging type (info by default)\n"
  printf "\t -h  | --help              prints this message\n"
  printf "\t -S  | --stolerance        parameter is not valid anymore\n"
  printf "\t -T  | --ttolerance        parameter is not valid anymore\n"
  printf "\n\n"
  __show_examples
  exit 0
}

__show_examples()
{
	cat <<EOD
Examples:
	./jcat_start.sh -u hssci

	./jcat_start.sh -u hssci

	./jcat_start.sh -u hssci

EOD
}
#============================================================================================================================================================================================#
#PARSE INPUT 
__parse_input()
{
  if [[  ($1 = "-h") ||  ($1 = "--help")  ]]; then
      __print_help_message
      exit 1;
  fi

  ARGS=$(getopt -s bash -n "$0"  -o l:u:s:L:v:c:t:r:h:o:S:T: --long "logdir:,username:,suite:,logging:,config:,topology:,repo:,help:,loadplotter:"  -- "$@");

  #Bad arguments
  if [ $? -ne 0 ];
  then
    exit 1
  fi
  
  #important part
  eval set -- "$ARGS";
  
  while true; do
    case "$1" in
    -l|--logdir)
                  shift;
                  logdir=$1
                  shift;
                  ;;
    -u|--username)
                  shift;
                  user=$1
                  mand=`expr $mand + 1`
                  shift;
                  ;;
    -s|--suite)
                  shift;
                  suite=$1
                  shift;
                  ;;
    -L|--logging)
                  shift;
                  jcatlogging=$1
                  shift;
                  ;;
    -c|--config)
                  shift;
                  TCconfiguration=$1
                  shift;
                  ;;
    -t|--topology)
                  shift;
                  topology=$1
                  shift;
                  ;;
    -r|--repo)
                  shift;
                  swRepo=$1
                  shift;
                  ;;
    -o|--loadplotter)
                  shift;
                  loadplotter=$1
                  shift;
                  ;;
    -h|--help)
                  __print_help_message
                  break;
                  ;;
    -S|--stolerance)
                  echo -e "parameter is not valid anymore"
                  break;
                  ;;
    -T|--Ttolerance)
                  echo -e "parameter is not valid anymore"
                  break;
                  ;;
    --)
      shift;
      break;
      ;;
    esac    
  done

  if [[ $mand != 1 ]]; then
    __print_help_message
    exit 1;
  fi
}

__set_parameters()
{
    #----------------------------------------------------------
	# TODO: Fix this using TestInfo to set up the params
    #----------------------------------------------------------
	if [[ -z $suite || -z $TCconfiguration || -z $topology ]];then
                printf "\n\e[1mERROR: Missing some Mandatory VM Arguments:\n\n"
	fi
	if [[ -z $suite ]];then
		echo -e "\e[1mERROR: Missing Suite VM Argument (suite=)\e[0m"		
	fi
	if [[ -z $TCconfiguration ]];then
		echo -e "\e[1mERROR: Missing Test Configuration VM Argument (TCconfiguration=)\e[0m"
		
	fi
	if [[ -z $topology ]];then
		echo -e "\e[1mERROR: Missing Topology VM Argument (topology=)\e[0m"
	fi
	if [[ -z $suite || -z $TCconfiguration || -z $topology ]];then
		__print_help_message
	fi
    #----------------------------------------------------------
    name=$(basename $suite| sed 's/\.xml//g')
	cabinet=$(sed -ne '/cabinetName/ { s/cabinetName//g' -e 's/[\\<\\>\/]//g' -e 's/[ \t]*//gp}' $topology | tr '[:lower:]' '[:upper:]')
	product=HSS
	project=HSS
	productname=$product
	testtype=HSS_ST_JCAT
}
#============================================================================================================================================================================================#
#MAIN#

__parse_input "$@"
__set_parameters

cmd="java \
-Djcatuser=$user \
-Dtestconf.config=$TCconfiguration \
-Dtopology.config=$topology \
-Dswrepo.config=$swRepo \
-Dloadplotter.udp=$loadplotter \
-Dname=$name \
-Dsutname=$cabinet \
-Dgroupid=$cabinet \
-Dproject=$project \
-Dproductname=$product \
-Dtesttype=$testtype \
-Dlogdir=$logdir \
-Djcat.logging=$jcatlogging \
-cp $jarfile org.testng.TestNG $suite"

echo "Executing Command: [$cmd]"
$cmd
exit $?
