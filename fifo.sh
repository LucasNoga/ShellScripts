#!/bin/bash
# fifo: Faire des sauvegardes journalières, en utilisant des tubes nommés
  
ICI=`uname -n`    # ==> nom d'hôte
LA_BAS=bilbo
echo "début de la sauvegarde distante vers $LA_BAS à `date +%r`"
# ==> `date +%r` renvoie l'heure en un format sur 12 heures, par exempe
# ==> "08:08:34 PM".

#  Assurez-vous que /pipe est réellement un tube et non pas un fichier
#+ standard.
rm -rf /tube
mkfifo /tube       # ==> Crée un fichier "tube nommé", nommé "/tube".

# ==> 'su xyz' lance les commandes en tant qu'utilisateur "xyz".
# ==> 'ssh' appele le shell sécurisé (client de connexion à distance).
su xyz -c "ssh $LA_BAS \"cat > /home/xyz/sauve/${ICI}-jour.tar.gz\" < /tube"&
cd /
tar -czf - bin boot dev etc home info lib man root sbin share usr var > /tube
# ==> Utilise un tube nommé, /tube, pour communiquer entre processus:
# ==> 'tar/gzip' écrit dans le tube et 'ssh' lit /tube.

#  ==> Le résultat final est que cela sauvegarde les répertoires principaux;
#+ ==> à partir de /.

# ==>  Quels sont les avantages d'un "tube nommé" dans cette situation,
# ==>+ en opposition avec le "tube anonyme", avec |?
# ==> Est-ce qu'un tube anonyme pourrait fonctionner ici?

# ==>  Est-il nécessaire de supprimer le tube avant de sortir du script ?
# ==>  Comment le faire ?

exit 0

