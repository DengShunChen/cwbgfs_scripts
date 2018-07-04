#!/bin/ksh 
set -x
for file in *sh ;do 
  cp $file ${file}.bck
  sed  "s%setup_mpi+omp\.fx10%setup_mpi+omp%g" ${file}.bck > ${file}
done
exit
