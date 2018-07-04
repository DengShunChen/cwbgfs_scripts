#!/bin/ksh
if [ $# -eq 1 ] ; then
  if [ $1 = v ] ; then
    vi run.input
    exec 7< run.input
  else
    exec 7< $1
  fi
  read -u7 tmpvar
  fn_config=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  date_ini=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  date_end=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  opt_fcst=`echo $tmpvar | cut -d= -f2`
elif [ $# -eq 4 ] ; then
  fn_config=$1
  date_ini=$2
  date_end=$3
  opt_fcst=$4
else
  echo "usage : $0 [input file]"
  echo "        or "
  echo "usage : $0 [config] [date_ini] [date_end] [opt_fcst]"
  echo " config   : configuration "
  echo " date_ini : initial date"
  echo " date_end : ended date"
  echo " opt_fcst : fcst option"
  exit
fi
#==============================================================================================#
#
# Main GFS scripts controler
#
# Created by Wen-Mei Chen
#
# Modified by Deng-Shun Chen 
# 2018-01-22
#
#==============================================================================================#
export MACHINE=${MACHINE:-'fx100'}
export NWPBINS=${NWPBINS:-`pwd`}
if [ $MACHINE = 'fx100' ]  ; then
  export RSCGRP='research-x'
else
  export RSCGRP='research'
fi 
#==============================================================================================#
# env setting
#==============================================================================================#
  set -x

  # apply envorinmental settings
  . ${NWPBINS}/${fn_config}
  cat ${NWPBINS}/${fn_config} | sed "s/_dtg_/${date_ini}/" >  ${NWPBINS}/${fn_config}.set
  . ${NWPBINS}/${fn_config}.set

  optset=0
  optsub=0
  curdir=`pwd`
  runfn=`basename $0`
  echo $runfn

  echo ${date_ini} > ${NWPDTG}/crdate
  echo ${date_ini} > ${NWPDTGENS}/crdate
  echo ${date_ini} > ${GFSDIR}/crdate

  dtg=$date_ini

#==============================================================================================#
# clean all status of current dtg
#==============================================================================================#
  cd $STATUS
  rm -f *${date_ini}*
#----------------------------------------------------------------
# check gfsctl file for gfs and ensemble forecast
#----------------------------------------------------------------
# if [ ! -s ${GFSDIR}/gfsctl.0012.${opt_fcst}  -o ! -s ${GFSDIR}/gfsctl.0618.${opt_fcst} ] ; then
#   echo "stop, please prepare files : "
#   echo ${GFSDIR}/gfsctl.0012.${opt_fcst}" and " ${GFSDIR}/gfsctl.0618.${opt_fcst} ; exit
# fi
#----------------------------------------------------------------
# create working directory for ENKF run
#----------------------------------------------------------------
  if [ $opt_hyb -eq 1 ] ; then
    cd ${WRKEXP}
    rm -fr  $NWPWRKENS
    mkdir $NWPWRKENS

    cd $NWPWRKENS
    typeset -Z3 imem
    imem=1
    while [ $imem -le $NTOTMEM ] ; do
      mkdir innov_${imem}
      ((imem=imem+1))
    done
  fi

  cd $LOGDIR
  echo $date_end > crdate_end
   
#-------------------------------------------------------------
#- check experiment name, the first character should not be numeric.
# first_char=`echo ${DMSFN} | cut -c1-1`
# expr $first_char + 1 2> /dev/null
# if [ $? = 0 ] ; then
#   echo "Val was numeric"
#   EXP_NAME="gfs_${DMSFN}"
# else
#   echo "Val was non-numeric"
#   EXP_NAME="${DMSFN}"
# fi
# 
#--------------------
# prepare snowice, sst, ec and obs for next dtg
#--------------------
# optsub=1
# typeset -i gttau2
# gttau2=1*$inthr
#
# fn_config: confing file
# date_ini : initial date
# gttau2 : define the interval hours of next dtg 
# optobs : define preparing obs or not
# optsub : define next dtg or current  
# ${NWPBINS}/0200_prepdat.ksh ${fn_config} $date_ini $gttau2   $optobs  $optsub
#
#-------------------------------------------------------------
# prepare snowice, sst, ec and obs for current dtg
#-------------------------------------------------------------
  optsub=0
  typeset -i gttau2
  gttau2=0
  ${NWPBINS}/0200_prepdat.ksh ${fn_config} $date_ini $gttau2   $optobs  $optsub

  jsn=1
  LOG=${LOGDIR}/0200_prepdat.${date_ini}
  JOB=${LOGDIR}/pdt
  jid=`ssh ${LGIN} ${PJSUB} -N ${EXP_NAME}_pobs  --step --sparam "sn=1" -z jid -o  ${LOG}  ${JOB} | cut -d"_" -f1`
#-------------------------------------------------------------
# prepcwbobs
#-------------------------------------------------------------
  ${NWPBINS}/0300_Gprepcwbobs.ksh ${fn_config} $date_ini 

  ((jsn=jsn+1))
  LOG=${LOGDIR}/0300_prepcwbobs.${date_ini}
  JOB=${LOGDIR}/prcwb
  ssh ${LGIN} ${PJSUB} -N ${EXP_NAME}_cwbobs -o ${LOG}  --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
#-------------------------------------------------------------
# get oz
#-------------------------------------------------------------
  optrun=MAIN
  optsub=0
  ${NWPBINS}/0400_Gtoz.ksh ${fn_config} $date_ini   $optrun $optsub
  ((jsn=jsn+1))
  LOG=${LOGDIR}/0400_Gtoz_${optrun}.${date_ini}
  JOB=${LOGDIR}/gtoz_${optrun}
  ssh ${LGIN} ${PJSUB} -N ${EXP_NAME}_proz -o ${LOG}  --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
#-------------------------------------------------------------
# reloc &fguess
#-------------------------------------------------------------
  optsub=0

  if [ $opt_4denvar -eq 1 ] ; then
    OBSBINS='03 04 05 06 07 08 09'
    optreloc=0
  else
    OBSBINS='06'
    optreloc=1
  fi

  for OBS_BIN in $OBSBINS ; do
     optrun="MAIN"
     export OBS_BIN
    ${NWPBINS}/0500_Gfguess.ksh ${fn_config} $date_ini   $optrun $optreloc $optsub MAIN_f${OBS_BIN}

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0500_fg_f${OBS_BIN}_${optrun}.${date_ini}
    JOB=${LOGDIR}/fg_MAIN_f${OBS_BIN}
    ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_fg_f${OBS_BIN} -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
  done
#-------------------------------------------------------------
## member first guess
#-------------------------------------------------------------
  if [ $opt_hyb -eq 1 ] ; then
    ${NWPBINS}/0600_GENSfguess.ksh ${fn_config} $date_ini   ${optsub}

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0600_ensfg.${date_ini}
    JOB=${LOGDIR}/Efg
    ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_fg_ens -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after"  ${JOB}
  fi
#-------------------------------------------------------------
# bogus
#-------------------------------------------------------------
  optsub=0
  optbogus=1
  if [ $opt_cbogus -ne 1 ]  ; then
    echo 'opt_cbogus='$opt_cbogus', do not run Gcbogus for testing !!! '
    nowt=\`date\`
    echo "\$nowt $dtg bogus ok, no typn" >> ${STATUS}/bogus.${dtg}.ok
  else
    ${NWPBINS}/0700_Gcbogus.ksh ${fn_config} $date_ini $optbogus $optsub

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0700_cbogus.${date_ini}
    JOB=${LOGDIR}/bg
    ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_bogs -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
  fi
#-------------------------------------------------------------
## gsi
#-------------------------------------------------------------
  if [ $opt_g3dvar -ne 1 ] ; then
    echo 'opt_g3dvar='$opt_g3dvar', do not run g3dv for testing !!! '
    nowt=\`date\`
    echo "\$nowt $dtg g3dv ok" >> ${STATUS}/g3dv_MAIN.${dtg}.ok
  else
    optsub=0
    ${NWPBINS}/0800_Gana.ksh ${fn_config} $date_ini $optrun $optsub MAIN

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0800_g3dvar_${optrun}.${date_ini} 
    JOB=${LOGDIR}/j3dv_MAIN
    ssh ${LGIN} ${PJSUB} -L rscgrp=large-x -N ${EXP_NAME}_da -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after"  ${JOB}
  fi
#-------------------------------------------------------------
## angupdate
#-------------------------------------------------------------
# ${NWPBINS}/0900_G3dvar2.ksh ${fn_config} $date_ini  $optsub
# ((jsn=jsn+1))
# ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_agud -o ${LOGDIR}/0900_g3dvar2.${date_ini}  --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${LOGDIR}/j3d2
#-------------------------------------------------------------
## ncep2gm
#-------------------------------------------------------------
  optsub=0
  ${NWPBINS}/0a00_Gncep2gm.ksh ${fn_config} $date_ini  $optrun $optsub MAIN

  ((jsn=jsn+1))
  LOG=${LOGDIR}/0a00_ncep2gm.${date_ini}
  JOB=${LOGDIR}/j2gm_MAIN
  ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_2gm -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after"  ${JOB}
#-------------------------------------------------------------
## fcst
#-------------------------------------------------------------
  if [ $opt_gfs -ne 1 ]  ; then
    echo "opt_gfs=$opt_gfs, do not run MAIN fcst for testing !!!"
    nowt=\`date\`
    echo "\$nowt $dtg fcst ok" >> ${STATUS}/fcst.${dtg}.ok
  else
    optsub=0
    ${NWPBINS}/0b00_Ggfs.ksh ${fn_config} $dtg ${opt_fcst} ${optsub}

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0b00_fcst.${date_ini}
    JOB=${LOGDIR}/jfc
    ssh ${LGIN} ${PJSUB}  -L rscgrp=large-x -N ${EXP_NAME}_fcst -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after"  ${JOB}
  fi
#-------------------------------------------------------------
## ensemble
#-------------------------------------------------------------
  if [ $opt_hyb -eq 1 ] ; then
    ${NWPBINS}/0c00_GENSemble.ksh ${fn_config} $dtg   ${optsub}

    ((jsn=jsn+1))
    LOG=${LOGDIR}/0c00_ens.${date_ini} 
    JOB=${LOGDIR}/jens
    ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_ens -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after"  ${JOB}
  fi
#-------------------------------------------------------------
##  next job
#-------------------------------------------------------------
  cd ${NWPBINS}
  ${NWPBINS}/0d00_nxtpost.ksh $fn_config ${date_ini} ${date_end} ${runfn} ${opt_fcst}

  ((jsn=jsn+1))
  LOG=${LOGDIR}/0d00_nxtpost.${date_ini}
  JOB=${LOGDIR}/jnxt
  ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_next -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
#-------------------------------------------------------------
##  for diagnose
#-------------------------------------------------------------
  cd ${LOGDIR}
  ${NWPBINS}/0e00_diag.ksh ${fn_config} ${date_ini} ${date_end}

  ((jsn=jsn+1))
  LOG=${LOGDIR}/0e00_diag.${date_ini}
  JOB=${LOGDIR}/dia
  ssh ${LGIN} ${PJSUB}  -N ${EXP_NAME}_diag -o ${LOG} --step --sparam "jid=$jid,sn=$jsn,sd=ec!=0:after" ${JOB}
#-------------------------------------------------------------
# prepare snowice, sst, ec and obs for next dtg
#-------------------------------------------------------------
  echo "wait ... for get obs for next dtg ..."
  sleep 180

  optsub=1
  typeset -i gttau2
  gttau2=1*$inthr
  ${NWPBINS}/0200_prepdat.ksh ${fn_config} ${date_ini} ${gttau2}  ${optobs}  ${optsub}
#-------------------------------------------------------------

exit
