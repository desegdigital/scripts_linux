#!/bin/bash
#
#-------------------------------------------------------------------------------------------------#
#install_config_samba.sh - Instalação e configuração do serviço de compartilhamento Samba.
#
#Autor   :Pablo Almeida
#E-mail  :pablot.i@hotmail.com 
#
###################################################################################################
#																								  #
# 	O presente script foi desenvolvido de forma experimental, para uso livre.					  #
# Este script é uma ferramenta para estudos complementares aos asusntos aboradados 				  #
# no segundo módulo do curso Técnico em Informática da Faculdade de Tecnologia SENAC PF.	      #
#																								  #
# 	Bem, vamos ao motivo da criação do presente script. Este foi desenvolvido para automatizar 	  #
# uma prática, na cadeira de Planejamento e Implantação de Servidores, referente ao Serviço 	  #
# SAMBA, que nada mais é do que um servidor de compartilhamento.								  #
#																								  #
# 	Com este scipt se é capaz de fazer a instalação e configuração completa do SAMBA. Sendo assim #
# uma ferramenta muíto útil, para agilizar a configuração do mesmo.                               #
#																								  #
###################################################################################################
#
#
#Versão: v1.0
#
#Licença: GPL
#
#-------------------------------------------------------------------------------------------------#
#
#TODO Fazer uma breve explicação da execução do script, ou gerar uma documentação do mesmo
#TODO Fazer agradecimentos.




###Inicialização das Variáveis
#-------------------------------------------------------------------------------------------------#
###
#Variável para identificação do usuário
USUARIO=$(whoami)
###
#Variável que retorna um valor, para a checagem de instalação.
samba=$(rpm -qa | grep samba | cut -d '-' -f1 | sed '2!d')         
vsamba=$(smbd -V | cut -d '-' -f1 | sed 's/Version//')
#adicionar_grupo="s"
#adicionar_usuario="s"
#adicionar_usuario_ao_grupo="s"
#adicionar_compartilhamento="s"
checa_grupo=$(grep ^$nome /etc/group | cut -d ':' -f1)
checa_usuario=$(grep ^$nome /etc/passwd | cut -d ':' -f1)
#-------------------------------------------------------------------------------------------------#




###Verificação de Usuário
#-------------------------------------------------------------------------------------------------#
if [ "${USUARIO}" != root ]; then
	echo "#-------------------------------------------------------------#"
	echo "#     ESTE SCRIPT PRECISA SER EXECUTADO COM USUARIO ROOT      #"
	echo "#-------------------------------------------------------------#"
	exit
fi
#-------------------------------------------------------------------------------------------------#


#=================================================================================================#
#                                            FUNÇÕES                                              #
#=================================================================================================#

###Função para a cehcagem da instalação do samba
#-------------------------------------------------------------------------------------------------#
function f_checa_instalacao(){
if [ "$samba" = "samba" ];
then
	echo "------------------------------------------------------------"
	echo "INSTALACAO CONCLUIDA COM SUCESSO!"
	sleep 1
	echo "------------------------------------------------------------"
	echo -e "VOCE INSTALOU A VERSAO $vsamba \nDO SAMBA"
	sleep 1
	echo "------------------------------------------------------------"
	echo "CONTINUANDO..."
	mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp #Fazendo backup do arquivo original de
	touch /etc/samba/smb.conf					   #configuração do samba.
	sleep 2
	echo "------------------------------------------------------------"
	echo "INICIANDO A CONFIGURACAO DO SAMBA..."
	sleep 2
else
	echo "------------------------------------------------------------"
	echo "OCORREU ALGUM ERRO DURANTE A INSTALACAO!"
	sleep 1
	echo "------------------------------------------------------------"
	echo "TENTANDO FAZER A INSTALACAO NOVAMENTE"
	sleep 1
	echo "------------------------------------------------------------"
	echo "ATUALIZANDO O SISTEMA, AGUARDE..."
	sleep 2
	
	yum update -y
	
	echo "------------------------------------------------------------"
	echo "INSTALANDO O SAMBA..."
	sleep 1
	
	yum install -y samba samba-client samba-doc
	
	f_checa_instalacao
fi
}
#-------------------------------------------------------------------------------------------------#


###Função que checa a  criação de grupo
#-------------------------------------------------------------------------------------------------#
function f_checa_criacao_grupo(){
checa_grupo=$(grep ^$nome /etc/group | cut -d ':' -f1)
if [ "$checa_grupo" = "$nome" ];
then
	echo "------------------------------------------------------------"
	echo "GRUPO ADICIONADO COM SUCESSO!"
	sleep 2
	echo "------------------------------------------------------------"
	echo -n "VOCE DESEJA ADICIONAR OUTRO GRUPO? [s/n]: "
	read adicionar
	case $adicionar in
		n)
			echo "------------------------------------------------------------"
			echo "CONTINUANDO. . ."
			sleep 2;;
		s)
			f_criar_grupo;;
	esac
else
	echo "------------------------------------------------------------"
	echo -e "O GRUPO NAO FOI ADICIONADO CORRETAMENTE \nTENTE NOVAMENTE..."
	sleep 2
	f_criar_grupo
fi
}
#-------------------------------------------------------------------------------------------------#


###Função de criação de grupo
#-------------------------------------------------------------------------------------------------#
function f_criar_grupo(){
echo "------------------------------------------------------------"
echo -n "DIGITE O NOME DO GRUPO: "
read nome

###Variável para a checagem de caracteres especiais
checa_caracteres=$(echo "$nome" | tr -d ".,;/|[]{}()=-")

if [ -z $nome ];
then
	echo "------------------------------------------------------------"
	echo "CAMPO VAZIO, POR FAVOR TENTE NOVAMENTE"
	sleep 2
	f_criar_grupo
elif [ "$checa_caracteres" != "$nome" ];
then
	echo "------------------------------------------------------------"
	echo "VALOR INVALIDO!"
	sleep 2
	f_criar_grupo
elif [ "$nome" = "$checa_grupo" ];
then
	echo "------------------------------------------------------------"
	echo "O GRUPO $nome JA EXISTE!"
	sleep 2
	f_criar_grupo
else
	groupadd $nome
	f_checa_criacao_grupo
fi
}
#-------------------------------------------------------------------------------------------------#

																	  
###Função que checa a criação de usuário
#-------------------------------------------------------------------------------------------------#
function f_checa_criacao_usuario(){
checa_usuario=$(grep ^$nome /etc/passwd | cut -d ':' -f1)
if [ "$checa_usuario" = "$nome" ];
then
	echo "------------------------------------------------------------"
	echo "USUARIO ADICIONADO COM SUCESSO!"
	sleep 2
	echo "------------------------------------------------------------"
	echo "DEFINA UMA SENHA PARA O USUARIO $nome:"
	smbpasswd -a $nome
	echo "------------------------------------------------------------"
	echo -n "VOCE DESEJA ADICIONAR OUTRO USUARIO? [s/n]: "
	read adicionar
	case $adicionar in
		n)
			echo "------------------------------------------------------------"
			echo "CONTINUANDO. . ."
			sleep 2;;
		s)
			f_criar_usuario;;
	esac
else
	echo "------------------------------------------------------------"
	echo "O USUARIO NAO FOI ADICIONADO CORRETAMENTE \nTENTE NOVAMENTE..."
	sleep 2
	f_criar_usuario
fi
}
#-------------------------------------------------------------------------------------------------#																  


###Função de criação de usuário
#-------------------------------------------------------------------------------------------------#
function f_criar_usuario(){
echo "------------------------------------------------------------"
echo -n "DIGITE O NOME DO USUARIO: "
read nome

checa_caracteres=$(echo "$nome" | tr -d ".,;/|[]{}()=-")
checa_usuario=$(grep ^$nome /etc/passwd | cut -d ':' -f1)

if [ -z $nome ];
then
	echo "------------------------------------------------------------"
	echo "CAMPO VAZIO, POR FAVOR TENTE NOVAMENTE"
	sleep 2
	f_criar_usuario
elif [ "$checa_caracteres" != "$nome" ];
then
	echo "------------------------------------------------------------"
	echo "VALOR INVALIDO!"
	sleep 2
	f_criar_usuario
elif [ "$nome" = "$checa_usuario" ];
then
	echo "------------------------------------------------------------"
	echo "O GRUPO $nome JA EXISTE!"
	sleep 2
	f_criar_usuario
else
	adduser $nome
	f_checa_criacao_usuario
fi
}

function f_incluir_usuario(){
echo -e -n "DIGITE O NOME DOS USUARIOS A SEREM ADICIONADOS: \n EX:( usuario1,usuario2,usuario3): "
read usuarios
checa_usuario=$(grep ^$usuarios /etc/passwd | cut -d ':' -f1)
if [ -z $usuarios ];
then
	echo "------------------------------------------------------------"
	echo "CAMPO VAZIO, POR FAVOR TENTE NOVAMENTE"
	f_incluir_usuario
else
	gpasswd -M $usuarios $grupo
fi
}

function f_incluir_usuario_grupo(){
echo "------------------------------------------------------------"
echo -e -n "DIGITE O NOME DO GRUPO AO QUAL DESEJA \nADICIONAR USUARIOS: "
read grupo

checa_grupo=$(grep ^$grupo /etc/group | cut -d ':' -f1)

if [ -z $grupo ];
then
	echo "------------------------------------------------------------"
	echo "CAMPO VAZIO, POR FAVOR TENTE NOVAMENTE"
	sleep 2
	f_incluir_usuario_grupo
elif [ "$grupo" != "$checa_grupo" ];
then
	echo "------------------------------------------------------------"
	echo "O GRUPO INFORMADO NAO EXISTE, TENTE NOVAMENTE"
	sleep 2
	f_incluir_usuario_grupo
else
	f_incluir_usuario
	echo "------------------------------------------------------------"
	echo "VERICANDO A INCLUSAO DOS USUARIOS..."
	sleep 1
	echo "------------------------------------------------------------"
	cat /etc/group | grep ^$grupo
	echo "------------------------------------------------------------"
	echo -n "OS USUARIOS FORAM ADICIONADOS CORRETAMENTE? [s/n]: "
	read verificacao
	case $verificacao in
		s)
			sleep 1
			echo "------------------------------------------------------------"
			echo "CONTINUANDO..."
			sleep 2;;
		n)
			sleep 1
			echo "------------------------------------------------------------"
			echo "INICIANDO INCLUSAO NOVAMENTE..."
			sleep 1
			f_incluir_usuario_grupo;;
	esac
fi
}

function f_editar_global(){
echo "------------------------------------------------------------"
echo "INICIANDO CONFIGURACAO DOS PARAMETROS GLOBAIS DO SMB.CONF..."
sleep 2

echo "------------------------------------------------------------"
echo -n "DEFINA O workgroup: "
read workgroup
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O netbios name: "
read netbios_name
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O server string: "
read server_string
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O security [share/user]: "
read security
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O os level: "
read os_level
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O max log size: "
read log_size
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O encrypt passwords: "
read encrypt_passwords
sleep 1

echo "------------------------------------------------------------"
echo -n "DEFINA O hosts allow: "
read hosts_allow
sleep 1

echo "------------------------------------------------------------"
echo "ESCREVENDO NO SMB.CONF..."
echo -e > /etc/samba/smb.conf "
#------------------------------------------------------------#
#                          SMB.CONF                          #
#------------------------------------------------------------#
#
#Arquivo de configuração do samba gerado automaticamente pelo
#script install_config_samba.sh.
#Este arquivo, assim como as demais configurações feitas pelo
#script devem ser revisadas para o correto funcionamento do
#servidor samba.

#========== global settings ==========#
[global]
workgroup = $workgroup
netbios name = $netbios_name
server string = $server_string
os level = $os_level
log file = /var/log/samba/log-samba.%m
log level = 1
max log size = $log_size
security = $security
hosts allow = $hosts_allow
encrypt passwords = $encrypt_passwords
smb passwd file = /etc/samba/smbpasswd

#Carregamento das Impressoras
printcap name = /etc/printcap
load printers = yes
printing = cups

#Parâmetros de configuração da impressora
vfs objects = recycle 
recycle:keeptree = yes
recycle:versions = yes
recycle:repository = lixeira_pst
recycle:exclude = *.tmp, *.log, *.obj, ~*.*, *.bak, *.iso
recycle:exclude_dir = tmp, cache
"
sleep 2
echo "------------------------------------------------------------"
echo "CONTINUANDO..."
sleep 2
}

function f_add_compartilhamento(){
echo "------------------------------------------------------------"
echo -n "DIGITE O NOME PARA O COMPARTILHAMENTO: "
read nome
echo "------------------------------------------------------------"
echo "CRIANDO DIRETORIO DO COMPARTILHAMENTO..."
mkdir /usr/local/$nome
chmod 777 /usr/local/$nome
sleep 1
echo "------------------------------------------------------------"
echo -e -n "DEFINA QUEM TERA ACESSO AO COMPARTILHAMENTO $nome \n(Ex.: @grupo usuario): "
read valid_users
echo "------------------------------------------------------------"
echo "ESCREVENDO NO SMB.CONF..."
echo -e >> /etc/samba/smb.conf "
#========== compartilhamento $nome ==========#
[$nome]
comment = $nome
path = /usr/local/$nome
public = no
only guest = no
writable = yes
force create mode = 777
force directory mode = 777
valid users = $valid_users
"
sleep 1
echo "------------------------------------------------------------"
echo -n "DESEJA ADICONAR OUTRO COMPARTILHAMENTO? [s/n]: "
read adicionar
case $adicionar in
	n)
		echo "------------------------------------------------------------"
		echo "CONTINUANDO. . ."
		sleep 2;;
	s)
		f_add_compartilhamento;;
esac
}

function f_add_impressora(){
echo "------------------------------------------------------------"
echo -n "IDENTIFIQUE A IPRESSORA CONFORME O ARQUIVO printcap: "
read nome
echo -e >> /etc/samba/smb.conf "
#Impressora $nome
[$nome]
comment = Impressora
path = /var/spool/samba
browseable = yes
printable = yes
printer = $nome
guest ok = yes
read only = yes
use client driver = yes
print command = lpr -r -h -P %p %s
"
sleep 1
echo "------------------------------------------------------------"
echo "IMPRESSORA ADICIONADA!"
echo "------------------------------------------------------------"
echo "CONTINUANDO..."
sleep 2
}

function f_add_lixeira(){
echo "------------------------------------------------------------"
echo -n "DEFINA O DIRETORIO PARA A LIXEIRA: "
read diretorio
mkdir $diretorio
chmod 777 $diretorio
sed -i -e "s:lixeira_pst:$diretorio:g" /etc/samba/smb.conf
sleep 1
echo "------------------------------------------------------------"
echo "LIXEIRA ADICIONA!"
sleep 1
echo "------------------------------------------------------------"
echo -n "DESEJA ADICIOAR UM COMPARTILHAMENTO PARA A LIXEIRA? [s/n]: "
read adicionar
case $adicionar in
	n)
		echo "------------------------------------------------------------"
		echo "CONTINUANDO. . ."
		sleep 2;;
	s)
		echo "------------------------------------------------------------"
		echo -n "DEFINA O NOME PARA O COMPARTILHAMENTO: "
		read nome
		echo -e -n "DEFINA QUEM TERA ACESSO AO COMPARTILHAMENTO $nome \n(Ex.: @grupo usuario): "
		read valid_users
		echo "------------------------------------------------------------"
		echo "ESCREVENDO NO SMB.CONF..."
		echo -e >> /etc/samba/smb.conf "
#========== compartilhamento $nome ==========#
[$nome]
comment = $nome
path = $diretorio
public = no
only guest = no
writable = yes
force create mode = 777
force directory mode = 777
valid users = $valid_users
"
		sleep 1
		echo "------------------------------------------------------------"
		echo "LIXEIRA ADICIONA!"
		echo "------------------------------------------------------------"
		echo "CONTINUANDO...";;
esac
sleep 2
}
#-------------------------------------------------------------------------------------------------#
#=================================================================================================#


###Seção de checagem de instalação, isto é, se for detectada uma instalação do samba, será
###perguntado se o administrador deseja fazer a atualização. Do contrário será instalado
###normalmente o samba.
if [ $samba = "samba" ];
then
	echo "------------------------------------------------------------"
	echo "VOCE POSSUI A VERSAO $vsamba DO SAMBA"
	echo "------------------------------------------------------------"
	echo -n "DESEJA ATUALIZAR? [s/n]: "
	read atualizar
	
	case $atualizar in
		n)
			echo "------------------------------------------------------------"
			echo "VOCE OPTOU POR NAO ATUALIZAR O SAMBA"
			sleep 1
			echo "------------------------------------------------------------"
			echo "PARTINDO PARA A PROXIMA ETAPA..."
			echo "------------------------------------------------------------"
			echo "INICIANDO A CONFIGURACAO DO SAMBA..."
			sleep 2;;
		
		s)
			echo "------------------------------------------------------------"
			echo "INICIANDO ATUALIZACAO DO SAMBA..."
			sleep 2
	
			yum isntall -y samba samba-client samba-doc
			f_checa_instalacao
			
			sleep 2;;
		*)
			echo "------------------------------------------------------------"
			echo "VALOR INVALIDO!"
			sleep 1;;	
	esac
else
	echo "------------------------------------------------------------"
	echo "INICIANDO INSTALACAO DO SAMBA..."
	sleep 2
	
	yum install -y samba samba-client samba-doc
	
	sleep 2
	echo "------------------------------------------------------------"
	echo "CHECANDO A INSTALACAO..."
	sleep 1
	f_checa_instalacao
fi
#=================================================================================================#


###MENU PRINCIPAL
menu (){
while true $opcao != 0
do
	echo "------------------------------------------------------------"
	echo ""
	echo "ESCOLHA UMA OPCAO:"
	echo "#------------------------------------------------------------#"
	echo "#####     1) ADICIONAR GRUPOS;"
	echo " #####    2) ADICIONAR USUARIOS;"
	echo "#######   3) INCLUIR USUARIOS EM GRUPO;"
	echo " #######  4) CONFIGURAR GLOBAL;"
	echo " #######  5) ADICIONAR COMPARTILHAMENTO;"
	echo "#######   6) ADICIONAR IMPRESSORA;"
	echo " #####    7) ADICIONAR LIXEIRA;"
	echo "#####     0) SAIR"
	echo "#------------------------------------------------------------#"
	echo -n "SELECIONE SUA OPCAO: "
	read opcao
	case $opcao in
		0)
			echo "------------------------------------------------------------"
			echo "REINICIANDO SAMBA."
			echo "------------------------------------------------------------"
			/etc/init.d/smb stop
			/etc/init.d/smb start
			echo "SAINDO DO SCRIPT..."
			sleep 2
			echo "------------------------------------------------------------"
			echo "AH!! NAO ESQUEÇA DE CONFERIR O ARQUIVO SMB.CONF..."; sleep 3;
			echo "------------------------------------------------------------"
			echo "OBRIGADO E ATÉ A PROXIMA!! ;)"
			echo "  ::::::::::: :::    :::     :::     ::::    ::: :::    ::: :::::::: "
			sleep 0.5
			echo "     :+:     :+:    :+:   :+: :+:   :+:+:   :+: :+:   :+: :+:    :+: "
			sleep 0.5
			echo "    +:+     +:+    +:+  +:+   +:+  :+:+:+  +:+ +:+  +:+  +:+         "
			sleep 0.5
			echo "   +#+     +#++:++#++ +#++:++#++: +#+ +:+ +#+ +#++:++   +#++:++#++   "
			sleep 0.5
			echo "  +#+     +#+    +#+ +#+     +#+ +#+  +#+#+# +#+  +#+         +#+    "
			sleep 0.5
			echo " #+#     #+#    #+# #+#     #+# #+#   #+#+# #+#   #+# #+#    #+#     "
			sleep 0.5
			echo "###     ###    ### ###     ### ###    #### ###    ### ########       "
			sleep 2
			break; exit;;
		1)f_criar_grupo;;
		2)f_criar_usuario;;
		3)f_incluir_usuario_grupo;;
		4)f_editar_global;;
		5)f_add_compartilhamento;;
		6)f_add_impressora;;
		7)f_add_lixeira;;
		*)
			echo "------------------------------------------------------------"
			echo "VALOR INVALIDO!"
			sleep 2;;
	esac
done
}
menu



