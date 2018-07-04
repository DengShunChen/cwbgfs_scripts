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
cat > Efg <<EOFEfg
#!/bin/ksh
#PJM -L "node=3"
#PJM -L elapse=2:30:00
#PJM -L node-mem=unlimited
#PJM -j
#PJM --no-stging

 . ${NWPBINS}/setup_mpi
 . ${NWPBINS}/${fnconf}.set
 set -x

 cd ${LOGDIR}

#-------------------------------------------------------------------------------
#   run option -- for research only
#-------------------------------------------------------------------------------
 if [ $optens_fguess -ne 1 ]  ; then
   nowt=\`date\`
   echo "\$nowt $dtg ens ok" >> ${STATUS}/fguess_ENS.${dtg}.ok
   echo "\$nowt $dtg ens ok" >> ${STATUS}/sfcges_ENS.${dtg}.ok
   echo "\$nowt $dtg ens ok" >> ${STATUS}/gtoz_ENS.${dtg}.ok
   exit
 fi
#-------------------------------------------------------------------------------
#   get oz
#-------------------------------------------------------------------------------
 optrun=ENS
 optsub=0
 ${NWPBINS}/0400_Gtoz.ksh ${fnconf} $dtg  \$optrun \$optsub
 chmod u+x ${LOGDIR}/gtoz_\${optrun}
 ${LOGDIR}/gtoz_\${optrun}

 if [ $opt_lag -eq 1 ] ; then
   optrun=LAG
   optsub=0
   ${NWPBINS}/0400_Gtoz.ksh ${fnconf} $dtg  \$optrun \$optsub
   chmod u+x ${LOGDIR}/gtoz_\${optrun}
   ${LOGDIR}/gtoz_\${optrun}
 fi

#-------------------------------------------------------------------------------
#   get member's guess
#-------------------------------------------------------------------------------

optreloc=0
optsub=0

if [ $opt_4denvar -eq 1 ] ; then
   OBSBINS='03 04 05 06 07 08 09'
else
   OBSBINS='06'
fi 

for OBS_BIN in \$OBSBINS ; do 

  export optrun=ENS
  export OBS_BIN
  
  mem=1
  while [ \$mem -le $NTOTMEM ] ; do
    cmem3=\`printf %03i \${mem}\`
    job_name="fg_f\${OBS_BIN}_mem\${cmem3}"

#   if [ \$mem -gt 36 ] ;  then
#     rscgrp="-L rscgrp=large-x"
#   else
#     rscgrp=""
#   fi

    rscgrp="-L rscgrp=large-x"

    ${NWPBINS}/0500_Gfguess.ksh ${fnconf} $dtg  \$optrun \$optreloc \$optsub \$mem
    ssh ${LGIN} ${PJSUB} \${rscgrp} -N ${EXP_NAME}_\${job_name} -o ${LOGDIR}/0600_\${job_name}.${dtg} ${LOGDIR}/\${job_name}

    sleep 1
    ((mem=mem+1))
  done
  
  # Time lagging member 
  if [ $opt_lag -eq 1 ] ; then 
    ((OBS_BIN_LAG=\${OBS_BIN}+${LAGGED_HR}))

    export optrun=LAG
    export OBS_BIN_LAG=\`printf %02i \${OBS_BIN_LAG}\`
  
    mem=1
    while [ \$mem -le $NTOTMEM ] ; do
      ((mem_lag=mem+$NTOTMEM)) 

      cmem3_lag=\`printf %03i \${mem_lag}\`  
      job_name="fg_f\${OBS_BIN_LAG}_mem\${cmem3_lag}"

#     if [ \$mem -gt 36 ] ;  then
#       rscgrp="-L rscgrp=large-x"
#     else
#       rscgrp=""
#     fi

      rscgrp=""

      ${NWPBINS}/0500_Gfguess.ksh ${fnconf} $dtg  \$optrun \$optreloc \$optsub \$mem_lag
      ssh ${LGIN} ${PJSUB} \${rscgrp} -N ${EXP_NAME}_\${job_name} -o ${LOGDIR}/0600_\${job_name}.${dtg} ${LOGDIR}/\${job_name}

      sleep 1
      ((mem=mem+1))
    done
  fi 
 
#-------------------------------------------------------------------------------
#   check member's guess status
#-------------------------------------------------------------------------------

  fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -${UPDATEHR_ENS} \`
  delt=6
  tott=1200
  tt=1
  while [ \$tt -le \$tott ] ; do
    sleep  \${delt}

    njob1=\`ssh ${LGIN} -n "pjstat -S " | grep "${DMSFN}_fg_f\${OBS_BIN_LAG}_mem" | wc -l \`
    njob2=\`ssh ${LGIN} -n "pjstat -S " | grep "${DMSFN}_fg_f\${OBS_BIN}_mem" | wc -l \`
    ((njob=njob1+njob2))

    if [ \$njob -eq 0 ] ; then
      ((tt=\${tt}+\${tott}))
      sleep 5
      success_sig=1
      success_sfc=1
      nmem=1
      while [ \$nmem -le $NTOTMEM ] ; do 
         cmem3=\`printf %03i \$nmem\`
         sigfn=${NWPDTGENS}/sigf\${OBS_BIN}_20\${fgdtg}_mem\${cmem3}
         sfcfn=${NWPDTGENS}/sfcf\${OBS_BIN}_20\${fgdtg}_mem\${cmem3}
         if [ -s \${sigfn} ] ; then
           ln -fs \${sigfn} ${NWPWRKENS}/sigf\${OBS_BIN}_mem\${cmem3}
           echo \${sigfn} ready >> ${STATUS}/fguess_ENS.${dtg}
         else
           success_sig=0
           echo \${sigfn} fail  >> ${STATUS}/fguess_ENS.${dtg}
         fi
         if [ -s \${sfcfn} ] ; then
           ln -fs \${sfcfn} ${NWPWRKENS}/sfcf\${OBS_BIN}_mem\${cmem3}
           echo \${sfcfn} ready >> ${STATUS}/sfcges_ENS.${dtg}
         else
           success_sfc=0
           echo \${sfcfn} fail  >> ${STATUS}/sfcges_ENS.${dtg}
         fi
         ((nmem=\${nmem}+1))     
      done
    fi
    ((tt=\${tt}+1))     
  done


  #----- get ensemble mean  
  cd ${NWPWRKENS}

  if [ \${success_sig} -eq 1 ] ; then
    /usr/bin/time -p ${NWPBIN}/GENS_sigensmean_smooth ${NWPWRKENS}/  sigf\${OBS_BIN}_ensmean sigf\${OBS_BIN} ${NTOTMEM}
    if [ \$? -eq 0 ] ; then
      echo "sigf\${OBS_BIN}_ensmean.\${fgdtg} ok"  
      echo "sigf\${OBS_BIN}_ensmean.\${fgdtg} ok"  >> ${STATUS}/fguess_ENS.${dtg}
      mv sigf\${OBS_BIN}_ensmean ${NWPDTGENS}/sigf\${OBS_BIN}_ensmean.20\${fgdtg}
      mv  ${STATUS}/fguess_ENS.${dtg} ${STATUS}/fguess_ENS.${dtg}.ok
    else
      echo "sigf\${OBS_BIN}_ensmean.\${fgdtg} fail!!"  
      echo "sigf\${OBS_BIN}_ensmean.\${fgdtg} fail!!"  >> ${STATUS}/fguess_ENS.${dtg}
      mv  ${STATUS}/fguess_ENS.${dtg} ${STATUS}/fguess_ENS.${dtg}.fail
    fi
  else
    echo member sigf\${OBS_BIN} of \${fgdtg} fail!!  
    mv  ${STATUS}/fguess_ENS.${dtg} ${STATUS}/fguess_ENS.${dtg}.fail
  fi

  if [ \${success_sfc} -eq 1 ] ; then
    /usr/bin/time -p ${NWPBIN}/GENS_sfcensmean ${NWPWRKENS}/  sfcf\${OBS_BIN}_ensmean sfcf\${OBS_BIN} ${NTOTMEM}
    if [ \$? -eq 0 ] ; then
      echo sfcf\${OBS_BIN}_ensmean.\${fgdtg} ok  
      echo sfcf\${OBS_BIN}_ensmean.\${fgdtg} ok  >> ${STATUS}/sfcges_ENS.${dtg}
      mv sfcf\${OBS_BIN}_ensmean ${NWPDTGENS}/sfcf\${OBS_BIN}_ensmean.20\${fgdtg}
      mv  ${STATUS}/sfcges_ENS.${dtg} ${STATUS}/sfcges_ENS.${dtg}.ok
    fi
  else
    echo member sfcf\${OBS_BIN} of \${fgdtg} fail!!  
    mv  ${STATUS}/sfcges_ENS.${dtg} ${STATUS}/sfcges_ENS.${dtg}.fail
  fi

done  # end of OBS_BIN

exit
EOFEfg
if [ $optsub -eq 1 ] ; then
  ssh ${LGIN} ${PJSUB} ${LOGDIR}/Efg
fi
exit
