# Instalação e Configuração do authd no Ubuntu 24

Este repositório contém um script Bash que automatiza a instalação e configuração do authd no Ubuntu 24, incluindo a integração com o login via SSH. O script utiliza variáveis de ambiente para facilitar a personalização dos parâmetros de configuração.

## Pré-requisitos

- **Sistema Operacional:** Ubuntu 24.
- **Permissões:** O script deve ser executado como root (ou com sudo).
- **Variáveis de Ambiente Obrigatórias:**
  - `AUTHD_SERVER_ADDRESS` – Endereço do servidor authd (ex.: `https://auth.seudominio.com`)
  - `AUTHD_API_KEY` – Chave de API para autenticação com o authd
- **Variáveis de Ambiente Opcionais:**
  - `AUTHD_CONFIG_PATH` – Caminho do arquivo de configuração do authd (padrão: `/etc/authd/authd.conf`)
  - `AUTHD_SSH_CONFIG_OPTION` – Valor para integração SSH (padrão: `enabled`)

## Instruções de Uso

### 1. Definir as Variáveis de Ambiente

Antes de executar o script, defina as variáveis necessárias. Por exemplo:

```bash
export AUTHD_SERVER_ADDRESS="https://auth.seudominio.com"
export AUTHD_API_KEY="sua-chave-de-api"
export AUTHD_SSH_CONFIG_OPTION="enabled"  # Opcional, se desejar alterar o padrão
```

### 2. Tornar o Script Executável

Conceda permissão de execução ao script:

```bash
chmod +x install_authd.sh
```

### 3. Executar o Script

Execute o script com privilégios de root:

```bash
sudo ./install_authd.sh
```

### 4. O que o Script Faz

- Atualiza os repositórios do sistema.
- Instala o pacote `authd`.
- Cria o arquivo de configuração em `/etc/authd/authd.conf` (ou no caminho definido na variável `AUTHD_CONFIG_PATH`), inserindo as variáveis de ambiente para o endereço do servidor e a chave de API.
- Realiza a integração do authd com o serviço SSH, fazendo backup do arquivo `/etc/ssh/sshd_config` e adicionando a configuração necessária.
- Configura a integração com o PAM para SSH, fazendo backup do arquivo `/etc/pam.d/sshd` e adicionando o módulo `pam_authd.so`.
- Reinicia os serviços `authd` e `ssh` para aplicar as configurações.

## Notas Importantes

- **Backup:** O script cria backups dos arquivos de configuração do SSH e do PAM (`sshd_config.bak` e `sshd.bak`), permitindo que você reverta as alterações se necessário.
- **Personalização:** Consulte a [documentação oficial do authd](https://documentation.ubuntu.com/authd/en/latest/howto/configure-authd/) para ajustes finos na configuração ou para adicionar novas diretivas conforme as necessidades do seu ambiente.
- **Integração SSH:** Verifique a seção de integração com SSH na [documentação oficial](https://documentation.ubuntu.com/authd/en/latest/howto/login-ssh/#) para garantir que a configuração adicionada ao `sshd_config` está de acordo com os requisitos da sua infraestrutura.

## Recursos Adicionais

- [Instalação do authd](https://documentation.ubuntu.com/authd/en/latest/howto/install-authd/)
- [Configuração do authd](https://documentation.ubuntu.com/authd/en/latest/howto/configure-authd/)
- [Login via SSH com authd](https://documentation.ubuntu.com/authd/en/latest/howto/login-ssh/#)