#!/bin/ksh 
if [ $# -eq 2 ] ; then
  fnconf=$1
  dtg=$2
else
  echo "usage :  GENSenkf.ksh fnconf dtg"
  exit -1
fi

cd $LOGDIR
cat > jenkf << EOFenkf
#!/bin/ksh
#PJM -L "node=${enode}:noncont"
#PJM --mpi "proc=${empi}"
#PJM -L "elapse=1:30:00"
#PJM -L rscgrp=large-x
#PJM -L node-mem=unlimited
#PJM -j 

set -x
. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi+omp $eomp

MPI=${empi}
#-------------------------------------------------------------------------------
# run option
#-------------------------------------------------------------------------------
if [ $opt_enkf -eq 0 ] ; then
  echo "opt_enkf=${opt_enkf}, exit"
  echo "opt_enkf=${opt_enkf}, exit" > ${STATUS}/enkf.${dtg}.ok
  exit
fi

#-------------------------------------------------------------------------------
# check wait
#-------------------------------------------------------------------------------
 pjob=innov
 cjob=enkf
 ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 800 5 $STATUS

#-------------------------------------------------------------------------------
# enkf
#-------------------------------------------------------------------------------
 cd ${NWPWRKENS}

 export dtg=${dtg:-}
 export dtg10=20${dtg}
 export fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -6 \`
 export fgdtg10=20\${fgdtg}


# run enkf 
. ${NWPBINS}/global_enkf.ksh 

echo "ENKF: success: GENSenkf.ksh ok !!" > ${STATUS}/enkf.${dtg}.ok

EOFenkf

exit
