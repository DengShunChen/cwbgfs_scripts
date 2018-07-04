#!/bin/ksh 
if [ $# -eq 3 ]
then
  fnconf=$1
  dtg=$2
  optsub=$3
else
  echo 'usage : fcst.ksh fnconf dtg  optsub'
  exit -1
fi

cd $LOGDIR
cat > jens <<EOFens
#!/bin/ksh
#PJM -L "node=1"
#PJM -L elapse=24:00:00
#PJM -L node-mem=unlimited
#####PJM --mpi "rank-map-bychip"   ! for performance consideration, no need for gfs
#PJM -j
#PJM --no-stging
set -x
. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi
echo "BEGIN ...."

if [ $opt_ens -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg innov ok" >> ${STATUS}/innov.${dtg}.ok
  echo "\$nowt $dtg enkf ok" >> ${STATUS}/enkf.${dtg}.ok
  exit
fi

# check wait
nckjob=3
ckjoblst="g3dv_MAIN fguess_ENS sfcges_ENS"
cjob=ens
nn=1
while [  \$nn -le \$nckjob ] ; do
  pjob=\`echo \$ckjoblst | cut -d" " -f\$nn\`
  ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob  800 5 $STATUS
  if [ \$? -ne 0 ] ; then
      nowt=\`date\`
      echo "\$nowt $dtg \$cjob fail,since \$pjob fail!!" > ${STATUS}/\${cjob}.${dtg}.fail
      exit -1
  fi
  ((nn=\$nn+1))
done


cd ${LOGDIR}
optrun="ENS"
optsub=0
#-------------------------------------------------------------------------------
#   select_obs for ensmean 
#-------------------------------------------------------------------------------
# for generating GSI namelist (gsiparm.anl)
export lrun_select_obs=.true.
export lrun_innovate=.true.

export SELECT_OBS_TARBALL=YES
export DIAG_COMPRESS=NO
export DIAG_TARBALL=YES

nmem=0
${NWPBINS}/0800_Gana.ksh ${fnconf} $dtg  \$optrun \$optsub \${nmem}
ssh ${LGIN} ${PJSUB} -L rscgrp=large-x -N ${EXP_NAME}_inno_ensmean -o ${LOGDIR}/0c00_0800_innov_ensmean.${dtg} ${LOGDIR}/j3dv_\${nmem}

#-------------------------------------------------------------------------------
#   check ensmean innovation status
#-------------------------------------------------------------------------------
dtg10=20${dtg}
delt=5
tott=6000

tt=1
success_innov=0
while [ \$tt -le \$tott ] ; do
  sleep  \${delt}
  njob=\`ssh ${LGIN} -n "pjstat -S" | grep "${DMSFN}_inno_ensmean" | wc -l \`
  if [ \$njob -eq 0 ] ; then
    ((tt=tt+\${tott}))
    sleep \${delt}
    success_innov=1
    if [ -s ${STATUS}/g3dv_ENS.${dtg}.fail ] ; then
      success_innov=0
    fi
  fi
done

if [ \${success_innov} -eq 1 ] ; then
    echo innov_ensmean.${dtg} success !!  >> ${STATUS}/g3dv_ENS.${dtg}
    mv  ${STATUS}/g3dv_ENS.${dtg} ${STATUS}/innov_ensmean.${dtg}.ok
else
  echo some member innov of ${dtg} fail!!
  mv  ${STATUS}/g3dv_ENS.${dtg}.fail  ${STATUS}/innov.${dtg}.fail
  cat ${STATUS}/g3dv_ENS.${dtg}.ok >>   ${STATUS}/innov.${dtg}.fail
  echo "$dtg \$cjob fail,since some member innov fail!!" >> ${STATUS}/innov.${dtg}.fail
  exit -1
fi
sleep 5

#-------------------------------------------------------------------------------
#   get obs innovation for all member
#-------------------------------------------------------------------------------
nmem=1
while [ \$nmem -le $NTOTMEM ] ; do
  if [ $opt_innov -ne 1  ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg g3dv_${optrun} \$nmem ok,opt_innov=$opt_innov" >> ${STATUS}/g3dv_ENS.${dtg}.ok
  else
    # for generating GSI namelist (gsiparm.anl)
    export lrun_select_obs=.false.
    export lrun_innovate=.true.

    export DIAG_COMPRESS=NO
    export DIAG_TARBALL=YES

    ${NWPBINS}/0800_Gana.ksh ${fnconf} $dtg  \$optrun \$optsub \$nmem

    cmem3=\`printf %03i \$nmem\`
    ssh ${LGIN} ${PJSUB} -L rscgrp=large-x -N ${EXP_NAME}_inno_m\${cmem3} -o ${LOGDIR}/0c00_0800_innov_mem\${cmem3}.${dtg} ${LOGDIR}/j3dv_\${nmem}

    rm -f ${LOGDIR}/j3dv_\${nmem}
    sleep 5
  fi
  ((nmem=\${nmem}+1))
done

#-------------------------------------------------------------------------------
#   check member's innovation status
#-------------------------------------------------------------------------------
dtg10=20${dtg}
delt=5
tott=6000

tt=1
success_innov=0
while [ \$tt -le \$tott ] ; do
  sleep  \${delt}
  njob=\`ssh ${LGIN} -n "pjstat -S" | grep "${DMSFN}_inno_m" | wc -l \`
  if [ \$njob -eq 0 ] ; then
    ((tt=tt+\${tott}))
    sleep \${delt}
    success_innov=1
    if [ -s ${STATUS}/g3dv_ENS.${dtg}.fail ] ; then
      success_innov=0
    fi
  fi
done

if [ \${success_innov} -eq 1 ] ; then
  echo innov_ens.${dtg} success !!  >> ${STATUS}/g3dv_ENS.${dtg}
  mv  ${STATUS}/g3dv_ENS.${dtg} ${STATUS}/innov.${dtg}.ok
else
  echo some member innov of ${dtg} fail!!
  mv  ${STATUS}/g3dv_ENS.${dtg}.fail  ${STATUS}/innov.${dtg}.fail
  cat ${STATUS}/g3dv_ENS.${dtg}.ok >>   ${STATUS}/innov.${dtg}.fail
  echo "$dtg \$cjob fail,since some member innov fail!!" >> ${STATUS}/innov.${dtg}.fail
  exit -1
fi
sleep 5

#-------------------------------------------------------------------------------
#   EnKF  run
#-------------------------------------------------------------------------------
if [ $opt_enkf -eq 0 ] ; then
  echo "opt_enkf=${opt_enkf}, exit"
  echo "opt_enkf=${opt_enkf}, opt_enkf=$opt_enkf exit" > ${STATUS}/enkf.${dtg}.ok
else
  ${NWPBINS}/0c10_GENSenkf.ksh ${fnconf} $dtg  
  ssh ${LGIN} ${PJSUB} -L rscgrp=large-x -N ${EXP_NAME}_enkf -o ${LOGDIR}/0c10_enkf.${dtg} ${LOGDIR}/jenkf
fi

#   check EnKF run status
success_enkf=0
delt=5

while [ \${success_enkf} -eq 0 ] ; do
  sleep  \${delt}
  if [ -s ${STATUS}/enkf.${dtg}.ok ] ; then
    success_enkf=1
  elif  [ -s ${STATUS}/enkf.${dtg}.fail ] ; then
    success_enkf=0
    echo enkf.${dtg} fail !!  
    exit 2
  else
    success_enkf=0
  fi
done


#-------------------------------------------------------------------------------
#   inflation by NMC perturbation method
#-------------------------------------------------------------------------------
# --  get ens mean by getdigensmean_smooth
if [ $opt_recenter -eq  0 ] ; then
  echo "opt_inflation=$opt_inflation" > ${STATUS}/ENS_inflation.${dtg}.ok
else
  ${NWPBINS}/0c20_GENSinflation.ksh ${fnconf} $dtg  
  ssh ${LGIN} ${PJSUB} -N ${EXP_NAME}_inflate -o ${LOGDIR}/0c20_infl.${dtg} ${LOGDIR}/jinfl
fi

#   check inflation status
success_infl=0
delt=5
tott=6000
tt=1
while [ \$tt -le \$tott ] ; do
  sleep  \${delt}
  if [ -s ${STATUS}/ENS_inflation.${dtg}.ok ] ; then
    success_infl=1
    ((tt=tt+\${tott}))
    echo inflation.${dtg} ok !!  
  elif [ -s ${STATUS}/ENS_inflation.${dtg}.fail ] ; then
    echo inflation.${dtg} fail !!  
    exit 2
  fi
done
if [ \${success_infl} -eq 0 ] ; then
    echo inflation.${dtg} fail !!  
    exit 2
fi

#-------------------------------------------------------------------------------
#   recenter
#-------------------------------------------------------------------------------
if [ $opt_recenter -eq  0 ] ; then
  echo "opt_recenter=$opt_recenter" > ${STATUS}/ENS_recenter.${dtg}.ok
else
  ${NWPBINS}/0c30_GENSrecenter.ksh ${fnconf} $dtg  
  ssh ${LGIN} ${PJSUB} -N ${EXP_NAME}_recenter -o ${LOGDIR}/0c30_recenter.${dtg} ${LOGDIR}/jrecntr
fi

#  check recenter status
success_rcntr=0
delt=5
tott=6000
tt=1
while [ \$tt -le \$tott ] ; do
  sleep  \${delt}
  if [ -s ${STATUS}/ENS_recenter.${dtg}.ok ] ; then
    echo "GENSemble : recenter.${dtg} ok !!  "
    success_rcntr=1
    ((tt=tt+\${tott}))
  elif [ -s ${STATUS}/ENS_recenter.${dtg}.fail ] ; then
    echo "GENSemble : recenter.${dtg} fail !!  "
    exit 2
  fi
done

if [ \${success_rcntr} -eq 0 ] ; then
    echo "GENSemble : recenter.${dtg} fail !!  "
    exit 2
fi

#-------------------------------------------------------------------------------
##  ensemble fcst
#-------------------------------------------------------------------------------
mem=1
while [ \$mem -le $NTOTMEM ] ; do
  if [ $optens_fcst -eq 0  ] ; then
    echo "optens_fcst=$optens_fcst, do not run."
  else
    cmem3=\`printf %03i \$mem\`
    ${NWPBINS}/0c40_GENSgfs.ksh ${fnconf} $dtg  \$mem
    ssh ${LGIN} ${PJSUB} -L rscgrp=large-x -N ${EXP_NAME}_fc_m\${cmem3} -o ${LOGDIR}/0c40_ens_fcst_mem\${cmem3}.${dtg} ${LOGDIR}/jensfc_\${mem}
    sleep 5
  fi
#  rm -f ${LOGDIR}/fjensfc\${mem}
  ((mem=\${mem}+1))
done

#-------------------------------------------------------------------------------
# check fcst status
#-------------------------------------------------------------------------------
((ntott=6000))
((delt=5))
((tt=1))
while [ \$tt -le \$ntott ] ; do
  sleep \${delt}
  njob=\`ssh ${LGIN} -n "pjstat -S" | grep "${DMSFN}_fc_m" | wc -l \`
  if [ \${njob} -eq 0 ] ; then
      ((tt=10+\${ntott}))
      sleep \${delt}
      echo "ens_fcst fininsh" > ${STATUS}/ens.${dtg}
      if [ -s ${STATUS}/ens_fcst.${dtg}.fail ] ; then
         mv ${STATUS}/ens.${dtg} ${STATUS}/ens.${dtg}.fail
      else
         mv ${STATUS}/ens.${dtg} ${STATUS}/ens.${dtg}.ok
      fi
   fi
done

exit
EOFens
if [ $optsub -eq 1 ]
then
  ssh ${LGIN} ${PJSUB} ${LOGDIR}/jens
fi
exit
