#!/bin/bash

helpFunction()
{
    printf "\nProvide valid params\n\n"
    echo "Usage: ~/baniries/tbsbuilderwizard.sh"
    echo -e "\t-p | --parallel-request-count total number of parallel request to be executed. Default is: 1. Only numeric value allowed."
    echo -e "\t-c | --category *Required. possible values are cpu | memory | delay | output | healthcheck"
    echo -e "\t-t | --time params time in ms. cause request to last for period of time. server sleeps."
    echo -e "\t-n | --nbytes request size. when passes with \"category=memory\", it causes memory size to be allocated in the server side. When passed with \"category=output\" it cause random text of size to be output."
    echo -e "\t-r | --random randomise the return. accepted values true | false"
    echo -e "\t-s | --http-status the http status code to be returned"
    echo -e "\t-f | --output-file output file path. Default value is: stress-test.csv"
    echo -e "\t-h | --help help"
    printf "\n"
    printf "\nExamples:\n"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/cpu?time=1000 - causes a request to last one second. During that time it will try to use 100% of a CPU core."
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/memory?nbytes=10000000&time=5000 - causes a request to last five seconds. During that time 10MB of memory will be allocated"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/delay?time=30000 - causes a request to last 30 seconds. During that time no CPU resources are spent, simulating slow or hung backend calls"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/delay?time=3000&random=true - causes a request to last, randomically, from 0 to 3 seconds"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/output?nbytes=3000 - causes 3KB of random text data to be returned from the server"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/output?nbytes=3000&time=60000 - the same as above, but now it will generate 3KB of data with a data rate of 0.5b/s so that it will last 60 seconds to output the whole data. It's usefull to test network appliances under slow connections conditions"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/delay?time=3000&random=true&http-status=500 - causes a request with random duration (0-3s) to return a response indicating an internal error"
    echo -e "\t* http://localhost:8080/web-stress-simulator-1.0.0/healthcheck - simple health check. traditional request processing."
}

parallelRequestCount=1
unset category
unset timems
unset nbytes
unset random
unset httpstatus
outputfile='stress-test.csv'

# read the options
TEMP=`getopt -o p:c:t:n:rs:f:h --long parallel-request-count:,category:,time:,nbytes:,random,http-status:,output-file:,help -n $0 -- "$@"`
eval set -- "$TEMP"
# echo $TEMP;
while true ; do
    # echo "here -- $1"
    case "$1" in
        -p | --parallel-request-count )
            case "$2" in
                "" ) shift 2 ;;
                * ) parallelRequestCount=$2; shift 2 ;;
            esac ;;
        -c | --category )
            case "$2" in
                "" ) shift 2 ;;
                * ) category=$2; shift 2 ;;
            esac ;;
        -t | --time )
            case "$2" in
                "" ) shift 2 ;;
                * ) timems=$2 ; shift 2 ;;
            esac ;;
        -n | --nbytes )
            case "$2" in
                "" ) shift 2 ;;
                * ) nbytes=$2; shift 2 ;;
            esac ;;
        -r | --random )
            case "$2" in
                "" ) shift 2 ;;
                * ) random=true; shift 2 ;;
            esac ;;
        -s | --http-status )
            case "$2" in
                "" ) shift 2 ;;
                * ) httpstatus=$2; shift 2 ;;
            esac ;;
        -f | --output-file )
            case "$2" in
                "" ) shift 2 ;;
                * ) outputfile=$2; shift 2 ;;
            esac ;;
        -h | --help ) helpFunction; break;;  
        -- ) shift; break;; 
        * ) break;;
    esac
done
#shopt -po xtrace 

if [[ -z $category || $category != @("cpu"|"memory"|"delay"|"output"|"healthcheck") ]]
then
    printf "\nInvalid category: $category\n--category cannot be blank and must be of accepted values.\n\nRun $0 --help to see all the options.\n\n"
    # helpFunction
    exit 1
fi


export $(cat .env | xargs)

# printf "\nbastion: $BASTION_HOST $FORWARDING_PORT $FORWARDING_IP"

stresstestsimulatorhost=$WEB_STRESS_TEST_SIMULATOR_URL
stresstestsimulatorport=$WEB_STRESS_TEST_SIMULATOR_PORT

if [[ -n $BASTION_HOST ]]
then
    isexist=$(netstat -ntlp | awk /$stresstestsimulatorport/'{print $4}' | grep ":${stresstestsimulatorport}$")
    if [[ -z $isexist ]]
    then
        source ~/binaries/bastiontunnel.sh
    fi
    stresstestsimulatorhost='localhost'
fi


baseurl='http://'$stresstestsimulatorhost':'$stresstestsimulatorport'/web-stress-simulator-1.0.0/'$category
params=''
if [[ -n $timems ]]
then
    params=$params'&time='$timems
fi
if [[ -n $nbytes ]]
then
    params=$params'&nbytes='$nbytes
fi
if [[ -n $random ]]
then
    params=$params'&random='$random
fi
if [[ -n $httpstatus ]]
then
    params=$params'&http-status='$httpstatus
fi







printf "\nCount: $parallelRequestCount, URL: $baseurl?run=x$params\n"

# while true; do
#     read -p "ok to continue? [y/n] " yn
#     case $yn in
#         [Yy]* ) printf "you said yes.\n"; break;;
#         [Nn]* ) printf "You said no.\n"; exit 1;;
#         * ) echo "Please answer yes[y] or no[n].";;
#     esac
# done

echo "" > $outputfile

seq 1 $parallelRequestCount | xargs -n1 -P$parallelRequestCount bash -c 'i=$0; url="'$baseurl'?run=${i}'$params'"; curl ${url}' >> $outputfile