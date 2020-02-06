#Affiche un bref compte-rendu du download et de l'upload de votre machine en se basant
#sur le fichier de log du programme IPTraf, iface_stats_detailed.log.


#Ce script très utile analyse un fichier de log du programme IPTraf, iface_stats_detailed.log
#(le fichier de log de l'analyse détaillée), pour en extraire la quantité de download et d'upload
#depuis le lancement du programme (si on a activé le log). Si on l'évoque par la ligne de commande,
#il donne les résultats "en direct". S'il est lancé par crond, il envoie un mail à root... Magique ?
#Non, bash... ;-)

#Le script marche très bien. Cependant, je ne l'ai pas mis dans la section
#"Scripts terminés" car je pense sérieusement l'améliorer, pour qu'il fournisse plus d'informations,
#notamment le nombre de fois qu'IPTraf a été lancé, et le cumul du download et de l'upload
#(pour l'instant, il n'indique que la quantité pour le dernier lancement d'IPTraf).

#Comme d'habitude, on lance le script automatiquement à heures précises, avec cron:

#    Loggez-vous en root (ou faites un "su")
#    Demandez à modifier la crontab par la commande "crontab -e"
#    Entrez la ligne suivante:

#    0 */6 * * * /usr/local/sbin/iptraf-analyzer.sh

#    Sauvegardez, c'est fini.

#Cela lancera le script toutes les 6 heures (minuit, 6 heures, midi, 18 heures).
#Le superuser (root) recevra donc un mail 4 fois par jour, pour savoir où en est le traffic sur la
#machine concernée.

#Comme d'habitude, si vous préférez un autre endroit que /usr/local/sbin
#(ce qui me paraît pourtant logique, puisque ce programme ne peut être exécuté que par root,
#ayant besoin de ses droits pour les lire les fichiers dans /var/log/iptraf), modifiez la ligne en conséquence.




#/////////////////////////////////////////////////////////////////////////////////////////

#! /bin/sh

# iptraf-analyzer.sh - Version 0.1
# Prints a report of how much you have uploaded and downloaded,
# based on the detailed stats logfile from the program iptraf
# by Raphaël HALIMI <raphaelh@easynet.fr>
# Thanks to pn and gomesdv from DALnet's #linux-fr who helped me on awk :)

# Variables - this shouldn't be changed, unless you have defined different
# directories for iptraf's logfiles during the installation

LOGFILE=/var/log/iptraf/iface_stats_detailed.log
TMPFILE=/tmp/iptraf-analyzer.out
FROM=`grep started < $LOGFILE | tail -n 1 | cut -d ";" -f 1`
GEN=`grep generated < $LOGFILE | tail -n 1 | cut -d " " -f 8,9,10,11,12`

# The hard part... We parse the logfile and then extract the results

OUTBYTES=`awk 'BEGIN {T = 0} $1 ~ /^Total:$/ {getline ; T = $9} END {print T}' $LOGFILE`
INBYTES=`awk 'BEGIN {T = 0 } $1 ~ /^Total:$/ {getline ; T= $4} END {print T}' $LOGFILE`

# Calulating the Kb and Mb equivalents - very easy

OUTKB=$[$OUTBYTES / 1024]
OUTMB=$[$OUTKB / 1024]
INKB=$[$INBYTES / 1024]
INMB=$[$INKB / 1024]

# We print the results to a file, and then mail it

echo "Download and Upload statistics"
echo
echo "From $FROM to $GEN"
echo
echo "You have downloaded $INBYTES bytes."
echo "This approximatively corresponds to $INKB Kb and $INMB Mb."
echo
echo "You have also uploaded $OUTBYTES bytes."
echo "This approximatively corresponds to $OUTKB Kb and $OUTMB Mb."
