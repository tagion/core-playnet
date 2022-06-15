<a href="https://tagion.org"><img alt="tagion logo" src="https://github.com/tagion/resources/raw/master/branding/logomark.svg?sanitize=true" alt="tagion.org" height="60"></a>

# Tagion 0.9.0 release
> The Tagion network decentralizes trading and transferring between compatible cryptocurrencies and is operated by a democratic governance mechanism. The network's users essentially own and control the network, as it is open and technically accessible for everyone.
> 
> The network itself consists of a **gossip protocol,** which is used for data synchronization, the **hashgraph algorithm**, which provides consensus and ordering transactions, and the **sharding** **opportunity,** which lets transactions run in parallel and enhances the speed of the system.

[Changelog file](changelog.md)

## Table of contents
- [Tagion 0.9.0 Release](#tagion-0.9.0-release)
  - [Table of contents](#table-of-contents)
- [Simple guide ](#simple-guide)
  - [Pre-installation](#pre-installation)
  - [Create network structure](#create-network-structure)
  - [Launch a network](#launch-a-network)
  - [Make a transaction](#make-a-transaction)
    - [Create an invoice](#create-an-invoice) 
    - [Update the balance](#update-the-balance)
    - [Make a payment](#make-a-payment)
- [Advanced guide](#advanced-guide)
  - [Preconditions](#preconditions)
    - [Docker usage](#docker-usage)
    - [Binary usage](#binary-usage)
  - [tagionwave CLI](#tagionwave-cli)
  - [tagionwallet CLI](#tagionwallet-cli)
  - [The payment request](#the-payment-reques) 
  - [Tagionboot CLI](#tagionboot-cli) 
  - [Dartutil CLI](#dartutil-cli) 
  - [The network setup](#the-network-setup)
- [Report an issue](#report-an-issue)


## Simple guide
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
Run the `create_wallets.sh` script to create a set of wallets and fulfilled the database. By default, 7 wallets with pin code 000N (N-wallet number) and an initial 100_000 TGN will be generated. Please use the appropriate argument to set up some different numbers of wallets. 
```
cd tagion_network
```
In this directory, you can find N wallets. Also, it contains a data directory for the database and a shared directory for synchronizing nodes in mode1. 

If you want to clean everything in the tagion_network directory, just run `clean_tagion.sh`.

### Launch a network
You can run a network in 2 modes: 
- mode0 is the interprocess communication network mode
Example: ```launch. sh 5 --mode0```
- mode1 is the local-network mode
The`launch. sh N --mode1 --gnome` command starts the network with N nodes. 
For mode1, it is necessary to provide a terminal mode as well: `--gnome` or `--screen`. Gnome is the default for ubuntu, so it's easy to run. But `screen` is recommended because you don't need to run multiple consoles. 
> To install screen, run `sudo apt-get install screen`.

Let's launch a network in mode1 with the default gnome terminal: 
```
../launch.sh 5 --mode1 --gnome
```
Now you can see 5 terminals opened - each terminal is a separate node.

If you want to stop a mode1, just run `../stop_docker.sh`.

### Make a transaction
To start making a transaction, we need to create an invoice in the receiver wallet first. Next, we need to update the balance on the sender, create and send a payment contract to pay an invoice and update the balance on both wallets.
Let's do it:
#### Create an invoice
```
../wallet.sh wallet_1 tagionwallet --create-invoice Test:55 --pin 0001
```
`../wallet.sh wallet_N` it runs a command in the correct wallet folder.

`--create-invoice LABEL:AMOUNT` this command will create an `invoice_file.hibon`.

#### Update the balance
```
../wallet.sh wallet_2 tagionwallet --update --amount --pin 0002 --port 10801
```
> Notice: for the transactions in mode1, we use ports: 10801 - 1080N 
> For mode0 you can use the default port - 10800

Now you can see how much TGN you have on your account.
#### Make a payment
```
../wallet.sh wallet_2 tagionwallet --pay ../wallet_1/invoice_hibon.sh --send --pin 0002 --port 10801
```
With `--pay ../wallet_1/invoice_file.hibon`, we specify the preferred invoice to pay, so it will generate a payment contract. Parameter `--send ` will just send a contract to the network.

After ~10-15 seconds, you can update your balance to check the transaction's complete.

```
../wallet.sh wallet_2 tagionwallet --update --amount --pin 0002 --port 10801
../wallet.sh wallet_1 tagionwallet --update --amount --pin 0001 --port 10801
```
> You may notice that sender sends more tagions - it's a fee's
> 
If you see that balance has changed - congratulations :tada::tada::tada:. 
If it doesn't work - you can find help in our [Discord channel](https://discord.gg/x7Wcg26E)  or report an issue on GitHub [Report Issue](#report-an-issue).



## Advanced guide
This guideline contains instructions if you want to use CLI directly, not via scripts. It has much more possible test scenarios. 

### Preconditions
Tagion CLI tools were tested only on Ubuntu 18.04 and Ubuntu 20.04.

You can try using our experimental Docker container instead if you use a different OS. If you're unfamiliar with Docker, follow the [Getting Started With Docker guide](https://www.docker.com/get-started/) first.
#### Docker usage
1. Run the following commands:
```
docker pull tagion/playnet

```
To run in interactive mode, use:
 `docker run --net host -it -v ${PWD}:/tgn/workspace tagion/playnet
`

To run a single command, use:
`docker run --net host --rm -v ${PWD}:/tgn/workspace tagion/playnet TOOLNAME (PARAMS)`

2. The set of the CLI tools will be opened. The command running the CLI tools also contains the CLI name and arguments.

There are the following CLI tools available here:

* datrutil
* hibonutil
* tagionboot
* tagionwallet
* tagionwave 

#### Binary usage

For binary usage - download tagion binary from the release tab. Tagion binary contains all the other binaries. For better UX - you can create soft links with the following commands: 
```
ln -s ${PWD}/tagion ${PWD}/tagionwave
ln -s ${PWD}/tagion ${PWD}/tagionwallet
ln -s ${PWD}/tagion ${PWD}/hibonutil
ln -s ${PWD}/tagion ${PWD}/dartutil
ln -s ${PWD}/tagion ${PWD}/tagionboot
```

### tagionwave CLI
Tagionwave is a CLI for the network setup and running.
There are the following modes to run the network:
* Mode 0 - the interprocess communication (runs as one program);
* Mode 1 - the local network;
* Mode 2 - the distributed network;
* Mode 3 - the mode 2 + swap in and out.

`--net-mode=` set in witch mode to run a network: `internal` - mode0, `local` - mode1.
`--dart-init` flag shows if it's necessary to set a new Dart database. If it is set as `true`, the new Dart database will be created. If the database is already created, it will be rewritten to a new empty Dart database with this command, and all the previous data will be lost.
`--dart-synchronize` flag identify if the node needs to synchronize database. For the master node - set `false`.
`--dart-path="/data/%dir%/dart.drt"` set a path to the database where `%dir%` will be replaced in mode0 with nodeN (N - node number). 
`--boot` set a path to shared file (used only in mode1).
`--port` set a port for inter-node communication.
`--transaction-port=10800` set a port for connection with the wallet.
`--logger-filename` set a path to the logger file.
Use `tagionwave --help` to see all the parameters.
### tagionwallet CLI

To create the Dart database containing some tagions, generating a wallet first is necessary.
The wallet can be generated via the command line or UI application.

**To generate the tagionwallet via command line, complete the following steps:**

```
tagionwallet --generate-wallet --questions q1,q2,q3,q4 --answers a1,a2,a3,a4 -x 1111
```

After the wallet is created, the `device.hibon quiz.hibon tagionwallet.hibon` files will be generated.

The `device.hibon` file contains the data that allows the wallet's private key recovery.

The `quiz.hibon` contains the information for the wallet recovery and has to be saved separately from the device where the wallet is installed.

The `tagionwallet.hibon` has to be saved separately from `quiz.hibon` and `device.hibon`  for security reasons.

To check `*.hibon` files, use `hibonutil filename.hibon -p` command. The file will be converted from hibon to JSON format.

###  The payment request
For sending some tagions between the users, the payment request has to be generated first. The payment request here is a structure that contains a derived public key to send tagions to.


After wallet creation, the payment request can be generated with

`tagionwallet --create-invoice LABEL:100 -x 1111` command, and it will generate a file.


### Tagionboot CLI
The tagionboot is used to convert the payment request with tagion amount to the Dart database recorder file.

Use  `tagionboot invoice_file.hibon -o genesis.hibon`command to do it.

### Dartutil CLI
The dartutil CLI is used for communication with Dart database like:
*  to initialize the database
*  to show the database info
*  to modify the database

The `dartutil --initialize --dartfilename dart.drt`
command is used to create a new Dart database.
The `dartutil --dartfilename dart.drt --dump` command is used to read the concrete data into the database. 
To update the database with the recorder file, create the modify request with input file.
When `dartutil --dartfilename dart.drt --modify --inputfile genesis.hibon` command is executed, the previously created recorder file will be added to the Dart database.
 
###  The network setup
By default, the Dart file will be created in the current working directory.
In case of the network runs in internal mode, there will be directories for each node (node0, node1, node2, ...) with similar dart files in each one. We can run as many nodes as necessary. Each node is stored in a separate folder, and there is a separate Dart for each folder. All the nodes synchronize the Dart with node 0. So, node 0 becomes the master node, and the rest of the nodes have the same database as node 0.


When the data is synchronized, the Hashgraph starts. Nodes use SSL transaction ports for communication with the wallet client's app. Setting the port name and URL is necessary to send a request to the appropriate node.


There are the following request types:
 
*  The wallet update - an ability to send the request to the node to check your wallet balance with the `tagionwallet -- update --pin 1111 --amount` command.
*  The health check - the request to the node to check if it works. If the result is `{ 'inGraph': true', 'rounds':['u64', '0x47']}}}`, so the node works.
*  The request for tagions sending - an ability to create the 'invoice file.hibon' and create the path to this invoice via the 'pay' argument and some additional ones. Use the `tagionwallet --pay./w1/invoice_file.hibon --send --pin 1111` command for this action.

The transaction will be executed 10-15 seconds after the contract is sent to the network. 
After the wallet update, the amount of tagions sent will be available there.

## Report an issue
If you face a problem with the network - you can [open an issue](https://github.com/tagion/core-playnet/issues) or contact us in the development thread in [Discord](https://discord.gg/x7Wcg26E). 
To provide maximum information in this issue - you can provide a: 
- whole network directory (create an archive from `./tagion_network`)
- command history (type in console `history > console_history.log`)
- network logs (`./tagion_network/shared/`)