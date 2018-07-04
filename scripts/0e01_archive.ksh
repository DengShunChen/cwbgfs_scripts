#!/bin/ksh
#
#  PROPOSE :  sub-task of archive dms file for ensemble member 
#
#-
#  In order to speed up the process of archive and upload dms data 
#-

if [ $# -eq 4 ] ; then
  fnconf=$1
  dtg=$2
  mem=$3
  subopt=$4 
else
  echo "usage : $0 dtg -- exit" ; exit
fi

cd ${LOGDIR}
cat > archive_${mem} << EOF
#!/bin/ksh
#PJM -L node=1
#PJM -L "elapse=2:30:00"
#PJM --no-stging
#PJM -j

set -x

. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi


#-------------------------------------------------------------------------
# Set date and time
#-------------------------------------------------------------------------

 pr24dtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24\`
 pr24dtg10=20\${pr24dtg}

 pr12dtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -12\`
 pr12dtg10=20\${pr12dtg}

 dtg_arc=\${pr12dtg}

#-------------------------------------------------------------------------
# Archive dms 
#-------------------------------------------------------------------------

 # asign member ID
 typeset -Z3 cmem3
 cmem3=${mem}

 # into main directory
 cd ${DB_PATH}/${DB_NAME}.ufs

 # define target and destination
 target="MASOPS_mem\${cmem3}"
 destin="${DMSFN}\${dtg_arc}${DMSENSTL}_mem\${cmem3}"

 # create directory
 mkdir  \${destin}

 # moving to container
 mv  \${target}/*\${dtg_arc}* \${destin}/
 
 # pack dms data 
 tar -zcvf \${destin}.tar.gz \${destin}
 if [ \$? = 0 ] ;  then
    rm -rf \${destin}
 else
    nowt=\`date\`
    echo "\$nowt ${dtg} archive_ENS ${mem} fail" >> ${STATUS}/archive_ENS.${dtg}.fail
    echo " archive_${mem} Fail !!!" ; exit -1
 fi

 # upload archive file 
 ssh ${DTMV} ssh dm07  -n " cp ${DB_PATH}/${DB_NAME}.ufs/\${destin}.tar.gz  ${DTMVDMSPATH}"
 if  [ \$? != 0 ] ;  then
   ssh ${DTMV} -n " scp ${DB_PATH}/${DB_NAME}.ufs/\${destin}.tar.gz  ${SILOUSER}@hsmsvr:${DTMVDMSPATH}"
 fi 
 if [ \$? = 0 ] ;  then
    rm -rf \${destin}.tar.gz
 else
    nowt=\`date\`
    echo "\$nowt ${dtg} archive_ENS $mem fail" >> ${STATUS}/archive_ENS.${dtg}.fail
    echo " archive_${mem} Fail !!!" ; exit -1
 fi

 echo "archive dms data ok, mem=${mem}"

EOF


if [ $subopt -eq 1 ] ; then
  ssh ${LGIN} ${PJSUB} archive_${mem}
fi

exit

