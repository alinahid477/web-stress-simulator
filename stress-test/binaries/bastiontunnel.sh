#!/bin/bash


export $(cat .env | xargs)

# printf "\nbastion: $BASTION_HOST $FORWARDING_PORT $FORWARDING_IP"

stresstestsimulatorhost=$WEB_STRESS_TEST_SIMULATOR_URL
stresstestsimulatorport=$WEB_STRESS_TEST_SIMULATOR_PORT

if [[ -n $BASTION_HOST ]]
then
    idrsa=''
    isexist=$(ls .ssh/id_rsa)
    if [[ -z $isexist ]]
    then
        printf "\nWarning: BASTION_HOST $BASTION_HOST is mentioned in .env file but no id_rsa present in .ssh dir. This will prompt for password\n"
    else 
        idrsa="-i .ssh/id_rsa"
    fi
    printf "\nSetting up bastion host tunnel\n"
    ssh $id_rsa -4 -fNT -L $WEB_STRESS_TEST_SIMULATOR_PORT:$WEB_STRESS_TEST_SIMULATOR_URL:$WEB_STRESS_TEST_SIMULATOR_PORT $BASTION_USERNAME@$BASTION_HOST
    printf "Done\n"
fi
