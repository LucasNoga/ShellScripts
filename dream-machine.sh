#Vous réveille avec des MP3, un CD ou des MIDI.

#Un beau matin, je me suis réveillé avec un mal de crâne terrible. La cause:
#l'antenne de mon radio-reveil avait bougé, et au lieu de la belle musique de ma radio préférée,
#une ignoble cacophonie mêlée de grésillements a résonné à mes oreilles pendant près
#d'une demi-heure (trop "dans les vapes" pour m'en rendre compte et me lever l'éteindre...).

#C'est donc ce matin-là, dans le RER, que j'ai commencé à réfléchir à ce script.

#Tout comme les radio-reveils modernes, il joue de la musique à une heure bien précise
#(enfin ça c'est plutôt crond qui s'en charge), puis il s'arrête comme un grand au bout d'un certain temps.
#En changeant une simple variable dans le script, vous pouvez choisir entre jouer des mp3,
#des fichiers MIDI ou bien un CD. Cette version utilise mpg123, playmidi, et les cdtools,
#mais rien ne vous empêche d'opter pour d'autres players (de simples variables à changer,
#c'est expliqué dans le script).

#Pour le déclencher tous les matins, il faut le mettre dans la crontab de root:

#    Loggez-vous en root (ou faites un "su")
#    Demandez à modifier la crontab par la commande "crontab -e"
#    Entrez la ligne suivante:

#     0 6 * * 1-5 /usr/local/bin/dream-machine.sh

#    Sauvegardez, c'est fini.

#Cela lancera le script du lundi au vendredi à 6 heures du matin.

#Bien sûr, si vous le placez ailleurs que dans /usr/local/bin, modifiez l'entrée dans la crontab.

#Pour plus de précisions sur la syntaxe du fichier crontab, "man 5 crontab".




#/////////////////////////////////////////////////////////////////////////////////////////
