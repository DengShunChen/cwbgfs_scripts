#!/bin/ksh 
if [ $# -eq 4 ] ; then
  fnconf=$1
  dtg=$2
  opt_fcst=$3
  optsub=$4
  export fnconf dtg opt_fcst optsub
else
  echo 'usage : fcst.ksh fnconf dtg opt_fcst optsub'
  exit -1
fi

cd $LOGDIR

cat > jfc <<EOF
#!/bin/ksh
#PJM -L "node=$fnode_main:noncont"
#PJM --mpi "proc=$fmpi_main"
#PJM -L elapse=4:00:00
#PJM -L node-mem=unlimited
#PJM -L rscgrp=large-x
#PJM --mpi "rank-map-bynode"
#PJM -j
#PJM --no-stging

#-- Enviornmental Settings 
 . ${NWPBINS}/${fnconf}.set
 set -x

#-- check igonoring this proccess or not.
 if [ $opt_gfs -ne 1 ]  ; then
    echo "opt_gfs=$opt_gfs, exit"
    nowt=\`date\`
    echo "\$nowt ${dtg} fcst ok" >> ${STATUS}/fcst.${dtg}.ok
    exit
 fi

#-- Check wait
 nckjob=3
 ckjoblst="sst snowice ncep2gm"
 cjob=fcst
 typeset -i nn
 nn=1
 while [ \$nn -le \$nckjob ] ; do
   pjob=\`echo \$ckjoblst | cut -d" " -f\$nn\`
   ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob  200 5 $STATUS

   if [ \$? -ne 0 ] ;then
     nowt=\`date\`
     echo "\$nowt $dtg \$cjob fail,since \$pjob fail!!" > ${STATUS}/\${cjob}.${dtg}.fail
     exit -1
   fi
   nn=nn+1
 done

#-- Set mpi omp
 MPI=${fmpi_main}
 OMP=${fomp_main}
 . ${NWPBINS}/setup_mpi+omp \${OMP}

export DMSFLAG=${gfsflag}
export GFSWRK=${GFSDIR}
export LON=${LONB}
export RUN_MODE='MAIN'

 . ${NWPBINS}/global_fcst.ksh ${dtg}

#-- Check status
 if [ \$? != 0 ]  ; then
   echo "error occured: fct model fail !!"
   echo "\$nowt $dtg fcst fail" >> ${STATUS}/fcst.${dtg}.fail
   exit -1
 else
   echo "fct model OK !!"
   nowt=\`date\`
   echo "\$nowt $dtg fcst ok" >> ${STATUS}/fcst.${dtg}.ok
   cp \${GFSWRK}/trk${dtg}.dat ${NWPTRK}/trk${dtg}.dat
   exit 0
 fi

 exit

EOF

if [ $optsub -eq 1 ] ; then
  ssh ${LGIN} ${PJSUB} ${LOGDIR}/jfc
fi
exit
