#!/bin/bash
set -e  # Encerra o script se ocorrer um erro

LOG_FILE="/var/log/authd_instalacao.log"
exec &> >(tee -a "$LOG_FILE")  # Redireciona a saída para log

echo "🚀 Iniciando a instalação e configuração do authd..."
echo "📅 Data: $(date)"

# Verifica se o sistema é Ubuntu 24.04
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "24.04" ]]; then
    echo "❌ Este script é compatível apenas com Ubuntu 24.04. Encerrando..."
    exit 1
fi

echo "✅ Versão do Ubuntu: $UBUNTU_VERSION"

# Atualiza os pacotes do sistema
echo "🔄 Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

# Instala authd e pacotes adicionais conforme a documentação oficial
echo "📦 Instalando authd e pacotes adicionais..."
sudo add-apt-repository ppa:ubuntu-enterprise-desktop/authd -y
sudo apt update
sudo apt install -y authd gnome-shell yaru-theme-gnome-shell

# Instala o broker do Microsoft Entra ID
echo "📦 Instalando o broker do Microsoft Entra ID..."
sudo snap install authd-msentraid

# Cria o diretório de configuração dos brokers
echo "📁 Criando diretório de configuração dos brokers..."
sudo mkdir -p /etc/authd/brokers.d/

# Copia o arquivo de configuração do broker
echo "📝 Configurando o broker do Microsoft Entra ID..."
sudo cp /snap/authd-msentraid/current/conf/authd/msentraid.conf /etc/authd/brokers.d/

# Define as variáveis de ambiente conforme seu pedido
TENANT_ID="77bc4e1a-ae35-4264-a31c-6a302abd9b8c"
CLIENT_ID="98c29ad6-3913-45c5-afaf-4b2427252b6a"
DOMAIN="@hexingbrasil.onmicrosoft.com"

# Edita o arquivo de configuração do broker exatamente como solicitado
echo "📝 Criando broker.conf com a configuração exata..."
sudo tee /var/snap/authd-msentraid/current/broker.conf > /dev/null <<EOL
[oidc]
issuer = https://login.microsoftonline.com/$TENANT_ID/v2.0
client_id = $CLIENT_ID

[users]
home_base_dir = /home
ssh_allowed_suffixes = $DOMAIN

## 'allowed_users' specifies the users who are permitted to log in after
## successfully authenticating with the Identity Provider.
## Values are separated by commas. Supported values:
## - 'OWNER': Grants access to the user specified in the 'owner' option
##            (see below). This is the default.
## - 'ALL': Grants access to all users who successfully authenticate
##          with the Identity Provider.
## - <username>: Grants access to specific additional users
##               (e.g. user1@example.com).
## Example: allowed_users = OWNER,user1@example.com,admin@example.com
#allowed_users = OWNER

## 'owner' specifies the user assigned the owner role. This user is
## permitted to log in if 'OWNER' is included in the 'allowed_users'
## option.
##
## If this option is left unset, the first user to successfully log in
## via this broker will automatically be assigned the owner role. A
## drop-in configuration file will be created in broker.conf.d/ to set
## the 'owner' option.
##
## To disable automatic assignment, you can either:
## 1. Explicitly set this option to an empty value (e.g. owner = "")
## 2. Remove 'OWNER' from the 'allowed_users' option
##
## Example: owner = user2@example.com
#owner =
EOL

# Configura o SSH para utilizar o authd
echo "🔧 Configurando o SSH para utilizar o authd..."
sudo tee /etc/ssh/sshd_config.d/authd.conf > /dev/null <<EOL
UsePAM yes
KbdInteractiveAuthentication yes
EOL

# Reinicia os serviços para aplicar as configurações
echo "🔄 Reiniciando serviços..."
sudo systemctl restart authd
sudo snap restart authd-msentraid
sudo systemctl restart ssh

echo "✅ Configuração concluída com sucesso!"
echo "🛠️ Teste o login via SSH utilizando: ssh usuario$DOMAIN@hostname"
echo "📜 Logs disponíveis em: $LOG_FILE"
