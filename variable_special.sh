#!/bin/bash
#Ce script représente les variables spéciales du shell

echo "Nom du script : " $0;
echo "parametre de position 1 : " $1;
echo "parametre de position 2 a 9 : " $2 $9;
echo "parametre de position 10 : " ${10};
echo "nombre de parametres : " $#
echo "Tous les paramètres de position (en un seul mot) : " $*
echo "Tous les paramètres de position (en des chaînes séparées) : " $@
echo "Nombre de paramètres sur la ligne de commande passés au script : " ${#*}
echo "Nombre de paramètres sur la ligne de commande passés au script : " ${#@}
echo "Code retour de la derniere commande : " $?
echo "Numéro d'identifiant du processus (PID) généré par le script : " $$
echo "Options passées au script (utilisant set) : " $-
echo "Dernier argument de la commande précédente : " $_
echo "Identifiant du processus (PID) du dernier job exécuté en tâche de fond : " $!;












