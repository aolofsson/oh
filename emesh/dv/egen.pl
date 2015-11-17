#! /usr/bin/perl 
use Getopt::Long;
$Usage =<<EOF;
#######################################################
Usage: erand.pl -rand <random-mode>
                -n    <count>
                -mask <ID mask>
Description: Epiphany random transaction generator

#######################################################
#1.) Generates random writes(8,16,32,64)
#2.) Random burst sizes (1-16) 
#3.) Data and address is random (xxx0xxxxx)
#######################################################      
EOF
$result = GetOptions('rand:s',
		     'da:s',
		     'sa:s',
		     'd:s',
		     'c:s', 
		     'n:s'
    );

if ((!defined $opt_n)) {
    printf $Usage;
    exit;
}
$n=$opt_n;

$burst_max = 4;
$count =0;
$addrid  =hex("0x83000000"); #NOTE: should not be equal to RX ID
$returnid=hex("0x810D0000");
#RANDOM TRANSACTION GENERATOR
if(defined $opt_rand){

    #Writes
    for ($i=0;$i<$n;$i++){
	$ctrlmode = (int(rand(hex("0x7"))) + 1)  | 0x1;  #only writes
	$burst    = (int(rand($burst_max)) + 1);         #variable bursts

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
	$dstaddr  = $addrid + ((int(rand(hex("0xFFFFFFFF"))) + 0) & $addrmask); #filter "D/F group" and illegal alings

	for ($j=0;$j<$burst;$j++){ 
	    $dstaddr = $dstaddr+$incr;
	    $datalo     = (int(rand(hex("0xFFFFFFFF"))) + 0) & 0xFFFFFFFF;	
	    $datahi     = (int(rand(hex("0xFFFFFFFF"))) + 0) & 0xFFFFFFFF;		    
	    $transaction[$count]{dstaddr}   =$dstaddr;
	    $transaction[$count]{srcaddr}   =$datahi;
	    $transaction[$count]{data}      =$datalo;
	    $transaction[$count]{reslo}     =$datalo & $masklo;
	    $transaction[$count]{reshi}     =$datahi & $maskhi; 
	    $transaction[$count]{ctrlmode}  =$ctrlmode;
	    $transaction[$count]{returnaddr}=$returnid+((int(rand(hex("0xFFFFFFFF")))) & $addrmask);
	    $transaction[$count]{burst}     =$burst;
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
		printf("%08x_%08x_%08x_%02x_0000//WRITE (i=%d, burst=%d)\n",
		       $datahi,$datalo,$dstaddr,$ctrlmode, $i, $burst);
		$count=$count+1;
	    }	    	   	   
	    else{
		#printf("ADDR %08x in USE (CTRLMODE=%04x)\n",$dstaddr,$ctrlmode);
	    }
	}
    }
    #Reads/Expected results
    for ($i=0;$i<($#transaction+1);$i++){
	#Pushing read transactions
	printf("%08x_%08x_%08x_%02x_0000//READ\n",
	       $transaction[$i]{returnaddr},        #address to return to
	       hex("0xDEADBEEF"), 
	       $transaction[$i]{dstaddr},           
	       ($transaction[$i]{ctrlmode}&hex(0x6),#turn write into read
		$transaction[$i]{burst})
	    );	
	#Expected results
 	printf("%08x_%08x_%08x_%02x\n",
	       $transaction[$i]{reshi},
	       $transaction[$i]{reslo},
	       $transaction[$i]{returnaddr},
	       $transaction[$i]{ctrlmode}
	    );	
    }  
}

#############################################################################
#       Author:  Andreas Olofsson
#       Date:    Nov 11, 2015
##############################################################################
