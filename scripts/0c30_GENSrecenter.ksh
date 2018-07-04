#!/bin/ksh
if [ $# -eq 2 ]
then
  fnconf=$1
  dtg=$2
else
  echo 'usage : GENrecenter.ksh fnconf dtg  '
  exit -1
fi

cd ${LOGDIR}
cat > jrecntr << EOFrecntr
#!/bin/ksh
#PJM -L "node=3"
#PJM --mpi "proc=48"
#PJM -L "elapse=3:00:00"
#PJM --no-stging
#PJM -j 

set -x
. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fnconf}.set
MPI=48

#---------------------------------------------------------------------------
# run option  ---  for research only
#---------------------------------------------------------------------------
if [ $opt_recenter -eq  0 ] ; then
  echo "opt_recenter=$opt_recenter" > ${STATUS}/ENS_recenter.${dtg}.ok
  exit
fi
#---------------------------------------------------------------------------
# initial workdir
#---------------------------------------------------------------------------
#rm -f -r ${NWPWRKENS}
#mkdir ${NWPWRKENS}
 cd ${NWPWRKENS}
#---------------------------------------------------------------------------
# prepare input data
#---------------------------------------------------------------------------
 mem=1
 while [ \$mem -le ${NTOTMEM} ] ; do
   cmem3=\`printf %03i \$mem\`
   ln -sf  ${NWPDTGENS}/sanlpr_20${dtg}_mem\${cmem3} sanlpr_20${dtg}_mem\${cmem3}
   ((mem=\$mem+1))
 done
#---------------------------------------------------------------------------
# get ensemble mean 
#---------------------------------------------------------------------------
 filenameout=sanlpr_20${dtg}_ensmean			# ens mean file name (output)
 fileprefix=sanlpr_20${dtg}				# member file prefix (input)
 /usr/bin/time -p ${NWPBIN}/GENS_sigensmean_smooth ${NWPWRKENS}/ \$filenameout \$fileprefix $NTOTMEM
 if [ \$? != 0 ] ; then
   echo "RECNETER: ${dtg}  error occured: GENS_sigensmean_smooth fail !!" >> ${STATUS}/ENS_recenter.${dtg}
   echo "RECNETER: ${dtg}  error occured: GENS_sigensmean_smooth fail !!"
   mv  ${STATUS}/ENS_recenter.${dtg} ${STATUS}/ENS_recenter.${dtg}.fail
   exit 2
 else
   echo "RECNETER: ${dtg}  GENS_sigensmean_smooth  success !!" >> ${STATUS}/ENS_recenter.${dtg}
 fi
#---------------------------------------------------------------------------
# downscaling hybrid analysis to ensemble resolution in dms format 
#---------------------------------------------------------------------------
 if [ "${ensflag}" != "${gfsflag}" ] ;  then
   ${NWPBINS}/0c31_GENSgg2ge.ksh $dtg 0 $MASOPS $MASOPS_ensres
   if [ \$? != 0 ] ; then
     echo "RECNETER: ${dtg}  error occured: gg2ge.ksh fail !!" >> ${STATUS}/ENS_recenter.${dtg}
     echo "RECNETER: ${dtg}  error occured: gg2ge.ksh fail !!"
     mv  ${STATUS}/ENS_recenter.${dtg} ${STATUS}/ENS_recenter.${dtg}.fail
     exit 2
   else
     echo "RECNETER: ${dtg}  gg2ge.ksh success !!" >> ${STATUS}/ENS_recenter.${dtg}
   fi
 fi

#---------------------------------------------------------------------------
# convret dms file to ncep format 
#---------------------------------------------------------------------------
 O3fn=${NWPDTGENS}/o3_ENS.20${dtg}
 optreloc=0
 optsub=0
 optrun=ENSRES
 
 if [ "${ensflag}" = "${gfsflag}" ] ;  then
   export MASOPS_ensres=${MASOPS}
 fi
 ${NWPBINS}/0500_Gfguess.ksh ${fnconf} ${dtg} \${optrun} \${optreloc} \${optsub} ENSRES
 chmod u+x ${LOGDIR}/fg_\${optrun}
 ${LOGDIR}/fg_\${optrun}
 if [  -s ${NWPDTGENS}/sanl_main_ensres.20${dtg} ] ; then
  echo "RECENTER: 0500_fguess.ksh reformat success !!" >> ${STATUS}/ENS_recenter.${dtg}
 else
  echo "RECENTER: 0500_fguess.ksh reformat fail !!" >> ${STATUS}/ENS_recenter.${dtg}
  mv  ${STATUS}/ENS_recenter.${dtg} ${STATUS}/ENS_recenter.${dtg}.fail
  exit 2
 fi


#---------------------------------------------------------------------------
# recenter 
#---------------------------------------------------------------------------
 filenamein=sanlpr_20${dtg}			              # input ensemble member file prefix 
 filename_ensmeanin=sanlpr_20${dtg}_ensmean	  # ensemble mean 
 filename_main=sanl_main_ensres.20${dtg} 	    # hybrid analysis with ensemble resolutinon 
 filenameout=sanlprc_20${dtg}		              # output ensemble member file prefix after recentering  

 ln -fs ${NWPDTGENS}/\${filename_main}  \${filename_main}
 /usr/bin/time -p mpiexec -of stdout.recenter -n \$MPI ${NWPBIN}/GENS_recenter \$filenamein \$filename_ensmeanin \$filename_main \$filenameout $NTOTMEM
 if [ \$? = 0 ] ; then
    echo "RECENTER: GENSrecenter  success !!" >> ${STATUS}/ENS_recenter.${dtg}
    nmem=1
    while [ \$nmem -le $NTOTMEM ] ; do
       cmem3=\`printf %03i \$nmem\`
       sanlfn=sanlprc_20${dtg}_mem\${cmem3}
       cp \${sanlfn} ${NWPDTGENS}
       ((nmem=\${nmem}+1))
    done
    mv  ${STATUS}/ENS_recenter.${dtg} ${STATUS}/ENS_recenter.${dtg}.ok
#un-ln files
    rm -f   sanlpr_20${dtg}_* \${filename_main}
 else
    echo "RECENTER: GENSrecenter  fail  !!" >> ${STATUS}/ENS_recenter.${dtg}
    mv  ${STATUS}/ENS_recenter.${dtg} ${STATUS}/ENS_recenter.${dtg}.fail
#un-ln files
    rm -f   sanlpr_20${dtg}_* \${filename_main}
    exit 2
 fi
exit
EOFrecntr
