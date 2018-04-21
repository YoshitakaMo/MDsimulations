#!/bin/sh

input="../../top/1lke"

rm -f min1.out.mdp min1.tpr
gmx grompp \
  -f min1.mdp \
  -po min1.out.mdp \
  -c ${input}.gro \
  -r ${input}.gro \
  -p ${input}.top \
  -o min1.tpr || exit 1
rm -f min1.log min1.gro min1.trr min1.edr
gmx mdrun -v \
  -s min1.tpr \
  -o min1.trr \
  -c min1.gro \
  -e min1.edr \
  -g min1.log || exit 1
rm -f min2.out.mdp min2.tpr
gmx grompp \
  -f min2.mdp \
  -po min2.out.mdp \
  -c min1.gro \
  -r ${input}.gro \
  -p ${input}.top \
  -o min2.tpr || exit 1
rm -f min2.log min2.gro min2.trr min2.edr
gmx mdrun -v \
  -s min2.tpr \
  -o min2.trr \
  -c min2.gro \
  -e min2.edr \
  -g min2.log

