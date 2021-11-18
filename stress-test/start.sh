name=$1
forcebuild=$2
if [[ $name == "forcebuild" ]]
then
    name=''
    forcebuild='forcebuild'
fi
if [[ -z $name ]]
then
    name='stresstest'
    printf "\nAssuming default container name: $name"
fi
isexists=$(docker images | grep "\<$name\>")
if [[ -z $isexists || $forcebuild == "forcebuild" ]]
then
    docker build -f Dockerfile -t $name .
fi


docker run -it --rm --add-host kubernetes:127.0.0.1 -v ${PWD}:/root/ --name $name $name /bin/bash

