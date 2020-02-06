#!bin/bash

echo "Saisir une valeur" 
read value 
result=1 
for (( i=0 ; i<$value ; i++ )); do 
    let result=$result*$value 
    echo "$value^$value = $result"
done 
echo "$value^$value = $result"