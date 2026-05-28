# 🔥 DANSSUXP SSH MANAGER PRO

Sistema profissional de gerenciamento de contas SSH com expiração automática, controle de conexões e instalação simplificada.

## ✨ Funcionalidades

- 🔐 Tela de acesso com senha administrativa
- 👤 Criar/Remover/Consultar/Bloquear contas
- 📅 Expiração automática via `usermod -e`
- 🔒 Limite de conexões simultâneas
- 📈 Monitoramento de CPU, RAM e Disco
- ⚙️ Instalação automática de OpenSSH, Dropbear e Squid
- 📝 Logs completos de todas as ações

## 🚀 Instalação Rápida

```bash
# Clonar repositório
git clone https://github.com/RicardoSouzaCruz/danssuxp-ssh-manager.git
cd danssuxp-ssh-manager

# Dar permissão e executar
chmod +x danssuxp-ssh.sh
bash danssuxp-ssh.sh
```

## 🛡️ Segurança

- Usuários criados sem shell (`/usr/sbin/nologin`)
- Sem pasta home (`-M`)
- Senhas ocultas na digitação
- Validação de campos e inputs
- Logs centralizados em `/var/log/danssuxp.log`

## 📋 Requisitos

- Sistema: Ubuntu 20.04/22.04 ou Debian 10+
- Acesso root ou sudo
- Conexão com internet

## 🔧 Comandos Úteis

```bash
# Atualizar script
git pull origin main

# Ver status
git status

# Ver logs
cat /var/log/danssuxp.log

# Ver contas
cat /etc/danssuxp/contas.db
```

## 👨‍ Desenvolvido por

**DANSSUXP (Ricardo Souza Cruz)**  
Todos os direitos reservados © 2026

## 📄 Licença

MIT License - Sinta-se à vontade para usar e modificar.

---

**Versão:** 3.0-SECURE  
**Última atualização:** Maio/2026
