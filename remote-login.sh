# Permet de se logger facilement sur les n'importe quelle machine de votre réseau local. Update le 4 juin !

#Ce script est destiné à tous les fainéants (comme moi :-) qui administrent plusieurs
#machines en réseau local. Il permet de lancer un shell (par telnet, rlogin, ssh...)
#sur une machine distante (ou même locale, dans ce cas, il ne lance qu'un simple "sh").
#Il est très simple à utiliser: il construit une liste numérotée de machines, et vous
#entrez le numéro correspondant à la machine sur laquelle vous voulez vous logger, suivi de la touche ENTER.

#Pour le configurer, c'est tout aussi simple: il y a deux variables,
#la première contiendra la liste des noms des machines, separés par des espaces,
#et la seconde, le programme utilisé pour lancer un shell distant (telnet, ssh..).

#Ensuite, il ne vous reste plus qu'à l'intégrer dans le menu de votre
#window manager préféré (ou le Dock de Window Maker, ou le Wharf d'AfterStep, ou...).




#/////////////////////////////////////////////////////////////////////////////////////////
