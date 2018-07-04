#!/bin/ksh
#------------------------------------------------------------------------------
#
#* Archive ensemble DMS files
#
#------------------------------------------------------------------------------
# system settings
export SILOUSER='xb80'
export DTMV="datamv08"
export NWPDTGENS=`pwd`
cd ${NWPDTGENS}

# date time settings 
export ini_dtg=15061400
export end_dtg=15063018

# ensemble size
export NTOTMEM=36

# tar file name
export DMSFN="h3drrtmg"

# dmsfile tail
export DMSENSTL_HRS="GHMGP"     # main 
export DMSENSTL_ENS="GGMGP"     # ensemble 

# target
export DB_PATH="/nwpr/gfs/xb80/data2/dmsdb"
export DB_NAME="h3drrtmg"

# destination 
export DTMVDMSPATH="/rs/bak/${SILOUSER}/dmsdir/${DMSFN}"

#------------------------------------------------------------------------------
# function
packdms() {
   
    dtg=${1} 
    targetdir=${2}   
    targetfile=${3}
   
    if [ -e ${targetdir}/*${dtg}* ] ; then  # if target directory has those files 

      if [ ! -e ${targetfile} ] ; then   # if target file NOT exist, make a directory for it. 
        mkdir  ${targetfile}
        mv ${targetdir}/*${dtg}* ${targetfile}
      else
        echo "Error : ${targetdir} has target files, but also ${targetfile} is exist"
        exit
      fi  

      rm -rf ${targetfile}/*001

      echo "Running : pack ${targetfile}"
      tar -zcvf ${targetfile}.tar.gz ${targetfile}
      if [ $? = 0 ] ;  then
        rm -rf ${targetfile}
      fi

      echo "Running : copy tar-file ${targetfile}.tar.gz to ${DTMVDMSPATH}"
      ssh ${DTMV} -n "cp ${DB_PATH}/${DB_NAME}.ufs/${targetfile}.tar.gz ${DTMVDMSPATH}"
      if [ $? = 0 ] ;  then
        rm -rf ${targetfile}.tar.gz
      fi

    else  # if target directory has NOT those files

      echo "${targetfile}"
      if [ -e ${targetfile} ] ; then
        rm -rf ${targetfile}/*001

        echo "Running : pack ${targetfile}"
        tar -zcvf ${targetfile}.tar.gz ${targetfile}
        if [ $? = 0 ] ;  then
          rm -rf ${targetfile}
        fi

        echo "Running : copy tar-file ${targetfile}.tar.gz to ${DTMVDMSPATH}"
        ssh ${DTMV} -n "scp ${DB_PATH}/${DB_NAME}.ufs/${targetfile}.tar.gz ${SILOUSER}@hsmsvr:${DTMVDMSPATH}"
        if [ $? = 0 ] ;  then
          rm -rf ${targetfile}.tar.gz
        fi
      else
        if [ -e ${targetfile}.tar.gz ] ; then
          echo "Running : copy tar-file ${targetfile}.tar.gz to ${DTMVDMSPATH}"
          ssh ${DTMV} -n "scp ${DB_PATH}/${DB_NAME}.ufs/${targetfile}.tar.gz ${SILOUSER}@hsmsvr:${DTMVDMSPATH}"
          if [ $? = 0 ] ;  then
            rm -rf ${targetfile}.tar.gz
          fi
        else
          echo "Warning : No target files and not copied files, it may already processed !!"
        fi
      fi 

    fi
}

#------------------------------------------------------------------------------
# make directory for silo destination 
ssh ${DTMV} -n " mkdir ${DTMVDMSPATH}"

dtg=$ini_dtg
while [ $dtg -le $end_dtg ] ; do

  echo "process --> $dtg"
  export dtg
  export dtg10=20${dtg}

  # pack dms main  
  cd ${DB_PATH}/${DB_NAME}.ufs
  targetfile="${DMSFN}${dtg}${DMSENSTL_HRS}"
  targetdir="MASOPS"

  echo "packing dms file = ${targetfile}"
  packdms ${dtg} ${targetdir} ${targetfile}

  # pack dms ensres
  cd ${DB_PATH}/${DB_NAME}.ufs
  targetfile="${DMSFN}${dtg}${DMSENSTL_HRS}_ensres"
  targetdir="MASOPS_ensres"

  echo "packing dms file = ${targetfile}"
  packdms ${dtg} ${targetdir} ${targetfile}

  # pack dms ensemble
  typeset -Z3 mem
  typeset -Z3 cmem3

  ((mem=1))
  while [ $mem -le $NTOTMEM ] ; do
    cd ${DB_PATH}/${DB_NAME}.ufs
    targetfile="${DMSFN}${dtg}${DMSENSTL_ENS}_mem${cmem3}"
    targetdir="MASOPS_mem${cmem3}"

    echo "packing dms file = ${targetfile}"
    packdms ${dtg} ${targetdir} ${targetfile}
 
    ((mem=$mem+1))
  done

  # time cycle 
  dtg=`/nwpr/gfs/xb80/bin/Caldtg.ksh $dtg +6`

done


 
