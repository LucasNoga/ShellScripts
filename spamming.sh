#!/bin/bash
# whx.sh : recherche d'un spammeur via "whois"
# Auteur: Walter Dnes
# Révisions légères (première section) par l'auteur du guide ABS.
# Utilisé dans le guide ABS avec sa permission.

#  Nécessite la version 3.x ou ultérieure de Bash pour fonctionner
#+ (à cause de l'utilisation de l'opérateur =~).
#  Commenté par l'auteur du script et par l'auteur du guide ABS.



E_MAUVAISARGS=65    # Argument manquant en ligne de commande.
E_SANSHOTE=66       # Hôte introuvable.
E_DELAIDEPASSE=67   # Délai dépassée pour la recherche de l'hôte.
E_NONDEF=68         # D'autres erreurs (non définies).
ATTENTEHOTE=10      # Spécifiez jusqu'à 10 secondes pour la réponse à la requête.
                    # L'attente réelle pourrait être un peu plus longue.
FICHIER_RESULTAT=whois.txt   # Fichier en sortie.
PORT=4321


if [ -z "$1" ]      # Vérification de l'argument (requis) en ligne de commande.
then
  echo "Usage: $0 nom de domaine ou adresse IP"
  exit $E_MAUVAISARGS
fi


if [[ "$1" =~ "[a-zA-Z][a-zA-Z]$" ]]  # Se termine avec deux caractères alphabetiques ?
then                                  # C'est un nom de domaine et nous devons faire une recherche d'hôte.
  ADR_IP=$(host -W $ATTENTEHOTE $1 | awk '{print $4}')
                                      # Recherche d'hôte pour récupérer l'adresse IP.
                                      # Extraction du champ final.
else
  ADR_IP="$1"                         # L'argument en ligne de commande était une adresse IP.
fi

echo; echo "L'adresse IP est "ADR_IP""; echo

if [ -e "$FICHIER_RESULTAT" ]
then
  rm -f "$FICHIER_RESULTAT"
  echo "Ancien fichier résultat \"$FICHIER_RESULTAT\" supprimé."; echo
fi


#  Vérification.
#  (Cette section nécessite plus de travail.)
#  ==========================================
if [ -z "$ADR_IP" ]
# Sans réponse.
then
  echo "Hôte introuvable !"
  exit $E_SANSHOTE    # Quitte.
fi

if [[ "$ADR_IP" =~ "^[;;]" ]]
#  ;; connection timed out; no servers could be reached
then
  echo "Délai de recherche dépassé !"
  exit $E_DELAIDEPASSE   # On quitte.
fi

if [[ "$ADR_IP" =~ "[(NXDOMAIN)]$" ]]
#  Host xxxxxxxxx.xxx not found: 3(NXDOMAIN)
then
  echo "Hôte introuvable !"
  exit $E_SANSHOTE    # On quitte.
fi

if [[ "$ADR_IP" =~ "[(SERVFAIL)]$" ]]
#  Host xxxxxxxxx.xxx not found: 2(SERVFAIL)
then
  echo "Hôte introuvable !"
  exit $E_SANSHOTE    # On quitte.
fi



# ======================== Corps principal du script ========================

AFRINICquery() {
#  Définit la fonction qui envoit la requête à l'AFRINIC.
#+ Affiche une notification à l'écran, puis exécute la requête
#+ en redirigeant la sortie vers $FICHIER_RESULTAT.

  echo "Recherche de $ADR_IP dans whois.afrinic.net"
  whois -h whois.afrinic.net "$ADR_IP" > $FICHIER_RESULTAT

#  Vérification de la présence de la référence à un rwhois.
#  Avertissement sur un serveur rwhois.infosat.net non fonctionnel
#+ et tente une requête rwhois.
  if grep -e "^remarks: .*rwhois\.[^ ]\+" "$FICHIER_RESULTAT"
  then
    echo " " >> $FICHIER_RESULTAT
    echo "***" >> $FICHIER_RESULTAT
    echo "***" >> $FICHIER_RESULTAT
    echo "Avertissement : rwhois.infosat.net ne fonctionnait pas le 2005/02/02" >> $FICHIER_RESULTAT
    echo "                lorsque ce script a été écrit." >> $FICHIER_RESULTAT
    echo "***" >> $FICHIER_RESULTAT
    echo "***" >> $FICHIER_RESULTAT
    echo " " >> $FICHIER_RESULTAT
    RWHOIS=`grep "^remarks: .*rwhois\.[^ ]\+" "$FICHIER_RESULTAT" | tail -n 1 |\
    sed "s/\(^.*\)\(rwhois\..*\)\(:4.*\)/\2/"`
    whois -h ${RWHOIS}:${PORT} "$ADR_IP" >> $FICHIER_RESULTAT
  fi
}

APNICquery() {
  echo "Recherche de $ADR_IP dans whois.apnic.net"
  whois -h whois.apnic.net "$ADR_IP" > $FICHIER_RESULTAT

#  Just  about  every  country has its own internet registrar.
#  I don't normally bother consulting them, because the regional registry
#+ usually supplies sufficient information.
#  There are a few exceptions, where the regional registry simply
#+ refers to the national registry for direct data.
#  These are Japan and South Korea in APNIC, and Brasil in LACNIC.
#  The following if statement checks $FICHIER_RESULTAT (whois.txt) for the presence
#+ of "KR" (South Korea) or "JP" (Japan) in the country field.
#  If either is found, the query is re-run against the appropriate
#+ national registry.

  if grep -E "^country:[ ]+KR$" "$FICHIER_RESULTAT"
  then
    echo "Recherche de $ADR_IP dans whois.krnic.net"
    whois -h whois.krnic.net "$ADR_IP" >> $FICHIER_RESULTAT
  elif grep -E "^country:[ ]+JP$" "$FICHIER_RESULTAT"
  then
    echo "Recherche de $ADR_IP dans whois.nic.ad.jp"
    whois -h whois.nic.ad.jp "$ADR_IP"/e >> $FICHIER_RESULTAT
  fi
}

ARINquery() {
  echo "Recherche de $ADR_IP dans whois.arin.net"
  whois -h whois.arin.net "$ADR_IP" > $FICHIER_RESULTAT

#  Several large internet providers listed by ARIN have their own
#+ internal whois service, referred to as "rwhois".
#  A large block of IP addresses is listed with the provider
#+ under the ARIN registry.
#  To get the IP addresses of 2nd-level ISPs or other large customers,
#+ one has to refer to the rwhois server on port 4321.
#  I originally started with a bunch of "if" statements checking for
#+ the larger providers.
#  This approach is unwieldy, and there's always another rwhois server
#+ that I didn't know about.
#  A more elegant approach is to check $FICHIER_RESULTAT for a reference
#+ to a whois server, parse that server name out of the comment section,
#+ and re-run the query against the appropriate rwhois server.
#  The parsing looks a bit ugly, with a long continued line inside
#+ backticks.
#  But it only has to be done once, and will work as new servers are added.
#@   ABS Guide author comment: it isn't all that ugly, and is, in fact,
#@+  an instructive use of Regular Expressions.

  if grep -E "^Comment: .*rwhois.[^ ]+" "$FICHIER_RESULTAT"
  then
    RWHOIS=`grep -e "^Comment:.*rwhois\.[^ ]\+" "$FICHIER_RESULTAT" | tail -n 1 |\
    sed "s/^\(.*\)\(rwhois\.[^ ]\+\)\(.*$\)/\2/"`
    echo "Recherche de $ADR_IP dans ${RWHOIS}"
    whois -h ${RWHOIS}:${PORT} "$ADR_IP" >> $FICHIER_RESULTAT
  fi
}

LACNICquery() {
  echo "Recherche de $ADR_IP dans whois.lacnic.net"
  whois -h whois.lacnic.net "$ADR_IP" > $FICHIER_RESULTAT

#  The  following if statement checks $FICHIER_RESULTAT (whois.txt) for the presence of
#+ "BR" (Brasil) in the country field.
#  If it is found, the query is re-run against whois.registro.br.

  if grep -E "^country:[ ]+BR$" "$FICHIER_RESULTAT"
  then
    echo "Recherche de $ADR_IP dans whois.registro.br"
    whois -h whois.registro.br "$ADR_IP" >> $FICHIER_RESULTAT
  fi
}

RIPEquery() {
  echo "Recherche de $ADR_IP dans whois.ripe.net"
  whois -h whois.ripe.net "$ADR_IP" > $FICHIER_RESULTAT
}

#  Initialise quelques variables.
#  * slash8 est l'octet le plus significatif
#  * slash16 consiste aux deux octets les plus significatifs
#  * octet2 est le deuxième octet le plus significatif




slash8=`echo $IPADDR | cut -d. -f 1`
  if [ -z "$slash8" ]  # Encore une autre vérification.
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi
slash16=`echo $IPADDR | cut -d. -f 1-2`
#                             ^ Point spécifié comme délimiteur pour cut.
  if [ -z "$slash16" ]
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi
octet2=`echo $slash16 | cut -d. -f 2`
  if [ -z "$octet2" ]
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi


#  Vérification de différentes étrangetés.
#  Il n'y a pas d'intérêts à chercher ces adresses.

if [ $slash8 == 0 ]; then
  echo $ADR_IP est l\'espace '"This Network"' \; Pas de requêtes
elif [ $slash8 == 10 ]; then
  echo $ADR_IP est l\'espace RFC1918 \; Pas de requêtes
elif [ $slash8 == 14 ]; then
  echo $ADR_IP est l\'espace '"Public Data Network"' \; Pas de requêtes
elif [ $slash8 == 127 ]; then
  echo $ADR_IP est l\'espace loopback \; Pas de requêtes
elif [ $slash16 == 169.254 ]; then
  echo $ADR_IP est l\'espace link-local \; Pas de requêtes
elif [ $slash8 == 172 ] && [ $octet2 -ge 16 ] && [ $octet2 -le 31 ];then
  echo $ADR_IP est l\'espace RFC1918 \; Pas de requêtes
elif [ $slash16 == 192.168 ]; then
  echo $ADR_IP est l\'espace RFC1918 \; Pas de requêtes
elif [ $slash8 -ge 224 ]; then
  echo $ADR_IP est l\'espace Multicast ou réservé \; Pas de requêtes
elif [ $slash8 -ge 200 ] && [ $slash8 -le 201 ]; then LACNICquery "$ADR_IP"
elif [ $slash8 -ge 202 ] && [ $slash8 -le 203 ]; then APNICquery "$ADR_IP"
elif [ $slash8 -ge 210 ] && [ $slash8 -le 211 ]; then APNICquery "$ADR_IP"
elif [ $slash8 -ge 218 ] && [ $slash8 -le 223 ]; then APNICquery "$ADR_IP"

#  Si nous sommes arrivés ici sans prendre de décision, demander à l'ARIN.
#  Si une référence est trouvée dans $FICHIER_RESULTAT à l'APNIC, l'AFRINIC, LACNIC ou RIPE,
#+ alors envoyez une requête au serveur whois approprié.

else
  ARINquery "$ADR_IP"
  if grep "whois.afrinic.net" "$FICHIER_RESULTAT"; then
    AFRINICquery "$ADR_IP"
  elif grep -E "^OrgID:[ ]+RIPE$" "$FICHIER_RESULTAT"; then
    RIPEquery "$ADR_IP"
  elif grep -E "^OrgID:[ ]+APNIC$" "$FICHIER_RESULTAT"; then
    APNICquery "$ADR_IP"
  elif grep -E "^OrgID:[ ]+LACNIC$" "$FICHIER_RESULTAT"; then
    LACNICquery "$ADR_IP"
  fi
fi

#@  ---------------------------------------------------------------
#   Essayez aussi :
#   wget http://logi.cc/nw/whois.php3?ACTION=doQuery&amp;DOMAIN=$ADR_IP
#@  ---------------------------------------------------------------

#  Nous avons fini maintenant toutes les requêtes.
#  Affiche une copie du résultat final à l'écran.

cat $FICHIER_RESULTAT
# Ou "less $FICHIER_RESULTAT" . . .


exit 0

#@  Commentaires de l'auteur du guide ABS :
#@  Rien de particulièrement intéressant ici,
#@+ mais quand même un outil très utile pour chasser les spammeurs.
#@  Bien sûr, le script peut être un peu nettoyé et il est encore un peu bogué
#@+ (exercice pour le lecteur) mais, en fait, c'est un joli code de
#@+ Walter Dnes.
#@  Merci !

