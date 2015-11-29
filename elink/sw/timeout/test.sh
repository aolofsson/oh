#!/bin/bash



SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")


$EXEPATH/bin/e-main.elf $EXEPATH/bin/e-task.srec > e-main.log

retval=$?

if [ $retval -ne 0 ]
then
    echo "$SCRIPT FAILED"
else
    echo "$SCRIPT PASSED"
fi

exit $retval

