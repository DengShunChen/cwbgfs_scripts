#!/bin/ksh
set -x

if [ $# -eq 0 ]
then
 echo " usage : gtw10.ksh fnconf dtg imem"
else
 fnconf=$1
 dtg=$2
 imem=$3
fi

set +x
. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi

set -x
cd ${GFSDIR}_${imem}

export SFGRID=SSTNMC@${NCEPECDB}
export NCEPGRID=MASOPS_mem${imem}@${DB_NAME}
export masopsdb=${masopsdb:-"${DB_PATH}/${DB_NAME}.ufs/"}

export general_dtg=${general_dtg:-${dtg}}
export general_yyyymm=`echo 20${general_dtg} | cut -c1-6`
export general_00z=`echo ${general_dtg} | cut -c1-6`00

dtg_2017=17100100

# create namelist and dms key list file
if [ ${general_dtg} -lt ${dtg_2017}  ] ; then
echo "W001000000NA0820${general_dtg}00H0259200" > gg2gg.fil
echo "nomoda" >> gg2gg.fil
cat > namlsts.getsst << EOF
 &sstlst
  im_i=720,
  im_o=${LONA_ENKF},
  flag_i="NA08",
  flag_o="${ensflag}0G",
  idmsfn='SFGRID',
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
  im_o=${LONA_ENKF},
  flag_i="NA10",
  flag_o="${ensflag}0G",
  idmsfn='SFGRID',
  odmsfn='NCEPGRID',
  readfil='gg2gg.fil',
 &end
EOF
fi


/usr/bin/time -p ${NWPBIN}/getsst
if [ $? -eq 0 ] ; then
  fail=0
else
  fail=1
fi

if [ ${opt_newsst} -eq 1 ] ; then
  ssh ${DTMV} -n "${DMSPATHx86}/rdmscpy -l34 -k"W001000000${ensflag}0G20${general_00z}*" ${general_yyyymm}@OSTIA  ${NCEPGRID}"
  sstdir_f=${masopsdb}/MASOPS_mem${imem}/20${general_00z}000000
  sstdir_t=${masopsdb}/MASOPS_mem${imem}/20${general_dtg}000000
  if [ ! -e ${sstdir_t} ] ; then
    mkdir ${sstdir_t}
  fi
  cp ${sstdir_f}/W00100${ensflag}0G* ${sstdir_t}/

  if [ $? -eq 0 ] ; then
    fail=0
  else
    fail=1
  fi
fi

if [ $fail -eq 0 ] ; then
    echo "member $imem , $dtg ens_sst W00100 ok" 
    echo "member $imem , dtg ens_sst W00100 ok" > ${STATUS}/ens_sst.${dtg}.ok
else
    echo "member $imem , dtg ens_sst W00100 fail" 
    echo "member $imem , dtg ens_sst W00100 fail" > ${STATUS}/ens_sst.${dtg}.fail
fi

