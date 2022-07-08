#!/bin/bash

gnome="gnome-terminal --tab -- "
screen="screen -S testnet -dm "

if [[ $* == *--nodocker* ]]
then 
    PRECOMMAND=""
else 
    PRECOMMAND="docker run -it --net host --rm -v ${PWD}:/tgn/node tagion/playnet "
fi
if [[ $* == *--gnome* ]] 
then
    if ! command -v gnome-terminal &> /dev/null
    then
        echo "gnome-terminal could not be found"
    else
        CONSOLE=$gnome
    fi
fi
if [[ $* == *--screen* ]]
then
    if ! command -v screen &> /dev/null
    then 
        echo "screen could not be found"
    else
        CONSOLE=$screen
        echo "To view running sessions use: screen -ls"
        echo "To attach to session use: screen -x session_id"
    fi
fi
mode0() {
    amount=$1
    # if [ -f "./data/node0/dart.drt" ]; then
    #     echo "DART file already exists.. If you want a clear dart - run create_wallets.sh"
    # else
    #     # cp ./data/dart.drt ./data/node0/dart.drt
    # fi

    $PRECOMMAND tagionwave --dart-init=false -N $amount --dart-synchronize=true     
}
mode1() {
    amount=$1
    # touch ./shared/.way
    rm -f ./shared/*
    for (( i=1; i < $amount; i++ ))
    do
        $CONSOLE $PRECOMMAND tagionwave --net-mode=local --boot=./shared/boot.hibon --dart-init=true --dart-synchronize=true --dart-path="./data/dart$i.drt" --port=$((4000+$i)) --transaction-port=$((10800+$i)) --logger-filename=./shared/node-$i.log -N $amount        
    done

    $CONSOLE $PRECOMMAND tagionwave --net-mode=local --boot=./shared/boot.hibon --dart-init=false --dart-synchronize=false --dart-path="./data/dart.drt" --port=4020 --transaction-port=10820 --logger-filename=./shared/node-master.log -N $amount
        
}
if [[ $* == *--mode1* ]]
then

    if [ -z "$CONSOLE" ]
    then
        echo "No terminal provider! Can't run multiple nodes.. Please select --gnome or --screen"
    else
        mode1 $1
    fi
elif [[ $* == *--mode0* ]]
then
    mode0 $1
else 
    echo "Please provide mode flag: --mode0 or --mode1"
fi
