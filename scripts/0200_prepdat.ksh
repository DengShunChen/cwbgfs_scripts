#!/bin/ksh 
if [ $# -eq 5 ]
then
  fnconf=$1
  dtg=$2
  gttau=$3
  optobs=$4
  optsub=$5
else
  echo "usage : prepdat.ksh fnconf dtg gettau  optobs optsub"
  exit
fi

set -x

echo 'gttau='$gttau
general_dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} ${gttau}`

cd $LOGDIR
cat > pdt << EOFpdt
#PJM -L node=1
#PJM -L "elapse=4:00:00"
#PJM --no-stging
#PJM -j

. ${NWPBINS}/setup_mpi.fx100
. ${NWPBINS}/${fnconf}.set
set -x
echo "BEGIN ...."

general_dtg=${general_dtg}

if [ $opt_prepdat -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg sst W00100 ok" > ${STATUS}/sst.${general_dtg}.ok
  echo "\$nowt $dtg snowice SNOWICE OK" >> ${STATUS}/snowice.${general_dtg}.ok
  echo "\$nowt $dtg ec ok" > ${STATUS}/ec.${general_dtg}.ok
  echo "\$nowt $dtg oz ok" > ${STATUS}/oz.${general_dtg}.ok
  echo "\$nowt $dtg obsbufr ok" > ${STATUS}/obsbufr.${general_dtg}.ok
  echo "\$nowt $dtg obsoi ready,optobs=0," > ${STATUS}/obsoi.${general_dtg}.ok
  exit
fi

# create working dmsfile
if [ ! -s ${DB_PATH}/${DB_NAME}.ufs/MASOPS ] ; then
  ${DMSPATH}/rdmscrt -l34 MASOPS
fi

cd ${NWPDTGGLB}

#------
# getcwbdata
#------
. ${NWPBINS}/global_getdata.ksh

#------
# for finishing ${PJSUB} step job 
#------
sleep 30

exit
EOFpdt

if [ $optsub -eq 1 ] ; then
  echo "dtg=$general_dtg"
  ssh ${LGIN} -n "${PJSUB}  -o ${LOGDIR}/0200_prepdat_next.${general_dtg} ${LOGDIR}/pdt"
fi

exit 0
