#!/bin/bash

gnome="gnome-terminal --tab --"
CONSOLE="${3:-$gnome}"

mode0() {
    amount=$1
    # if [ -f "./data/node0/dart.drt" ]; then
    #     echo "DART file already exists.. If you want a clear dart - run create_wallets.sh"
    # else
    #     # cp ./data/dart.drt ./data/node0/dart.drt
    # fi
    docker run -it --net host --rm -v ${PWD}:/tgn/node tagion/playnet tagionwave --dart-init=false -N $amount --dart-synchronize=true 
}
mode1() {
    amount=$1
    # touch ./shared/.way
    rm -f ./shared/*
    for (( i=1; i < $amount; i++ ))
    do
        $CONSOLE docker run -it --net host --rm -v ${PWD}/shared:/tgn/node/shared tagion/playnet tagionwave --net-mode=local --boot=./shared/boot.hibon --dart-init=true --dart-synchronize=true --dart-path="./data/dart.drt" --port=400$i --transaction-port=1080$i --logger-filename=./shared/node-$i.log -N $amount
    done
    $CONSOLE docker run -it --net host --rm -v ${PWD}/shared:/tgn/node/shared -v ${PWD}/data:/tgn/node/data tagion/playnet tagionwave --net-mode=local --boot=./shared/boot.hibon --dart-init=false --dart-synchronize=false --dart-path="./data/dart.drt" --port=4020 --transaction-port=10820 --logger-filename=./shared/node-master.log -N $amount
}
if [[ $2 == *--mode1* ]]
then
    mode1 $1
else
    mode0 $1
fi
