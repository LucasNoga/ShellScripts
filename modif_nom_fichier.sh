#!/bin/bash

echo "vous etes dans le repertoire $(pwd)";
let numpage=1;

for i in *
do
	mv $i "page$numpage.png";
	let numpage++;
	#check si cest le bon ordre est donc rename en page1, page 2 etc
done

echo $numpage;