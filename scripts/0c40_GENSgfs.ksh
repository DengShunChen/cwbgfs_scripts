#!/bin/ksh
if [ $# -eq 3 ]
then
  fnconf=$1
  dtg=$2
  mem=$3
else
  echo 'usage : GENgfs.ksh fnconf dtg  mem'
  exit -1
fi

cmem3=`printf %03i ${mem}`

cd ${LOGDIR}
cat > jensfc_${mem} << EOF
#!/bin/ksh
#PJM -L "node=${fnode_enkf}:noncont"
#PJM --mpi "proc=${fmpi_enkf}"
#PJM -L "elapse=2:30:00"
#PJM -L rscgrp=large-x
#PJM --no-stging
#PJM --mpi "rank-map-bynode"
#PJM -L node-mem=unlimited
#PJM -j 

set -x
. ${NWPBINS}/${fnconf}.set

if [ $optens_fcst -eq 0  ] ; then 
  echo "optens_fcst=$optens_fcst, do not run." ; exit
fi

#--- get sst and snowice
${NWPBINS}/0c41_GENSsst.ksh $fnconf $dtg $cmem3
${NWPBINS}/0c42_GENSsnowice.ksh $fnconf $dtg $cmem3

#-- reformat data to dms
export BCKOPS=${BCKENS}
export MASOPS=MASOPS_mem${cmem3}@${DB_NAME}
export optrun="ENS" ; optsub=0

${NWPBINS}/0a00_Gncep2gm.ksh ${fnconf} ${dtg} \${optrun} \${optsub} $mem
${LOGDIR}/j2gm_${mem}

if [ \$? != 0 ] ; then
  echo "0a00_GENSgfs.ksh : error occured: ${mem}, 0a00_Gncep2gm.ksh fail !!"
  echo "0a00_GENSgfs.ksh : error occured: ${mem}, 0a00_Gncep2gm.ksh fail !!" >> ${STATUS}/ENS_gfs.${dtg}.fail
  exit 2
fi

#-- Set mpi omp
export MPI=${fmpi_enkf}
export OMP=${fomp_enkf}
. ${NWPBINS}/setup_mpi+omp \$OMP

export DMSFLAG=${ensflag}
export GFSWRK=${GFSDIR}_${cmem3}
export LON=${LONB_ENKF}
export RUN_MODE='ENS'

. ${NWPBINS}/global_fcst.ksh $dtg

if [ \$? != 0 ] ; then
  echo "GENSgfs.ksh: error occured: ens_fct_${cmem3}  model fail !!"
  echo "GENSgfs.ksh: error occured: ens_fct_${cmem3}  model fail !!"  >> ${STATUS}/ens_fcst.${dtg}.fail
  exit 2
else
  echo "GENSgfs.ksh: ens_fct_${cmem3}  model ok !!"
  echo "GENSgfs.ksh: ens_fct_${cmem3}  model ok !!"  >> ${STATUS}/ens_fcst.${dtg}.ok
  cp \${GFSWRK}/trk${dtg}.dat ${NWPTRK}/trk${dtg}_mem${cmem3}.dat 
  sleep 10
fi
exit

EOF

