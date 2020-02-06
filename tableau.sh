#Pour declarer un tableau
tab=("John Smith" "Jane Doe")

#ou bien
tab[0]='John Smith'
tab[1]='Jane Doe'

#Pour compter le nombre d'éléments du tableau :
len=${#tab[*]} 
echo "taille du tableau = $len"

#Pour afficher un élément :
echo ${tab[1]}

#Pour afficher tous les éléments :
echo ${tab[*]}

#Ou bien
for i in ${!tab[*]}; do echo ${tab[i]}; done

#ou encore ( C style )
for (( i=0; i < ${#tab[*]}; i++ )); do echo ${tab[i]}; done