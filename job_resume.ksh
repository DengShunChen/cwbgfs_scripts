#!/bin/bash
#######################################################
#                                                     #
#  Purpose : job resuming for GFS scripts             #
#                                                     #
#  Created by Deng-Shun Chen                          #
#  Date : 2018-06-28                                  #
#######################################################

# must make sure this is correct. 
export exp_home='/nwpr/gfs/xb80/data2/CWBGFS'

# experiments list
. ~/etc/explist
export caselist=${caselist:-'h3d10obs h4dctl h3dtlm h3dTco h3dsdb'}

#------ working area ------------
for icase in ${caselist} ; do
  lines=`/nwpr/gfs/xb80/bin/job fx100 | grep ${icase} | wc -l `
  if [ $lines -gt 0 ] ; then
    dtg=`cat ${exp_home}/exp_${icase}/dtg/crdate`
    echo "${dtg} ${icase} exist !"
  else
    dtg=`cat ${exp_home}/exp_${icase}/dtg/crdate`
    echo "${dtg} ${icase} NOT exist ! resume? [y/n]"
    read -p '  n(N) : No ; y(Y): Yes ' yorn 
    if [ $yorn = 'Y' -o $yorn = 'y' ] ; then
      echo dtg=${dtg}
      sed -i 's/the initial dtg for this exp        =\(.*\)/the initial dtg for this exp        ='${dtg}'/g' ${exp_home}/exp_${icase}/bins/0100_gdas.input.${icase}      
      cd ${exp_home}/exp_${icase}/bins
      nohup ./0100_gdas.ksh 0100_gdas.input.${icase} & 
    fi
  fi
done

