#!/bin/ksh

date=$1

mv satbias_ang.20${date}  satbias_ang.20${date}.orig
mv satbias.20${date}      satbias.20${date}.orig
ln -fs satbias_ang.20${date}.orig   satbias_angle
ln -fs satbias.20${date}.orig       satbias_in
./write_biascr_option.x -newpc4pred -adp_anglebc 4
mv satbias_angle.new  satbias_ang.20${date}
mv satbias_in.new     satbias.20${date}
mv satbias_pc         satbias_pc.20${date}

