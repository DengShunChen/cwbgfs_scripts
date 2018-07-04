#!/bin/ksh
################################################################################
#  This script was made for testing GSI.                          
# 
#  Created by Deng-Sun Chen 
#  Date : 2017-03-14
###############################################################################
#Hardware settings
  MACHINE='fx10'
  NODES=66
  MPI=192
  OMP=4

#GSI executable
  GSIexe=/nwpr/gfs/xb80/data/exp/EXP-4denv-sdbeta/exe/global_gsi_${MACHINE}
# GSIexe=/nwpr/gfs/xb80/data2/emc_svn/gsi/trunk/src/global_gsi_${MACHINE}

#Resource group
  if [[ ${MACHINE} = 'fx100' ]] ; then
    RSCGRP='large-x'
  elif  [[ ${MACHINE} = 'fx10' ]] ; then
    RSCGRP='research'
  fi 

  LOCAL=`pwd`


#Create run script
  Run_Script_Name="Test_GSI_${NODES}"
  Run_Script=${LOCAL}/${Run_Script_Name}

cat > ${Run_Script} <<EOF
#!/bin/ksh
#PJM -L node=${NODES}:noncont
#PJM -L rscgrp=${RSCGRP}
#PJM -L elapse=3:00:00
#PJM -L node-mem=unlimited
#PJM --mpi "proc=${MPI}"
#PJM --no-stging
#PJM -j

 . /nwpr/gfs/xb80/etc/setup_mpi+omp.${MACHINE} ${OMP}

 set -x
 
 rm -rf dir.*
 rm -rf fort.*
#rm -rf obs_input.*

 /usr/bin/time -p mpiexec -n ${MPI} -of stdout -stdin gsiparm.anl ${GSIexe}

 if [[ \$? = 0 ]] ; then
   echo "GSI normal stop !!"
 else
   echo "GSI failed !! stop " ; exit
 fi 

EOF
 
#Submit job
cd ${LOCAL}
pjsub ${Run_Script}

