#!/bin/bash
# conversion_html.sh : Convertir en HTML

# Convertit un fichier texte au format HTML.
# Auteur :      Mendel Cooper
# Licence :     GPL3
# Utilisation : sh tohtml.sh < fichiertexte > fichierhtml
#  Ce script est facilement modifiable pour accepter
#+ des noms de fichier source et destination.

#    Suppositions :
# 1) Les paragraphes du fichier texte (cible) sont séparés par une ligne blanche.
# 2) Les images JPEG (*.jpg) sont situées dans le sous-répertoire "images".
#    Dans le fichier cible, les noms des images sont placés entre des crochets,
#    par exemple [image01.jpg].
# 3) Les phrases importantes (en italique) commencent avec un espace suivi d'un
#+   tiret bas ou le premier caractère sur la ligne est un tiret bas
#+   et finissent avec un tiret bas suivi d'un espace ou d'une fin de ligne.


# Paramétrages
TAILLEPOLICE=2        # Taille de police.
REPIMG="images"  # Répertoire images.
# En-têtes
ENT01='&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"&gt;'
ENT02='&lt;!-- Convertit en HTML par le script ***tohtml.sh*** --&gt;'
ENT03='&lt;!-- auteur du script : M. Leo Cooper &lt;thegrendel@theriver.com&gt; --&gt;'
ENT10='&lt;html&gt;'
ENT11='&lt;head&gt;'
ENT11a='&lt;/head&gt;'
ENT12a='&lt;title&gt;'
ENT12b='&lt;/title&gt;'
ENT121='&lt;META NAME="GENERATOR" CONTENT="tohtml.sh script"&gt;'
ENT13='&lt;body bgcolor="#dddddd"&gt;'   # Modifie la couleur du fond.
ENT14a='&lt;font size='
ENT14b='&gt;'
# Bas de page
FTR10='&lt;/body&gt;'
FTR11='&lt;/html&gt;'
# Balises
GRAS="&lt;b&gt;"
CENTRE="&lt;center&gt;"
FIN_CENTRE="&lt;/center&gt;"
LF="&lt;br&gt;"


ecrire_entetes ()
  {
  echo "$ENT01"
  echo
  echo "$ENT02"
  echo "$ENT03"
  echo
  echo
  echo "$ENT10"
  echo "$ENT11"
  echo "$ENT121"
  echo "$ENT11a"
  echo "$ENT13"
  echo
  echo -n "$ENT14a"
  echo -n "$TAILLEPOLICE"
  echo "$ENT14b"
  echo
  echo "$GRAS"        # Tout en gras (plus facile à lire).
  }


traitement_texte ()
  {
  while read ligne    # Lire une ligne à la fois.
  do
    {
    if [ ! "$ligne" ] # Ligne vide ?
    then              # Alors un nouveau paragraphe doit suivre.
      echo
      echo "$LF"      # Insérer deux balises &lt;br&gt;.
      echo "$LF"
      echo
      continue        # Ignorer le test du tiret bas.
    else              # Sinon...

      if [[ "$ligne" =~ "\[*jpg\]" ]] # Une image ?
      then                            # Supprimer les crochets.
        temp=$( echo "$ligne" | sed -e 's/\[//' -e 's/\]//' )
        line=""$CENTRE" &lt;img src="\"$REPIMG"/$temp\"&gt; "$FIN_CENTRE" "
                                      # Ajouter la balise de l'image
                                      # et la centrer.
      fi

    fi


    echo "$ligne" | grep -q _
    if [ "$?" -eq 0 ]    # Si la ligne contient un tiret bas..
    then
      # ============================================================
      # Placer en italique une phrase entre tiret bas.
      temp=$( echo "$ligne" |
              sed -e 's/ _/ &lt;i&gt;/' -e 's/_ /&lt;\/i&gt; /' |
              sed -e 's/^_/&lt;i&gt;/'  -e 's/_$/&lt;\/i&gt;/' )
      #  Traiter seulement les tirets bas préfixés par un espace,
      #+ suivi par un espace ou en fin ou en début de ligne.
      #  Ne pas convertir les tirets bas contenus dans un mot !
      line="$temp"
      # Ralentit l'exécution du script. Cela peut-il être optimisé ?
      # ============================================================
    fi


   
    echo
    echo "$ligne"
    echo
    } # Fin while
  done
  }   # Fin traitement_texte ()


ecrire_basdepage ()  # Fin des balises.
  {
  echo "$FTR10"
  echo "$FTR11"
  }


# main () {
# =========
ecrire_entetes
traitement_texte
ecrire_basdepage
# =========
#         }

exit $?

