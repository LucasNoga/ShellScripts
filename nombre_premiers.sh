 #!/bin/bash
# primes: Générer des nombres premiers en utilisant l'opérateur modulo

#  Il n'utilise *pas* l'algorithme classique du crible d'Ératosthène,
#+ mais utilise à la place la méthode plus intuitive de test de chaque nombre
#+ candidat pour les facteurs (diviseurs), en utilisant l'opérateur modulo "%".


LIMITE=1000                 # Premiers de 2 à 1000

Premiers(){
   (( n = $1 + 1 ))             # Va au prochain entier.
   shift                        # Prochain paramètre dans la liste.
   #echo "_n=$n i=$i_"
 
   if (( n == LIMITE )); then 
      echo $*
   fi

   for i; do                    #  "i" est initialisé à "@", les précédentes #+ valeurs de $n.                          
      #echo "-n=$n i=$i-"  
      (( i * i > n )) && break   # Optimisation.
      (( n % i )) && continue    # Passe les non premiers en utilisant l'opérateur #+ modulo.                                      
      Premiers $n $@             # Récursion à l'intérieur de la boucle.
   done

   # Récursion à l'extérieur de la boucle.
   #  Accumule successivement les paramètres de  #+ position. 
   # "$@" est la liste des premiers accumulés.
   Premiers $n $@ $n                 
}

Premiers 1

exit  $?  # Envoyer la sortie du script à 'fmt' pour un affichage plus joli.

# Décommentez les lignes 16 et 24 pour vous aider à comprendre ce qui se passe.

#  Comparez la vitesse de cet algorithme de génération des nombres premiers avec
#+ celui de "Sieve of Eratosthenes" (ex68.sh).


#  Exercice: Réécrivez ce script sans récursion, pour une exécution plus rapide.

