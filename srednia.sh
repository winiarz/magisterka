#!/bin/bash


sumy=(0 0 0 0 0 0 0 0 0);

for file in $@;
do
	i=0
	while read line;
	do
		#echo $line
		sumy[$i]=$(( ${sumy[$i]} + $line))
		i=$(($i+1))
	done < $file
done

i=0
while [ "$i" -lt "9" ];
do
	sumy[$i]=$(( ${sumy[$i]} / $# ))
	echo ${sumy[$i]}
	i=$(($i+1))
done
