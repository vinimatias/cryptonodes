# Desenvolvido por Cryptonodes.com.br

# Se você usou o nosso script, considere fazer uma doação e mantenha nosso site em funcionamento.

# Testado no Ubuntu 22.04

# Instalação dos node Pryzm

# Download da versão mais atualizada do GO
wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz 
# Remove as instalações anteriores do Go, e extrai os arquivos para a pasta
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
# Prepara a instalação do Docker
sudo install -m 0755 -d /etc/apt/keyrings
# Download das chaves de instalação do docker e acrescenta as mesmas e o repositório do docker ao Sistema
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Atualiza os repositórios e os programas já instalados
sudo apt update && sudo apt upgrade -y
# Instala o repositório do Ansible
apt-add-repository --yes --update ppa:ansible/ansible
# Instala os aplicativos que geralmente são exigidos pelos nodes e mais alguns utilitários.

sudo apt-get install linux-kernel-headers build-essential wget htop tmux screen make net-tools docker.io ca-certificates curl docker-compose-plugin software-properties-common git gnupg lsb-release jq lz4 gcc unzip ansible -y
# Inclui a pasta do GO nas variavéis do Sistema
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# set vars
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export PRYZM_CHAIN_ID="indigo-1"" >> $HOME/.bash_profile
echo "export PRYZM_PORT="41"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# download binary
cd $HOME
wget https://storage.googleapis.com/pryzm-zone/core/0.15.0/pryzmd-0.15.0-linux-amd64.tar.gz
tar -xzvf $HOME/pryzmd-0.15.0-linux-amd64.tar.gz
mv pryzmd $HOME/go/bin

# config and init app
pryzmd config node tcp://localhost:${PRYZM_PORT}657
pryzmd config keyring-backend os
pryzmd config chain-id indigo-1
pryzmd init "test" --chain-id indigo-1

# download genesis and addrbook
wget -O $HOME/.pryzm/config/genesis.json https://testnet-files.itrocket.net/pryzm/genesis.json
wget -O $HOME/.pryzm/config/addrbook.json https://testnet-files.itrocket.net/pryzm/addrbook.json

# set seeds and peers
SEEDS="fbfd48af73cd1f6de7f9102a0086ac63f46fb911@pryzm-testnet-seed.itrocket.net:41656"
PEERS="713307ce72306d9e86b436fc69a03a0ab96b678f@pryzm-testnet-peer.itrocket.net:41656,9bd9f155bb57d3ad2a8fb03e93c29da5ffd47751@[2a01:4f9:c011:a7e6::1]:23256,5d00ca94af3b6bde01f5684b81b9fd9a03fa0eeb@84.247.190.189:656,21086ec6fe14f8dc3f45886a9891ac8ec6f27da2@194.87.25.108:656,794b538577a59f789ce942fd393730da3e8c0ffe@34.65.224.175:26656,6e0ac6daac63bc2bedbad8c783b20bd3141c0556@79.133.57.214:26656,f53beda64d780fdee9da10aae7b5aa92636b10e0@207.180.210.65:41656,cdcd86ca01858275d0e78ee66b82109ee06df454@65.108.72.253:40656,2b4795eced0fe74bb866c6096731db1db10c4ec6@162.55.4.42:32656,405841883feda127e81f02d61bd5a800b0a5532a@95.217.62.210:13656,d46155d57418e3d4834fde3af7c4ce5a69ccbdda@95.216.245.247:34656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.pryzm/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${PRYZM_PORT}317%g;
s%:8080%:${PRYZM_PORT}080%g;
s%:9090%:${PRYZM_PORT}090%g;
s%:9091%:${PRYZM_PORT}091%g;
s%:8545%:${PRYZM_PORT}545%g;
s%:8546%:${PRYZM_PORT}546%g;
s%:6065%:${PRYZM_PORT}065%g" $HOME/.pryzm/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${PRYZM_PORT}658%g;
s%:26657%:${PRYZM_PORT}657%g;
s%:6060%:${PRYZM_PORT}060%g;
s%:26656%:${PRYZM_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${PRYZM_PORT}656\"%;
s%:26660%:${PRYZM_PORT}660%g" $HOME/.pryzm/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.pryzm/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.pryzm/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.pryzm/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.015upryzm"|g' $HOME/.pryzm/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.pryzm/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.pryzm/config/config.toml

# create service file
sudo tee /etc/systemd/system/pryzmd.service > /dev/null <<EOF
[Unit]
Description=Pryzm node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.pryzm
ExecStart=$(which pryzmd) start --home $HOME/.pryzm
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset and download snapshot
pryzmd tendermint unsafe-reset-all --home $HOME/.pryzm
if curl -s --head curl https://testnet-files.itrocket.net/pryzm/snap_pryzm.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/pryzm/snap_pryzm.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.pryzm
    else
  echo no have snap
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable pryzmd
sudo systemctl restart pryzmd && sudo journalctl -u pryzmd -f
