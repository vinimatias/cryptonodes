# Desenvolvido por Cryptonodes.com.br

# Se você usou o nosso script, considere fazer uma doação e mantenha nosso site em funcionamento.

# Testado no Ubuntu 22.04

# Instalação dos programas padrão para a maioria dos nodes.

# Download da versão mais atualizada do GO
wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz 
# Remove as instalações anteriores do Go, e extrai os arquivos para a pasta
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
# Inclui a pasta do GO nas variavéis do Sistema
export PATH=$PATH:/usr/local/go/bin
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

sudo apt-get install linux-kernel-headers build-essential htop screen make net-tools docker.io ca-certificates curl docker-compose-plugin software-properties-common git gnupg lsb-release jq ansible -y
