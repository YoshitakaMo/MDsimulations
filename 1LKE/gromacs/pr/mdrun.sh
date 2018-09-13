#!/bin/sh

input=1lke

# if md${input}.tpr doesn't exist, grompp will make the md${input} tpr file.
if [ ! -e md${input}.tpr ];then
    gmx grompp \
        -f mdrunset.mdp \
        -c ../heat/md9.tpr \
        -t ../heat/md9.cpt \
        -p ../../top2/${input}.top \
        -n ../../top2/index.ndx \
        -o md${input}.tpr \
        -po md${input}.mdp
fi

# gmx mdrun
gmx mdrun \
 -v -s md${input} -deffnm ${input} -cpi ${input}.cpt
