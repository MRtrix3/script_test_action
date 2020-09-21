#!/bin/bash
# Git commitish to be checkout out must be provided as first argument on the command-line
cmd="git clone -b $1 --depth 1 https://github.com/Lestropie/mrtrix3.git ."
echo $cmd; eval $cmd
#git clone -b $1 --depth 1 https://github.com/Lestropie/mrtrix3.git .
./configure -assert -nogui
./build
./run_tests scripts || ( cat testing_scripts.log && exit 1 )

