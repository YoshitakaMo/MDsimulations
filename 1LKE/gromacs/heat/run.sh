#!/bin/sh
#PBS -q h-small
#PBS -l select=1:mpiprocs=6:ompthreads=6
#PBS -W group_list=gg67
#PBS -l walltime=04:00:00

test $PBS_O_WORKDIR && cd $PBS_O_WORKDIR

input="1lke"
prev_tpr="../minimize/min2.gro"
prev_cpt="../minimize/min2.trr"
for (( i=1;i<10; i++));do
  rm -f md$i.out.mdp md$i.tpr
  gmx grompp \
    -f md$i.mdp \
    -c $prev_tpr \
    -r $prev_tpr \
    -p ../../top/${input}.top \
    -t $prev_cpt \
    -o md$i.tpr \
    -n ../../top/index.ndx \
    -po md$i.out.mdp || exit $?
  rm -f md$i.trr md$i.cpt md$i.gro md$i.edr md$i.log
  gmx mdrun -v \
    -s md$i.tpr \
    -o md$i.trr \
    -cpo md$i.cpt \
    -c md$i.gro \
    -e md$i.edr \
    -g md$i.log
  prev_tpr="md$i.tpr"
  prev_cpt="md$i.cpt"
done

rm md[1-9].trr
