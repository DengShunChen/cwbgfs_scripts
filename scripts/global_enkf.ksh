# prepare first guess dtg 
 CALDTG=${NWPBINS}/0x01_Caldtg.ksh
 fgdtg=`$CALDTG $dtg -6`

#----------------------------------------------------------------------------
# input fixed files setting
#   satinfo  = text file with information about assimilation of brightness temperatures
#   pcpinfo  = text file with information about assimilation of prepcipitation rates
#   ozinfo   = text file with information about assimilation of ozone data
#   convinfo = text file with information about assimilation of conventional data
#----------------------------------------------------------------------------
satinfo=${fnsatinfo}
pcpinfo=${NWPDATANA}/global_pcpinfo.txt
ozinfo=${NWPDATANA}/global_ozinfo.txt
convinfo=${fnconvinfo}
scaninfo=${NWPDATANA}/global_scaninfo.txt
hybens_locinfo=${NWPDATANA}/hybens_locinfo_enkf

cp ${hybens_locinfo}         hybens_locinfo
cp ${satinfo}                satinfo
cp ${pcpinfo}                 pcpinfo
cp ${ozinfo}                 ozinfo
cp ${convinfo}               convinfo
cp ${scaninfo}               scaninfo

#----------------------------------------------------------------------------
# prepare namelist 
#----------------------------------------------------------------------------
cat > enkf.nml <<EOF
 &nam_enkf
  datestring="20${dtg}",
  datapath="${NWPWRKENS}/",
  analpertwtnh=0.85,analpertwtsh=0.85,analpertwttr=0.85,
  covinflatemax=1.e2,covinflatemin=1,pseudo_rh=.true.,iassim_order=0,
  corrlengthnh=2000,corrlengthsh=2000,corrlengthtr=2000,
  lnsigcutoffnh=2.0,lnsigcutoffsh=2.0,lnsigcutofftr=2.0,
  lnsigcutoffpsnh=2.0,lnsigcutoffpssh=2.0,lnsigcutoffpstr=2.0,
  lnsigcutoffsatnh=2.0,lnsigcutoffsatsh=2.0,lnsigcutoffsattr=2.0,
  obtimelnh=1.e30,obtimelsh=1.e30,obtimeltr=1.e30,
  saterrfact=1.0,numiter=3,
  sprd_tol=1.e30,paoverpb_thresh=0.98,
  nlons=${LONA_ENKF},nlats=${LATA_ENKF},nlevs=${LEVS},nanals=${NTOTMEM},nvars=5,
  deterministic=.true.,sortinc=.true.,lupd_satbiasc=.false.,
  reducedgrid=.true.,readin_localization=.true.
  univaroz=.false.,adp_anglebc=.true.,angord=4,use_edges=.false.,emiss_bc=.true.,
 /
 &END
 &satobs_enkf
  sattypes_rad(1) = 'amsua_n15',     dsis(1) = 'amsua_n15',
  sattypes_rad(2) = 'amsua_n18',     dsis(2) = 'amsua_n18',
  sattypes_rad(3) = 'amsua_n19',     dsis(3) = 'amsua_n19',
  sattypes_rad(4) = 'amsub_n16',     dsis(4) = 'amsub_n16',
  sattypes_rad(5) = 'amsub_n17',     dsis(5) = 'amsub_n17',
  sattypes_rad(6) = 'amsua_aqua',    dsis(6) = 'amsua_aqua',
  sattypes_rad(7) = 'amsua_metop-a', dsis(7) = 'amsua_metop-a',
  sattypes_rad(8) = 'airs_aqua',     dsis(8) = 'airs281SUBSET_aqua',
  sattypes_rad(9) = 'hirs3_n17',     dsis(9) = 'hirs3_n17',
  sattypes_rad(10)= 'hirs4_n19',     dsis(10)= 'hirs4_n19',
  sattypes_rad(11)= 'hirs4_metop-a', dsis(11)= 'hirs4_metop-a',
  sattypes_rad(12)= 'mhs_n18',       dsis(12)= 'mhs_n18',
  sattypes_rad(13)= 'mhs_n19',       dsis(13)= 'mhs_n19',
  sattypes_rad(14)= 'mhs_metop-a',   dsis(14)= 'mhs_metop-a',
  sattypes_rad(15)= 'goes_img_g11',  dsis(15)= 'imgr_g11',
  sattypes_rad(16)= 'goes_img_g12',  dsis(16)= 'imgr_g12',
  sattypes_rad(17)= 'goes_img_g13',  dsis(17)= 'imgr_g13',
  sattypes_rad(18)= 'goes_img_g14',  dsis(18)= 'imgr_g14',
  sattypes_rad(19)= 'goes_img_g15',  dsis(19)= 'imgr_g15',
  sattypes_rad(20)= 'avhrr3_n18',    dsis(20)= 'avhrr3_n18',
  sattypes_rad(21)= 'avhrr3_metop-a',dsis(21)= 'avhrr3_metop-a',
  sattypes_rad(22)= 'avhrr3_n19',    dsis(22)= 'avhrr3_n19',
  sattypes_rad(23)= 'amsre_aqua',    dsis(23)= 'amsre_aqua',
  sattypes_rad(24)= 'ssmis_f16',     dsis(24)= 'ssmis_f16',
  sattypes_rad(25)= 'ssmis_f17',     dsis(25)= 'ssmis_f17',
  sattypes_rad(26)= 'ssmis_f18',     dsis(26)= 'ssmis_f18',
  sattypes_rad(27)= 'ssmis_f19',     dsis(27)= 'ssmis_f19',
  sattypes_rad(28)= 'ssmis_f20',     dsis(28)= 'ssmis_f20',
  sattypes_rad(29)= 'sndrd1_g11',    dsis(29)= 'sndrD1_g11',
  sattypes_rad(30)= 'sndrd2_g11',    dsis(30)= 'sndrD2_g11',
  sattypes_rad(31)= 'sndrd3_g11',    dsis(31)= 'sndrD3_g11',
  sattypes_rad(32)= 'sndrd4_g11',    dsis(32)= 'sndrD4_g11',
  sattypes_rad(33)= 'sndrd1_g12',    dsis(33)= 'sndrD1_g12',
  sattypes_rad(34)= 'sndrd2_g12',    dsis(34)= 'sndrD2_g12',
  sattypes_rad(35)= 'sndrd3_g12',    dsis(35)= 'sndrD3_g12',
  sattypes_rad(36)= 'sndrd4_g12',    dsis(36)= 'sndrD4_g12',
  sattypes_rad(37)= 'sndrd1_g13',    dsis(37)= 'sndrD1_g13',
  sattypes_rad(38)= 'sndrd2_g13',    dsis(38)= 'sndrD2_g13',
  sattypes_rad(39)= 'sndrd3_g13',    dsis(39)= 'sndrD3_g13',
  sattypes_rad(40)= 'sndrd4_g13',    dsis(40)= 'sndrD4_g13',
  sattypes_rad(41)= 'sndrd1_g14',    dsis(41)= 'sndrD1_g14',
  sattypes_rad(42)= 'sndrd2_g14',    dsis(42)= 'sndrD2_g14',
  sattypes_rad(43)= 'sndrd3_g14',    dsis(43)= 'sndrD3_g14',
  sattypes_rad(44)= 'sndrd4_g14',    dsis(44)= 'sndrD4_g14',
  sattypes_rad(45)= 'sndrd1_g15',    dsis(45)= 'sndrD1_g15',
  sattypes_rad(46)= 'sndrd2_g15',    dsis(46)= 'sndrD2_g15',
  sattypes_rad(47)= 'sndrd3_g15',    dsis(47)= 'sndrD3_g15',
  sattypes_rad(48)= 'sndrd4_g15',    dsis(48)= 'sndrD4_g15',
  sattypes_rad(49)= 'iasi_metop-a',  dsis(49)= 'iasi616_metop-a',
  sattypes_rad(50)= 'seviri_m08',    dsis(50)= 'seviri_m08',
  sattypes_rad(51)= 'seviri_m09',    dsis(51)= 'seviri_m09',
  sattypes_rad(52)= 'seviri_m10',    dsis(52)= 'seviri_m10',
  sattypes_rad(53)= 'amsua_metop-b', dsis(53)= 'amsua_metop-b',
  sattypes_rad(54)= 'hirs4_metop-b', dsis(54)= 'hirs4_metop-b',
  sattypes_rad(55)= 'mhs_metop-b',   dsis(55)= 'mhs_metop-b',
  sattypes_rad(56)= 'iasi_metop-b',  dsis(56)= 'iasi616_metop-b',
  sattypes_rad(57)= 'avhrr3_metop-b',dsis(57)= 'avhrr3_metop-b',
  sattypes_rad(58)= 'atms_npp',      dsis(58)= 'atms_npp',
  sattypes_rad(59)= 'cris_npp',      dsis(59)= 'cris_npp',
 /
 &END
 &ozobs_enkf
 /
 &END

EOF
 
#----------------------------------------------------------------------------
# copy member input input files
#----------------------------------------------------------------------------
# diagnose file list  
  echo $dtg > ${NWPWRKENS}/crdate

  NCP=/bin/cp

####### copy diag file 
  DIAG_SUFFIX='_ensmean'
  export CNVSTAT=${NWPSAVENS}/cnvstat.20${dtg}${DIAG_SUFFIX}.tar
  export PCPSTAT=${NWPSAVENS}/pcpstat.20${dtg}${DIAG_SUFFIX}.tar
  export OZNSTAT=${NWPSAVENS}/oznstat.20${dtg}${DIAG_SUFFIX}.tar
  export RADSTAT=${NWPSAVENS}/radstat.20${dtg}${DIAG_SUFFIX}.tar

  list="$CNVSTAT $OZNSTAT $RADSTAT"
  for type in $list; do
     $NCP ${type} ./
       tar -xvf ${type}
  done

#--
  imem=1
  while [[ $imem -le ${NTOTMEM} ]]; do
      member="_mem"`printf %03i $imem`
      export CNVSTAT=${NWPSAVENS}/cnvstat.20${dtg}${member}.tar
      export PCPSTAT=${NWPSAVENS}/pcpstat.20${dtg}${member}.tar
      export OZNSTAT=${NWPSAVENS}/oznstat.20${dtg}${member}.tar
      export RADSTAT=${NWPSAVENS}/radstat.20${dtg}${member}.tar

      list="$CNVSTAT $OZNSTAT $RADSTAT"
      for type in $list; do
         $NCP ${type} ./
         tar -xvf ${type}
      done
      (( imem = $imem + 1 ))
   done


######## link ges files 
  typeset -Z3 cmem3
  cmem3=1
  while [ $cmem3 -le ${NTOTMEM} ] ; do

    # link background input file  
    rm -f  sfg_20${dtg}_fhr06_mem${cmem3} 
    ln -sf  ${NWPDTGENS}/sigf06_20${fgdtg}_mem${cmem3} sfg_20${dtg}_fhr06_mem${cmem3}

    ((cmem3=$cmem3+1))
  done

  rm -f  sfg_20${dtg}_fhr06_ensmean
  ln -sf  ${NWPDTGENS}/sigf06_ensmean.20${fgdtg} sfg_20${dtg}_fhr06_ensmean
 
#----------------------------------------------------------------------------
# copy satallite bias correction files from MAIN run
#----------------------------------------------------------------------------
  cp ${NWPDTGSAV}/satbias.20${fgdtg}     satbias_in
  cp ${NWPDTGSAV}/satbias_pc.20${fgdtg}  satbias_pc
  cp ${NWPDTGSAV}/satbias_ang.20${fgdtg} satbias_angle

#----------------------------------------------------------------------------
# execute  enkf
#----------------------------------------------------------------------------
  #-- clear files
  rm -f sanl_20${dtg}*

  #-- executalbe
  #/usr/bin/time -p mpiexec -of stdoutenkf -stdin enkf.nml -n $MPI ${NWPBIN}/GENS_global_enkf
  /usr/bin/time -p mpiexec -of stdoutenkf -stdin enkf.nml -n $MPI  ${ENKFexe}

  if [ $? != 0 ] ; then 
    echo "ENKF: error occured: GENSenkf.ksh fail !!"
    echo "ENKF: error occured: enkf.ksh fail !!" > ${STATUS}/enkf.${dtg}.fail
    exit 2
  fi

  #-- un-ln files
  echo "NWPDTGENS="${NWPDTGENS}
  pwd

  ls -l  sanl_20${dtg}_mem*
  sleep 3

  #-- save log file 
  cp -f stdoutenkf ${NWPDTGENS}/stdout.enkf.${dtg}

  #--check file existing or not 
  cmem3=1
  while [ $cmem3 -le ${NTOTMEM} ] ; do
    sanlf=sanl_20${dtg}_mem${cmem3}

    # check file existing or not 
    if [ ! -s $sanlf ] ; then
      echo "ENKF: error occured: GENSenkf.ksh fail !!"
      echo "ENKF: error occured: enkf.ksh fail !!" > ${STATUS}/enkf.${dtg}.fail
      exit 2
    else
      rm -rf ${NWPDTGENS}/${sanlf}
      mv ${NWPWRKENS}/${sanlf} ${NWPDTGENS}     # copy ensemble analysis to Tank

      if [ $? != 0 ] ; then 
        echo "ENKF: error occured: GENSenkf.ksh fail !!"
        echo "ENKF: error occured: enkf.ksh fail !!" > ${STATUS}/enkf.${dtg}.fail
        exit 2
      fi
    fi

    ((cmem3=$cmem3+1))

  done


