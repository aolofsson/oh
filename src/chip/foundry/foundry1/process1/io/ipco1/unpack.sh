#!/bin/bash

#Script to unpack all views of all libs

#FOR ALL LIBS
cd proprietary
for dir in `ls -d * | grep -v tar.gz`
do
    cd $dir    
    for f in *.tar.gz; 
    do 
	echo "Unpack $f in directory $dir";
	tar -zxf $f; 
    done
    #FOR ALL VIEWS (GLORIOUS HACK!)
    for view in `ls -d Apollo* CDK GDS LEF | grep -v tar.gz`
    do
	cd $view
	#FOR ALL FILES
	for f in *.tar.gz; 
	do 
	    echo "Unpack $f in directory $dir";
	    tar -zxf $f; 
	done
	cd ../
    done
    cd ../
    #REMOVE TAR BALLS TO SAVE SPACE
    #find . -name "*.tar.gz" | xargs rm -f
done
cd ../
