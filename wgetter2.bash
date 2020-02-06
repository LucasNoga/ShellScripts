#!/bin/bash
# wgetter2.bash : Rendre wget plus facile à utiliser

# Auteur : Little Monster [monster@monstruum.co.uk]
# ==> Utilisé dans le guide ABS avec la permission de l'auteur du script.
# ==> Ce script a toujours besoin de débogage et de corrections (exercice
# ==> laissé au lecteur).
# ==> Il pourrait aussi bénéficier de meilleurs commentaires.


#  Ceci est wgetter2 --
#+ un script Bash rendant wget un peu plus facile à utiliser
#+ et évitant de la frappe clavier.

#  Écrit avec attention par Little Monster.
#  Plus ou moins complet le 02/02/2005.
#  Si vous pensez que ce script est améliorable,
#+ envoyez-moi un courrier électronique à : monster@monstruum.co.uk
# ==> et mettez en copie l'auteur du guide ABS.
#  Ce script est sous licence GPL.
#  Vous êtes libre de le copier, modifier, ré-utiliser,
#+ mais, s'il-vous-plait, ne dites pas que vous l'avez écrit.
#  À la place, indiquez vos changements ici.

# =======================================================================
# journal des modifications :

# 07/02/2005.  Corrections par Little Monster.
# 02/02/2005.  Petits ajouts de Little Monster.
#              (Voir après # +++++++++++ )
# 29/01/2005.  Quelques petites modifications de style et nettoyage de l'auteur
#              du guide ABS.
#              Ajout des codes d'erreur.
# 22/11/2004.  Fin de la version initiale de la seconde version de wgetter :
#              wgetter2 est né.
# 01/12/2004.  Modification de la fonction 'runn' de façon à ce qu'il
#              fonctionne de deux façons --
#              soit en demandant le nom d'un fichier soit en le récupérant sur
#              la ligne de commande.
# 01/12/2004.  Gestion sensible si aucune URL n'est fournie.
# 01/12/2004.  Boucle des options principales, de façon à ne pas avoir à
#              rappeller wgetter 2 tout le temps.
#              À la place, fonctionne comme une session.
# 01/12/2004.  Ajout d'une boucle dans la fonction 'runn'.
#              Simplifié et amélioré.
# 01/12/2004.  Ajout de state au paramètrage de récursion.
#              Active la ré-utilisation de la valeur précédente.
# 05/12/2004.  Modification de la routine de détection de fichiers dans la
#              fonction 'runn' de façon à ce qu'il ne soit pas gêné par des
#              valeurs vides et pour qu'il soit plus propre.
# 01/02/2004.  Ajout de la routine de récupération du cookie à partir de 
#              la dernière version (qui n'est pas encore prête), de façon à ne
#              pas avoir à codé en dur les chemins.
# =======================================================================

# Codes d'erreur pour une sortie anormale.
E_USAGE=67                   # Message d'usage, puis quitte.
E_SANS_OPTS=68               # Aucun argument en ligne de commande.
E_SANS_URLS=69               # Aucune URL passée au script.
E_SANS_FICHIERSAUVEGARDE=70  # Aucun nom de fichier de sortie passé au script.
E_SORTIE_UTILISATEUR=71      # L'utilisateur a décidé de quitter.


#  Commande wget par défaut que nous voulons utiliser.
#  C'est l'endroit où la changer, si nécessaire.
#  NB: si vous utilisez un proxy, indiquez http_proxy = yourproxy dans .wgetrc.
#  Sinon, supprimez --proxy=on, ci-dessous.
# ====================================================================
CommandeA="wget -nc -c -t 5 --progress=bar --random-wait --proxy=on -r"
# ====================================================================



# --------------------------------------------------------------------
# Initialisation de quelques autres variables avec leur explications.

pattern=" -A .jpg,.JPG,.jpeg,.JPEG,.gif,.GIF,.htm,.html,.shtml,.php"
                    #  Options de wget pour ne récupérer que certain types de
                    #+ fichiers. Mettre en commentaire si inutile
today=`date +%F`    # Utilisé pour un nom de fichier.
home=$HOME          # Utilise HOME pour configurer une variable interne.
                    #  Au cas où d'autres chemins sont utilisés, modifiez cette
                    #+ variable.
depthDefault=3      # Configure un niveau de récursion sensible.
Depth=$depthDefault # Sinon, le retour de l'utilisateur ne sera pas intégré.
RefA=""             # Configure la page blanche de référence.
Flag=""             #  Par défaut, ne sauvegarde rien,
                    #+ ou tout ce qui pourrait être voulu dans le futur.
lister=""           # Utilisé pour passer une liste d'url directement à wget.
Woptions=""         # Utilisé pour passer quelques options à wget.
inFile=""           # Utilisé pour la fonction run.
newFile=""          # Utilisé pour la fonction run.
savePath="$home/w-save"
Config="$home/.wgetter2rc"
                    #  Quelques variables peuvent être stockées, 
                    #+ si elles sont modifiées en permanence à l'intérieur de ce
                    #+ script.
Cookie_List="$home/.cookielist"
                    # Pour que nous sachions où sont conservés les cookies...
cFlag=""            # Une partie de la routine de sélection du cookie.

#  Définissez les options disponibles. Lettres faciles à modifier ici si
#+ nécessaire.
#  Ce sont les options optionnelles ; vous n'avez pas besoin d'attendre
#+ qu'elles vous soient demandées.

save=s   # Sauvegarde la commande au lieu de l'exécuter.
cook=c   # Modifie le cookie pour cette session.
help=h   # Guide d'usage.
list=l   # Passe à wget l'option -i et la liste d'URL.
runn=r   # Lance les commandes sauvegardées comme argument de l'option.
inpu=i   # Lance les commandes sauvegardées de façon interactive.
wopt=w   # Autorise la saisie d'options à passer directement à wget.
# --------------------------------------------------------------------


if [ -z "$1" ]; then   # Soyons sûr de donner quelque chose à manger à wget.
   echo "Vous devez entrer au moins une RLS ou une option!"
   echo "-$help pour l'utilisation."
   exit $E_SANS_OPTS
fi



# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ajout ajout ajout ajout ajout ajout ajout ajout ajout ajout ajout ajout

if [ ! -e "$Config" ]; then   #  Vérification de l'existence du fichier de
                              #+ configuration.
   echo "Création du fichier de configuration, $Config"
   echo "# Ceci est le fichier de configuration pour wgetter2" > "$Config"
   echo "# Vos paramètres personnalisés seront sauvegardés dans ce fichier" \
     >> "$Config"
else
   source $Config             #  Import des variables que nous avons initialisé
                              #+ en dehors de ce script.
fi

if [ ! -e "$Cookie_List" ]; then
   # Configure une liste de cookie, si elle n'existe pas.
   echo "Recherche des cookies..."
   find -name cookies.txt >> $Cookie_List   # Crée une liste des cookies.
fi #  Isole ceci dans sa propre instruction 'if',
   #+ au cas où nous serions interrompu durant la recherche.

if [ -z "$cFlag" ]; then # Si nous n'avons pas encore fait ceci...
   echo                  # Ajoute un espacement après l'invite de la commande.
   echo "Il semble que vous n'avez pas encore configuré votre source de cookies."
   n=0                   # S'assure que le compteur ne contient pas de valeurs.
   while read; do
      Cookies[$n]=$REPLY #  Place les cookies que nous avons trouvé dans un
                         #+ tableau.
      echo "$n) ${Cookies[$n]}"  # Crée un menu.
      n=$(( n + 1 ))     # Incrémente le comteur.
   done < $Cookie_List   # Remplit l'instruction read.
   echo "Saisissez le nombre de cookies que vous souhaitez utiliser."
   echo "Si vous ne voulez pas utiliser de cookie, faites simplement RETURN."
   echo
   echo "Je ne vous demanderais plus ceci. Éditez $Config"
   echo "si vous décidez de le changer ultérieurement"
   echo "ou utilisez l'option -${cook} pour des modifications sur une session."
   read
   if [ ! -z $REPLY ]; then   # L'utilisateur n'a pas seulement faire ENTER.
      Cookie=" --load-cookies ${Cookies[$REPLY]}"
      # Initialise la variable ici ainsi que dans le fichier de configuration.

      echo "Cookie=\" --load-cookies ${Cookies[$REPLY]}\"" >> $Config
   fi
   echo "cFlag=1" >> $Config  #  Pour que nous nous rappelions de ne pas le
                              #+ demander de nouveau.
fi

# fin section ajoutée fin section ajoutée fin section ajoutée 
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



# Une autre variable.
# Celle-ci pourrait être ou pas sujet à variation.
# Un peu comme le petit affichage.
CookiesON=$Cookie
# echo "cookie file is $CookiesON" # Pour débogage.
# echo "home is ${home}"           # Pour débogage. Faites attention à celui-ci!


wopts()
{
echo "Entrer les options à fournir à wget."
echo "Il est supposé que vous savez ce que vous faites."
echo
echo "Vous pouvez passer leurs arguments ici aussi."
# C'est-à-dire que tout ce qui est saisi ici sera passé à wget.

read Wopts
# Lire les options à donner à wget.

Woptions=" $Wopts"
#         ^  Pourquoi cet espace initial ?
# Affecter à une autre variable.
# Pour le plaisir, ou pour tout autre chose...

echo "options ${Wopts} fournies à wget"
# Principalement pour du débogage.
# Est joli.

return
}


save_func()
{
echo "Les paramètres vont être sauvegardés."
if [ ! -d $savePath ]; then  #  Vérifie si le répertoire existe.
   mkdir $savePath           #  Crée le répertoire pour la sauvegarde
                             #+ si ce dernier n'existe pas.
fi

Flag=S
# Indique au dernier bout de code ce qu'il faut faire.
# Positionne un drapeau car le boulot est effectué dans la partie principale.

return
}


usage() # Indique comment cela fonctionne.
{
    echo "Bienvenue dans wgetter. C'est une interface pour wget."
    echo "Il lancera en permanence wget avec ces options :"
    echo "$CommandeA"
    echo "et le modèle de correspondance: $modele (que vous pouvez changer en"
    echo "haut du script)."
    echo "Il vous demandera aussi une profondeur de récursion depth et si vous"
    echo "souhaitez utiliser une page de référence."
    echo "Wgetter accepte les options suivantes :"
    echo ""
    echo "-$help : Affiche cette aide."
    echo "-$save : Sauvegarde la commande dans un fichier"
    echo "$savePath/wget-($today) au lieu de l'exécuter."
    echo "-$runn : Exécute les commandes wget sauvegardées au lieu d'en"
    echo "commencer une nouvelle --"
    echo "Saisissez le nom du fichier comme argument de cette option."
    echo "-$inpu : Exécute les commandes wget sauvegardées, de façon"
    echo "interactive -- "
    echo "Le script vous demandera le nom du fichier."
    echo "-$cook : Modifie le fichier des cookies pour cette session."
    echo "-$list : Indique à wget d'utiliser les URL à partir d'une liste"
    echo "plutôt que sur la ligne de commande."
    echo "-$wopt : Passe toute autre option directement à wget."
    echo ""
    echo "Voir la page man de wget pour les options supplémentaires que vous"
    echo "pouvez lui passer."
    echo ""

    exit $E_USAGE  # Fin ici. Ne rien exécuter d'autre.
}



list_func() #  Donne à l'utilisateur l'option pour utiliser l'option -i de wget,
            #+ et une liste d'URL.
{
while [ 1 ]; do
   echo "Saisissez le nom du fichier contenant les URL (appuyez sur q si vous"
   echo "avez changé d'idée)."
   read urlfile
   if [ ! -e "$urlfile" ] && [ "$urlfile" != q ]; then
       # Recherche un fichier ou l'option de sortie.
       echo "Ce fichier n'existe pas!"
   elif [ "$urlfile" = q ]; then   # Vérifie l'option de sortie.
       echo "N'utilise pas de liste d'URL."
       return
   else
      echo "Utilisation de $urlfile."
      echo "Si vous m'avez fourni des URL sur la ligne de commandes,"
      echo "je les utiliserais en premier."
                    # Indique le comportement standard de wget à l'utilisateur.
      lister=" -i $urlfile" # C'est ce que nous voulons fournir à wget.
      return
   fi
done
}


cookie_func()  #  Donne à l'utilisateur l'option d'utiliser un fichier
               #+ cookie différent.
{
while [ 1 ]; do
   echo "Modification du fichier cookie. Appuyez sur return si vous ne voulez "
   echo "pas le changer."
   read Cookies
   # NB: Ceci n'est pas la même chose que Cookie, un peu plus tôt.
   # Il y a un 's' à la fin.
   if [ -z "$Cookies" ]; then                   # Clause d'échappement.
      return
   elif [ ! -e "$Cookies" ]; then
      echo "Le fichier n'existe pas. Essayez de nouveau." # On continue...
   else
       CookiesON=" --load-cookies $Cookies"  # Le fichier est bon -- utilisons-le!
       return
   fi
done
}


run_func()
{
if [ -z "$OPTARG" ]; then
# Teste pour voir si nous utilisons les options en ligne ou la requête.
   if [ ! -d "$savePath" ]; then  # Au cas où le répertoire n'existe pas...
      echo "$savePath ne semble pas exister."
      echo "Merci de fournir un chemin et un nom de fichiers pour les commandes"
      echo "wget sauvegardées :"
      read newFile
         until [ -f "$newFile" ]; do  #  Continue jusqu'à ce que nous obtenions
                                      #+ quelque chose.
            echo "Désolé, ce fichier n'existe pas. Essayez de nouveau."
            # Essaie réellement d'avoir quelque chose.
            read newFile
         done

# -------------------------------------------------------------------------
#         if [ -z ( grep wget ${newfile} ) ]; then
          # Suppose qu'ils n'ont pas encore le bon fichier.
#         echo "Désolé, ce fichier ne contient pas de commandes wget.
#         echo "Annulation."
#         exit
#         fi
#
# Ce code est bogué.
# Il ne fonctionne réellement pas.
# Si vous voulez le corriger, n'hésitez pas !
# -------------------------------------------------------------------------

      filePath="${newFile}"
   else
   echo "Le chemin de sauvegarde est $savePath"
      echo "Merci de saisir le nom du fichier que vous souhaitez utiliser."
      echo "Vous avez le choix entre :"
      ls $savePath                                # Leur donne un choix.
      read inFile
         until [ -f "$savePath/$inFile" ]; do     # Continuez jusqu'à obtention.
            if [ ! -f "${savePath}/${inFile}" ]; then
                                                  # Si le fichier n'existe pas.
               echo "Désolé, ce fichier n'existe pas."
               echo " Faites votre choix à partir de :"
               ls $savePath                           # Si une erreur est faite.
               read inFile
            fi
         done
      filePath="${savePath}/${inFile}"  # En faire une variable...
   fi
else filePath="${savePath}/${OPTARG}"   # qui peut être beaucoup de choses...
fi

if [ ! -f "$filePath" ]; then           # Si nous obtenons un fichier bogué.
   echo "Vous n'avez pas spécifié un fichier convenable."
   echo "Lancez tout d'abord ce script avec l'option -${save}."
   echo "Annulation."
   exit $E_SANS_FICHIERSAUVEGARDE
fi
echo "Utilisation de : $filePath"
while read; do
    eval $REPLY
    echo "Fin : $REPLY"
done < $filePath  # Remplit le fichier que nous utilisons avec une boucle while.

exit
}



# Récupération de toute option que nous utilisons pour ce script.
# Ceci est basé sur la démo de "Learning The Bash Shell" (O'Reilly).
while getopts ":$save$cook$help$list$runn:$inpu$wopt" opt
do
  case $opt in
     $save) save_func;;   #  Sauvegarde de quelques sessions wgetter pour plus
                          #  tard.
     $cook) cookie_func;; #  Modifie le fichier cookie.
     $help) usage;;       #  Obtient de l'aide.
     $list) list_func;;   #  Autorise wget à utiliser une liste d'URL.
     $runn) run_func;;    #  Utile si vous appelez wgetter à partir d'un script
                          #+ cron par exemple.
     $inpu) run_func;;    #  Lorsque vous ne connaissez pas le nom des fichiers.
     $wopt) wopts;;       #  Passe les options directement à wget.
        \?) echo "Option invalide."
            echo "Utilisez -${wopt} si vous voulez passer les options "
            echo "directement à to wget,"
            echo "ou -${help} pour de l'aide";;      # Récupère quelque chose.
  esac
done
shift $((OPTIND - 1))     # Opérations magiques avec $#.


if [ -z "$1" ] && [ -z "$lister" ]; then 
                          #  Nous devrions laisser au moins une URL sur la
                          #+ ligne de commande à moins qu'une liste ne soit
                          #+ utilisée - récupère les lignes de commandes vides.
   echo "Aucune URL fournie ! Vous devez les saisir sur la même ligne "
   echo "que wgetter2."
   echo "Par exemple,  wgetter2 http://somesite http://anothersite."
   echo "Utilisez l'option $help pour plus d'informations."
   exit $E_SANS_URLS        # Quitte avec le bon code d'erreur.
fi

URLS=" $@"
#  Utilise ceci pour que la liste d'URL puisse être modifié si nous restons dans
#+ la boucle d'option.

while [ 1 ]; do
   # C'est ici que nous demandons les options les plus utilisées.
   # (Pratiquement pas changées depuis la version 1 de wgetter)
   if [ -z $curDepth ]; then
      Current=""
   else Current=" La valeur courante est $curDepth"
   fi
       echo "A quelle profondeur dois-je aller ? "
       echo "(entier: valeur par défaut $depthDefault.$Current)"
       read Depth   # Récursion -- A quelle profondeur allons-nous ?
       inputB=""    # Réinitialise ceci à rien sur chaque passe de la boucle.
       echo "Saisissez le nom de la page de référence (par défaut, aucune)."
       read inputB  # Nécessaire pour certains sites.

       echo "Voulez-vous que la sortie soit tracée sur le terminal"
       echo "(o/n, par défaut, oui) ?"
       read noHide  # Sinon, wget le tracera simplement dans un fichier.

       case $noHide in
          # Maintenant, vous me voyez, maintenant, vous ne me voyez plus.
          o|O ) hide="";;
          n|N ) hide=" -b";;
            * ) hide="";;
       esac

       if [ -z ${Depth} ]; then       #  L'utilisateur a accepté la valeur par
                                      #+ défaut ou la valeur courante,
                                      #+ auquel cas Depth est maintenant vide.
          if [ -z ${curDepth} ]; then #  Vérifie si Depth a été configuré
                                      #+ sur une précédente itération.
             Depth="$depthDefault"    #  Configure la profondeur de récursion
                                      #+ par défaut si rien de défini
                                      #+ sinon, l'utilise.
          else Depth="$curDepth"      #  Sinon, utilisez celui configuré
                                      #+ précédemment.
          fi
       fi
   Recurse=" -l $Depth"               #  Initialise la profondeur.
   curDepth=$Depth                    #  Se rappeler de ce paramètrage la
                                      #+ prochaine fois.

       if [ ! -z $inputB ]; then
          RefA=" --referer=$inputB"   #  Option à utiliser pour la page de
                                      #+ référence.
       fi

  
WGETTER="${CommandeA}${modele}${hide}${RefA}${Recurse}${CookiesON}${lister}${Woptions}${URLS}"
   #  Crée une chaîne contenant le lot complet...
   #  NB: pas d'espace imbriqués.
   #  Ils sont dans les éléments individuels si aucun n'est vide,
   #+ nous n'obtenons pas d'espace supplémentaire.

   if [ -z "${CookiesON}" ] && [ "$cFlag" = "1" ] ; then
       echo "Attention -- impossible de trouver le fichier cookie."
       #  Ceci pourrait changer, au cas où l'utilisateur aurait choisi de ne 
       #+ pas utiliser les cookies.
   fi

   if [ "$Flag" = "S" ]; then
      echo "$WGETTER" >> $savePath/wget-${today}
      #  Crée un nom de fichier unique pour aujourd'hui
      #+ ou y ajoute les informations s'il existe déjà.
      echo "$inputB" >> $savePath/site-list-${today}
      #  Crée une liste pour qu'il soit plus simple de s'y référer plus tard,
      #+ car la commande complète est un peu confuse.
      echo "Commande sauvegardée dans le fichier $savePath/wget-${today}"
           # Indication pour l'utilisateur.
      echo "URL de la page de référence sauvegardé dans le fichier "
      echo "$savePath/site-list-${today}"
           # Indication pour l'utilisateur.
      Saver=" avec les options sauvegardées"
      #  Sauvegarde ceci quelque part, de façon à ce qu'il apparaisse dans la
      #+ boucle si nécessaire.
   else
       echo "**********************"
       echo "*****Récupération*****"
       echo "**********************"
       echo ""
       echo "$WGETTER"
       echo ""
       echo "**********************"
       eval "$WGETTER"
   fi

       echo ""
       echo "Continue avec$Saver."
       echo "Si vous voulez stopper, appuyez sur q."
       echo "Sinon, saisissez des URL :"
       # Laissons-les continuer. Indication sur les options sauvegardées.

       read
       case $REPLY in        # Nécessaire de changer ceci par une clause 'trap'.
          q|Q ) exit $E_SORTIE_UTILISATEUR;;  # Exercice pour le lecteur ?
            * ) URLS=" $REPLY";;
       esac

       echo ""
done


exit 0

