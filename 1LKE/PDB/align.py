#!/usr/bin/env python
# -*- coding: utf-8 -*-

from modeller import *
from modeller.automodel import *    # Load the automodel class

class MyModel(loopmodel):
    def special_patches(self, aln):
        self.patch(residue_type='DISU', residues=(self.residues['4'],
                                                  self.residues['111']))
        self.patch(residue_type='DISU', residues=(self.residues['38'],
                                                  self.residues['166']))

log.verbose()
env = environ()
env.io.hetatm = True
env.io.water = True

# directories for input atom files
env.io.atom_files_directory = ['.', '1LKE.pdb']

a = MyModel(env, alnfile = 'alignment.ali',knowns = '1LKE', sequence = '1LKE_fill')
a.starting_model= 1
a.ending_model  = 1

a.loop.starting_model = 1
a.loop.ending_model   = 5
a.loop.md_level       = refine.fast

a.make()
