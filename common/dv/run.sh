#!/bin/bash

rm test_0.emf
ln -s $2 test_0.emf
./$1 
