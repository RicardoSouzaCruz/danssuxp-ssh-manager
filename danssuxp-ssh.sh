#!/bin/bash

# ╔════════════════════════════════════════════════════╗
# ║           SCRIPT CRIADO POR: DANSSUXP              ║
# ║              TODOS DIREITOS RESERVADOS             ║
# ╚════════════════════════════════════════════════════╝

# --------------------------
# CONFIGURAÇÕES PERSONALIZADAS
# --------------------------
NOME_SCRIPT="DANSSUXP SSH"
VERSAO="3.0-SECURE"
SENHA_ACESSO="danssuxp123"   # ⚠️ MUDE ISSO!
PORTA_SSH=22
PORTA_SSL=443
PORTA_DROPBEAR=80
PORTA_SQUID=8080
DIRETORIO_DADOS="/etc/danssuxp"
ARQUIVO_LOG="/var/log/danssuxp.log"
ARQUIVO_CONTAS="$DIRETORIO_DADOS/contas.db"

# Cores
VERMELHO='\033[1;31m'
VERDE='\033[1;32m'
AMARELO='\033[1;33m'
AZUL='\033[1;34m'
ROXO='\033[1;35m'
CIANO='\033[1;36m'
RESET='\033[0m'

# Verifica se é root
if [ "$(id -u)" != "0" ]; then
   echo -e "${VERMELHO}❌ ERRO: Execute este script como root!${RESET}"
   exit 1
fi

# Cria pastas necessárias
mkdir -p $DIRETORIO_DADOS
touch $ARQUIVO_CONTAS
touch $ARQUIVO_LOG

# --------------------------
# CABEÇALHO COM SUA MARCA
# --------------------------
cabecalho() {
    clear
    echo -e "$ROXO"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║                                                    ║"
    echo "║          🔥 ${NOME_SCRIPT}  🔥                 ║"    echo "║              Versão: ${VERSAO}                      ║"
    echo "║                                                    ║"
    echo "║       💻 CRIADO E DESENVOLVIDO POR: DANSSUXP 💻   ║"
    echo "║                                                    ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "$RESET"
}

# --------------------------
# TELA DE SENHA DE ACESSO 🔒
# --------------------------
verificar_senha() {
    tentativas=3
    while [ $tentativas -gt 0 ]; do
        cabecalho
        echo -e "$CIANO🔐  ACESSO RESTRITO - SOMENTE ADMINISTRADOR$RESET"
        echo "--------------------------------------------"
        echo -e "Tentativas restantes: $VERMELHO$tentativas$RESET"
        read -s -p "Digite a senha de acesso: " senha_digitada
        echo ""

        if [ "$senha_digitada" = "$SENHA_ACESSO" ]; then
            echo -e "$VERDE✅ Acesso liberado! Carregando sistema...$RESET"
            sleep 1
            return 0
        else
            tentativas=$((tentativas - 1))
            if [ $tentativas -gt 0 ]; then
                echo -e "$VERMELHO❌ Senha incorreta! Tente novamente.$RESET"
                sleep 2
            fi
        fi
    done

    echo -e "$VERMELHO🚫 ACESSO NEGADO! Sistema bloqueado.$RESET"
    echo "[$(date)] Tentativa de acesso não autorizado" >> $ARQUIVO_LOG
    sleep 2
    clear
    exit 1
}

# --------------------------
# FUNÇÃO: CRIAR CONTA SSH 🔐
# --------------------------
criar_conta() {
    cabecalho
    echo -e "$CIANO📌 CRIAR NOVA CONTA - DANSSUXP$RESET"
    echo "------------------------"
    
    # Validação de campos    read -p "Usuário (sem espaços): " usuario
    if [ -z "$usuario" ]; then
        echo -e "$VERMELHO❌ Erro: Nome de usuário não pode ser vazio!$RESET"
        sleep 2
        return
    fi
    
    # Verifica se usuário já existe
    if id "$usuario" &>/dev/null; then
        echo -e "$VERMELHO❌ Erro: Usuário '$usuario' já existe!$RESET"
        sleep 2
        return
    fi
    
    # Validação do nome de usuário (só letras, números, _ e -)
    if ! [[ "$usuario" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "$VERMELHO❌ Erro: Use apenas letras, números, _ e -$RESET"
        sleep 2
        return
    fi
    
    read -s -p "Senha: " senha
    echo ""
    if [ -z "$senha" ]; then
        echo -e "$VERMELHO❌ Erro: Senha não pode ser vazia!$RESET"
        sleep 2
        return
    fi
    
    read -p "Validade (dias): " validade
    if ! [[ "$validade" =~ ^[0-9]+$ ]] || [ "$validade" -le 0 ]; then
        echo -e "$VERMELHO❌ Erro: Validade deve ser um número positivo!$RESET"
        sleep 2
        return
    fi
    
    read -p "Limite de conexões: " limite
    if ! [[ "$limite" =~ ^[0-9]+$ ]] || [ "$limite" -le 0 ]; then
        echo -e "$VERMELHO❌ Erro: Limite deve ser um número positivo!$RESET"
        sleep 2
        return
    fi

    # Cria usuário SEM home e SEM shell (segurança máxima)
    useradd -M -s /usr/sbin/nologin "$usuario" 2>/dev/null
    echo "$usuario:$senha" | chpasswd
    
    # Define validade da conta
    data_exp=$(date -d "+$validade days" +%Y-%m-%d)
    usermod -e "$data_exp" "$usuario"    
    # Define limite de conexões (via systemd ou limits.conf)
    echo "$usuario hard maxlogins $limite" >> /etc/security/limits.conf
    
    # Salva dados no banco
    data_criacao=$(date +%d/%m/%Y-%H:%M)
    echo "[$data_criacao] | Usuário: $usuario | Senha: $senha | Validade: $validade dias ($data_exp) | Conexões: $limite | Status: ATIVO" >> $ARQUIVO_CONTAS
    
    # Log
    echo "[$(date)] CONTA CRIADA: $usuario (Validade: $validade dias)" >> $ARQUIVO_LOG
    
    echo -e "$VERDE✅ Conta '$usuario' criada com sucesso!$RESET"
    echo -e "$CIANO📅 Vencimento: $data_exp$RESET"
    echo -e "$AMARELO🔑 Senha: $senha$RESET"
    sleep 3
}

# --------------------------
# FUNÇÃO: REMOVER CONTA 🗑️
# --------------------------
remover_conta() {
    cabecalho
    echo -e "$VERMELHO🗑️  REMOVER CONTA - DANSSUXP$RESET"
    echo "------------------------"
    read -p "Digite o nome do usuário para remover: " usuario

    if id "$usuario" &>/dev/null; then
        userdel -r "$usuario" 2>/dev/null || userdel "$usuario"
        sed -i "/$usuario/d" $ARQUIVO_CONTAS
        sed -i "/$usuario/d" /etc/security/limits.conf
        echo -e "$VERDE✅ Conta '$usuario' removida completamente!$RESET"
        echo "[$(date)] CONTA REMOVIDA: $usuario" >> $ARQUIVO_LOG
    else
        echo -e "$VERMELHO❌ Usuário '$usuario' não existe!$RESET"
    fi
    sleep 2
}

# --------------------------
# FUNÇÃO: BLOQUEAR/DESBLOQUEAR 🔒
# --------------------------
bloquear_conta() {
    cabecalho
    echo -e "$CIANO🔒 BLOQUEAR / DESBLOQUEAR - DANSSUXP$RESET"
    echo "-----------------------------------"
    read -p "Usuário: " usuario
    
    if ! id "$usuario" &>/dev/null; then
        echo -e "$VERMELHO❌ Usuário não existe!$RESET"
        sleep 2        return
    fi
    
    echo "1 - Bloquear"
    echo "2 - Desbloquear"
    read -p "Escolha: " opc

    if [ "$opc" = "1" ]; then
        passwd -l "$usuario"
        echo -e "$VERMELHO🔒 Conta '$usuario' BLOQUEADA!$RESET"
    elif [ "$opc" = "2" ]; then
        passwd -u "$usuario"
        echo -e "$VERDE🔓 Conta '$usuario' DESBLOQUEADA!$RESET"
    else
        echo -e "$VERMELHO❌ Opção inválida!$RESET"
    fi
    sleep 2
}

# --------------------------
# FUNÇÃO: ALTERAR SENHA 🔑
# --------------------------
alterar_senha() {
    cabecalho
    echo -e "$CIANO🔑 ALTERAR SENHA - DANSSUXP$RESET"
    echo "------------------------"
    read -p "Usuário: " usuario
    
    if ! id "$usuario" &>/dev/null; then
        echo -e "$VERMELHO❌ Usuário não existe!$RESET"
        sleep 2
        return
    fi
    
    read -s -p "Nova senha: " senha_nova
    echo ""
    if [ -z "$senha_nova" ]; then
        echo -e "$VERMELHO❌ Senha não pode ser vazia!$RESET"
        sleep 2
        return
    fi
    
    echo "$usuario:$senha_nova" | chpasswd
    echo -e "$VERDE✅ Senha alterada com sucesso para '$usuario'!$RESET"
    echo "[$(date)] SENHA ALTERADA: $usuario" >> $ARQUIVO_LOG
    sleep 2
}

# --------------------------
# FUNÇÃO: LISTAR CONTAS 📋# --------------------------
listar_contas() {
    cabecalho
    echo -e "$CIANO📋 LISTA DE CONTAS - DANSSUXP$RESET"
    echo "--------------------------"
    if [ -s "$ARQUIVO_CONTAS" ]; then
        echo -e "$AMARELO$(cat $ARQUIVO_CONTAS)$RESET"
    else
        echo -e "$AMARELONenhuma conta cadastrada ainda.$RESET"
    fi
    echo ""
    read -p "Pressione ENTER para voltar..."
}

# --------------------------
# FUNÇÃO: VERIFICAR CONTA 🔍
# --------------------------
ver_conta() {
    cabecalho
    echo -e "$CIANO🔍 CONSULTAR CONTA - DANSSUXP$RESET"
    echo "------------------------"
    read -p "Digite o usuário: " usuario
    
    if ! id "$usuario" &>/dev/null; then
        echo -e "$VERMELHO❌ Usuário não existe!$RESET"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "$CIANO📌 Dados do usuário $usuario:$RESET"
    chage -l "$usuario"
    echo ""
    echo -e "$CIANO🔗 Conexões ativas:$RESET"
    who | grep "$usuario" || echo "Nenhuma conexão ativa"
    echo ""
    read -p "Pressione ENTER..."
}

# --------------------------
# FUNÇÃO: STATUS DO SERVIDOR 📈
# --------------------------
status_servidor() {
    cabecalho
    echo -e "$CIANO📈 STATUS DO SERVIDOR - DANSSUXP$RESET"
    echo "------------------------------"
    
    # CPU
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "🖥️  CPU: $VERMELHO${cpu}%$RESET usado"    
    # Memória
    mem_info=$(free -m | awk 'NR==2{printf "Usado: %sMB / Total: %sMB (%.2f%%)", $3,$2,$3*100/$2}')
    echo -e "🧠 Memória: $AMARELO$mem_info$RESET"
    
    # Disco
    disco=$(df -h / | awk 'NR==2{print "Usado: "$3" / Total: "$2" ("$5")"}')
    echo -e "💾 Disco: $AZUL$disco$RESET"
    
    echo ""
    echo -e "🔌 Portas configuradas:"
    echo -e "   SSH: $VERDE$PORTA_SSH$RESET | SSL: $VERDE$PORTA_SSL$RESET | Dropbear: $VERDE$PORTA_DROPBEAR$RESET | Squid: $VERDE$PORTA_SQUID$RESET"
    
    echo ""
    echo -e "👥 Total de contas: $VERDE$(wc -l < $ARQUIVO_CONTAS)$RESET"
    
    echo ""
    read -p "Pressione ENTER para voltar..."
}

# --------------------------
# FUNÇÃO: INSTALAR SERVIÇOS ⚙️
# --------------------------
instalar_servicos() {
    cabecalho
    echo -e "$CIANO⚙️  INSTALAÇÃO DE SERVIÇOS - DANSSUXP$RESET"
    echo "-----------------------------------"
    echo "1 - Instalar OpenSSH"
    echo "2 - Instalar Dropbear"
    echo "3 - Instalar Squid Proxy"
    echo "4 - Instalar Todos"
    echo "0 - Voltar"
    read -p "Escolha: " opc
    
    case $opc in
        1)
            echo -e "$AMARELO Instalando OpenSSH...$RESET"
            apt-get update && apt-get install -y openssh-server
            sed -i "s/#Port 22/Port $PORTA_SSH/" /etc/ssh/sshd_config
            systemctl restart ssh
            echo -e "$VERDE✅ OpenSSH instalado e configurado na porta $PORTA_SSH$RESET"
            ;;
        2)
            echo -e "$AMARELO Instalando Dropbear...$RESET"
            apt-get install -y dropbear
            sed -i "s/NO_OPTIONS=\"\"/NO_OPTIONS=\"-p $PORTA_DROPBEAR\"/" /etc/default/dropbear
            systemctl restart dropbear
            echo -e "$VERDE✅ Dropbear instalado na porta $PORTA_DROPBEAR$RESET"
            ;;
        3)            echo -e "$AMARELO Instalando Squid...$RESET"
            apt-get install -y squid
            cat > /etc/squid/squid.conf <<EOF
http_port $PORTA_SQUID
visible_hostname danssuxp-proxy
cache_mgr admin@danssuxp.com
http_access allow all
EOF
            systemctl restart squid
            echo -e "$VERDE✅ Squid instalado na porta $PORTA_SQUID$RESET"
            ;;
        4)
            $0 1; $0 2; $0 3
            echo -e "$VERDE✅ Todos os serviços instalados!$RESET"
            ;;
        0) return ;;
        *) echo -e "$VERMELHO❌ Opção inválida!$RESET" ;;
    esac
    sleep 2
}

# --------------------------
# FUNÇÃO: SOBRE ℹ️
# --------------------------
sobre() {
    cabecalho
    echo -e "$CIANOℹ️  SOBRE O SISTEMA$RESET"
    echo "-----------------"
    echo "Script exclusivo desenvolvido por DANSSUXP"
    echo "Todos os direitos reservados © $(date +%Y)"
    echo "Ferramenta profissional para gerenciamento de acessos SSH"
    echo "Versão atual: $VERSAO"
    echo ""
    read -p "Pressione ENTER para voltar..."
}

# --------------------------
# MENU PRINCIPAL COMPLETO
# --------------------------
menu() {
    while true; do
        cabecalho
        echo -e "$CIANO📌 MENU PRINCIPAL - ${NOME_SCRIPT}$RESET"
        echo "----------------------------------------"
        echo "1  - Criar nova conta SSH"
        echo "2  - Listar todas as contas"
        echo "3  - Consultar dados de uma conta"
        echo "4  - Alterar senha de conta"
        echo "5  - Bloquear / Desbloquear conta"
        echo "6  - Remover conta"        echo "7  - Status do Servidor"
        echo "8  - Instalar Serviços (SSH/Dropbear/Squid)"
        echo "9  - Sobre o Danssuxp SSH"
        echo "0  - Sair"
        echo "----------------------------------------"
        read -p "Escolha uma opção: " opcao

        case $opcao in
            1) criar_conta ;;
            2) listar_contas ;;
            3) ver_conta ;;
            4) alterar_senha ;;
            5) bloquear_conta ;;
            6) remover_conta ;;
            7) status_servidor ;;
            8) instalar_servicos ;;
            9) sobre ;;
            0) clear ; echo -e "$VERDE Obrigado por usar o sistema DANSSUXP! ✨$RESET" ; exit 0 ;;
            *) echo -e "$VERMELHO❌ Opção inválida! Tente novamente.$RESET" ; sleep 1 ;;
        esac
    done
}

# ⚡ INICIO DO SISTEMA ⚡
verificar_senha  # Primeiro pede senha
menu             # Depois abre o menu
