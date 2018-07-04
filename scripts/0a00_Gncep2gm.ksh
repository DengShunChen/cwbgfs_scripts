#!/bin/ksh
if [ $# = 5 ]
then
  fnconf=$1
  dtg=$2
  optrun=$3
  optsub=$4
  mem=$5
else
  echo "usage : Gncep2gm.ksh fnconf dtg  optrun optsub mem"
  exit -1
fi


cmem3=`printf %03i $mem`

cd $LOGDIR
cat > j2gm_${mem} << EOFj2gm
#!/bin/ksh
#PJM -L node=1
#PJM --no-stging
#PJM -j

set -x
  export MPI=1 ; export OMP=16
. ${NWPBINS}/setup_mpi+omp \$OMP
. ${NWPBINS}/${fnconf}.set

echo "BEGIN ....,optrun="$optrun

#---------------------------------------------------------------------------
# check run option - for research only
#---------------------------------------------------------------------------

if [ $optrun = "MAIN"  -a  $opt_ncep2gm -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg ncep2gm ok" >> ${STATUS}/ncep2gm.${dtg}.ok
  exit
fi
if [ $optrun = "ENS"  -a  $optens_ncep2gm -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg ncep2gm ok" >> ${STATUS}/ncep2gm_ens.${dtg}.ok
  exit
fi

#---------------------------------------------------------------------------
#  wait for previous job
#---------------------------------------------------------------------------
if [ $optrun = "MAIN" ] ; then
  pjob=g3dv_MAIN
  cjob=ncep2gm
  ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 100 6 $STATUS
  if [ \$? -ne 0 ] ; then
     nowt=\`date\`
     echo "\$nowt $dtg \${cjob} fail, since ${pjob} fail!!" >> ${STATUS}/\${cjob}.${dtg}.fail
     exit -1
   fi
fi

#---------------------------------------------------------------------------
if [ $optrun = "MAIN" ] ; then
  export DTGDIR=${NWPDTGSAV}
  export WORKDIR=${NWPWRK}
  export sanl=siganl.20${dtg}
  export MASOPS=${MASOPS}
  cd \${WORKDIR}

# create namelist 
cat > \${WORKDIR}/post_ana.input << EOF
&post_ana
  nsigcwb=\${LEVS},
  jcapcwb=\${JCAPA},
  imcwb=\${LONA},
  jmcwb=\${LATA},
  odmsfn='MASOPS',
  flag='\${gfsflag}',
/
EOF

elif [ $optrun = "ENS" ] ; then
  export DTGDIR=${NWPDTGENS}
  export WORKDIR=${NWPWRKENS}/innov_${cmem3}
  export sanl=sanlprc_20${dtg}_mem${cmem3}
  export MASOPS=MASOPS_mem${cmem3}@${DB_NAME}
  cd \${WORKDIR}

# create namelist 
cat > \${WORKDIR}/post_ana.input << EOF
&post_ana
  nsigcwb=\${LEVS},
  jcapcwb=\${JCAPA_ENKF},
  imcwb=\${LONA_ENKF},
  jmcwb=\${LATA_ENKF},
  odmsfn='MASOPS',
  flag='\${ensflag}',
/
EOF

fi
#---------------------------------------------------------------------------

#----- link ncep sig file
#rm -f fort.12
#ln -fs \${DTGDIR}/\${sanl} fort.12
 rm -f sigfile
 ln -fs \${DTGDIR}/\${sanl} sigfile
# ${NWPBIN}/${gfsflag}_ncep2GM30_gsi < post_ana.input
# /nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/postproc/GH_ncep2dms_fx100  < post_ana.input

 ${NCEP2DMSexe} < post_ana.input

# rm -f fort.12
 rm -f sigfile

if [ \$? != 0 ] ; then
  echo "${gfsflag}_ncep2Gm30_gsi FAIL !!!"
  exit -1
else
  echo "${gfsflag}_ncep2Gm30_gsi OK !!!"
  nowt=\`date\`
  if [ $optrun = "MAIN" ] ; then
    echo "\$nowt $dtg ncep2gm ok" >> ${STATUS}/ncep2gm.${dtg}.ok
  else
    echo "\$nowt $dtg ncep2gm ok" >> ${STATUS}/ncep2gm_${optrun}_\${cmem3}.${dtg}.ok
  fi
fi

exit 0
EOFj2gm
if [ $optsub -eq 1 ] ; then
  ssh ${LGIN} ${PJSUB}  ${LOGDIR}/j2gm_${mem}
else
  chmod u+x  ${LOGDIR}/j2gm_${mem}
fi
exit
