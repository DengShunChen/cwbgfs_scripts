#!/bin/ksh

if [ $# = 5 ] ; then
  fnconf=$1
  dtg=$2
  optrun=$3
  optsub=${4}
  mem=${5}
else
  echo 'usage : G3dvar.ksh fnconf  dtg  optrun optsub'
  exit 
fi

if [ $optrun = "MAIN" ] ; then
  anode=$anode_main
  ampi=$ampi_main
  aomp=$aomp_main
else
  anode=$anode_ens
  ampi=$ampi_ens
  aomp=$aomp_ens
fi

cat > j3dv_${mem} << EOF
#!/bin/ksh
#PJM -L "node=$anode:noncont"
#PJM --mpi "proc=$ampi"
#PJM -L rscgrp=large-x
#PJM -L elapse=3:00:00
#PJM --no-stging
#PJM -L node-mem=unlimited
#PJM -j


#----------------------------------------------------------------------------
# Set up environment 
#----------------------------------------------------------------------------
  . ${NWPBINS}/${fnconf}.set
  . ${NWPBINS}/setup_mpi+omp ${aomp}
  echo "BEGIN ...."

  set -x
  if [ $opt_g3dvar -ne 1  -a $optrun = "MAIN" ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg g3dv ok" >> ${STATUS}/g3dv_MAIN.${dtg}.ok
    echo "opt_g3dvar=${opt_g3dvar}, exit"
    exit
  fi
  if [ $opt_innov -ne 1 -a $optrun = "ENS" ]  ; then
    nowt=\`date\`
    echo "\$nowt $dtg g3dv ok" >> ${STATUS}/innov_ENS.${dtg}.ok
    echo "opt_ens=${opt_ens}, exit"
    exit
  fi

#----------------------------------------------------------------------------
# check wait
#----------------------------------------------------------------------------
  if [ $MP = "P" -o $MP = "p" ] ; then
    mp=p
    if [ $optrun = "MAIN" ] ; then
      if [ $opt_hyb -eq 1 ] ; then
        nckjob=6
        ckjoblst="fguess_MAIN fguess_ENS  sfcges_MAIN bogus prepcwbobs obsbufr"
      else
        nckjob=5
        ckjoblst="fguess_MAIN  sfcges_MAIN bogus prepcwbobs obsbufr"
      fi
    else
      nckjob=4
      ckjoblst="fguess_${optrun} sfcges_${optrun} prepcwbobs obsbufr"
    fi
  else
    mp=m
    nckjob=6
    ckjoblst="fguess_${optrun} sfcges_${optrun} bogus prepcwbobs obsbufr obsoi"
  fi

  cjob=g3dv
  typeset -i nn
  nn=1

  while [ \$nn -le \$nckjob ] ; do
    pjob=\`echo \$ckjoblst | cut -d" " -f\$nn\`
    ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob  800 5 $STATUS
    if [ \$? -ne 0 ] ; then
      nowt=\`date\`
      echo "\$nowt $dtg \$cjob fail,since \$pjob fail!!" > ${STATUS}/\${cjob}.${dtg}.fail
      exit -1
    fi
    nn=nn+1
  done

#----------------------------------------------------------------------------
#  MAIN or ENS
#----------------------------------------------------------------------------
  export dtg=${dtg:-}
  export dtg10=20${dtg}
  export fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -6 \`
  export fgdtg10=20\${fgdtg}

  export optrun=${optrun}  
  export mem=${mem}
  export MPI=$ampi

  export lrun_select_obs=${lrun_select_obs:-".false."}
  export lrun_innovate=${lrun_innovate:-".false."}

  export SELECT_OBS_TARBALL=${SELECT_OBS_TARBALL:-'NO'}
  export DIAG_TARBALL=${DIAG_TARBALL:-'YES'}
  export DIAG_COMPRESS=${DIAG_COMPRESS:-'YES'}

  if [ $optrun = "MAIN" ] ; then
    WORKDIR=${NWPWRK}
    SAVEDIR=${NWPDTGSAV}
    rm -rf \${WORKDIR}/*
    mkdir \${WORKDIR}
    cd \${WORKDIR}
  elif [ $optrun = "ENS" ] ; then
    SAVEDIR=${NWPSAVENS}
    NLAT_A=${NLAT_A:-$(($LATA_ENKF+2))}
    NLON_A=${NLON_A:-$LONA_ENKF}
  else
    echo "Unknown optrun=$optrun -- stop " ; exit -1
  fi

#----------------------------------------------------------------------------
# run GSI 
#----------------------------------------------------------------------------
  . ${NWPBINS}/global_analysis.ksh

#----------------------------------------------------------------------------
# Exit 
#----------------------------------------------------------------------------
  echo "Anal OK!!"
  nowt=\`date\`
  echo "\$nowt $dtg anal ok" >> ${STATUS}/g3dv_${optrun}.${dtg}.ok
  exit 0


EOF
#---- End of create run script ----#

if [ $optsub -eq 1 ] ; then
  ssh ${LGIN} ${PJSUB} ${LOGDIR}/j3dv_${mem}
fi

exit
