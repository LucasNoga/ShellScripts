#!/bin/bash
#encryptedpw : Charger un fichier sur un site ftp, en utilisant un mot de passe crypté en local

# Exemple "ex72.sh" modifié pour utiliser les mots de passe cryptés.
#  Notez que c'est toujours moyennement sécurisé, car le mot de passe décrypté
#+ est envoyé en clair.
#  Utilisez quelque chose comme "ssh" si cela vous préoccupe.

E_MAUVAISARGS=65

if [ -z "$1" ]
then
  echo "Usage: `basename $0` nomfichier"
  exit $E_MAUVAISARGS
fi  

NomUtilisateur=bozo      # Changez suivant vos besoins.
motpasse=/home/bozo/secret/fichier_avec_mot_de_passe_crypte
# Le fichier contient un mot de passe crypté.

Nomfichier=`basename $1` # Supprime le chemin du fichier

Serveur="XXX"            #  Changez le nom du serveur et du répertoire suivant
Repertoire="YYY"         #+ vos besoins.


MotDePasse=`cruft <$motpasse`          # Décrypte le mot de passe.
#  Utilise le paquetage de cryptage de fichier de l'auteur,
#+ basé sur l'algorithme classique "onetime pad",
#+ et disponible à partir de:
#+ Site primaire:  ftp://ibiblio.org/pub/Linux/utils/file
#+                 cruft-0.2.tar.gz [16k]


ftp -n $Serveur <<Fin-de-Session
user $NomUtilisateur $MotDePasse
binary
bell
cd $Repertoire
put $Nomfichier
bye
Fin-de-Session
# L'option -n de "ftp" désactive la connexion automatique.
# Notez que "bell" fait sonner une cloche après chaque transfert.

exit 0