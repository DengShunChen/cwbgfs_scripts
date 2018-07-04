#!/bin/ksh

#-------------------------------------------------------------------------
# Set date and time
#-------------------------------------------------------------------------
 dtg=${1:-}
 fnconf=${2:-}
 end_dtg=${3:-}


 dtg10=20${dtg}
 hh=`echo $dtg | cut -c7-8 `

 fgdtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -6`

 pr12dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -12`
 pr12dd=`echo ${pr12dtg} | cut -c5-6`
 pr12hh=`echo ${pr12dtg} | cut -c7-8`

 pr24dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24`
 pr24dtg10=20${pr24dtg}

 pr30dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -30`
 pr30dtg10=20${pr30dtg}

 pr36dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -36`
 pr36dtg10=20${pr36dtg}

 pr48dtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -48`
 pr48yymmdd=`echo ${pr48dtg} | cut -c1-6`
 pr48hh=`echo ${pr48dtg} | cut -c7-8`


 if [ $MP =  "M" ] ; then
   porm='m'
 else
   porm=${MP}
 fi
 if [ $MP =  "P" ] ; then
   porm='p'
 else
   porm=${MP}
 fi

#-------------------------------------------------------------------------
# evaluation
#-------------------------------------------------------------------------
#EVALDIR=${HOME}/eval34/bin
#cd ${EVALDIR}

 if [ $hh = 12 -o $hh = 00 ] ; then
   optop=0
   ${NWPBINS}/0e10_score320.ksh ${fnconf} ${dtg} ${dtg} 12 namelist.input.gfs${gfsflag}0A_a11 $ggflag ${DMSFN} ${DMSTL} ${DB_NAME} ${DMSFN} 0
 else
   gg2ga=1
   frsilo=0
   optscore=0
   expsilodir=${model}
   optop=0
   ${NWPBINS}/0e10_score320.ksh ${fnconf} ${dtg} ${dtg} 12 namelist.input.gfs${gfsflag}0A_a11 $ggflag ${DMSFN} ${DMSTL} ${DB_NAME} ${DMSFN} 0
 fi 

#-------------------------------------------------------------------------
# waiting for score finished ...
#-------------------------------------------------------------------------
 delt=3
 tott=600
 tt=1
 while [ $tt -le $tott ] ; do
   sleep  ${delt}
   if [ -s ${STATUS}/score320.ksh.${dtg}.ok ] ; then
     ((tt=${tt}+${tott}))
     sleep ${delt}
   elif  [ -s ${STATUS}/score320.ksh.${dtg}.fail ] ; then
     ((tt=${tt}+${tott}))
     nowt=`date`
     echo "$nowt $dtg score fail!!!" >> ${STATUS}/0100_diag.ksh.${dtg}.fail
     sleep ${delt}
   fi
 done

#-------------------------------------------------------------------------
# archive dms file for main run
#  you have to do it immediatly or the data will be re-write by post for major run
#-------------------------------------------------------------------------

 if [ ${dtg} = ${end_dtg} ] ; then 
  dtg_list="${fgdtg} ${dtg}"
 else 
  dtg_list="${fgdtg}"
 fi
 
 for dtg_arc in ${dtg_list} ; do 
   #==================*** archive MASOPS ***================#
   cd ${DB_PATH}/${DB_NAME}.ufs
  
   target="MASOPS"
   destin="${DMSFN}${dtg_arc}${DMSTL}"
  
   mkdir  ${destin}
  
   tau_list='003 004 005 006 007 008 009 010 011 012 013 014 015'
   for itau in ${tau_list} ; do 
     if [ -e  ${target}/*${dtg_arc}*${itau} ] ; then 
       cp -rf ${target}/*${dtg_arc}*${itau} ${destin}/
     fi
   done
  
   tau_list='000 024 048 072 096 120 144 168 192'
   for itau in ${tau_list} ; do 
     if [ -e  ${target}/*${dtg_arc}*${itau} ] ; then 
       mv -f  ${target}/*${dtg_arc}*${itau} ${destin}/
     fi
   done
  
   tar -zcvf ${destin}.tar.gz ${destin}
   if [ $? = 0 ] ;  then
     ssh ${DTMV} ssh dm07 -n " rm -f  ${DTMVDMSPATH}/${destin}.tar.gz"
     rm -rf ${destin}
   fi
  
   ssh ${DTMV} ssh dm07 -n " cp  ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz  ${DTMVDMSPATH}" 
   if [ $? != 0 ] ;  then 
     ssh ${DTMV} -n "scp  ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz ${SILOUSER}@hsmsvr:${DTMVDMSPATH}"
   fi 
   if [ $? = 0 ] ;  then
     rm -rf ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz
   fi
  
   # clear 12 hours before dms files
   cd ${DB_PATH}/${DB_NAME}.ufs/${target}
   rm -f -r  *${pr12dtg}*
  
  
   #==================*** archive MASOPS_ensres ***================#
   cd ${DB_PATH}/${DB_NAME}.ufs
  
   target="MASOPS_ensres"
   destin="${DMSFN}${dtg_arc}${DMSTL}_ensres"
  
   mkdir  ${destin}
  
   mv  ${target}/*${dtg_arc}* ${destin}/
  
   tar -zcvf ${destin}.tar.gz ${destin}
   if [ $? = 0 ] ;  then
     ssh ${DTMV} ssh dm07 -n "rm -f  ${DTMVDMSPATH}/${destin}.tar.gz"
     rm -rf ${destin}
   fi
  
   ssh ${DTMV} ssh dm07 -n "cp  ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz  ${DTMVDMSPATH}"
   if [ $? != 0 ] ;  then 
      ssh ${DTMV} -n "scp  ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz  ${SILOUSER}@hsmsvr:${DTMVDMSPATH}"
   fi
   if [ $? = 0 ] ;  then
     rm -rf ${DB_PATH}/${DB_NAME}.ufs/${destin}.tar.gz
   fi
 done
#-------------------------------------------------------------------------
# archive dms file for ens run
#-------------------------------------------------------------------------

if [ $opt_hyb -eq  1 ] ; then

#   #****  just same as main run
#   typeset -Z3 mem
   typeset -Z3 cmem3

  ((mem=1))
  while [ $mem -le $NTOTMEM ] ; do

    cmem3=$mem
    echo "Submit ${EXP_NAME}_archive_m${cmem3} ..." 

    ${NWPBINS}/0e01_archive.ksh ${fnconf} ${dtg} $cmem3 0

    if [ $mem -gt 20 ] ;  then
      rscgrp="-L rscgrp=large-x"
    else
      rscgrp=""
    fi

    ssh ${LGIN} ${PJSUB} ${rscgrp} -N ${EXP_NAME}_archive_m${cmem3} -o ${LOGDIR}/0c01_archive_m${cmem3}.${dtg} ${LOGDIR}/archive_${cmem3}

    ((mem=$mem+1))
  done

  #   check member's innovation status
  dtg10=20${dtg}
  delt=5
  tott=3000

  tt=1
  success=0
  while [ $tt -le $tott ] ; do
    sleep  ${delt}
    njob=`ssh ${LGIN} -n "pjstat -S" | grep "${DMSFN}_archive_m" | wc -l `
    if [ $njob -eq 0 ] ; then
      ((tt=tt+${tott}))
      sleep ${delt}
      success=1
      if [ -s ${STATUS}/archive_ENS.${dtg}.fail ] ; then
        success=0
      fi
    fi
    ((tt=${tt}+1))
  done

  if [ ${success} -eq 1 ] ; then
    echo "archive_ens.${dtg} success !!"  >> ${STATUS}/archive_ENS.${dtg}
    mv  ${STATUS}/archive_ENS.${dtg} ${STATUS}/archive.${dtg}.ok
  else
    echo "archive_ens.${dtg} some of member failed !!"
    mv  ${STATUS}/archive_ENS.${dtg}.fail  ${STATUS}/archive.${dtg}.fail
    cat ${STATUS}/archive_ENS.${dtg}.ok >>   ${STATUS}/archive.${dtg}.fail
    echo "$dtg $cjob fail,since some member innov fail!!" >> ${STATUS}/archive.${dtg}.fail
    exit -1
  fi
   
fi # end of opt_hyb 

#-------------------------------------------------------------------------
# archive diagnose and ncep sig file
#-------------------------------------------------------------------------
 ntype=3
 export CNVSTAT=${CNVSTAT:-cnvstat.${pr24dtg10}${DIAG_SUFFIX}.tar}
 export PCPSTAT=${PCPSTAT:-pcpstat.${pr24dtg10}${DIAG_SUFFIX}.tar}
 export OZNSTAT=${OZNSTAT:-oznstat.${pr24dtg10}${DIAG_SUFFIX}.tar}
 export RADSTAT=${RADSTAT:-radstat.${pr24dtg10}${DIAG_SUFFIX}.tar}

 diagfile[0]=$CNVSTAT
 diagfile[1]=$PCPSTAT
 diagfile[2]=$OZNSTAT
 diagfile[3]=$RADSTAT

 tarfile="${NWPDTGSAV}/${porm}_diagall.${pr24dtg10}.tar"

 cd  ${NWPDTGSAV}

 n=-1
 while [ $((n+=1)) -le $ntype ] ;do
   TAROPTS="-uvf"
   if [ ! -s ${tarfile} ]; then
      TAROPTS="-cvf"
   fi
   if [ -s ${diagfile[n]} ]; then
      tar $TAROPTS ${tarfile} ${diagfile[n]}
   fi
   if [ $? = 0 ] ;  then
     rm -rf ${diagfile[n]}
   fi
 done

 if [ $? = 0 ] ;  then
   ssh ${DTMV} ssh dm07 -n  "rm -f  ${DTMVDIAPATH}/${tarfile##*/}"
 fi

 biasfiles="satbias.${pr24dtg10} satbias_pc.${pr24dtg10} pcpbias.${pr24dtg10}"
 sigfiles="sigf06.${pr24dtg10} sfcf06.${pr24dtg10} siganl.${pr24dtg10} sfcanl.${pr24dtg10}"

 for file in ${biasfiles} ${sigfiles};  do
   TAROPTS="-uvf"
   if [ ! -s ${tarfile} ]; then
       TAROPTS="-cvf"
   fi
   if [ -s ${file} ]; then
     tar $TAROPTS ${tarfile} ${file}
   fi
    if [ $? = 0 ] ;  then
      rm -rf ${file}
    fi
 done


 gzip ${tarfile}
 ssh ${DTMV} ssh dm07 -n " cp  ${tarfile}.gz  ${DTMVDIAPATH}"
 if [ $? !=  0 ] ; then
   ssh ${DTMV} -n " scp  ${tarfile}  ${SILOUSER}@hsmsvr:${DTMVDIAPATH}"
 fi
 if [ $? =  0 ] ; then
   rm -rf ${tarfile}
 fi


#-----------------------------------------------------------------
# tar ensemble data 
#-----------------------------------------------------------------
 tarfile="${NWPDTGENS}/${porm}_sigfile_ens.${pr24dtg10}.tar"

 # tar sanl 
 cd ${NWPDTGENS}
 targets="sanl*${pr24dtg10}*"
 if [ -e ${targets} ] ; then
   if [ ! -e  ${tarfile} ] ; then
     tar -cvf ${tarfile} ${targets}
   else
     tar -rvf ${tarfile} ${targets}
   fi    
   
   if [ $? = 0 ] ;  then
     ssh ${DTMV} ssh dm07 -n  "rm -f  ${DTMVDIAPATH}/${tarfile##*/}"
     rm -rf ${targets}
   fi
 fi

 # tar sigf06
 cd ${NWPDTGENS}
 targets="sigf06*${pr30dtg10}*"
 if [ -e ${targets} ] ; then
   if [ ! -e  ${tarfile} ] ; then
     tar -cvf ${tarfile} ${targets}
   else
     tar -rvf ${tarfile} ${targets}
   fi
   if [ $? = 0 ] ;  then
     ssh ${DTMV} ssh dm07 -n  "rm -f  ${DTMVDIAPATH}/${tarfile##*/}"
     rm -rf ${targets}
   fi
 fi

 # tar sigf12 
 cd ${NWPDTGENS}
 targets="sigf12*${pr36dtg10}*"
 if [ -e ${targets} ] ; then
   if [ ! -e  ${tarfile} ] ; then
     tar -cvf ${tarfile} ${targets}
   else
     tar -rvf ${tarfile} ${targets}
   fi
   if [ $? = 0 ] ;  then
     ssh ${DTMV} ssh dm07 -n  "rm -f  ${DTMVDIAPATH}/${tarfile##*/}"
     rm -rf ${targets}
   fi
 fi

 gzip ${tarfile}
 ssh ${DTMV} ssh dm07 -n " cp  ${tarfile}.gz  ${DTMVDIAPATH}"
 if [ $? -ne  0 ] ; then
   ssh ${DTMV} -n " scp  ${tarfile}.gz  ${SILOUSER}@hsmsvr:${DTMVDIAPATH}"
 fi 

 if [ $? -eq  0 ] ; then
   rm -rf ${tarfile}.gz
 fi
   
#-------------------------------------------------------------------------
# clean files
#-------------------------------------------------------------------------
 #** dms files
 if [ -s ${NWPDTGGLB}/typhoon${pr12dtg}.dat ] ; then
   export adms=RE${DMSFN}${pr12dtg}${DMSTL}@${DB_NAME}
   ${DMSPATH}/rdmspurge -f  $adms
   export adms=BG${DMSFN}${pr12dtg}${DMSTL}@${DB_NAME}
   ${DMSPATH}/rdmspurge -f  $adms
 fi
 if [ $MP = "M" -o $MP = "m" ] ; then
   export adms=${pDMSFN}${pr12dtg}${pDMSTL}@${DB_NAME}
   ${DMSPATH}/rdmspurge -f  $adms
   cd ${DB_PATH}/${DB_NAME}.ufs/MASOPSOI
   rm -rf *${pr12dtg}*
 fi
 
 #** observation files and ges files
 cd ${NWPDTGGLB}

 #rm -f ${porm}.*.${dtg} sfcf06.20${fgdtg}.dat sigf06.20${fgdtg}* ?obs${dtg10}.dat.*
 rm -f ${porm}.*.${dtg} ?obs${dtg10}.dat.*
 rm -f *bufr*${fgdtg}*
 rm -f g??f${dtg}.dat

 #** ozone files and obs
 rm -f o3.${pr48dtg} ncepoz.${pr48dtg}
 if [ $pr48hh -eq 00 ] ; then
   rm -f ncepoz.${pr48yymmdd}.tar oi${pr48yymmdd}.tar ncepbufr.${pr48yymmdd}.tar
 fi

 #** dtg_ens
 rm -rf ${NWPDTGENS}/*${pr48dtg}*


