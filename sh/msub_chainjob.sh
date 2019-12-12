#!/bin/bash
#
# Submit a chain job.
# Original taken from: http://www.fz-juelich.de/jsc/juropa/usage/quick-intro
#
# Syntax: chainjob.sh [iterations] [name] [jobscript.sh]
#
NO_OF_JOBS="$1" # num of jobs to submit
NAME="$2" # define jobname

SCRIPT="$3" # script
if [ ! -f $SCRIPT ]
then
	echo "the file $SCRIPT does not exist."
	exit 1
fi	

i=0
# make a distinct jobname
J_NAME=$NAME"_"$i
#submit the start job
echo "msub -N $J_NAME $SCRIPT"
msub -N $J_NAME $SCRIPT
while [ $i -le $NO_OF_JOBS ]; do
   J_PREV=$J_NAME
   let i=i+1
   J_NAME=$NAME"_"$i
# submit the next jobs with dependency defined
   echo "msub -N $J_NAME -W x=depend:afterok:$J_PREV $SCRIPT"
   msub -N $J_NAME -W x=depend:afterok:$J_PREV $SCRIPT
done 
