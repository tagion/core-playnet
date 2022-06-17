#!/bin/bash
default_wallets_num=7
wallets_number=${1:-$default_wallets_num}
tool_precommand="docker run --rm -v \${PWD}:/tgn/node tagion/playnet "
docker=$2
correct_command() {
    if [[ $docker == "--nodocker" ]]; then 
       echo ""
    else
       echo ${tool_precommand//"\${PWD}"/${PWD}}
    fi
}
create_wallets() {
    for (( i=1; i <= $wallets_number; i++ ))
    do
        echo "Creating $i wallet with pin 000$i"
        mkdir -p "wallet_$i"
        cd wallet_$i
        cmd_tool=$(correct_command)
        # echo $cmd_tool
        $cmd_tool tagionwallet --generate-wallet --questions q1,q2,q3,q4 --answers a1,a2,a3,a4 -x 000$i
        $cmd_tool tagionwallet --create-invoice GENESIS:100000 -x 000$i
        $cmd_tool tagionboot invoice_file.hibon -o genesis.hibon
        cd ../
        cmd_tool=$(correct_command)
        $cmd_tool dartutil --dartfilename ./data/dart.drt --modify --inputfile ./wallet_$i/genesis.hibon
    done
}

mkdir -p tagion_network
cd tagion_network

mkdir -p data/node0
mkdir shared
cd data
cmd_tool=$(correct_command)
$cmd_tool dartutil --initialize --dartfilename dart.drt
cd ../
create_wallets
cp ./data/dart.drt ./data/node0/dart.drt