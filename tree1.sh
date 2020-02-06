 #!/bin/sh
# tree: Afficher l'arborescence d'un répertoire

search () {
   for dir in `echo *`
   # ==> `echo *` affiche tous les fichiers du répertoire actuel sans retour à
   # ==> la ligne.
   # ==> Même effet que     for dir in *
   # ==> mais "dir in `echo *`" ne gère pas les noms de fichiers comprenant des
   # ==> espaces blancs.
   do
      if [ -d "$dir" ] ; then   # ==> S'il s'agit d'un répertoire (-d)...
         zz=0   # ==> Variable temporaire, pour garder trace du niveau du
                # ==> répertoire.
         while [ $zz != $1 ]    # Conserve la trace de la boucle interne.
         do
            echo -n "|   "    # ==> Affiche le symbole du connecteur vertical
                              # ==> avec 2 espaces mais pas de retour à la ligne
                              # ==> pour l'indentation.
            zz=`expr $zz + 1` # ==> Incrémente zz.
         done
         
         if [ -L "$dir" ] ; then   # ==> Si le répertoire est un lien symbolique...
            echo "+---$dir" `ls -l $dir | sed 's/^.*'$dir' //'`
            # ==> Affiche le connecteur horizontal et affiche le nom du
            # ==> répertoire mais...
            # ==> supprime la partie date/heure des longues listes.
         else
            echo "+---$dir"      # ==> Affiche le symbole du connecteur
                                 # ==> horizontal et le nom du répertoire.
            numdirs=`expr $numdirs + 1` # ==> Incrémente le compteur de répertoire.
            if cd "$dir" ; then # ==> S'il peut se déplacer dans le sous-répertoire...
              search `expr $1 + 1` # avec la récursivité ;-)
              # ==> La fonction s'appelle elle-même.
              cd ..
            fi
         fi
      fi
   done
}

if [ $# != 0 ] ; then
  cd $1 # se déplace au répertoire indiqué.
  #else # reste dans le répertoire actuel.
fi

echo "Répertoire initial = `pwd`"
numdirs=0

search 0
echo "Nombre total de répertoires = $numdirs"

exit 0

