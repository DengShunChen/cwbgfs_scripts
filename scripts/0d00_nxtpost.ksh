#!/bin/ksh 
if [ $# -eq 5 ]
then
  fn_conf=$1
  date_ini=$2
  date_end=$3
  runfn=${4}
  opt_fcst=${5}
else
 echo " please check the input arguments...."
 exit -1
fi

cd ${LOGDIR}
cat > jnxt << EOFjnxt
#!/bin/ksh
#PJM -L node=1
#PJM -L elapse=2:00:00
#PJM --no-stging
#PJM -j
set -x
. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fn_conf}.set

# check wait
if [ $opt_hyb -eq 1 ] ; then
  pjob=ens
else
  pjob=fcst
fi

cjob=nxt
${NWPBINS}/0x00_ckwait.ksh $date_ini \$pjob 100 6 $STATUS
if [ \$? -ne 0 ] ; then
     nowt=\`date\`
     echo "\$nowt \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${date_ini}.fail
     exit -1
fi

cd ${NWPBINS}
dtg=\`${NWPBINS}/0x01_Caldtg.ksh ${date_ini} $inthr\`
if [ \$dtg -le $date_end ] ; then
  ${NWPBINS}/${runfn} $fn_conf \$dtg $date_end   $opt_fcst
else
  echo "finish update cycle!!"
fi

EOFjnxt
exit
