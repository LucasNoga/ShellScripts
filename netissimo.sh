# LE script pour l'ADSL ! A essayer de toute urgence si vous êtes abonné...
#Son seul défaut : il ne fait pas le café :-) Nouveau !


#Voilà... LE script des possesseurs de connection ADSL. A utiliser conjointement avec chkconnect.sh...

#Vous avez l'ADSL ? Vous voulez pouvoir lancer la connection, la couper, ou la relancer en une seule commande ? Ce script est fait pour vous ! L'utilisation est vraiment simple :

#netissimo.sh start

#...pour lancer la connection,

#netissimo.sh stop

#...pour stopper la connection, et

#netissimo.sh restart

#...pour relancer la connection.

#Genial n'est-ce-pas ? Mais attendez ! Ce n'est pas tout !

#Si en plus vous avez un compte chez dhs.org (fournisseur de DNS dynamique), il va automatiquement mettre à jour votre IP sur leur serveur...

#Bien sûr, pour cela, il faut modifier les ligne 10 à 13 de manière à remplacer les valeurs des variables par vos login, password et hostname chez dhs.org.

#Quelques condition néanmoins. Tout d'abord, il faudra le lancer en root, car seul root peut écrire dans /var/log, et en général seul root peut lancer une connection ppp (sauf si vous avez bidouillé un peu). Autre condition, pour que l'update de dhs.org s'effectue, il faut que vous ayez installé Lynx (un package est sûrement inclus dans votre distribution). C'est un browser en mode texte. Aussi, toujours pour l'update de dhs.org, il faut que le type d'hôte spécifié lors de la création de votre compte soit un hôte dynamique (adresse du type machine.dyn.dhs.org).

#ATTENTION : si vous n'utilisez pas dhs.org, il faut commenter les lignes concernant cette fonction (lignes 10 à 13).




#/////////////////////////////////////////////////////////////////////////////////////////

#! /bin/sh

# netissimo.sh - v1.0
# Brings up or shuts down an ADSL "Netissimo" link (France Telecom)
# By Raphaël HALIMI <raphaelh@easynet.fr>

# First thing - Some parameters for dhs.org (Domain Host Services). If your
# machine isn't registered at this service, just comment out those lines.
# IMPORTANT : only dynamic hostnames (.dyn.dhs.org adress type) will work !
DHS=1
DHS_LOGIN=your_login
DHS_PASS=your_password
DHS_HOSTNAME=your_dhs_hostname

case $1 in
     start)
           echo -n "Bringing up Netissimo link : "
	   pptp 10.0.0.138
	   until [ "`/sbin/ifconfig | grep ppp`" ] ; do
		 sleep 1
	   done
	   echo "done."
	   IFACE=`/sbin/ifconfig | grep ppp | cut -d " " -f 1`
           NEWIP=`/sbin/ifconfig $IFACE | grep inet | cut -d ":" -f 2 | cut -d " " -f 1`
           echo "Interface $IFACE configured with IP adress $NEWIP."
           if [ $DHS = 1 ] ; then
              echo -n "Updating dhs.org entry : "
              lynx -dump -auth=$DHS_LOGIN:$DHS_PASS "http://members.dhs.org/nic/hosts?domain=dyn.dhs.org&hostname=$DHS_HOSTNAME&hostscmd=edit&hostscmdstage=2&type=4&updatetype=online&ip=$NEWIP" > /dev/null
              echo "done."
           fi
           echo "Now you know..." | mail -s "External IP of $HOSTNAME has changed to $NEWIP" root
           echo "A mail with the new IP address has been sent to root."
	   ;;
     stop)
           echo -n "Shutting down Netissimo link : "
	   killall pppd > /dev/null 2>&1
	   killall pptp > /dev/null 2>&1
	   rm -rf /var/run/pptp > /dev/null 2>&1
	   echo "done."
	   ;;
     restart)
           echo -n "Restarting Netissimo link : "
	   killall pppd > /dev/null 2>&1
	   killall pptp > /dev/null 2>&1
	   rm -rf /var/run/pptp > /dev/null 2>&1
	   pptp 10.0.0.138
	   until [ "`/sbin/ifconfig | grep ppp`" ] ; do
		 sleep 1
	   done
	   echo "done."
	   IFACE=`/sbin/ifconfig | grep ppp | cut -d " " -f 1`
           NEWIP=`/sbin/ifconfig $IFACE | grep inet | cut -d ":" -f 2 | cut -d " " -f 1`

           echo "Interface $IFACE configured with IP adress $NEWIP."
           if [ $DHS = 1 ] ; then
              echo -n "Updating dhs.org entry : "
              lynx -dump -auth=$DHS_LOGIN:$DHS_PASS "http://members.dhs.org/nic/hosts?domain=dyn.dhs.org&hostname=$DHS_HOSTNAME&hostscmd=edit&hostscmdstage=2&type=4&updatetype=online&ip=$NEWIP" > /dev/null
              echo "done."
           fi
           echo "Now you know..." | mail -s "External IP of $HOSTNAME has changed to $NEWIP" root
           echo "A mail with the new IP address has been sent to root."
	   ;;

     *)
           echo "Usage : netissimo.sh {start|stop|restart}"
	   ;;
esac
