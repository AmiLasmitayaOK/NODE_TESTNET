#!/bin/bash

while true
do

# Logo

curl -s https://raw.githubusercontent.com/Agus1224/NODE_TESTNET/main/logo_ALFONOVA | bash

# Menu

PS3='Select an action: '
options=(
"Install Node"
"Create wallet"
"Synchronize node via snapshot"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install Node")
echo "*********************"
echo -e "\e[1m\e[35m		Lets's begin\e[0m"
echo "*********************"
echo -e "\e[1m\e[32m	Enter your Validator_Name:\e[0m'"
echo "_|-_|-_|-_|-_|-_|-_|"
read Validator_Name
echo "_|-_|-_|-_|-_|-_|-_|"
echo export Validator_Name=${Validator_Name} >> $HOME/.bash_profile
echo export CHAIN_ID="canto_7700-1" >> $HOME/.bash_profile
source ~/.bash_profile

echo -e "\e[1m\e[32m1. Updating packages and dependencies--> \e[0m" && sleep 1
#UPDATE APT
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop screen unzip bc fail2ban htop -y

echo -e "        \e[1m\e[32m2. Installing GO--> \e[0m" && sleep 1
#INSTALL GO
ver="1.18.3" && \
cd $HOME && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "              \e[1m\e[32m3. Downloading and building binaries--> \e[0m" && sleep 1
#INSTALL
cd $HOME
git clone -b testnet https://github.com/Source-Protocol-Cosmos/source.git
cd ~/source
make install

sourced init $Validator_Name --chain-id $CHAIN_ID

curl -s  https://raw.githubusercontent.com/Source-Protocol-Cosmos/testnets/master/sourcechain-testnet/genesis.json > ~/.source/config/genesis.json
wget -O $HOME/.source/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Source/addrbook.json"

echo -e "                     \e[1m\e[32m4. Node optimization and improvement--> \e[0m" && sleep 1

seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.source/config/config.toml
peers="6ca675f9d949d5c9afc8849adf7b39bc7fccf74f@164.92.98.17:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.source/config/config.toml

sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0usource\"/;" ~/.source/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.source/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.source/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.source/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.source/config/config.toml

# pruning and indexer
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.source/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.source/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.source/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.source/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.source/config/config.toml


sudo tee /etc/systemd/system/sourced.service > /dev/null <<EOF
[Unit]
Description=source
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sourced) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable sourced
sudo systemctl restart sourced

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u sourced -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[35mcurl -s localhost:26657/status\e[0m"

break
;;
"Create wallet")
echo "_|-_|-_|-_|-_|-_|-_|"
echo -e "      \e[1m\e[35m Your WalletName:\e[0m'"
echo "_|-_|-_|-_|-_|-_|-_|"
read Wallet
echo export Wallet=${Wallet} >> $HOME/.bash_profile
source ~/.bash_profile
sourced keys add $Wallet
echo -e "      \e[1m\e[32m!!!!!!!!!SAVE!!!!!!!!!!!!!!!!SAVE YOUR MNEMONIC PHRASE!!!!!!!!!SAVE!!!!!!!!!!!!!!!!\e[0m'"

break
;;
"Synchronize node via snapshot")
sudo systemctl stop sourced
rm -rf $HOME/.source/data/
mkdir $HOME/.source/data/
cd $HOME
wget http://116.202.236.115:8000/sourcedata.tar.gz
tar -C $HOME/ -zxvf sourcedata.tar.gz --strip-components 1
wget -O $HOME/.source/data/priv_validator_state.json "https://raw.githubusercontent.com/obajay/StateSync-snapshots/main/priv_validator_state.json"
cd $HOME
rm sourcedata.tar.gz
sudo systemctl restart sourced && sudo journalctl -u sourced -f -o cat

break
;;
"Delete Node")
sudo systemctl stop sourced && \
sudo systemctl disable sourced && \
rm /etc/systemd/system/sourced.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .source && \
rm -rf source && \
rm -rf $(which sourced)

break
;;
"Exit")
exit
esac
done
done
