#!/bin/sh
#Por Pablo A. Almeida
#pablot.i@hotmail.com

# Verifica se o script está sendo executado pelo root. 
if [ "`id -u`" != "0" ]; then
echo 'Este script precisa ser executado como root. Digite "su -" para se logar
como root e execute o script novamente. 
Se você está usando o Ubuntu, defina a senha de root usando o comando 
"sudo passwd" e em seguida logue-se usando o "su -". Fechando...'
read pausa
exit
fi
#Configuração manual
static(){
 egw(){
  ifconfig $int $ip netmask $mask
  route del default
  route add default gw $gw dev $int
  #Pergunta se utilizará DNS
  echo 'Digite 0(para configurar o DNS) ou tecle ENTER(caso contrário)'
  read dns
  #Configura o DNS 
  if [ "$dns" = "0" ]; then
   echo 'Digite o DNS:'
   read dns1
   echo 'Digite o DNS secundário, caso não tenha tecle ENTER:'
   read dns2
   echo "nameserver $dns1" > /etc/resolv.conf
   [ -z "$dns2" ] && echo 'no DNS2' || echo "nameserver $dns2" >> /etc/resolv.conf
  fi
  #Fim!
  echo 'Done!'
  exit
 }
 #Recolhe a configuração
 echo 'Digite o IP(ex: 192.168.0.3):'
 read ip
 echo 'Digite a sub-mask(ex: 255.255.255.0):'
 read mask
 echo 'Digite o getway(ex: 192.168.0.1), caso não tenha tecle ENTER:'
 read gw
  #Configura sem ou com getway
 [ -z "$gw" ] && ifconfig $int $ip netmask $mask || egw
 echo 'Done!'
 exit
}
############Inicio############
#Pergunta qual interface utilizará
echo 'Digite a interface:'
read int
#Pergunta se que configurar o IP via DHCP(caso tenha na rede) ou manualmente 
echo 'Digite 0(para configurar via DHCP) ou 1(para configurar manualmente):'
read resp
[ "$resp" = "0" ] && dhclient $int || static
echo 'Done!'
exit
