#!/bin/bash
set -e

# =============================================================================
# Script para instalação e configuração do authd no Ubuntu 24
#
# Pré-requisitos:
#   - Este script deve ser executado como root (use sudo).
#   - As seguintes variáveis de ambiente precisam estar definidas:
#       AUTHD_SERVER_ADDRESS    -> Endereço do servidor authd (ex.: "https://auth.seudominio.com")
#       AUTHD_API_KEY           -> Chave de API para autenticação com o authd
#
# Variáveis opcionais (podem ser definidas ou usar os defaults):
#       AUTHD_CONFIG_PATH       -> Caminho do arquivo de configuração do authd
#                                   (default: /etc/authd/authd.conf)
#       AUTHD_SSH_CONFIG_OPTION -> Valor para integração SSH (ex.: "enabled")
#
# Referências:
#   - Instalação:    https://documentation.ubuntu.com/authd/en/latest/howto/install-authd/
#   - Configuração:  https://documentation.ubuntu.com/authd/en/latest/howto/configure-authd/
#   - Login via SSH: https://documentation.ubuntu.com/authd/en/latest/howto/login-ssh/#
# =============================================================================

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root. Use sudo."
  exit 1
fi

# Verifica as variáveis de ambiente obrigatórias
: "${AUTHD_SERVER_ADDRESS:?Variável AUTHD_SERVER_ADDRESS não definida}"
: "${AUTHD_API_KEY:?Variável AUTHD_API_KEY não definida}"

# Define valores padrão para variáveis opcionais, se não definidas
AUTHD_CONFIG_PATH=${AUTHD_CONFIG_PATH:-/etc/authd/authd.conf}
AUTHD_SSH_CONFIG_OPTION=${AUTHD_SSH_CONFIG_OPTION:-enabled}

echo "Atualizando repositórios..."
apt-get update

echo "Instalando o pacote authd..."
apt-get install -y authd

echo "Criando arquivo de configuração do authd em ${AUTHD_CONFIG_PATH}..."
cat > "${AUTHD_CONFIG_PATH}" <<EOF
# Configuração do authd
# =============================================================================
# Endereço do servidor authd
server_address = "${AUTHD_SERVER_ADDRESS}"

# Chave de API para autenticação
api_key = "${AUTHD_API_KEY}"

# Adicione aqui outras configurações conforme necessário...
EOF

echo "Configurando integração com o SSH..."

# --- Atualização do arquivo sshd_config ---
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_BACKUP="/etc/ssh/sshd_config.bak"

# Faz backup do arquivo sshd_config
cp "${SSHD_CONFIG}" "${SSHD_CONFIG_BACKUP}"
echo "Backup do ${SSHD_CONFIG} criado em ${SSHD_CONFIG_BACKUP}."

# Se necessário, insere a configuração para integração com authd.
# A linha abaixo é um exemplo; verifique na documentação oficial se há uma diretiva específica.
if ! grep -q "^# Authd Integration" "${SSHD_CONFIG}"; then
    echo -e "\n# Authd Integration" >> "${SSHD_CONFIG}"
    echo "AuthdIntegration ${AUTHD_SSH_CONFIG_OPTION}" >> "${SSHD_CONFIG}"
    echo "Linha de integração com authd adicionada ao ${SSHD_CONFIG}."
else
    echo "Configuração de integração com authd já existe em ${SSHD_CONFIG}."
fi

# --- Atualização do PAM para SSH (opcional) ---
PAM_SSHD="/etc/pam.d/sshd"
PAM_SSHD_BACKUP="/etc/pam.d/sshd.bak"

# Faz backup do arquivo PAM para ssh
cp "${PAM_SSHD}" "${PAM_SSHD_BACKUP}"
echo "Backup do ${PAM_SSHD} criado em ${PAM_SSHD_BACKUP}."

# Verifica se o módulo pam_authd já está referenciado; se não, adiciona uma linha.
if ! grep -q "pam_authd.so" "${PAM_SSHD}"; then
    echo -e "\n# Integração do authd via PAM" >> "${PAM_SSHD}"
    echo "auth    required    pam_authd.so" >> "${PAM_SSHD}"
    echo "Módulo pam_authd.so adicionado ao ${PAM_SSHD}."
else
    echo "Módulo pam_authd.so já configurado em ${PAM_SSHD}."
fi

echo "Reiniciando os serviços..."
systemctl restart authd
systemctl restart ssh

echo "Instalação e configuração do authd concluídas com sucesso."