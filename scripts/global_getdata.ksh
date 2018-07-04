#!/bin/ksh
#--- document block 
#
#   Purpose : get CWB GFS and GSI necessary data 
#
#  Created by Deng-Shun Chen
#  Date : 2018.01.17
#
#  Log : 
#   2018-02-19  Deng-Shun  change ncepbufr data path on hsmsvr(silo), 
#                          and after 20170715 ncep change bufr prefix gads1 to gads
#   2018-02-26  Deng-Shun  relocation bug-fix
#   2018-03-01  Deng-Shun  relocation bug-fix and add capability of reading NA10
#
#--- end of document block

export general_dtg=${general_dtg:-''}
export general_yymmdd=`echo ${general_dtg} | cut -c1-6`
export general_yyyymm=`echo 20${general_dtg} | cut -c1-6`
export general_yy=`echo ${general_dtg} | cut -c1-2`
export general_mm=`echo ${general_dtg} | cut -c3-4`
export general_dd=`echo ${general_dtg} | cut -c5-6`
export general_hh=`echo ${general_dtg} | cut -c7-8`
export general_00z=`echo ${general_dtg} | cut -c1-6`00

export firstguess_dtg=`${NWPBINS}/0x01_Caldtg.ksh ${general_dtg} -6`
export firstguess_yymmdd=`echo ${firstguess_dtg} | cut -c1-6`
export firstguess_yy=`echo ${firstguess_dtg} | cut -c1-2`
export firstguess_mm=`echo ${firstguess_dtg} | cut -c3-4`
export firstguess_dd=`echo ${firstguess_dtg} | cut -c5-6`
export firstguess_hh=`echo ${firstguess_dtg} | cut -c7-8`

export ncepecdb=${ncepecdb:-"${DB_PATH}/${NCEPECDB}.ufs/"}
export masopsdb=${masopsdb:-"${DB_PATH}/${DB_NAME}.ufs/"}

if [ ! -s ${ncepecdb} ]  ; then
    mkdir -p  ${ncepecdb}
fi
if [ ! -s ${ncepecdb}/SSTDMS ] ; then
    mkdir -p  ${ncepecdb}/SSTDMS
fi
if [  ! -s ${ncepecdb}/SNOWDMS ] ; then
   mkdir  ${ncepecdb}/SNOWDMS
fi
if [ ! -s ${ncepecdb}/SSTNMC ] ; then
   mkdir ${ncepecdb}/SSTNMC
fi

#----------------------------------------------------------
#  get first guess and bias files of post run for major run
#----------------------------------------------------------
if [ $MP = "M" -o $MP = "m" ] ; then
  #  1. dms keys
  export dmsfilename=${pDMSFN}${firstguess_dtg}${pDMSTL}
  cd ${DB_PATH}/${DB_NAME}.ufs
  if [ ! -s ${dmsfilename} ] ; then
    if [ ! -s ${dmsfilename}.tar.gz ] ; then
      ssh ${DTMV} -n "scp  ${pSILODMSPATH}/${dmsfilename}.tar.gz ${DB_PATH}/${DB_NAME}.ufs"
    fi
  fi
  gunzip ${dmsfilename}.tar.gz
  tar -xvf   ${dmsfilename}.tar
  rm -f ${dmsfilename}.tar
  cd ${dmsfilename}
  mv *006 ../MASOPS
  cd ..
  rm -f -r   ${dmsfilename}

  #  2. bias files
  file_list='satbias satbias_ang satbias_pc pcpbias'
  for file in $file_list  ; do
    if [ -s ${MDIR}/${pDMSFN}/dtg_save/${file}.20${firstguess_dtg} ] ; then
      cp  ${MDIR}/${pDMSFN}/dtg_save/${file}.20${firstguess_dtg} ${DTGSAV}
    fi
  done

  if [ ! -s  ${DTGSAV}/satbias.20${firstguess_dtg} -o ! -s ${DTGSAV}/satbias_pc.20${firstguess_dtg} ] ; then
    ssh ${DTMV} -n "scp ${pSILODIAPATH}/p_diagall.20${fgyymmdd}.tar  ${NWPDTGGLB}"
    cd ${NWPDTGGLB}
    tar -xvf p_diagall.20${fgyymmdd}.tar satbias.20${firstguess_dtg}
    tar -xvf p_diagall.20${fgyymmdd}.tar satbias_pc.20${firstguess_dtg}
  fi
fi

#--------------------------------------
# 20111108
#  prepare sst, snowice and ec
#  dtg_notproc    before 11110800, the resolution of operation is t240l40,
#                 do not proc now.
  dtg_notproc=11110800

# 20131231
#   sst, before 2013123118,  SST from operational archive(MASOPS)
#        after  2013123118,  SST from NCEP archive(NCEPGRID)
  dtg_2013=13123118

# 20150213  note :
#  NCEP SST (NA08) have 00Z only. The 06/12/18Z in npcagfs are copy
#                  from 00Z by NWP control.
# 20171001 note : start from 2017100100
# NCEP SST (NA10) have 00Z only. The 06/12/18Z in npcagfs are copy
#                 from 00Z by NWP control.
  dtg_2017=17100100

#
#
#--------------------------------------
cd ${NWPDTGGLB}

#--- do not proc SST before 11110800, job stop!!!
if [ ${general_dtg} -le ${dtg_notproc} ] ; then
  echo "before ${dtg_notproc}, no SST process here!!" >> ${LOGDIR}/STOPgdas.${general_dtg}
  exit -1
fi

sstdir=${ncepecdb}/${SSTDMS%%@*}/20${general_dtg}000000

if [ ! -s ${sstdir}/W00100${gfsflag}0GH0460800 ] ; then
  #-----  sst, before 2013123118,  SST from operational archive
  if [ ${general_dtg} -le ${dtg_2013} ] ; then
    export SSTSILO=MASOPS${general_dtg}GG0GM-0024@NWPDB-${general_mm}@archive@hsmsvr
    export TEMPSST=${SSTDMS}

    #GG0G for oper now(20150331 note)
    if [ ! -s ${sstdir}/W00100GG0GH0460800 ] ;then
      ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W001000000????20${general_dtg}*" ${SSTSILO} ${TEMPSST}"
    fi
    if [ ! -s ${sstdir}/W00100GG0GH0460800 ] ;then
      echo "$nowt $general_dtg sst W00100 fail" > ${STATUS}/sst.${general_dtg}.fail
    else
      export SFGRID=${SSTDMS}
      export NCEPGRID=${SSTDMS}
      mkdir -p gg2gg_${general_dtg} ; cd gg2gg_${general_dtg}
      echo "W001000000GG0G20${general_dtg}00H0460800" > gg2gg.fil
      echo "nomoda" >> gg2gg.fil
cat > namlsts.getsst << EOF
 &sstlst
  im_i=960,
  im_o=${LONA},
  flag_i="GG0G",
  flag_o="${gfsflag}0G",
  idmsfn='SFGRID',
  odmsfn='NCEPGRID',
  readfil='gg2gg.fil',
 &end
EOF
    fi
  else  # after 13123118 
    mkdir -p gg2gg_${general_dtg} ; cd gg2gg_${general_dtg}

    sstdir00z=${ncepecdb}/SSTNMC/20${general_00z}000000
       sstdir=${ncepecdb}/SSTNMC/20${general_dtg}000000

    # download SST from silo for 00Z only 
    if [ ! -s ${sstdir00z}/W00100NA??* ] ; then
      export SSTSILO=NCEPGRID${general_00z}_000-024@NCEPGRID-${general_mm}@archive@hsmsvr
      export TEMPDMS=SSTNMC@${NCEPECDB}
      ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W001000000NA??20${general_00z}*" ${SSTSILO} ${TEMPDMS}"
    fi

    # make directory 
    if [  ! -s ${sstdir} ] ; then
        mkdir  ${sstdir}
    fi

    # only 00z has SST data 
    cp ${sstdir00z}/W00100NA??* ${sstdir}

    # convert sst resolution 
    export SSTNMC=SSTNMC@${NCEPECDB}
    export NCEPGRID=${SSTDMS}

    # create namelist and dms key list file
    if [ ${general_dtg} -lt ${dtg_2017}  ] ; then 
      echo "W001000000NA0820${general_dtg}00H0259200" > gg2gg.fil
      echo "nomoda" >> gg2gg.fil
cat > namlsts.getsst << EOF
 &sstlst
  im_i=720,
  im_o=${LONA},
  flag_i="NA08",
  flag_o="${gfsflag}0G",
  idmsfn='SSTNMC',
  odmsfn='NCEPGRID',
  readfil='gg2gg.fil',
 &end
EOF
   else  # after Oct 1, 2017
      echo "W001000000NA1020${general_dtg}00H9331200" > gg2gg.fil
      echo "nomoda" >> gg2gg.fil
cat > namlsts.getsst << EOF
 &sstlst
  im_i=4320,
  im_o=${LONA},
  flag_i="NA10",
  flag_o="${gfsflag}0G",
  idmsfn='SSTNMC',
  odmsfn='NCEPGRID',
  readfil='gg2gg.fil',
 &end
EOF
    fi 
  fi

  # Convert SST resolution 
  ${NWPBIN}/getsst
  if [ $? -eq  0 ] ; then
    echo "$nowt $general_dtg sst W00100 ok" > ${STATUS}/sst.${general_dtg}.ok
    cd .. ; rm -f -r  gg2gg_${general_dtg}
  else
    echo "$nowt $general_dtg sst W00100 fail" > ${STATUS}/sst.${general_dtg}.fail
    cd .. ; rm -f -r  gg2gg_${general_dtg}
    exit -1
  fi

else
  echo "$nowt $dtg sst W00100 ok" > ${STATUS}/sst.${general_dtg}.ok
fi 


if [ ${opt_newsst} -eq 1 ] ; then 
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W001000000${gfsflag}0G20${general_00z}*" ${general_yyyymm}@OSTIA  ${MASOPS}"
  sstdir_f=${masopsdb}/MASOPS/20${general_00z}000000
  sstdir_t=${masopsdb}/MASOPS/20${general_dtg}000000
  if [ ! -e ${sstdir_t} ] ; then
    mkdir ${sstdir_t}
  fi  
  cp ${sstdir_f}/W00100${gfsflag}0G* ${sstdir_t}/
else
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W001000000${gfsflag}0G20${general_dtg}*" ${SSTDMS} ${MASOPS}"
fi

#--------------------------------------------------------------------------
# Get NCEP SnowIce dms key  
#--------------------------------------------------------------------------
cd ${NWPDTGGLB}

typeset -Z7 rleng
((rleng=LONB*LATB))
snowicedir=${ncepecdb}/${SNOWDMS%%@*}/20${general_dtg}000000

if [ ! -s ${snowicedir}/B00650${gfsflag}0GH${rleng} -o ! -s ${snowicedir}/W00091${gfsflag}0GH${rleng} ] ; then
  export SNOWICE=SNOWICE@${NCEPECDB}
  if [  ! -s ${ncepecdb}/SNOWICE ] ; then
     mkdir  ${ncepecdb}/SNOWICE
  fi
  ##-----------------------------------------------------
  #  NCEP dms file name at silo
  #  before 14032400   ,  NCEPGRID${general_dtg}_000-030
  #  after  14032400   ,  NCEPGRID${general_dtg}_000-024
  ##-----------------------------------------------------
  dtg_chg=14032400
  if [ ${general_dtg} -lt ${dtg_chg} ] ; then
    export SNOWDMS00z=NCEPGRID${general_00z}_000-030@NCEPGRID-${general_mm}@archive@hsmsvr
  else
    export SNOWDMS00z=NCEPGRID${general_00z}_000-024@NCEPGRID-${general_mm}@archive@hsmsvr
  fi 
  ##-----------------------------------------------------
  # NCEP Snow Depth of water state at the surface(B00650)
  # NCEP Snow Fraction (B00651) 
  ##-----------------------------------------------------
  if [ ! -s ${ncepecdb}/SNOWICE/20${general_00z}000000/B00650NA05H0259920 ] ; then
    ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"B006500000NA0520${general_00z}*" $SNOWDMS00z $SNOWICE"
    ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"B006510000NA0520${general_00z}*" $SNOWDMS00z $SNOWICE"
  fi
  ##-----------------------------------------------------
  # NCEP Sea Ice Fraction (W00091) 
  # before 15021400 using NA04 
  # after  15021400 using NA05 
  ##-----------------------------------------------------
  dtg_2015=15021400
  if [ ${general_dtg} -le ${dtg_2015} ] ; then
    if [ ! -s ${ncepecdb}/SNOWICE/20${general_00z}000000/W00091NA04H0259200 ] ; then
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"W000910000NA0420${general_00z}*" $SNOWDMS00z $SNOWICE"
    fi
  else
    if [ ! -s ${ncepecdb}/SNOWICE/20${general_00z}000000/W00091NA05H0259920 ] ; then
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"W000910000NA0520${general_00z}*" $SNOWDMS00z $SNOWICE"
    fi
  fi

  ##-----------------------------------------------------
  # Convert NCEP lat-lon to CWB gaussian grid for IC/BC
  ##-----------------------------------------------------
  export BCKOPS=${BCKOPS}
  export TMPSNOW=${SNOWDMS}
  if [ -s ${ncepecdb}/SNOWICE/20${general_00z}000000/W00091NA05H0259920 ] ; then
    nowt=`date`
    ${NWPBIN}/${gfsflag}_getsnowice ${general_dtg} $SNOWICE $TMPSNOW $BCKOPS
    if [ $? -eq 0  ] ; then
      echo "$nowt $dtg snowice SNOWICE OK" >> ${STATUS}/snowice.${general_dtg}.ok
    else
      echo "$nowt $dtg snowice SNOWICE FAIL" >> ${STATUS}/snowice.${general_dtg}.fail
      exit -1
    fi
  elif [ -s ${ncepecdb}/SNOWICE/20${general_00z}000000/W00091NA04H0259200 ] ; then
    nowt=`date`
    ${NWPBIN}/${gfsflag}_getsnowice_2014 ${general_dtg} $SNOWICE $TMPSNOW $BCKOPS
    if [ $? -eq 0  ] ; then
      echo "$nowt $dtg snowice SNOWICE OK" >> ${STATUS}/snowice.${general_dtg}.ok
    else
      echo "$nowt $dtg snowice SNOWICE FAIL" >> ${STATUS}/snowice.${general_dtg}.fail
      exit -1
    fi
  else
    nowt=`date`
    echo "${gfsflag}_getsnowice ${general_dtg} SNOWICE TMPSNOW BCKOPS FAIL!!"
    echo "$nowt $dtg snowice SNOWICE fail" >> ${STATUS}/snowice.${general_dtg}.fail
  fi
else
  echo "$nowt $dtg snowice SNOWICE OK" >> ${STATUS}/snowice.${general_dtg}.ok
fi

if [ ${opt_newsst} -eq 1 ] ; then
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W000900000${gfsflag}0G20${general_dtg}*" ${SNOWDMS} ${MASOPS}"
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W000910000${gfsflag}0G20${general_00z}*" ${general_yyyymm}@OSTIA ${MASOPS}"
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"B006500000${gfsflag}0G20${general_dtg}*" ${general_yyyymm}@OSTIA ${MASOPS}"
  sstdir_f=${masopsdb}/MASOPS/20${general_00z}000000
  sstdir_t=${masopsdb}/MASOPS/20${general_dtg}000000
  if [ ! -e ${sstdir_t} ] ; then
    mkdir ${sstdir_t}
  fi
  cp ${sstdir_f}/W00091${gfsflag}0G* ${sstdir_t}/
else
  #--- copy NCEP sst and snow dmsfile
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W000900000${gfsflag}0G20${general_dtg}*" ${SNOWDMS} ${MASOPS}"
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W000910000${gfsflag}0G20${general_dtg}*" ${SNOWDMS} ${MASOPS}"
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"B006500000${gfsflag}0G20${general_dtg}*" ${SNOWDMS} ${MASOPS}"
fi

#--------------------------------------------------------------------------
#--- Get ECMWF data
#--------------------------------------------------------------------------
export frdmsfn=ECGRID${general_dtg}@ECGRID-${general_mm}@archive@hsmsvr
export todmsfn=ECGRID@${NCEPECDB}
${DMSPATH}/rdmscrt -l34 todmsfn
if [ $MP = "P" -o $MP = "p" ] ; then
  if [ ${general_hh} -eq 00  -o ${general_hh} -eq 12 ] ;then
    if [  ! -s ${ncepecdb}/ECGRID/20${general_dtg}000000/850100EC05H0259920 ] ; then
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8501000000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8505100000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"2002000000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"2002100000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"5002000000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"5002100000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"7002000000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"7002100000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8502000000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8502100000EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
    else
      nowt=`date` ; echo "$nowt $dtg ec ok" > ${STATUS}/ec.${general_dtg}.ok
    fi
  fi
else
  if [ ${general_hh} -eq 00  -o ${general_hh} -eq 12 ] ;then
    if [  ! -s ${ncepecdb}/ECGRID/20${general_dtg}000024/850100EC05H0259920 ] ; then
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8501000024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8505100024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"2002000024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"2002100024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"5002000024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"5002100024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"7002000024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"7002100024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8502000024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
      ssh  ${DTMV} -n "${DMSPATHx86}/rdmscpy  -l34 -k"8502100024EC0520${general_dtg}*" ${frdmsfn} ${todmsfn}"
    else
      nowt=`date` ; echo "$nowt $dtg ec ok" > ${STATUS}/ec.${general_dtg}.ok
    fi
  fi
fi

nowt=`date` ; echo "$nowt $dtg ec ok" > ${STATUS}/ec.${general_dtg}.ok

#---------------------------------------------------
#  if typhoon${general_dtg}.dat is exist , 
#  prepare keys for TC bogus in RELOCATE
#---------------------------------------------------
if [ -s ${GFSDIR}/typhoon${general_dtg}.dat ] ;then
  ${DMSPATH}/rdmscrt -l34 ${RELOCATE}
  ${DMSPATH}/rdmscpy -l34 -k"S001000006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE 
  ${DMSPATH}/rdmscpy -l34 -k"S005400006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"B006500006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S005A10006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S005C00006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S015B00006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S025B00006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S011000006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"S021000006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"B102000006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"B102100006G?0G20${firstguess_dtg}*" $MASOPS $RELOCATE

  ${DMSPATH}/rdmscpy -l34 -k"B006500000G?0G20${general_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"B006510000G?0G20${general_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"W000900000G?0G20${general_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"W000910000G?0G20${general_dtg}*" $MASOPS $RELOCATE
  ${DMSPATH}/rdmscpy -l34 -k"W001000000G?0G20${general_dtg}*" $MASOPS $RELOCATE
fi

#---------------------------------------------------
## prepare ozone
#---------------------------------------------------
cd ${NWPDTGGLB}
if [ $MP = "P" -o $MP = "p" ] ;then
  # post run : get oz of anadtg
  ozdtg=${general_dtg}
else
  # major run : get oz of pre6hr-anadtg
  ozdtg=`${NWPBINS}/0x01_Caldtg.ksh ${general_dtg} -24`
fi

yymmdd=`echo ${ozdtg} | cut -c1-6`
if [ ! -s  ncepoz.${ozdtg} ] ; then
  if [ ! -s ncepoz.${yymmdd}.tar ] ; then
     if  [ -s ${NCEPOZ}/ncepoz.${yymmdd}.tar  ] ;then
        cd ${NWPDTGGLB}
        cp  ${NCEPOZ}/ncepoz.${yymmdd}.tar .
     else
        cd ${NWPDTGGLB}
        remozpath=${SILOUSER}@hsmsvr:/op/bak/amdp/ncepOzone
        ssh ${DTMV} -n "scp ${remozpath}/ncepoz.${yymmdd}.tar  ${NWPDTGGLB}"
        cp ncepoz.${yymmdd}.tar ${NCEPOZ}
        if [ $? -ne 0 ] ; then 
          ssh ${DTMV} -n "scp ${remozpath}/ncepoz.${yymmdd}_T511.tar  ${NWPDTGGLB}"
          cp ncepoz.${yymmdd}_T511.tar ${NCEPOZ}/ncepoz.${yymmdd}.tar
        fi          
     fi
  fi
  sleep 2
  tar -xvf  ncepoz.${yymmdd}.tar ncepoz.${ozdtg}
  if [ $opt_hyb -eq 1 ] ; then
    if [ -s ncepoz.${ozdtg} ] ; then
      cp ncepoz.${ozdtg} ${NWPDTGENS}
      nowt=`date`
      echo "$nowt $dtg oz ok" > ${STATUS}/oz.${general_dtg}.ok
    else
      nowt=`date`
      echo "$nowt $dtg oz fail" > ${STATUS}/oz.${general_dtg}.fail
    fi
  else
    echo "$nowt $dtg oz ok" > ${STATUS}/oz.${general_dtg}.ok
  fi
else
  nowt=`date`
  echo "$nowt $dtg oz ok" > ${STATUS}/oz.${general_dtg}.ok
fi

#---------------------------------------------------
# prepare obs
#---------------------------------------------------
echo "prepare obs optobs="${optobs}
if [ $optobs -eq 1 ] ; then
  if [ $MP = p -o  $MP = P ] ; then
    pm=p
    if [ $general_yymmdd -gt 170715 ] ; then
      prefix_obs=gdas
    else
      prefix_obs=gdas1
    fi 
  else
    pm=m
    prefix_obs=gfs
    remfggepath=${SILOUSER}@hsmsvr:/op/bak/archive/oi
    echo 'NWPDTGGLB='$NWPDTGGLB
    if  [ ! -s  oi${general_yymmdd}.tar ] ; then
      if  [  -s  ${CWBFGGE}/oi${general_yymmdd}.tar ] ; then
        cp ${CWBFGGE}/oi${general_yymmdd}.tar  ${NWPDTGGLB}
      else
        ssh ${DTMV}  -n "scp ${remfggepath}/oi${general_yymmdd}.tar  ${NWPDTGGLB}"
      fi
    fi
    cd ${NWPDTGGLB}
    if [ -s oi${general_yymmdd}.tar ] ; then
      tar -xvf oi${general_yymmdd}.tar gusf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar guxf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gukf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gupf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar guaf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gtsf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gtwf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gsmf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gshf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gsaf${general_dtg}.dat
      tar -xvf oi${general_yymmdd}.tar gttf${general_dtg}.dat
      nowt=`date`
      echo "$nowt $dtg obsoi ok" > ${STATUS}/obsoi.${general_dtg}.ok
    else
      nowt=`date`
      echo "$nowt $dtg obsoi fail" > ${STATUS}/obsoi.${general_dtg}.fail
    fi
    export OIQC_MASIN=${pDMSFN}${firstguess_dtg}${pDMSTL}@${DB_NAME}
    export OIQC_MASOUT=OI${OIQC_MASIN}
    ${DMSPATH}/rdmscrt -l34 OIQC_MASOUT
    ${NWPBIN}/${gfsflag}_preoiqc ${general_dtg} 0006
    if [ $? != 0 ] ; then
      echo "${gfsflag}_preoiqc Fail"
      nowt=`date`
      echo "$nowt $dtg ${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/${cjob}.${general_dtg}.fail
      exit -1
    fi
    cd ${NWPDTGGLB}
    ls -l crdate
    ls -l gus*
    export MASOPS=${OIQC_MASOUT}
    ${NWPBIN}/${gfsflag}_mvoi_noana
    ${NWPBIN}/${gfsflag}_qoi_noana
    if [ $? != 0 ] ; then
      echo "Gqoi execute Fail"
      nowt=`date`
      echo "$nowt $dtg ${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/${cjob}.${general_dtg}.fail
      exit -1
    fi

   ## dropsonde qc
    if [ -s ${NWPOIGLB}/guxf${general_dtg}.dat ] ; then
      export MASOPS=${OIQC_MASOUT}
      ${NWPBIN}/GG_mvoi_drps_noana
      if [ $? != 0 ] ; then
        echo "`date`:GG_mvoi_drps_noana ${general_dtg} Fail" >> ${LOGDIR}/warning.log
        nowt=`date`
        echo "$nowt $dtg ${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/${cjob}.${general_dtg}.fail
        exit -1
      fi
      ${NWPBIN}/GG_qoi_drps_noana
      if [ $? != 0 ] ; then
        echo "`date`:GG_qoi_drps_noana ${general_dtg} Fail" >> ${LOGDIR}/warning.log
        nowt=`date`
        echo "$nowt $dtg ${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/${cjob}.${general_dtg}.fail
        exit -1
      fi
    fi
  fi


  if [  ! -s  ${NWPDTGGLB}/ncepbufr.${general_yymmdd}.tar ] ; then
    if [ -s ${NCEPBUFR}/ncepbufr.${general_yymmdd}.tar  ] ; then
      cd ${NWPDTGGLB}
      cp  ${NCEPBUFR}/ncepbufr.${general_yymmdd}.tar  .
    else
      
      ssh ${DTMV} -n "scp ${SILOUSER}@hsmsvr:/op/bak/amdp/ncepbufr/20${general_yy}/ncepbufr.${general_yymmdd}.tar  ${NWPDTGGLB}/ncepbufr.${general_yymmdd}.tar"
      if [ ! -s ${NCEPBUFR} ] ; then
         mkdir  ${NCEPBUFR}
      fi
      cp ${NWPDTGGLB}/ncepbufr.${general_yymmdd}.tar ${NCEPBUFR}
    fi
  fi

  sleep  3

  cd ${NWPDTGGLB}
  suffix=tm00.bufr_d

  typeset -i nn
  nn=1
  while [ $nn -le $ntype ] ; do
     tmpf=`echo $bufrlst  | cut -d" " -f$nn `
     name=`echo $namelst  | cut -d" " -f$nn `
     if [ $tmpf = prepbufr ] ; then
        if [ ! -s ${pm}.${name}.${general_dtg} ]  ; then
          rm -f  ${prefix_obs}.${tmpf}.${general_dtg}
          tar -xvf ncepbufr.${general_yymmdd}.tar ${prefix_obs}.${tmpf}.${general_dtg}
          mv ${prefix_obs}.${tmpf}.${general_dtg}  ${pm}.${name}.${general_dtg}
        fi
     else
        if [ ! -s ${pm}.${name}.${general_dtg} ] ; then
          rm -f  ${prefix_obs}.${tmpf}.${suffix}.${general_dtg}
          tar -xvf ncepbufr.${general_yymmdd}.tar ${prefix_obs}.${tmpf}.${suffix}.${general_dtg}
          mv ${prefix_obs}.${tmpf}.${suffix}.${general_dtg}  ${pm}.${name}.${general_dtg}
        fi
     fi
     nn=nn+1
  done
  nowt=`date`
  echo "$nowt $dtg obsbufr ok" > ${STATUS}/obsbufr.${general_dtg}.ok
else
  nowt=`date`
  echo "$nowt $dtg obsoi ready,optobs=0," > ${STATUS}/obsoi.${general_dtg}.ok
  echo "$nowt $dtg obsbufr ready,optobs=0," > ${STATUS}/obsbufr.${general_dtg}.ok
fi


