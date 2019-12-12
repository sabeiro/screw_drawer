#!/bin/bash
for i in de;
  do
  for j in Verboj;
	do
	echo "use Lingvo; select ("$i") from Verboj;" | mysql |  awk -f Lingvo.awk > $j/$j.$i.tex ;
	done ;
done;

