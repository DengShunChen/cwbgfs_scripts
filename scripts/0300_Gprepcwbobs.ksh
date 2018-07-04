#!/bin/ksh
if [ $# = 2 ]
then
  fnconf=$1
  dtg=$2
else
  exit -1
fi

cd ${LOGDIR}
cat > prcwb <<EOFprcwb
#PJM -L node=1
#PJM --no-stging
#PJM -j
set -x
. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fnconf}.set
echo "BEGIN ...."

cjob=prepcwbobs

if [ $MP = "P" -o $MP = "p" ]
then
  nckjob=1
  ckjoblst="ec "
  hh=\`echo $dtg | cut -c7-8\`
  if [ \$hh -eq 06 -o  \$hh -eq 18 ] 
  then
    nowt=\`date\`
    echo "\$nowt $dtg \${cjob} ok" >> ${STATUS}/\${cjob}.${dtg}.ok
    exit
  fi
else
  nckjob=1
  ckjoblst="ec"
fi
cjob=prepcwbobs

let nn=1
while [ \$nn -le \$nckjob ]
do
  pjob=\`echo \$ckjoblst | cut -d" " -f\$nn\`
  ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 100 6 $STATUS
  if [ \$? -eq 0 ]
  then
       nowt=\`date\`
       echo "\$nowt $dtg \${cjob} ok" >> ${STATUS}/\${cjob}.${dtg}.ok
  else
       nowt=\`date\`
       echo "\$nowt $dtg \${cjob} fail" >> ${STATUS}/\${cjob}.${dtg}.vail
       exit -1
  fi
  let nn=nn+1
done

export ECDMS=$ECDMS
cd ${NWPDTGGLB}
cp ${NWPDAT}/obs/prepobs_errtable.global errtable
rm -f ?obs20${dtg}.dat
rm -f fort.41 fort.42 fort.43 fort.44
rm -f usfgge smfgge shfgge
rm -f uvusdgs uvupdgs uvuadgs uvtsdgs uvuxdgs uvukdgs
rm -f tqusdgs tquxdgs tqukdgs
if [ $MP = m -o  $MP = M ]
then

## oiqc
  fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -6 \`
  export OIQC_MASIN=${MASOPS}
  export OIQC_MASOUT=${MASOPSOI}
  ${NWPBIN}/GG_preoiqc ${dtg} 0006
  if [ $? != 0 ]
  then
     echo "GG_preoiqc Fail"
      nowt=\`date\`
      echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
      exit -1
  fi
  cd ${NWPDTGGLB}
  echo $dtg > crdate
  export MASOPS=\${OIQC_MASOUT}
  ${NWPBIN}/GG_mvoi_noana
  if [ $? != 0 ]
  then
    echo "Goi execute Fail"
    nowt=\`date\`
    echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
    exit -1
  fi
  ${NWPBIN}/GG_qoi_noana
  if [ $? != 0 ]
  then
    echo "Gqoi execute Fail"
    nowt=\`date\`
    echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
    exit -1
  fi
## dropsonde qc
  if [ -s ${NWPOIGLB}/guxf${dtg}.dat ]
  then
    export MASOPS=\${OIQC_MASOUT}
    ${NWPBIN}/GG_mvoi_drps_noana
    if [ $? != 0 ]
    then
      echo "`date`:GG_mvoi_drps_noana ${dtg} Fail" >> ${LOGDIR}/warning.log
      nowt=\`date\`
      echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
      exit -1
    fi
    ${NWPBIN}/GG_qoi_drps_noana
    if [ $? != 0 ]
    then
      echo "`date`:GG_qoi_drps_noana ${dtg} Fail" >> ${LOGDIR}/warning.log
      nowt=\`date\`
      echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
      exit -1
    fi
  fi

## prepcwbobs
  cp ${NWPDAT}/obs/prep_cwbobs_major.input prep_cwbobs.input
  cp ${NWPOIDGS}/gusf${dtg}.dat usfgge
  cp ${NWPOIDGS}/gsmf${dtg}.dat smfgge
  cp ${NWPOIDGS}/gshf${dtg}.dat shfgge
  cp ${NWPOIDGS}/gusf${dtg}.dgs uvusdgs
  cp ${NWPOIDGS}/gupf${dtg}.dgs uvupdgs
  cp ${NWPOIDGS}/guaf${dtg}.dgs uvuadgs
  cp ${NWPOIDGS}/gtsf${dtg}.dgs uvtsdgs
  cp ${NWPOIDGS}/gusf_q${dtg}.dgs tqusdgs
  [[ -s ${NWPOIDGS}/guxf${dtg}.dgs ]]   && cp ${NWPOIDGS}/guxf${dtg}.dgs uvuxdgs
  [[ -s ${NWPOIDGS}/guxf_q${dtg}.dgs ]] && cp ${NWPOIDGS}/guxf_q${dtg}.dgs tquxdgs
  [[ -s ${NWPOIDGS}/gukf${dtg}.dgs ]]   && cp ${NWPOIDGS}/gukf${dtg}.dgs uvukdgs
  [[ -s ${NWPOIDGS}/gukf_q${dtg}.dgs ]] && cp ${NWPOIDGS}/gukf_q${dtg}.dgs tqukdgs 
  ttt="024"
else
  cp ${NWPDAT}/obs/prep_cwbobs_post.input prep_cwbobs.input
  ttt="000"
fi

${NWPBIN}/GG_prep_cwbobs 20${dtg} \${ttt}
if [ \$? -ne 0 ] ; then
   nowt=\`date\`
   echo "\$nowt $dtg \${cjob} fail" >> ${STATUS}/\${cjob}.${dtg}.fail
   exit
fi

[[ -s fort.41 ]] && cat fort.41 >> pobs20${dtg}.dat
[[ -s fort.42 ]] && cat fort.42 >> tobs20${dtg}.dat
[[ -s fort.43 ]] && cat fort.43 >> wobs20${dtg}.dat
[[ -s fort.44 ]] && cat fort.44 >> qobs20${dtg}.dat

 nowt=\`date\`
 echo "\$nowt $dtg \${cjob} ok" >> ${STATUS}/\${cjob}.${dtg}.ok

exit 0
EOFprcwb
exit
