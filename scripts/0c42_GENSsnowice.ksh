#!/bin/ksh
if [ $# -eq 0 ]
then
 echo "usage : GENSsnowice.ksh fnconf dtg imem"
 exit
else
  fnconf=$1
  dtg=$2
  imem=$3
fi

. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fnconf}.set
set -x

export indms=SNOWICE@${NCEPECDB}
export outdms=MASOPS_mem${imem}@${DB_NAME}
export bckdms=${BCKENS}

export masopsdb=${masopsdb:-"${DB_PATH}/${DB_NAME}.ufs/"}

export general_dtg=${general_dtg:-${dtg}}
export general_yyyymm=`echo 20${general_dtg} | cut -c1-6`
export general_00z=`echo ${general_dtg} | cut -c1-6`00


if [ ${dtg} -le 15011400 ] ; then
  time ${NWPBIN}/GENS_getsnowice_2014 $dtg indms outdms bckdms
else
  time ${NWPBIN}/GENS_getsnowice $dtg indms outdms bckdms
fi
if [ $? -eq 0 ] ; then
  fail=0
else
  fail=1
fi

if [ ${opt_newsst} -eq 1 ] ; then
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"B006500000${ensflag}0G20${general_dtg}*" ${general_yyyymm}@OSTIA ${outdms}"
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W000910000${ensflag}0G20${general_00z}*" ${general_yyyymm}@OSTIA ${outdms}"
  sstdir_f=${masopsdb}/MASOPS_mem${imem}/20${general_00z}000000
  sstdir_t=${masopsdb}/MASOPS_mem${imem}/20${general_dtg}000000
  if [ ! -e ${sstdir_t} ] ; then
    mkdir ${sstdir_t}
  fi
  cp ${sstdir_f}/W00091${ensflag}0G* ${sstdir_t}/

  if [ $? -eq 0 ] ; then
    fail=0
  else
    fail=1
  fi
fi

if [ $fail -eq 0 ] ; then
  echo "member $imem , GENSsnowice    ok!!!"
  echo "member $imem , GENSsnowice    ok!!!" >> ${STATUS}/ens_snowice.${dtg}.ok
else
  echo "member $imem , GENSsnowice    fail!!!"
  echo "member $imem , GENSsnowice    fail!!!" >> ${STATUS}/ens_snowice.${dtg}.fail
  exit 1
fi

exit
