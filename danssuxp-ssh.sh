#!/bin/bash
set +H

# CORES
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
B='\033[1;34m'; M='\033[1;35m'; C='\033[1;36m'
W='\033[1;37m'; N='\033[0m'

# CONFIG
DIR="/etc/danssuxp"
DB="$DIR/contas.db"
mkdir -p $DIR; touch $DB

limpar() { clear; }

cabecalho() {
limpar
echo -e "$R╔══════════════════════════════════════════════════════════════════╗$N"
echo -e "$R║           🔥 DANSSUXP SSH MANAGER PRO 🔥                       ║$N"
echo -e "$R╠══════════════════════════════════════════════════════════════════╣$N"
echo -e "$R║$N $W SISTEMA$N          $W MEMORIA RAM$N           $W PROCESSADOR$N              $R║$N"
echo -e "$R║$N $C OS: $W Ubuntu$N     $C Total: $W $(free -h | awk 'NR==2{print $2}')$N   $C Nucleos: $W $(nproc)$N              $R║$N"
echo -e "$R║$N $C Hora: $W $(date +%H:%M:%S)$N         $C Em Uso: $W $(free | awk 'NR==2{printf "%.0f%%", $3*100/$2}')$N    $C Em Uso: $W $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%$N         $R║$N"
echo -e "$R╠══════════════════════════════════════════════════════════════════╣$N"
TOTAL=$(wc -l < $DB 2>/dev/null || echo "0")
echo -e "$R║$N $G Onlines: $W 0$N        $Y Expirados: $W 0$N         $W Total: $W $TOTAL$N              $R║$N"
echo -e "$R╚══════════════════════════════════════════════════════════════════╝$N"
echo ""
}

menu() {
while true; do
cabecalho
echo -e "$C┌──────────────────────────────────────────────────────────────────────┐$N"
echo -e "$C│$N $W                    GERENCIAMENTO DE USUARIOS$N                  $C│$N"
echo -e "$C├──────────────────────────────────────────────────────────────────────┤$N"
echo -e "$C│$N $G [01]$N $W CRIAR USUARIO$N          $G [13]$N $W SPEEDTEST$N                  $C│$N"
echo -e "$C│$N $G [02]$N $W REMOVER USUARIO$N        $G [14]$N $W OTIMIZAR SISTEMA$N           $C│$N"
echo -e "$C│$N $G [03]$N $W RENOVAR USUARIO$N        $G [15]$N $W FIREWALL$N                   $C│$N"
echo -e "$C│$N $G [04]$N $W ALTERAR SENHA$N          $G [16]$N $W INFO SISTEMA$N               $C│$N"
echo -e "$C│$N $G [05]$N $W LISTAR CONTAS$N           $G [17]$N $W INSTALAR SERVICOS$N          $C│$N"
echo -e "$C│$N $G [06]$N $W BLOQUEAR/DESBLOQUEAR$N   $G [18]$N $W BACKUP$N                      $C│$N"
echo -e "$C│$N $G [07]$N $W CONSULTAR CONTA$N        $G [19]$N $W MODOS CONEXAO$N              $C│$N"
echo -e "$C│$N $G [08]$N $W INSTALAR XRAY$N          $G [20]$N $W INSTALAR SLOWDNS$N           $C│$N"
echo -e "$C│$N $G [09]$N $W INSTALAR HYSTERIA$N      $G [00]$N $W SAIR$N                        $C│$N"
echo -e "$C└──────────────────────────────────────────────────────────────────────┘$N"
echo ""
echo -ne "$Y ➜ INFORME UMA OPCAO: $N"
read OP
case $OP in
  1|01) criar ;;
  2|02) remover ;;
  3|03) renovar ;;
  4|04) alterar_senha ;;
  5|05) listar ;;
  6|06) bloquear ;;
  7|07) consultar ;;
  8|08) xray ;;
  9|09) hysteria ;;
  10) speedtest ;;
  11) otimizar ;;
  12) firewall ;;
  13) info ;;
  14) backup ;;
  15) modos ;;
  16) slowdns ;;
  17) servicos ;;
  0|00) limpar; echo -e "$G Saindo... $N"; exit ;;
  *) limpar; echo -e "$R OPCAO INVALIDA!$N"; sleep 1 ;;
esac
done
}

criar() {
limpar
echo -e "$C┌──────────────────────────────────────────────────────────────────────┐$N"
echo -e "$C│$N $W                    CRIAR NOVO USUARIO$N                   $C│$N"
echo -e "$C└──────────────────────────────────────────────────────────────────────┘$N"
echo ""
read -p " Usuario: " U
[ -z "$U" ] && echo -e "$R Vazio!$N" && sleep 2 && return
id "$U" &>/dev/null && echo -e "$R Existe!$N" && sleep 2 && return
read -s -p " Senha: " S; echo ""
read -p " Dias: " D
useradd -M -s /usr/sbin/nologin "$U"
echo "$U:$S" | chpasswd
EXP=$(date -d "+$D days" +%Y-%m-%d)
usermod -e "$EXP" "$U"
echo "[$(date +%d/%m/%Y)] $U | $S | $D dias | Exp: $EXP" >> $DB
echo -e "$G ✅ Criado! Senha: $S | Exp: $EXP$N"
sleep 3
}

remover() {
limpar
read -p " Usuario: " U
if id "$U" &>/dev/null; then
  userdel -r "$U" 2>/dev/null
  sed -i "/$U/d" $DB  echo -e "$G ✅ Removido!$N"
else
  echo -e "$R ❌ Nao encontrado!$N"
fi
sleep 2
}

renovar() {
limpar
read -p " Usuario: " U
id "$U" &>/dev/null || { echo -e "$R Nao encontrado!$N"; sleep 2; return; }
read -p " Dias: " D
ATUAL=$(chage -l "$U" | grep "Account expires" | cut -d: -f2 | xargs)
NOVA=$(date -d "$ATUAL + $D days" +%Y-%m-%d 2>/dev/null)
usermod -e "$NOVA" "$U"
echo -e "$G ✅ Renovado ate $NOVA!$N"
sleep 2
}

alterar_senha() {
limpar
read -p " Usuario: " U
id "$U" &>/dev/null || { echo -e "$R Nao encontrado!$N"; sleep 2; return; }
read -s -p " Nova senha: " NS; echo ""
echo "$U:$NS" | chpasswd
echo -e "$G ✅ Senha alterada!$N"
sleep 2
}

listar() {
limpar
echo -e "$C┌──────────────────────────────────────────────────────────────────────┐$N"
echo -e "$C│$N $W                    CONTAS CADASTRADAS$N                   $C│$N"
echo -e "$C└──────────────────────────────────────────────────────────────────────┘$N"
echo ""
[ -s "$DB" ] && cat $DB || echo "Nenhuma conta"
echo ""
read -p " Pressione ENTER..."
}

bloquear() {
limpar
read -p " Usuario: " U
id "$U" &>/dev/null || { echo -e "$R Nao encontrado!$N"; sleep 2; return; }
echo -e "$G [1] Bloquear$N"
echo -e "$Y [2] Desbloquear$N"
read -p " Opcao: " O
[ "$O" = "1" ] && passwd -l "$U" && echo -e "$R Bloqueado!$N"
[ "$O" = "2" ] && passwd -u "$U" && echo -e "$G Desbloqueado!$N"
sleep 2}

consultar() {
limpar
read -p " Usuario: " U
id "$U" &>/dev/null || { echo -e "$R Nao encontrado!$N"; sleep 2; return; }
chage -l "$U"
read -p " Pressione ENTER..."
}

xray() {
limpar
echo -e "$Y Instalando XRay...$N"
bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install
echo -e "$G ✅ XRay instalado!$N"
sleep 3
}

hysteria() {
limpar
echo -e "$Y Instalando Hysteria2...$N"
curl -fsSL https://get.hy2.sh/ | bash
echo -e "$G ✅ Hysteria2 instalado!$N"
sleep 3
}

slowdns() {
limpar
echo -e "$Y Instalando SlowDNS...$N"
cd /root
wget https://raw.githubusercontent.com/fisabiliya/SlowDNS/main/slowdns.sh
chmod +x slowdns.sh
./slowdns.sh
echo -e "$G ✅ SlowDNS instalado!$N"
sleep 3
}

servicos() {
limpar
echo -e "$G [1] OpenSSH$N | $G [2] Dropbear$N | $G [3] Squid$N | $G [4] Todos$N"
read -p " Opcao: " O
case $O in
  1) apt-get install -y openssh-server; systemctl restart ssh ;;
  2) apt-get install -y dropbear; systemctl restart dropbear ;;
  3) apt-get install -y squid; systemctl restart squid ;;
  4) apt-get update && apt-get install -y openssh-server dropbear squid ;;
esac
echo -e "$G ✅ Instalado!$N"
sleep 2
}
speedtest() {
limpar
echo -e "$Y Testando velocidade...$N"
command -v speedtest &>/dev/null || apt-get install -y speedtest-cli
speedtest --simple
sleep 3
}

otimizar() {
limpar
echo "net.core.default_qdisc=fq_codel" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p &>/dev/null
echo -e "$G ✅ Sistema otimizado!$N"
sleep 2
}

firewall() {
limpar
echo -e "$G [1] Ativar UFW$N | $G [2] Bloquear Torrent$N"
read -p " Opcao: " O
[ "$O" = "1" ] && ufw enable && echo -e "$G Firewall ativado!$N"
[ "$O" = "2" ] && iptables -A FORWARD -p tcp --dport 6881 -j DROP && echo -e "$G Torrent bloqueado!$N"
sleep 2
}

info() {
limpar
echo -e "$C CPU: $G $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%$N"
echo -e "$C Memoria: $Y $(free -h | awk 'NR==2{print $3" / "$2}')$N"
echo -e "$C Disco: $B $(df -h / | awk 'NR==2{print $3" / "$2}')$N"
read -p " Pressione ENTER..."
}

backup() {
limpar
echo -e "$G [1] Criar Backup$N | $G [2] Restaurar$N"
read -p " Opcao: " O
if [ "$O" = "1" ]; then
  tar -czf /root/danssuxp_$(date +%d%m%Y).tar.gz $DB /etc/passwd /etc/shadow 2>/dev/null
  echo -e "$G ✅ Backup em /root/$N"
fi
sleep 2
}

modos() {
limpar
echo -e "$W OPENSSH: $G 22$N | SSL: $G 443$N | WS: $G 80 8080$N"
echo -e "$W SLOW DNS: $G 5300$N | XRAY: $G 1085 443$N"read -p " Pressione ENTER..."
}

menu
