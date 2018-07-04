#!/bin/ksh
#--------------------------------------------------------------------
# purpose  prepare first guess of sigma level and surface
# dtg      date-time-group of analysis dtg
# optrun   option for main run(=1) 
#           =MAIN     main run
#           =ENS      EnKF run
#           =ENSRES   downscale from MAIN run to ENSemble resolution
#           =LAG      time lag members
# optreloc option for typn process
#           =1  yes
#           =0  no
#--------------------------------------------------------------------
if [ $# = 6 ] ; then
  fnconf=$1
  dtg=$2
  optrun=$3
  optreloc=$4
  optsub=$5
  mem=$6
else
  echo "Gfguess.ksh fnconf dtg fgtau  optsub"
  exit
fi

cd ${LOGDIR}

expr $mem + 1 2> /dev/null
if [ $? = 0 ] ; then 
 echo "Val was numeric"
 cmem3=`printf %03i ${mem}`
else
 echo "Val was non-numeric"
 cmem3=$mem
fi

if [ $optrun = "MAIN" ]  ; then
  script_name="fg_${cmem3}"
elif [ $optrun = "ENS" ]  ; then
  script_name="fg_f${OBS_BIN}_mem${cmem3}"
elif [ $optrun = "LAG" ]  ; then
  script_name="fg_f${OBS_BIN_LAG}_mem${cmem3}"
else
  script_name="fg_${cmem3}"
fi

rm -f ${script_name}
cat > ${script_name}  << EOFfg
#!/bin/ksh
#PJM -L node=1
#PJM -L node-mem=unlimited
#PJM --no-stging
#PJM -L "elapse=3:00:00"
#PJM --mpi "proc=1"
#PJM -j

. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fnconf}.set
set -x
echo "BEGIN ...."

#---------------------------------------------------------------------------
# options and option-dependent assignment
#---------------------------------------------------------------------------
# optrun  =MAIN     main run
#         =ENS      ens run  
#         =LAG      time lag run
#---------------------------------------------------------------------------
export  fnconf=$1
export  dtg=$2
export  optrun=$3
export  optreloc=$4
export  optsub=$5
export  mem=$6
if [ ${MP} = "M" -o ${MP} = "m"  ] ; then
  export kdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24 \`
else
  export kdtg=${dtg}
fi
export O3fn=o3_${optrun}.20\${kdtg}
if [ $opt_4denvar = 1 ] ; then
  export l4denvar=.true.
else
  export l4denvar=.false.
fi
if [ $optrun = "MAIN" ] ; then
  export OBS_BIN=${OBS_BIN:-06}
  export UPDATEHR=${UPDATEHR_MAIN:-6}
  export fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -\${UPDATEHR} \`
  export DTGDIR=${NWPDTGGLB}
  export WORKDIR=${NWPWRK}/fg_f\${OBS_BIN}
  export LEVS=${LEVS}
  export JCAP=${JCAPA}
  export LON=${LONA}
  export LAT=${LATA}
  export TAU=${OBS_BIN#0}
  export FLAG=${gfsflag}
  export CDTG=\${fgdtg}
  export l4denvar=\${l4denvar}
  export sigfn=sigf\${OBS_BIN}.20\${fgdtg}
  export sfcfn=sfcf\${OBS_BIN}.20\${fgdtg}
  export MASOPS=\${MASOPS}
  export BCKOPS=\${BCKOPS}
elif [ $optrun = "ENS" ] ; then
  export OBS_BIN=${OBS_BIN:-06}
  export UPDATEHR=${UPDATEHR_MAIN:-6}
  export fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -\${UPDATEHR} \`
  export DTGDIR=${NWPDTGENS}
  export WORKDIR=${NWPWRKENS}/fg_${cmem3}_f\${OBS_BIN}
  export LEVS=${LEVS}
  export JCAP=${JCAPA_ENKF}
  export LON=${LONA_ENKF}
  export LAT=${LATA_ENKF}
  export TAU=${OBS_BIN#0}
  export FLAG=${ensflag}
  export CDTG=\${fgdtg}
  export l4denvar=\${l4denvar}
  export sigfn=sigf\${OBS_BIN}_20\${fgdtg}_mem${cmem3}
  export sfcfn=sfcf\${OBS_BIN}_20\${fgdtg}_mem${cmem3}
  export MASOPS=MASOPS_mem${cmem3}@${DB_NAME}
  export BCKOPS=\${BCKENS}
elif [ $optrun = "LAG" ] ; then
  ((mem=$mem-$NTOTMEM)) ; cmem3=\`printf %03i \${mem}\`    #  expand member size
  export OBS_BIN=${OBS_BIN_LAG:-12}
  export UPDATEHR=${UPDATEHR_LAG:-12}
  export fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -\${UPDATEHR} \`
  export DTGDIR=${NWPDTGENS}
  export WORKDIR=${NWPWRKENS}/fg_${cmem3}_f\${OBS_BIN}
  export LEVS=${LEVS}
  export JCAP=${JCAPA_ENKF}
  export LON=${LONA_ENKF}
  export LAT=${LATA_ENKF}
  export TAU=${OBS_BIN_LAG#0}
  export FLAG=${ensflag}
  export CDTG=\${fgdtg}
  export l4denvar=\${l4denvar}
  export sigfn=sigf\${OBS_BIN}_20\${fgdtg}_mem\${cmem3}
  export sfcfn=sfcf\${OBS_BIN}_20\${fgdtg}_mem\${cmem3}
  export MASOPS=MASOPS_mem\${cmem3}@${DB_NAME}
  export BCKOPS=\${BCKENS}
elif [ $optrun = "ENSRES" ] ; then
  export DTGDIR=${NWPDTGENS}
  export WORKDIR=${NWPWRKENS}
  export LEVS=${LEVS}
  export JCAP=${JCAPA_ENKF}
  export LON=${LONA_ENKF}
  export LAT=${LATA_ENKF}
  export TAU=0
  export FLAG=${ensflag}
  export CDTG=${dtg}
  export l4denvar=\${l4denvar}
  export sigfn=sanl_main_ensres.20${dtg}
  export sfcfn=sfcanl_main_ensres.20${dtg}
  export MASOPS=${MASOPS_ensres:-${MASOPS_ensres}}
  export BCKOPS=\${BCKENS}
  export O3fn=o3_ENS.20\${kdtg}
else
  echo "optrun="$optrun",  must be MAIN, ENS or ENSRES, something wrong!! exit!!!"
  exit
fi

if [ $optreloc -ne 1 -a $optreloc -ne 0 ] ; then
  echo "optreloc="$optreloc", it must be 0 or 1, something wrong!! exit!!!"
  exit
fi

#---------------------------------------------------------------------------
# run options  --- for research only
#---------------------------------------------------------------------------
if [ $optrun = "MAIN" ]  ; then
  echo in MAIN
  if [ $opt_fguess -ne 1  ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    echo "\$nowt $dtg sfcges ok" >> ${STATUS}/sfcges_${optrun}.${dtg}.ok
    exit
  fi
elif [ $optrun = "ENS" ] ; then
  echo in ENS
  echo 'optens_fguess='$optens_fguess
  if [ $optens_fguess -ne 1  ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    echo "\$nowt $dtg sfcges ok" >> ${STATUS}/sfcges_${optrun}.${dtg}.ok
    exit
  fi
elif [ $optrun = "LAG" ] ; then
  echo in LAG
  echo 'optens_fguess='$optens_fguess
  if [ $optens_fguess -ne 1  ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    echo "\$nowt $dtg sfcges ok" >> ${STATUS}/sfcges_${optrun}.${dtg}.ok
    exit
  fi
elif [ $optrun = "ENSRES" ] ; then
  if [ $optensres_fguess -ne 1  ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    echo "\$nowt $dtg sfcges ok" >> ${STATUS}/sfcges_${optrun}.${dtg}.ok
    exit
  fi
fi
#---------------------------------------------------------------------------
# wait for previous job 
#---------------------------------------------------------------------------
  pjob=gtoz_${optrun}
  if [ $optrun = "ENSRES" ] ; then
    pjob=gtoz_ENS
  fi

  cjob=fguess_${optrun}
  ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 100 6 $STATUS
  if [ \$? -ne 0 ] ; then
     nowt=\`date\`
     echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
     exit -1
  fi
#========================================================================================
# Run dms2sig 
#========================================================================================

. ${NWPBINS}/global_fguess.ksh


exit 0
EOFfg
if [ $optsub -eq 1 ] ; then
  ${PJSUB} fg_${mem}
fi
exit
