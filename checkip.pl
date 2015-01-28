#!/bin/perl

# Quickie script to scan through all my IP directories and look for any 
#  where the Verilog is newer than the component file.

print "\nScanning current dir...\n\n";

my @dirlist = glob("*/");
my @updatelist;
my $compcount = 0;

foreach my $dir (@dirlist) {
  my $uptodate=1;

  print "  $dir", " " x (25 - length($dir));

  unless(-e "${dir}component.xml") {
    print "No component found\n";
    next;
  }

  $compcount++;

  my @srclist = glob("${dir}*/*.v");  # Note: only looks 1 dir in

  unless($#srclist > -1) {
    print "No source files found\n";
    next;
  }

  my $ver = "?";
  my $rev = "?";
  my $gotname = 0;
  if(open my $FILE, "<", "${dir}component.xml") {
    while(my $line = <$FILE>) {
      if(!$gotname and $line =~ /spirit:name/) {
        $gotname = 1;
      } elsif($gotname and $ver eq "?" and $line =~ /version>(.*?)</i) {
        $ver = $1;
      } elsif($line =~ /corerevision>(.*?)</i) {
        $rev = $1;
      }
    }
    close $FILE;
  }

  my $comptime = (-M "${dir}component.xml");
  printf "Comp v$ver/rev$rev, age: %dD %d:%02d\n", int($comptime), int($comptime * 24) % 24,
    int($comptime * 24 * 60) % 60;

  foreach my $file (@srclist) {

    if((-M $file) < $comptime) {
      $uptodate = 0;
      print "    $file newer\n";
    } else {
      print "    $file OK\n";
    }
  }

  unless($uptodate) {
    push @updatelist, "$dir v$ver/rev$rev";
  }

  print "\n";
}

if(!$compcount) {

  printf "\nNo components found, are we in the right directory?\n\n";

} elsif(@updatelist) {

  print "\nPlease update:\n  ", join("\n  ", @updatelist);
  print "\n\n";

} else {

  print "\nCongratulations, all $compcount components are up to date.\n\n";

}

print "Done!\n";
