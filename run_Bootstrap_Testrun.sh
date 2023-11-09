#!/bin/bash

set -evxf
logname='out_g20km_BootstrapTest.txt'
./Bootstrap_Testrun.sh &> /mnt/data/syhsv/Data/PISMOut/Spinups/MACLU_Test/${logname} &

exit
