#Checke l'IP de votre machine, modifie au besoin le fichier
#/etc/hosts, et envoie un mail contenant la nouvelle IP aux personnes de votre choix.




#J'ai écrit ce script au départ pour être au courant en cas de changement de mon IP. En effet, ma machine est connectée au Net par le câble et tourne 24h/24. Il m'arrive de m'y connecter à distance, et j'ai donc besoin de connaître l'adresse IP (car chez Cybercable, le nom d'hôte est construit à partir de l'IP, qui peut changer même en cours de connection... Bref...). Si l'IP change, le script envoie un mail à mon adresse sur Yahoo! Mail, que je peux consulter de n'importe où. Par la suite, j'y ai ajouté une petite routine qui met à jour le fichier /etc/hosts pour y inclure la nouvelle adresse IP.
#Je vous conseille d'utiliser ce script de manière automatique, en insérant une entrée y faisant référence dans la crontab du superuser (root), car le script a besoin des droits root pour mettre à jour le fichier /etc/hosts. Pour cela:

#    Loggez-vous en root (ou faites un "su")
#    Demandez à modifier la crontab par la commande "crontab -e"
#    Entrez la ligne suivante:

#    0/15 * * * * /etc/init.d/ipcheck.sh

#    Sauvegardez, c'est fini.

#Cela lance automatiquement le script tous les quarts d'heure.

#Bien entendu, il faudra peut-être modifier le chemin du programme. Chez moi, j'utilise une Debian et j'ai donc mis le script dans /etc/init.d (avec les liens nécéssaires dans les différents rcX.d) pour que le script soit appelé au démarrage. Comme je ne connais pas les procédures de démarrage pour les autres distributions, je ne peux pas vous aider. Si quelqu'un veut me communiquer la marche à suivre, me contacter par e-mail, c'est avec grand plaisir que je la publierai ici.

#Pour plus de précisions sur la syntaxe du fichier crontab, "man 5 crontab".




#/////////////////////////////////////////////////////////////////////////////////////////



#! /bin/sh

# ipcheck.sh - Version 1.1
# Modify your file /etc/hosts if the IP adress has changed after a reboot
# By Raphaël HALIMI <raphaelh@easynet.fr>

# The interface you want the watch the IP of. Change it to suit your needs.

INTERFACE=eth0

# People who will be sent a mail if IP changes.
# You can add people you want to be informed of the change in the $INFORMED
# variable, just add the names (or e-mails) seperated by commas

INFORMED="root"

# Variables you don't need to change.

CURRENT_IP=`/sbin/ifconfig $INTERFACE | grep inet | cut -d ":" -f 2 | cut -d " " -f 1`
REGISTERED_IP=`grep $HOSTNAME /etc/hosts | cut -f 1`

# First we check if the interface is configured

if ! /sbin/ifconfig $INTERFACE > /dev/null 2>&1 ; then
   echo "Network interface $INTERFACE not configured: aborting."
   exit
fi

# Definitions of the old and new IP adresses

echo "Current IP: $CURRENT_IP."
echo "Registered IP: $REGISTERED_IP."

# Check if IP is modified, and if so, we update the /etc/hosts file
# If the creation of the new /etc/hosts file fails, no modification is done

if [ $CURRENT_IP != $REGISTERED_IP ] ; then
   echo -n "IP adress has changed: créating a new /etc/hosts file"
   sed -e "s/$REGISTERED_IP/$CURRENT_IP/g" /etc/hosts > /etc/hosts.new
   echo "."
   if [ -s /etc/hosts.new ] ; then
      echo -n "Creation of the new file succeeded: replacing /etc/hosts"
      cp /etc/hosts /etc/hosts.bak
      mv /etc/hosts.new /etc/hosts
      echo "."
      echo "Backup copy of the old /etc/hosts: /etc/hosts.bak."
   else
      echo "Error when creating file: /etc/hosts.new is empty, no update done."
      echo "Please modify /etc/hosts by yourself."
   fi
else
   echo "IP adress hasn't changed: no update needed."
fi

# If the IP has changed, a mail is sent to people mentioned in the $INFORMED
# variable above.

if [ $CURRENT_IP != $REGISTERED_IP ] ; then
   echo "New IP adress: $CURRENT_IP" | mail $INFORMED -s "IP adress of $HOSTNAME has changed"
   echo "A mail has been sent to $INFORMED."
fi
