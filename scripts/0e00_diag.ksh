#!/bin/ksh
#---------------------------------------------------------------------------------------------
#  2013.1       create
#  2013.4.26    extra diagnose added
#  2017.05.10  - Deng-Shun - add global_diag.ksh
#---------------------------------------------------------------------------------------------
export fnconf=${1}
export dtg=${2}
export end_dtg=${3}
export LOGDIR NWPBIN NWPBINS optcdms optcdia optarc NPWDAT
export DMSFN DMSTL DMSDB SILODMSPATH REMWRK DTGSAV DTGWRK
export diagcnv=1
export diagstd=0
export diagrad=1
export diagradstd=0

cd ${LOGDIR}
cat > dia <<EOFdia
#PJM -L node=1
#PJM -L elapse=24:00:00
#PJM --no-stging
#PJM -j

 set -x

 . ${NWPBINS}/${fnconf}.set
 . ${NWPBINS}/setup_mpi

#-------------------------------------------------------------------------
# check wait
#-------------------------------------------------------------------------
 pjob=fcst
 cjob=diag
 ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 100 6 $STATUS

 if [ \$? -ne 0 ] ; then
   nowt=\`date\`
   echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
   exit -1
 fi

#-------------------------------------------------------------------------
#  run global diag
#-------------------------------------------------------------------------
. ${NWPBINS}/global_diag.ksh ${dtg} ${fnconf} ${end_dtg}


EOFdia

ls -l dia

exit
