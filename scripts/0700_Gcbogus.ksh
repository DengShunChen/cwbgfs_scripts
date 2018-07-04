#!/bin/ksh
if [ $# = 4 ] ; then
  fnconf=$1
  dtg=$2
  optbogus=$3
  optsub=$4
else
  echo "usage : Gcbogus.ksh fnconf dtg"
  exit -1
fi

cat > bg <<EOFbg
#PJM -L node=8:noncont
#PJM -L elapse=00:30:00
#PJM -L node-mem=unlimited
#PJM --no-stging
#PJM --mpi "proc=32"
#PJM -j
. ${NWPBINS}/${fnconf}.set
MPI=32
OMP=4
. ${NWPBINS}/setup_mpi+omp  \${OMP}

set -x
export FLIB_CNTL_BARRIER_ERR=FALSE

if [ $opt_cbogus -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg bogus ok, no typn" >> ${STATUS}/bogus.${dtg}.ok
  exit
fi

export GDMSPATH=$DMSPATH

dtg10=20${dtg}
yyyy=20\`echo ${dtg} | cut -c1-2\`
fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -6 \`

if [ ! -s ${NWPOIGLB}/typhoon${dtg}.dat ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg bogus ok, no typn" >> ${STATUS}/bogus.${dtg}.ok
  exit
fi
  
export BCKOPS=${BCKOPS}
export RELOCATE=${RELOCATE}
export BGSOUT=${BGSOUT}
\${GDMSPATH}/rdmscrt -l 34  \${BGSOUT}
cd ${GFSDIR}
cp ${NWPOIGLB}/typhoon${dtg}.dat .
cp ${NWPDAT}/obs/errtable .
_stdout=bogus

mpiexec -n \${MPI} \${LPG} ${BOGexe}
if [ $? != 0 ] ; then
  echo "${BOGexe} Fail"
  \$GDMSPATH/rdmspurge -f   BGSOUT
  nowt=\`date\`
  echo "\$nowt $dtg bogus fail" >> ${STATUS}/bogus.${dtg}.fail
  exit 0
else
  cat idtgmaxobs.dat.bgs > tobs\${dtg10}.dat.bgs
  cat tobs.dat.bgs  >> tobs\${dtg10}.dat.bgs
  cat idtgmaxobs.dat.bgs > wobs\${dtg10}.dat.bgs
  cat wobs.dat.bgs  >> wobs\${dtg10}.dat.bgs
  cat idtgmaxobsp.dat.bgs > pobs\${dtg10}.dat.bgs
  cat pobs.dat.bgs  >> pobs\${dtg10}.dat.bgs
  cat idtgmaxobs.dat.bgs > qobs\${dtg10}.dat.bgs
  cat tobs.dat.bgs  >> qobs\${dtg10}.dat.bgs
  mv *.bgs ${NWPDTGGLB}
#  \$GDMSPATH/rdmspurge -f 34  BGSOUT
  rm -f ?obs.dat.bgs
  rm -f BOGUSOBS.DAT
  nowt=\`date\`
  echo "\$nowt $dtg bogus OK" >> ${STATUS}/bogus.${dtg}.ok
fi

exit 0
EOFbg
if [ $optsub -eq 1 ] ; then
  ${PJSUB} bg
fi
exit
