# Getting Started

Welcome to **_100 Days of Move_**, where we will learn everything about Move. This journey will help us cover all the concepts in the Move language and inspire everyone to develop and contribute to the ecosystem.

## What is Move?

![](assets/20250102_173148_movement-labs_cover.webp)

**Move** is a secure, verifiable, and flexible programming language used to write highly performant contracts on the blockchain. It was initially created by a team of engineers at **Meta** as part of their blockchain initiative. Later on, Move was adopted by newer blockchains like **Aptos**, **Sui**, and **MovementLabs**.

Move derives many of its core principles from **Rust** and follows a similar **strongly typed**, **borrow ownership** model. The way the Move language is designed gives users deep control over the management of borrowed resources, thereby allowing blockchains to **parallelize the execution** of multiple Move programs at once. This has led to significant boosts in **Transactions Per Second** (**TPS**) for these blockchains, even though the language is relatively new.

## Setup Movement CLI

Before we can start exploring the Movement ecosystem, we need to set up an execution environment that will enable us to compile, test, and deploy contracts on a Move-based blockchain ecosystem.

Luckily, **Movement** has its own highly performant and easy-to-use Movement CLI, which we can set up on our local machine. Here, I am using an Apple Silicon MacBook; however, for your system, you can refer to the in-depth guide posted in the [Resources](#resources) section.

### Step 1 - Clone Movement Repository

Go to an appropriate terminal, run the git clone command, and navigate to the project root

```bash
git clone https://github.com/movementlabsxyz/aptos-core/ && cd aptos-core
```

### Step 2 - Check Dependencies (Cargo and Rust)

Once in the project root, check if the required dependencies are installed to build the CLI. One can install all the necessary Rust requirements by following these commands:

```bash
curl https://sh.rustup.rs -sSf | sh
```

After successfully installing Cargo and Rust, the following output should be displayed.

```bash
Rust is installed now. Great!
```

Apart from installing Rust, please ensure that the other dependencies are also live and up-to-date. Feel free to raise a query in the issues section in case of any blockers.

* CMake
* Clang
* grcov
* lcov
* pkg-config
* libssl-dev
* protoc (and related tools)
* lld (only for Linux)

### Step 3 - Build Movement CLI

Run the cargo command to build the Movement CLI.

```bash
cargo build -p movement
```

![](assets/20250102_183043_cargo-build-output.png)

Kindly note that for the initial build, the time taken could be significant. However, with subsequent builds, it shouldn't take as long. After the build, one should be able to see the **movement binary** under **{PROJECT_ROOT}/target/debug**.

![](assets/20250102_183349_debug-build-output.png)

### Step 4 - Add to PATH

This binary can then be moved to a common PATH folder so that it can be easily accessed.

```bash
sudo cp target/debug/movement /usr/local/bin/
```

Additionally, one can run the following command to verify the installation.

```bash
movement -h
```

![Output for Movement Help Command](assets/20250102_183648_movement-cli-output.png)

## Setup Movement Project

After setting up the Movement CLI, one can go to the location where they want to initialize their project and run the following command.

```bash
mkdir first-movement-project
cd first-movement-project
movement init
```

You can enter the following details for the prompt shown. In case one wants to set up a project for another network, they can refer to the [network endpoints page](https://docs.movementnetwork.xyz/devs/networkEndpoints).

```bash
Configuring for profile default
Choose network from [devnet, testnet, local, custom | defaults to devnet]. For testnet, start over and run movement init --skip-faucet
custom
Enter your rest endpoint [Current: None | No input: Exit (or keep the existing if present)]
https://aptos.testnet.bardock.movementlabs.xyz/v1

Enter your faucet endpoint [Current: None | No input: Skip (or keep the existing one if present) | 'skip' to not use a faucet]
https://fund.testnet.bardock.movementlabs.xyz/

Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]
0x<YOUR_PRIVATE_KEY>

Account 0x9465f8e8a734d4d3576433559938087d35bee5e6fcb19c71337547bde522a457 has been already found onchain

---
Movement CLI is now set up for account 0x9465f8e8a734d4d3576433559938087d35bee5e6fcb19c71337547bde522a457 as profile default!
 See the account here: https://explorer.movementlabs.xyz/account/0x9465f8e8a734d4d3576433559938087d35bee5e6fcb19c71337547bde522a457?network=custom
 
            Run `movement --help` for more information about commands. 
 
            Visit https://faucet.movementlabs.xyz to use the testnet faucet.
{
  "Result": "Success"
}
```

Now, run the following command to add the necessary files.

```bash
movement move init --name hello_movement
```

Here hello_movement is the name of the Move module. The CLI is well-diversified, and one could try out various other options present in the toolkit. To explore the project directory, one can refer to this [folder](../demos/getting-started).

**Note:**
_The private key added in the demo folder is just for experimental purpose. It is strongly recommended to create your own private key for project setup, also never expose your private key publicly or commit it to any repository._

### Additional Commands

There are many more usecases which can be fulfilled by **Movement CLI** each of which are shown below:

```bash
 movement account balance  
```

To fetch users' account balance.

```bash
movement account transfer --account 0xba05b4d0b58763d566e807e75ec526c87a4a5645da406ccd6cf70309f1154f8a --amount 100000000
```

To transfer the balance from `default` account to another account. Note here `--account` tag is the receiver address.

```bash
movement account fund-with-faucet --faucet-url https://faucet.testnet.bardock.movementnetwork.xyz/ --account 0xba05b4d0b58763d566e807e75ec526c87a4a5645da406ccd6cf70309f1154f8a
```

To fund a given account from movement faucet. This command can be invoked in case the user is lacking funds for deployment and carrying other essential operations in devnet or testnet.

**Note:**
_The faucet command is only available for testnet and devnet._

## Resources<a id="resources"></a>

- [Move Origins](https://www.halborn.com/blog/post/what-is-the-move-programming-language)
- [Introduction - Move Book](https://move-language.github.io/move/introduction.html)
- [Setup Movement CLI](https://docs.movementnetwork.xyz/devs/movementcli)
- [Cargo and Rust Setup](https://doc.rust-lang.org/cargo/getting-started/installation.html)
- [Movement Network Endpoints](https://docs.movementnetwork.xyz/devs/networkEndpoints)
