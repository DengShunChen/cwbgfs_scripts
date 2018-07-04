#!/bin/ksh
if [ $# -eq 2 ]
then
  fnconf=$1
  dtg=$2
else
  echo 'usage : GENSinflation.ksh fnconf dtg  '
  exit -1
fi

cd $LOGDIR
cat > jinfl << EOFjinfl
#!/bin/ksh
#PJM -L "node=${inode}"
#PJM --mpi "proc=${impi}"
#PJM -L "elapse=0:10:00"
#PJM --no-stging
#PJM -j 

 set -x
 . ${NWPBINS}/${fnconf}.set
 . ${NWPBINS}/setup_mpi

#-------------------------------------------------------------------------------
# run option
#-------------------------------------------------------------------------------
if [ $opt_inflation -eq 0 ] ; then
  echo "opt_inflation=${opt_inflation}, exit"
  echo "opt_inflation=${opt_inflation}, exit" > ${STATUS}/ENS_inflation.${dtg}.ok
  exit
fi

#-------------------------------------------------------------------------------
# resource and pre-defined parameters
#-------------------------------------------------------------------------------
  MPI=$impi           # total number of mpi task, should greater than total member( MPI > NTOTMEM)
  if [ \$MPI -lt $NTOTMEM ] ; then
    echo  "total number of mpi=\$MPI,", should be > total enkf member=$NTOTMEM"
    nowt=\`date\`
    echo "\$nowt $dtg ENSinflation  fail" > ${STATUS}/ENS_inflation.${dtg}.fail
    echo  "mpi=\$MPI,", should be > total enkf member=$NTOTMEM" >> ${STATUS}/ENS_inflation.${dtg}.fail
    exit -1
  fi
  scalefact=32      # rescaling factor (%) : final perturbation = perturbation * rescaling factor
  ndays=40          # total days 
  nhours=\$((\$ndays*24))

#-------------------------------------------------------------------------------
# prepare working and fgdtg
#-------------------------------------------------------------------------------
# rm -f -r ${NWPWRKENS}
# mkdir ${NWPWRKENS}
  cd ${NWPWRKENS}
  fgdtg=\`${NWPBINS}/0x01_Caldtg.ksh $dtg -6\`


#----------------------------------------------------------------------------------------------
# perturbation files data path
#----------------------------------------------------------------------------------------------
# export NMCPERTPATH=/nwpr/gfs/xb33/data2/wkpert/save	# NMC database should not be changed.
#----------------------------------------------------------------------------------------------
# Prepare data
#----------------------------------------------------------------------------------------------
 ln -sf  ${NWPDTGENS}/sigf06_ensmean.20\${fgdtg}  ${NWPWRKENS}/sfg_20${dtg}_fhr06_ensmean

 mem=1
 while [ \$mem -le ${NTOTMEM} ] ; do
   cmem3=\`printf %03i \$mem\`
   ln -sf  ${NWPDTGENS}/sanl_20${dtg}_mem\${cmem3} ${NWPWRKENS}/sanl_20${dtg}_mem\${cmem3}
   ((mem=\$mem+1))
 done

 
#----------------------------------------------------------------------------------------------
# Generate sequential list of perturbation dates
#----------------------------------------------------------------------------------------------
 ((rag=-1*\$nhours))
 bdate=\`${NWPBINS}/0x01_Caldtg.ksh $dtg \$rag\`
 ((rag=+1*\$nhours))
 edate=\`\${NWPBINS}/0x01_Caldtg.ksh $dtg \$rag\`

 rm -f temp_all temp_dat temp_new
 npert=0
 sdate=\$bdate

#deal with lossing data in 2012
 while [[ \$sdate -le \$edate ]]; do
   mmddhh=\`echo \$sdate | cut -c3-8\`
#   case \$mmddhh in
#   030306) yyyy=2013;;
#   030312) yyyy=2013;;
#   030318) yyyy=2013;;
#   030400) yyyy=2013;;
#   030406) yyyy=2013;;
#   030412) yyyy=2013;;
#   030418) yyyy=2013;;
#   030506) yyyy=2013;;
#   032600) yyyy=2013;;
#   032606) yyyy=2013;;
#   032700) yyyy=2013;;
#   032706) yyyy=2013;;
#   100318) yyyy=2013;;
#        *) yyyy=2012;;
#   esac
   yyyy=2014
   pdate=\${yyyy}\${mmddhh}
   ln -fs  \${NWPDATPERT}/sigf48_f24.\${pdate}  sigf48_f24.gfs.\${pdate}
   echo \$pdate >> temp_all
   idate=\`${NWPBINS}/0x01_Caldtg.ksh \$sdate 6\`
   sdate=\$idate
   npert=\$((npert+1))
 done
 mv temp_all dates_seq.dat

#----------------------------------------------------------------------------------------------
# Perturb and recenter ensemble analysis members
#----------------------------------------------------------------------------------------------
 exec="${NWPBIN}/GENS_adderrspec_nmcmeth_spec"
 /usr/bin/time -p mpiexec -of stdout.adderr -n \$MPI \${exec} ${NTOTMEM} 20${dtg} \$scalefact ${NWPWRKENS}/ \$npert

if [ \$? != 0 ] ; then
  nowt=\`date\`
  echo "\$nowt $dtg ENSinflation  fail" >> ${STATUS}/ENS_inflation.${dtg}
  echo "GENS_adderrspec_nmcmeth_spec Fail !!!"
  mv ${STATUS}/ENS_inflation.${dtg} ${STATUS}/ENS_inflation.${dtg}.fail

  cp dates_ran.dat ${NWPDTGENS}/pertdates_20${dtg}
  cp stdout.adderr  ${NWPDTGENS}/stdout.adderr.20${dtg}

  #un-ln files
  rm -f  sanl_20${dtg}_* sigf48_f24.gfs.*
  exit -1
else
  mem=1
  while [ \$mem -le ${NTOTMEM} ] ; do
    smem=\`printf %03i \$mem\`
    mv sanlpr_20${dtg}_mem\${smem} ${NWPDTGENS}
    ((mem=\$mem+1))
  done

  cp dates_ran.dat ${NWPDTGENS}/pertdates_20${dtg}
  cp stdout.adderr  ${NWPDTGENS}/stdout.adderr.20${dtg}

  echo "GENS_adderrspec_nmcmeth_spec OK !!!"
  nowt=\`date\`

  echo "\$nowt $dtg ENSinflation  OK" >> ${STATUS}/ENS_inflation.${dtg}
  mv ${STATUS}/ENS_inflation.${dtg} ${STATUS}/ENS_inflation.${dtg}.ok

  #un-ln files
  rm -f  sanl_20${dtg}_* sigf48_f24.gfs.*
fi

#----------------------------------------------------------------------------------------------
#copy back to ${NWPDTGENS}
#----------------------------------------------------------------------------------------------
exit
EOFjinfl
