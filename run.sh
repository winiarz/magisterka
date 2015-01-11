#!/bin/bash

i=0
while [ $i -lt 100 ]
do
  ./nbodyProject --print_time_only > "results/2_13_$i.txt"
	i=$(( $i + 1 ))
done
