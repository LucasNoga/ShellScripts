#!/bin/bash
#copy-cd : Copier un CD de données

CDROM=/dev/cdrom                           # périphérique CD ROM
OF=/home/bozo/projects/cdimage.iso         # fichier de sortie
#       /xxxx/xxxxxxx/                     A modifier suivant votre système.
TAILLEBLOC=2048
VITESSE=2                                  # Utiliser une vitesse supèrieure
                                           #+ si elle est supportée.
PERIPHERIQUE=cdrom
#PERIPHERIQUE="0,0" pour les anciennes versions de cdrecord

echo; echo "Insérez le CD source, mais ne le montez *pas*."
echo "Appuyez sur ENTER lorsque vous êtes prêt. "
read pret                                  # Attendre une entrée, $pret n'est
                                           # pas utilisé.

echo; echo "Copie du CD source vers $OF."
echo "Ceci peut prendre du temps. Soyez patient."

dd if=$CDROM of=$OF bs=$TAILLEBLOC         # Copie brute du périphérique.


echo; echo "Retirez le CD de données."
echo "Insérez un CDR vierge."
echo "Appuyez sur ENTER lorsque vous êtes prêt. "
read pret                                  # Attendre une entrée, $pret n'est
                                           # pas utilisé.

echo "Copie de $OF vers CDR."

cdrecord -v -isosize speed=$VITESSE dev=$PERIPHERIQUE $OF
# Utilise le paquetage "cdrecord" de Joerg Schilling's (voir sa doc).
# http://www.fokus.gmd.de/nthp/employees/schilling/cdrecord.html


echo; echo "Copie terminée de $OF vers un CDR du périphérique $CDROM."

echo "Voulez-vous écraser le fichier image (o/n)? "  # Probablement un fichier
                                                     # immense.
read reponse

case "$reponse" in
[oO]) rm -f $OF
      echo "$OF supprimé."
      ;;
*)    echo "$OF non supprimé.";;
esac

echo

#  Exercice:
#  Modifiez l'instruction "case" pour aussi accepter "oui" et "Oui" comme
#+ entrée.

exit 0

