#! /usr/bin/perl
use Getopt::Long;
use POSIX qw(ceil floor);
#######################################################
# Author:  Andreas Olofsson, Nov 11, 2015
#######################################################
$Usage =<<EOF;
#######################################################
Usage: egen.pl  -mode <random|memcpy>
                -n    <number-of-bytes>
                -bl   <max-burst-in-bytes>
#######################################################
Description: 
* Generates random Epiphany 104 bit packet transaction
* Data is completely random
* Data sizes are completely random
* Address fields are random (but legal)
* Random burst sizes up to <max-burst-length>
* Default return address base is 810D0000
* Default destination address base is 83000000
#################################################################
Example1: Generate a random test
    
egen.pl -mode random -n 1024 -bl 128

Example2:
    
egen.pl -mode memcpy -n 1024 -dstaddr 90000000 -srcaddr 80000000

################################################################
EOF
$result = GetOptions('mode:s',
		     'dstaddr:s', 
		     'srcaddr:s',
		     'd:s',
		     'c:s',  #ctrlmode 
		     'n:s',
		     'bl:s',
		     '32:s',
    );


if ((!defined $opt_n) | (!defined $opt_mode) ) {
    printf $Usage;
    exit;
}
$n=$opt_n;
$mode=$opt_mode;
#####################################################################
# OPTIONAL OPTIONS
#####################################################################

#MAX BURST
if(defined $opt_bl){
    $burst_max = $opt_bl;
}
else{
    $burst_max = 4;
}

#LIMIT TO 32 BITS
if(defined $opt_32){
    $ctrl_max = 5;
}
else{
    $ctrl_max = 7;
}
if(defined $did){
    $addrid = $opt_did;
}
else{
    $addrid  =hex("0x83000000"); #NOTE: should not be equal to RX ID
}
if(defined $sid){
    $returnid=$sid;
}
else{
    $returnid=hex("0x810D0000");
}
if(defined $opt_c){
    $cltrmode=$opt_c;
}
else{
    $ctrlmode = 5;	
}

$count =0;
$bytes=0;
#Writes
$dstaddr    = hex($opt_dstaddr);
$returnaddr = $returnid+ (hex($opt_srcaddr) & 0x000FFFFF);
while($bytes<$n){
    if($mode eq "random"){
	$ctrlmode = (int(rand(hex($ctrl_max))) + 1)  | 0x1;  #only writes
	$burst    = (int(rand($opt_bl)) + 1);         #variable bursts
    }
    else{

	$burst = $n;
    }
    #BYTES
    if($ctrlmode<2){
	$addrmask = hex("0x0000ffff");
	$maskhi   = hex("0x00000000");
	$masklo   = hex("0x000000FF");
	$incr     = 1;
    }
    #HALF-WORD
    elsif($ctrlmode<4){
	$addrmask = hex("0x0000fffe");
	$maskhi   = hex("0x00000000");
	$masklo   = hex("0x0000FFFF");
	$incr     = 2;
    }
    #WORD
    elsif($ctrlmode<6){
	$addrmask = hex("0x0000fffc");
	$maskhi   = hex("0x00000000");
	$masklo   = hex("0xFFFFFFFF");
	$incr     = 4;
    }
    #DOUBLE
    else{
	$addrmask = hex("0x0000fff8");
	$maskhi   = hex("0xFFFFFFFF");
	$masklo   = hex("0xFFFFFFFF");
	$incr     = 8;
    }
    $burst=floor($burst/$incr);

    #randomize destination address
    if($mode eq "random"){
	$dstaddr    = $addrid + ((int(rand(hex("0xFFFFFFFF"))) + 0) & $addrmask); #filter "D/F group" and illegal alings
	$returnaddr = $returnid+((int(rand(hex("0xFFFFFFFF")))) & $addrmask);
    }
    #create a burst of transactions
    for ($j=0;$j<$burst;$j++){ 
	$datalo     = (int(rand(hex("0xFFFFFFFF"))) + 0) & 0xFFFFFFFF;	
	$datahi     = (int(rand(hex("0xFFFFFFFF"))) + 0) & 0xFFFFFFFF;		    
	
	#make sure address wasn't used already
	$inuse=0;
	for($k=0;$k<$incr;$k++){	    
	    $addr=$dstaddr+$k;
	    #check if in use
	    if(exists ($usedaddr{$addr})){
		$inuse=1;
	    }
	    #set as used	       
	    $usedaddr{$addr}=1;
	}	   
	if($inuse == 0){
	    $transaction[$count]{dstaddr}   =$dstaddr;
	    $transaction[$count]{srcaddr}   =$datahi;
	    $transaction[$count]{data}      =$datalo;
	    $transaction[$count]{reslo}     =$datalo & $masklo;
	    $transaction[$count]{reshi}     =$datahi & $maskhi; 
	    $transaction[$count]{ctrlmode}  =$ctrlmode;
	    $transaction[$count]{returnaddr}=$returnaddr;
	    $transaction[$count]{burst}     =$burst;		
	    printf("%08x_%08x_%08x_%02x_0000//WRITE (i=%d, j=%d, bytes=%d)\n",
		   $datahi,$datalo,$dstaddr,$ctrlmode, $count, $j, $bytes);
	    $bytes      = $bytes+$incr;
	    $count      = $count+1;
	    $dstaddr    = $dstaddr+$incr;
	    $returnaddr = $returnaddr+$incr;
	}	    	   	   
	else{
	    #printf("ADDR %08x in USE (CTRLMODE=%04x)\n",$dstaddr,$ctrlmode);
	}
	#print "b=$bytes incr=$incr transaction-burst=$burst ctrl=$ctrlmode count=$count use=$inuse n=$n\n";
    }
}
#Reads/Expected results
for ($i=0;$i<($#transaction+1);$i++){
    #Pushing read transactions
    printf("%08x_%08x_%08x_%02x_0000//READ\n",
	   $transaction[$i]{returnaddr},       #address to return to
	   hex("0xDEADBEEF"), 
	   $transaction[$i]{dstaddr},           
	   $transaction[$i]{ctrlmode}&hex(0x6) #turn write into read
	);	
    #Expected results
    printf("%08x_%08x_%08x_%02x\n",
	   $transaction[$i]{reshi},
	   $transaction[$i]{reslo},
	   $transaction[$i]{returnaddr},
	   $transaction[$i]{ctrlmode}
	);	
}

