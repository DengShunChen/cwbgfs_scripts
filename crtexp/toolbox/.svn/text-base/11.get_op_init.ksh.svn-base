#!/bin/ksh

 set -x

## download first guess from silo

 dtg_first=$1
# dtg_first=15091900

#-- if silo and fcst are the same resolution, then no need to do interpolation 
 silo_gfsflag=GH
 fcst_gfsflag=`echo ${INDMSTL} | cut -c1-2`

#-- interpolation 
 if [ ${silo_gfsflag} = ${fcst_gfsflag} ] ; then
  opt_gm2gm=0    # no need to change resolution 
  silo_maindms=${INDMSHD}${dtg_first}${INDMSTL}
  fcst_maindms=${silo_maindms}
 else
  restflag=`echo ${INDMSTL} | cut -c3-`
  opt_gm2gm=1
  silo_maindms=${INDMSHD}${dtg_first}${silo_gfsflag}${restflag}
  fcst_maindms=${INDMSHD}${dtg_first}${INDMSTL}
  #-- make working directory
  workdir=${MDIR_WORK}/get_init
  if [ ! -s $workdir ] ;  then
    mkdir $workdir 
  fi

 fi

#--------------------------------------------------------------------------------#
 
 fgdtg=`$CALDTG $dtg_first -6 `
 fgmm=`echo $fgdtg | cut -c3-4`
   mm=`echo $dtg_first | cut -c3-4`

 export MASOPS=${silo_maindms}@${INDMSDB}
 ssh $DTMV -n ${DMSPATH}/rdmscrt ${MASOPS}

 if [ ! -s  ${DMS_HOME}/${INDMSDB}.ufs/${silo_maindms}/20${fgdtg}000006 ] ;  then
  #export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}MGP-0006@GFSt511-${fgmm}@archive@hsmsvr
  #export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}MGP@NWPDB-${fgmm}@archive@hsmsvr1a
  #export MASOPS_silo=MASOPS@NWPDB@ncsagfs@datamv01.mic.cwb                                   # OPERATION
   export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}MGM-0006@GFSt511-${fgmm}@archive@hsmsvr    # SILO
   ssh $DTMV -n ${DMSPATH}/rdmscpy -l34 -k"??????0006${silo_gfsflag}MG20${fgdtg}*" $MASOPS_silo $MASOPS
  #export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}0GP-0006@GFSt511-${fgmm}@archive@hsmsvr
  #export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}0GP@NWPDB-${fgmm}@archive@hsmsvr1a
  #export MASOPS_silo=MASOPS@NWPDB@ncsagfs@datamv01.mic.cwb                                   # OPERATION
   export MASOPS_silo=MASOPS${fgdtg}${silo_gfsflag}0GM-0006@GFSt511-${fgmm}@archive@hsmsvr    # SILO
   ssh $DTMV -n ${DMSPATH}/rdmscpy -l34 -k"??????0006${silo_gfsflag}0G20${fgdtg}*" $MASOPS_silo $MASOPS
 else
   echo "DOWNLOAD_DMSFILE : ${DMS_HOME}/${INDMSDB}.ufs/${silo_maindms}/20${fgdtg}000006 exist !!"
 fi
 if [ ! -s  ${DMS_HOME}/${INDMSDB}.ufs/${silo_maindms}/20${dtg_first}000000 ] ;  then
  #export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}MGP-0000@GFSt511-${mm}@archive@hsmsvr
  #export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}MGP@NWPDB-${mm}@archive@hsmsvr1a
  #export MASOPS_silo=MASOPS@NWPDB@ncsagfs@datamv01.mic.cwb                                   # OPERATION 
   export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}MGM-0000@GFSt511-${mm}@archive@hsmsvr  # SILO
   ssh $DTMV -n ${DMSPATH}/rdmscpy -l34 -k"??????0000${silo_gfsflag}MG20${dtg_first}*" $MASOPS_silo $MASOPS
  #export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}0GP-0000@GFSt511-${mm}@archive@hsmsvr
  #export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}0GP@NWPDB-${mm}@archive@hsmsvr1a
  #export MASOPS_silo=MASOPS@NWPDB@ncsagfs@datamv01.mic.cwb                                   # OPERATION 
   export MASOPS_silo=MASOPS${dtg_first}${silo_gfsflag}0GM-0000@GFSt511-${mm}@archive@hsmsvr  # SILO
   ssh $DTMV -n ${DMSPATH}/rdmscpy -l34 -k"??????0000${silo_gfsflag}0G20${dtg_first}*" $MASOPS_silo $MASOPS
 else
   echo "DOWNLOAD_DMSFILE : ${DMS_HOME}/${INDMSDB}.ufs/${silo_maindms}/20${dtg_first}000000 exist !!"
 fi

if [ $opt_gm2gm -eq 1 ] ; then

cd $workdir

cat > gm2gm_namlsts << EOFgm2gm
&gm2gm_param
ggdef1='${silo_gfsflag}0G',
gmdef1='${silo_gfsflag}MG',
km=40,
ggdef2='${fcst_gfsflag}0G',
gmdef2='${fcst_gfsflag}MG',
lev=60,
lmax=16,
&end

from f1 to f2
lmax=16 no need to change

EOFgm2gm

cat > t3tot5 << EOFt3to5
#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j

OMP=16
. /users/xa09/sample/setup_omp.${MACHINE} \$OMP

set -x
#-- input
export GM2GM_MASIN=${silo_maindms}@${INDMSDB}

#-- output
export GM2GM_MASOUT=${fcst_maindms}@${INDMSDB}

#-- terrrian data
export GM2GM_BCK=$BCKOPS

rdmscrt -l34 GM2GM_MASOUT

cd ${workdir}
export NWPETC=${workdir}
export NWPETCGLB=${workdir}
export GM2GM_NAMLSTS=${workdir}/gm2gm_namlsts

/usr/bin/time -p ${EXE_GM2GM_NOAH} $dtg_first 0006
 
if [ $? = 0 ] ; then
 echo ${MDIR_STATUS}/${EXP_NAME}_11_get_op_init_okay 
fi
if [ $? = 0 ] ; then
 echo "${EXP_NAME}_11_get_op_init okay!"   > ${MDIR_STATUS}/${EXP_NAME}_11_get_op_init_okay
else
 echo "${EXP_NAME}_11_get_op_init failed!" > ${MDIR_STATUS}/${EXP_NAME}_11_get_op_init_fail
fi


EOFt3to5

job_log=${MDIR_LOG}/${EXP_NAME}${dtg}.t3tot5
ssh $LGIN -n /usr/bin/pjsub -o ${job_log} ${workdir}/t3tot5

rm -rf ${MDIR_STATUS}/${EXP_NAME}_11_get_op_init_okay
# checking job state to keep flow correctly
 runflag='true'
 typeset -i icount=1
 while [ $runflag  = true ] && (( $icount <= 60*12 )) ; do

  if [ -e ${MDIR_STATUS}/${EXP_NAME}_11_get_op_init_okay ] ; then
   runflag='false'
  else
   runflag='true'
  fi

  ((imin=$icount/2))
  echo " Waiting for jobs in $imin minutes -- sleep 60s"
  sleep 60

  icount=$icount+1

 done


fi
