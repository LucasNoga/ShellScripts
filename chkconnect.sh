#Un petit script qui relance une connection (via le script ci-dessus) en cas de déconnection. Pratique. Nouveau !

#Nécéssite netissimo.sh pour fonctionner.

#Que fait-il donc ? Simple. Il vérifie votre connection. S'il n'arrive pas à atteindre l'extérieur, il relance la connection tout seul. Et, cerise sur le gâteau, il logge toutes les connections/deconnections dans un fichier, comme ça vous pourrez gueuler sur France Télécom (l'ADSL est vraiment pourri à Paris...) avec preuve à l'appui :-)

#Deux conditions néanmoins. Tout d'abord, il faudra le lancer en root, car seul root peut écrire dans /var/log, et en général seul root peut lancer une connection ppp (sauf si vous avez bidouillé un peu). Ensuite, il vous faudra modifier la ligne 11 (adresse IP d'un serveur DNS de votre fournisseur d'accès) pour un fonctionnement optimal.

#Ce script est déstiné à être éxécuté automatiquement, le plus souvent possible (toutes les minutes par exemple). Pour cela :

#    Loggez-vous en root (ou faites un "su")
#    Demandez à modifier la crontab par la commande "crontab -e"
#    Entrez la ligne suivante:

#    * * * * * /usr/local/sbin/chkconnect.sh

#    Sauvegardez, c'est fini.

#Evidemment, si vous décidez de placer le script ailleurs que dans /usr/local/sbin, modifiez la ligne en conséquence.


#/////////////////////////////////////////////////////////////////////////////////////////


#! /bin/sh

# chkconnect.sh - Checks if you're connected to the internet and tries to
# reconnect if you're not any more
# By Raphaël HALIMI <raphaelh@easynet.fr>
# Based on a script by Bruce BUHLER and Wayne LARMON
# which can be found at http://www.scrounge.org/ipwatch

# The SERVER variable should be set to the DNS server of your ISP
# (even if your machine or network runs its own DNS server)
SERVER=195.114.64.230

# This is the script used to restart your internet cnonnection
CONNECT="/usr/local/sbin/netissimo.sh restart"

# The name of the temp file
TEMPFILE=/tmp/chkconnect.tmp

# The name of the log file
LOGFILE=/var/log/chkconnect.sh

# We check if another instance of the script is running
if [ -e $TEMPFILE ] ; then
   echo "Another instance of this script is already running. If you are sure"
   echo "that's not the case, please delete the file /tmp/chkconnect.tmp"
   exit
fi

# Creating the temporary file
touch $TEMPFILE

# Test if you can reach the server
if ! `nslookup -retry=1 -timeout=2 $SERVER $SERVER > /dev/null 2>&1` ; then

   # Lest's make sure we're really disconnected
   if ! `nslookup -retry=4 -timeout=5 $SERVER $SERVER > /dev/null 2>&1` ; then

      # Okay, we are disconected. Warn root.
      echo "Can't reach external adress !" | mail -s "Connection lost !" root

      # Write log file
      echo "`date` : Disconnected." >> $LOGFILE

      # Run the connection script
      $CONNECT > /dev/null

      # Normally, we should be connected now. So try again to reach the server
      if `nslookup -retry=1 -timeout=2 $SERVER $SERVER > /dev/null 2>&1` ; then
         echo "Connection reestablished." | mail -s "Connection OK." root
         echo "`date` : Reconnected." >> $LOGFILE
      else
         echo "The connection script failed to reestablish the connection." \
         | mail -s "Connection failed." root
         echo "`date` : Connection failed." >> $LOGFILE
      fi
   fi
fi

# Deletes the temporary file
rm  $TEMPFILE
