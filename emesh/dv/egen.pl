#! /usr/bin/perl
use Getopt::Long;
$Usage =<<EOF;
#######################################################
Usage: egen.pl -da <dstaddr>
               -sa <srcaddr>
               -d  <data>
               -c  <ctrlmode>
               -n  <numoftrans>

Description: Generates a list of emesh packets
#######################################################
      
EOF
$result = GetOptions('da:s','sa:s','d:s','c:s', 'n:s' );
 
if (
    (!defined $opt_c)) 
{
    printf $Usage;
    exit;
}

$dstaddr=hex($opt_da);
$srcaddr=hex($opt_sa);
$data=hex($opt_d);
$ctrlmode=$opt_c;
$n=$opt_n;

if($ctrlmode%2){
    $op="write";
}
else{
    $op="read";
}

if($ctrlmode < 2){
    $incr=1;
    $size=byte;
    
}
elsif($ctrlmode < 4){
    $incr=2;
    $size=halword;
}
elsif($ctrlmode < 6){
    $incr=4;
    $size=word;
}
elsif($ctrlmode < 8){
    $incr=8;
    $size=double;
}

for($i=0;$i<$n;$i++){    
    printf("%08x_%08x_%08x_%02x_0000 // $op $size \n", $srcaddr,
	   $dstaddr,
	   $data,
	   $ctrlmode,
	   $op,
	   $size);
    $srcaddr=$srcaddr+$incr;
    $dstaddr=$dstaddr+$incr;
    $data   =$data+$incr;
}



#############################################################################
#       Author:  Andreas Olofsson
#       Date:    Nov 11, 2015
##############################################################################
