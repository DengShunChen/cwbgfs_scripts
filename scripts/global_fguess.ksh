#!/bin/ksh
#-------------------------------------------------------------------------------
# Purpose : convert dms to NCEP sigma file 
#
# LOG:
#   2017-10-26 Deng-Shun Created
#   2018-02-27 Deng-Shun fix the missing namelist of relocation module
#
#
#
#  Created by Deng-Shun Chen
#  Email :: dschen@cwb.gov.tw
#-------------------------------------------------------------------------------

# forecast time
export OBS_BIN=${OBS_BIN:-06}
export UPDATEHR=${UPDATEHR:-6}
export DTGDIR=${DTGDIR:-${NWPDTGGLB}}
# setup workdir
export WORKDIR=${WORKDIR:-${NWPWRK}/fg_f${OBS_BIN}}

if [ ! -s ${WORKDIR} ] ; then 
  mkdir ${WORKDIR}
fi

cd ${WORKDIR}
# setup namelist 
export LEVS=${LEVS:-}
export JCAP=${JCAP:-${JCAPA}}
export LON=${LON:-${LONA}}
export LAT=${LAT:-${LATA}}
export TAU=${TAU:-6}
export FLAG=${FLAG:-${gfsflag}}
export fgdtg=${fgdtg:-`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -${UPDATEHR} `}
export CDTG=${CDTG:-${fgdtg}}
export l4denvar=${l4denvar:-'.false.'}
# setup filename
export sigfn=${sigfn:-sigf${OBS_BIN}.20${CDTG}}
export sfcfn=${sfcfn:-sfcf${OBS_BIN}.20${CDTG}}
export MASOPS=${MASOPS:-${MASOPS}}
export BCKOPS=${BCKOPS:-${BCKOPS}}
export siglevel=${siglevel:-${NWPDATANA}/global_siglevel.cwbl${LEVS}hybrid.txt}
#export siglevel=${siglevel:-${NWPDATANA}/global_siglevel.l${LEVS}hybd.txt}
export GLB_TYPHINI=${GLB_TYPHINI:-"$GFSDIR"}

#-------------------------------------------------------------------------------
# setup namelist
#-------------------------------------------------------------------------------
cat > ${WORKDIR}/pre_ana.input << EOF
&pre_ana
  nsigcwb=${LEVS},
  jcapcwb=${JCAP},
  imcwb=${LON},
  jmcwb=${LAT},
  jcapncep=382,
  nsigncep=64,
  tau=${TAU}.,
  flag='${FLAG}',
  idmsfn='MASOPS',
  bckdmsfn='BCKOPS',
  fn_sigi='sigicwb.dat',
  idvc=2,
  ptop=0.1,
  cdtg=${CDTG},
  l4denvar=${l4denvar},
/
EOF
#-------------------------------------------------------------------------------
#  vertical level information
#-------------------------------------------------------------------------------
  cd ${WORKDIR}
  echo ${dtg} > ./crdate

  #  first guess
  cp ${DTGDIR}/$O3fn ./
  rm -f ./ncepo3
  ln -fs ${O3fn} ./ncepo3

  cp ${siglevel} ./sigicwb.dat

#-------------------------------------------------------------------------------
# typhoon relocate, only when optreloc=1(now for main run only  -  201402170
#-------------------------------------------------------------------------------
if [ -s ${NWPOIGLB}/typhoon${dtg}.dat -a ${optreloc} -eq 1  -a $optrun = "MAIN" ] ; then

  Gdms="${DMSPATH}/rdmscpy"

  cd $GFSDIR

  # create relocation dms file
  ${DMSPATH}/rdmscrt -l RELOCATE

  # copy typhoon information file
  cp ${NWPOIGLB}/typhoon${dtg}.dat $GLB_TYPHINI

  # create date time infomation file
  echo  ${dtg} > ./crdate

  # create namelist  
cat > namlsts_typ << EOF
&modlst
 taup=  6.0,
 ptop= 0.1,
 ksgeo= 2,
&end
EOF

  # Run reloc 
  ${RELOCexe}
  if [ $? != 0 ] ; then
    echo "${gfsflag}_reloc Fail"
    nowt=`date`
    echo "$nowt $dtg fguess fail",since reloc fail  >> ${STATUS}/fguess_${optrn}.${dtg}.fail
    exit -1
  else
    if [ $MP = M ] ; then
      fn_relocdms=RE${pDMSFN}${dtg}${DMSTL}
    else
      fn_relocdms=RE${DMSFN}${dtg}${DMSTL}
    fi
    cntkey=`ls ${DB_PATH}/${DB_NAME}.ufs/${fn_relocdms}/20${fgdtg}000006 | wc -l`   
    if [ $cntkey -le 60 ] ; then
      echo "$nowt $dtg fguess fail,since reloc fail,no relocate to continue" >> ${STATUS}/fguess_${optrn}.${dtg}.warning
      ${Gdms} -l 34 -k??????0006${gfsflag}??20${fgdtg}00* MASOPS RELOCATE
    fi
    echo "${gfsflag}_reloc OK"
    ${Gdms} -l 34 -kS001000006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS005A10006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kB006500006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS005400006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS005C00006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS015B00006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS025B00006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS011000006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kS021000006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kB102000006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kB102100006${gfsflag}0G20${fgdtg}00* MASOPS RELOCATE
    ${Gdms} -l 34 -kL????00006${gfsflag}MG20${fgdtg}00* MASOPS RELOCATE
  fi

  export sstdms=$SSTDMS
  export snowdms=$SNOWDMS
  ymd=`echo $dtg | cut -c1-6`
  ${Gdms} -l 34 -kW001000000${gfsflag}0G20${dtg}00* sstdms  RELOCATE
  ${Gdms} -l 34 -kW000900000${gfsflag}0G20${dtg}*   snowdms RELOCATE
#  export XLFRTEOPTS="namelist=new"
  export MASOPS=$RELOCATE
fi

#-------------------------------------------------------------------------------
# sigma fields first guess
#-------------------------------------------------------------------------------
cd ${WORKDIR}

rm -f ./fort.40

${FGUESSexe} < pre_ana.input
if [ $? != 0 ] ; then
  echo "${gfsflag}_fguess_gsi Fail"
  nowt=`date`
  echo "$nowt $dtg fguess fail,${gfsflag}_fguess_gsi fail" >> ${STATUS}/fguess_${optrun}.${dtg}.fail
  exit -1
else
  if [ -s fort.40 ] ; then
    mv ./fort.40 ${DTGDIR}/${sigfn}
    echo "${gfsflag}_fguess_gsi OK"
    echo "$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    rm -f ./fort.37
  elif [ -s sigfile ] ; then
    mv ./sigfile ${DTGDIR}/${sigfn}
    echo "${gfsflag}_fguess_gsi OK"
    echo "$nowt $dtg fguess ok" >> ${STATUS}/fguess_${optrun}.${dtg}.ok
    rm -f ./ncepo3
  else
    echo "${gfsflag}_fguess_gsi fail"
    nowt=`date`
    echo "$nowt $dtg fguess fail" >> ${STATUS}/fguess_${optrun}.${dtg}.fail
    rm -f ./ncepo3
    exit -1
  fi
fi

if [ $optrun != "ENSRES" ] ; then
  # surface guess
  rm -f ./sfcges.dat

  ${SFCGESexe} < pre_ana.input
  if [ $? != 0 ] ; then
    nowt=`date`
    echo "${gfsflag}_sfcges_gsi  Fail"
    echo "$nowt $dtg sfcges fail" >> ${STATUS}/sfcges_${optrun}.${dtg}.fail
    exit -1
  else
    if [ -s sfcges.dat ] ; then
      echo "${gfsflag}_sfcges_gsi OK !"
      mv ./sfcges.dat ${DTGDIR}/$sfcfn
      echo "$nowt $dtg sfcges ok" >> ${STATUS}/sfcges_${optrun}.${dtg}.ok
    else
      echo "${gfsflag}_sfcges_gsi  fail !"
      echo "$nowt $dtg sfcges fail" >> ${STATUS}/sfcges_${optrun}.${dtg}.fail
      exit -1
    fi
  fi
fi

