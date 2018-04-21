#!/usr/bin/perl -w

use strict;
use warnings;

my $fx=4.184;	# in kJ nm^-2
my $fy=4.184;
my $fz=4.184;
my @sca=(1000,500,200,100,50,20,10,0);	# 1000 -> 10 kcal A^-2
#my @sca=(10000);	# 1000 -> 10 kcal A^-2

foreach my $s (@sca) {
  open(IN,"$ARGV[0]");
  open(OUT,">posre$s.itp");
  printf(OUT "[ position_restraints ]\n");
  printf(OUT "; atom  type      fx      fy      fz\n");

  my $title=<IN>;
  my $natom=<IN>;
  chomp($natom);
  for(my $i=0;$i<$natom;$i++) {
    $_=<IN>;
    my @data;
    $data[0]=substr($_,0,5);  # residue number (5 positions, integer)
    $data[1]=substr($_,5,5);  # residue name (5 characters)
    $data[2]=substr($_,10,5); # atom name (5 characters)
    $data[3]=substr($_,15,5); # atom number (5 positions, integer)
    for (my $j=0;$j<3;$j++) {
      $data[$j]=trim($data[$j]);
    }
    my $resnum=$data[0];
    my $resnam=$data[1];
    if($resnam ne "Na+" && $resnam ne "Cl-" && $resnam ne "WAT") {
      if($data[2] =~ /^[^H]/) {
        printf(OUT "%6d%6d%6d%6d%6d\n",$data[3],1,$fx*$s,$fy*$s,$fz*$s);
      }
    }
  }
}
close(IN);
close(OUT);

sub trim {
  my $val = shift;
  $val =~ s/^ *(.*?) *$/$1/;
  return $val;
}
