#!/bin/ksh
#------------------------------------------------------------------------------
#
#* Adjoint of archive ensemble DMS files
#
#------------------------------------------------------------------------------

# system settings
export SILOUSER='xb80'
export DTMV='datamv07.cwb.gov.tw'
export NWPDTGENS=`pwd`
cd ${NWPDTGENS}

# date time settings
export ini_dtg=15061418
export end_dtg=15061418

# ensemble size
export NTOTMEM=36

# tar file name
export DMSFN="h3dctl"

# dmsfile tail
export DMSENSTL_HRS="GHMGP"     # main
export DMSENSTL_ENS="GGMGP"     # ensemble

# target 
export DTMVDMSPATH="/rs/bak/${SILOUSER}/dmsdir/${DMSFN}"

# denstination 
export DB_PATH="/nwpr/gfs/xb80/data2/dmsdb"
export DB_NAME="h3dcwbo3"

#------------------------------------------------------------------------------
# function 
unpackdms() {

  dtg=${1}
  denstination_dir=${2}
  denstination_file=${3}

  ssh ${DTMV} -n "scp ${SILOUSER}@hsmsvr:${DTMVDMSPATH}/${denstination_file}.tar.gz ${DB_PATH}/${DB_NAME}.ufs/"    
  if [ $? = 0 ] ;  then
     echo "Copy  ${denstination_file}.tar.gz  successed !!"
  else
     echo "Error : copy ${denstination_file}.tar.gz  failed !!" ; exit
  fi

  tar -zxvf ${denstination_file}.tar.gz
  if [ $? = 0 ] ;  then
     echo "De-tar ${denstination_file}.tar.gz  successed !!"
     rm -rf ${denstination_file}.tar.gz
  else
     echo "Error : de-tar ${denstination_file}.tar.gz failed !!" ; exit    
  fi
 
  if [ -e ${denstination_dir}/*${dtg}* ] ; then 
    rm -rf ${denstination_dir}/*${dtg}*
  fi
  mv ${denstination_file}/*${dtg}* ${denstination_dir}
  if [ $? = 0 ] ;  then
     echo "Copy ${denstination_file}/*${dtg}*  successed !!"
     rm -rf ${denstination_file}
  else
     echo "Error : copy ${denstination_file}/*${dtg}*  failed !!" ; exit 
  fi

}


dtg=$ini_dtg
while [ $dtg -le $end_dtg ] ; do

  echo "process --> ${dtg}"
  export dtg
  export dtg10=20${dtg}

  # un-pack dms main
  if [ -e  ${DB_PATH}/${DB_NAME}.ufs/ ] ; then
     cd ${DB_PATH}/${DB_NAME}.ufs/
  else
     echo "${DB_PATH}/${DB_NAME}.ufs/ not exist !! -- stop" ; exit
  fi
  targetfile="${DMSFN}${dtg}${DMSENSTL_HRS}"
  targetdir="MASOPS"

  echo "un-packing dms file = ${targetfile}"
  unpackdms ${dtg} ${targetdir} ${targetfile}
 
  # un-pack dms ensemble
  typeset -Z3 mem
  typeset -Z3 cmem3

  ((mem=1))
  while [ $mem -le $NTOTMEM ] ; do
    cmem3=${mem} ; echo "mem--> ${cmem3}"
    
    cd ${DB_PATH}/${DB_NAME}.ufs/
    targetfile="${DMSFN}${dtg}${DMSENSTL_ENS}_mem${cmem3}"
    targetdir="MASOPS_mem${cmem3}"

    echo "un-packing dms file = ${targetfile}"
    unpackdms ${dtg} ${targetdir} ${targetfile}

    ((mem=$mem+1))
  done
 
  dtg=`/nwpr/gfs/xb80/bin/Caldtg.ksh $dtg +6`

done

if [ $? -eq 0 ] ; then
  echo "Normal Stop !!"
else
  echo "Failed !!"
fi

