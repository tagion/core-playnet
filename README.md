## The simple way
Tagion scripts were tested on Ubuntu 18.04 and Ubuntu 20.04.
To be able to run our network and use scripts, please set up the Docker app.
If you're unfamiliar with Docker, follow the [Getting Started With Docker guide](https://www.docker.com/get-started/) first.

### Pre-installation 
After installing the Docker app, open the terminal and enter the following commands to pull the necessary data.

```
docker pull tagion/playnet
git clone https://github.com/tagion/core-playnet.git
cd core-playnet
```

### Create network structure
Run the `create_wallets.sh` script to create a set of wallets and fulfiled database. By default, 7 wallets with pin code 000N (N-wallet number) and initial 100_000 TGN will be generated. To set up some different numbers of wallets, please, use the appropriate argument.
```
cd tagion_network
```
In this directory you can find N wallets. Also it contains data directory for database and shared directory for synchronizing nodes in mode1. 

If you want to clean everything in the tagion_network directory, just run `clean_tagion.sh`.

### Launch a network
You can run a network in 2 modes: 
- mode0 is the interprocess communication network mode
- mode1 is the local-network mode
The`launch. sh N --mode1` command starts the network with N nodes. If --mode1 is not provided it will start mode0 instead. 
Let's launch a network: 
```
../launch.sh 5 --mode1
```
Now you can see 5 terminals opened - each terminal is a separate node.

If you want to stop a mode1, just run `../stop_docker.sh`.

### Make a transaction
To make a first transaction we need create an invoice in receiver wallet first. Next, we need to update balance on sender, create and send a payment contract to pay an invoice and update balance on both wallets.
Let's do it:

```
../wallet.sh wallet_1 tagionwallet --create-invoice Test:55 --pin 0001
```
`../wallet.sh wallet_N` it runs a command in correct wallet folder

`--create-invoice LABEL:AMOUNT` this will create an `invoice_file.hibon`


```
../wallet.sh wallet_2 tagionwallet --update --amount --pin 0002 --port 10801
```
> Notice: for transactions in mode1 we use ports: 10801 - 1080N 

Now you can see how much TGN you have on your account now

```
../wallet.sh wallet_2 tagionwallet --pay ../wallet_1/invoice_hibon.sh --send --pin 0002 --port 10801
```
With `--pay ../wallet_1/invoice_file.hibon` we specify which invoice we would like to pay, so it will generate a payment contract. Parameter `--send ` will just send a contract to the network.

After ~10-15 seconds you can update your balance to check that transaction was completed

```
../wallet.sh wallet_2 tagionwallet --update --amount --pin 0002 --port 10801
../wallet.sh wallet_1 tagionwallet --update --amount --pin 0001 --port 10801
```
