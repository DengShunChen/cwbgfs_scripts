#!/bin/ksh
#==============================================================================
#
# Purpose : Main CWB GDAS (GSI) Script
#
# Log:
#   2017-10-26  Deng-Shun  Created 
#   2017-12-13  Deng-Shun  Add capacity of copy or link file into working
#                          directory.
#
#
#
#  Created by Deng-Shun Chen 
#==============================================================================
  export NLAT_A=${NLAT_A:-$(($LATA+2))}
  export NLON_A=${NLON_A:-$LONA}
  export NMEM_ENS=${NTOTMEM}
  export dtg10=${dtg10:-''}
  export SAVEDIR=${SAVEDIR:-'./'}
  export SELECT_OBS_TARBALL=${SELECT_OBS_TARBALL:-'NO'}
  export DIAG_TARBALL=${DIAG_TARBALL:-'YES'}
  export DIAG_COMPRESS=${DIAG_COMPRESS:-'YES'}
  if [ $optrun = "MAIN"  ]; then
    export DIAG_SUFFIX=${DIAG_SUFFIX:-""}
  else
    if [ $mem -eq  0   ]; then
      export DIAG_SUFFIX=${DIAG_SUFFIX:-"_ensmean"}
    else
      cmem3=`printf %03i ${mem}`
      export DIAG_SUFFIX=${DIAG_SUFFIX:-"_mem${cmem3}"}
    fi
  fi
  export GSISTAT=${GSISTAT:-gsistat.${dtg10}${DIAG_SUFFIX}}
  export CNVSTAT=${CNVSTAT:-cnvstat.${dtg10}${DIAG_SUFFIX}.tar}
  export PCPSTAT=${PCPSTAT:-pcpstat.${dtg10}${DIAG_SUFFIX}.tar}
  export OZNSTAT=${OZNSTAT:-oznstat.${dtg10}${DIAG_SUFFIX}.tar}
  export RADSTAT=${RADSTAT:-radstat.${dtg10}${DIAG_SUFFIX}.tar}
  export wc=${wc:-/usr/bin/wc}
  export COMPRESS=${COMPRESS:-gzip}
  export UNCOMPRESS=${UNCOMPRESS:-gunzip}
  export ERRSCRIPT=${ERRSCRIPT:-'eval [[ $err = 0 ]]'}
  export FILESTYLE=${FILESTYLE:-'C'}

  #-- catech up option flag from outside
  if [ $opt_4denvar -eq 1 ] ; then
    export l4densvar='.true.'
  fi
  if [ $opt_sdbeta -eq 1 ] ; then
    export lsdbeta='.true.'
  fi


  #-- setup namelsit
  export suffix=''   # currently not allow subfix in gsiparm

  # controls for innovation
  export lrun_select_obs=${lrun_select_obs:-".false."}
  export lrun_innovate=${lrun_innovate:-".false."}
  export lrun_subdirs=${lrun_subdirs:-".false."}        # run GSI with scratch files in sub-directories

  #  Set script / GSI control parameters
  export use_gfs_nemsio=${use_gfs_nemsio:-".false."}   # run GSI with NEMSIO input/output

  # controls for 4DEnVar
  export l4densvar=${l4densvar:-".false."}             # run GSI in hybrid 4D ensemble-variational mode
  export lwrite4danl=${lwrite4danl:-".false."}         # .false. = write single analysis at center time
  export DOIAU=${DOIAU:-"NO"}                          # run global_cycle for IAU

  # scale-dependent weighting
  export lsdbeta=${lsdbeta:-".false."}

#==============================================================================
# mode setttings
#==============================================================================
if [ $optrun = "MAIN" ] ; then

  SAVEDIR=${NWPDTGSAV}

  stdout_fn=${SAVEDIR}/stdout.anl.${dtg10}
  siganl_fn=${SAVEDIR}/siganl.${dtg10}
  sfcanl_fn=${SAVEDIR}/sfcanl.${dtg10}
  sigf06_fn=${SAVEDIR}/sigf06.${fgdtg10}
  sfcf06_fn=${SAVEDIR}/sfcf06.${fgdtg10}
  status_fn=${STATUS}/g3dv_MAIN.${dtg10}

  if [ $opt_4denvar -eq 1 ] ; then
    OBSBINS='03 04 05 06 07 08 09'
  else
    OBSBINS='06'
  fi

  UPDATEHR=${UPDATEHR_MAIN}
  idtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -${UPDATEHR} `
  for OBS_BIN in ${OBSBINS} ; do
     ln -sf ${NWPDTGGLB}/sfcf${OBS_BIN}.20${idtg}  ./sfcf${OBS_BIN}
     ln -sf ${NWPDTGGLB}/sigf${OBS_BIN}.20${idtg}  ./sigf${OBS_BIN}
  done

  # member guess files, for opt_hyb=1 only
  if [ $opt_hyb -eq 1 ] ; then
     export DOHYBVAR=YES

    if [ -s ${STATUS}/fguess_ENS.${dtg}.ok ] ; then

      UPDATEHR=${UPDATEHR_MAIN}
      idtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -${UPDATEHR} `

      for OBS_BIN in ${OBSBINS} ; do
        for (( nmem=1; nmem<=${NTOTMEM}; nmem=nmem+1 )) ; do

          # set member id
          cmem3=`printf %03i $nmem`

          if [ ! -e ${NWPDTGENS}/sigf${OBS_BIN}_20${idtg}_mem${cmem3} ] ; then 
            echo "$nowt $dtg g3dv_${optrun} $mem fail" >> ${STATUS}/g3dv_${optrun}.${dtg}.fail
            echo "*Error* : ${NWPDTGENS}/sigf${OBS_BIN}_20${idtg}_mem${cmem3} NOT exist !! -exit" ;  exit -1 
          else
            ln -sf ${NWPDTGENS}/sigf${OBS_BIN}_20${idtg}_mem${cmem3}  ./sigf${OBS_BIN}_ens_mem${cmem3}
          fi 
        done
      done

      if [ $opt_lag -eq 1 ] ; then
        ((UPDATEHR=${UPDATEHR_MAIN}+${LAGGED_HR}))
        idtg=`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -${UPDATEHR} `
        l_lag='true'

        for OBS_BIN in ${OBSBINS} ; do
          for (( nmem=1; nmem<=${NTOTMEM}; nmem=nmem+1 )) ; do

            # set member id            
            cmem3=`printf %03i $nmem`

            # set time lagging memeber id 
            ((nmem_lag=nmem+${NTOTMEM}))
            cmem3_lag=`printf %03i $nmem_lag`

            # set time lagging member lead time
            ((OBS_BIN_LAG=${OBS_BIN}+${LAGGED_HR}))
            export OBS_BIN_LAG=`printf %02i ${OBS_BIN_LAG}`

            ln -sf ${NWPDTGENS}/sigf${OBS_BIN_LAG}_20${idtg}_mem${cmem3} ./sigf${OBS_BIN}_ens_mem${cmem3_lag}
            if [ ! -e ${NWPDTGENS}/sigf${OBS_BIN_LAG}_20${idtg}_mem${cmem3} ] ; then
              l_lag='false'
            fi 
          done
        done

        #-- double ensemble size
        if [ $l_lag = 'true' ] ; then
          ((NTOTMEM_LAG=$NTOTMEM*2))
          export NMEM_ENS=${NTOTMEM_LAG}
        fi

      fi
    else
      nowt=`date`
      echo "$nowt $dtg $cjob fail,since member guess files not ready!!" > ${STATUS}/${cjob}.${dtg}.fail
      exit -1
    fi
  else
    echo "None Hybrid DA run."
    export DOHYBVAR=NO
  fi
elif [ $optrun = "ENS" ] ; then
  SELECT_OBS=${SELECT_OBS:-"obsinput_${dtg10}_ensmean"}
  SAVEDIR=${NWPSAVENS}

  if [ $mem -eq 0 ] ; then   # ensemble mean 
    WORKDIR=${NWPWRKENS}/innov_ensmean
    rm -f -r  ${WORKDIR}
    mkdir ${WORKDIR}
    cd ${WORKDIR}
    stdout_fn=${SAVEDIR}/stdout_ensmean.anl.${dtg10}
    siganl_fn=${SAVEDIR}/siganl_ensmean.${dtg10}
    sfcanl_fn=${SAVEDIR}/sfcanl_ensmean.${dtg10}
    ln -fs ${NWPDTGENS}/sfcf06_ensmean.20${fgdtg}   sfcf06
    ln -fs ${NWPDTGENS}/sigf06_ensmean.20${fgdtg}   sigf06
  else
    cmem3=`printf %03i $mem`
    WORKDIR=${NWPWRKENS}/innov_${cmem3}
    rm -f -r  ${WORKDIR}
    mkdir ${WORKDIR}
    cd ${WORKDIR}
    stdout_fn=${SAVEDIR}/stdout_${cmem3}.anl.${dtg10}
    siganl_fn=${SAVEDIR}/siganl_mem${cmem3}.${dtg10}
    sfcanl_fn=${SAVEDIR}/sfcanl_mem${cmem3}.${dtg10}
    ln -fs ${NWPDTGENS}/sfcf06_20${fgdtg}_mem${cmem3}  sfcf06
    ln -fs ${NWPDTGENS}/sigf06_20${fgdtg}_mem${cmem3}  sigf06
    cp ${NWPDTGENS}/${SELECT_OBS} ${SELECT_OBS}
    tar -xvf ${SELECT_OBS}
  fi

else
  echo "Unknown optrun=$optrun -- stop " ; exit -1
fi

#==============================================================================
# input fixed files setting
#==============================================================================
#   berror   = forecast model background error statistics
#   specoef  = CRTM spectral coefficients
#   trncoef  = CRTM transmittance coefficients
#   emiscoef = CRTM coefficients for IR sea surface emissivity model
#   aerocoef = CRTM coefficients for aerosol effects
#   cldcoef  = CRTM coefficients for cloud effects
#   satinfo  = text file with information about assimilation of brightness temperatures
#   satangl  = angle dependent bias correction file (fixed in time)
#   pcpinfo  = text file with information about assimilation of prepcipitation rates
#   ozinfo   = text file with information about assimilation of ozone data
#   errtable = text file with obs error for conventional data (optional)
#   convinfo = text file with information about assimilation of conventional data
#   bufrtable= text file ONLY needed for single obs test (oneobstest=.true.)
#   bftab_sst= bufr table for sst ONLY needed for sst retrieval (retrieval=.true.)
#----------------------------------------------------------------------------
  export FIXGSI=${NWPDATANA}

  export SATINFO=${fnsatinfo:-${FIXGSI}/global_satinfo.txt}
  export CONVINFO=${fnconvinfo:-${FIXGSI}/global_convinfo.txt}

  export BERROR=${BERROR:-${FIXGSI}/global_berror.l${LEVS}y${NLAT_A}.f77}
  export SATANGL=${SATANGL:-${FIXGSI}/global_satangbias.txt}
  export ATMSFILTER=${ATMSFILTER:-${FIXGSI}/atms_beamwidth.txt}
  export RTMFIX=${RTMFIX:-${FIXGSI}/crtm_coeffs}
  export ANAVINFO=${ANAVINFO:-${FIXGSI}/global_anavinfo.l${LEVS}.txt}
  export INSITUINFO=${INSITUINFO:-${FIXGSI}/global_insituinfo.txt}
  export OZINFO=${OZINFO:-${FIXGSI}/global_ozinfo.txt}
  export PCPINFO=${PCPINFO:-${FIXGSI}/global_pcpinfo.txt}
  export AEROINFO=${AEROINFO:-${FIXGSI}/global_aeroinfo.txt}
  export SCANINFO=${SCANINFO:-${FIXGSI}/global_scaninfo.txt}
  export HYBENSINFO=${HYBENSINFO:-${FIXGSI}/global_hybens_locinfo.l${LEVS}.txt}
  export OBERROR=${OBERROR:-${FIXGSI}/prepobs_errtable.global}

  if [[ $FILESTYLE = 'C' ]]; then
    export FCPLN="cp"
  else
    export FCPLN="ln -fs"
  fi

  # Fixed fields
  $FCPLN $BERROR      berror_stats
  $FCPLN $SATANGL     satbias_angle
  $FCPLN $SATINFO     satinfo
  $FCPLN $ATMSFILTER  atms_beamwidth.txt
  $FCPLN $ANAVINFO    anavinfo
  $FCPLN $CONVINFO    convinfo
# $FCPLN $INSITUINFO  insituinfo
  $FCPLN $OZINFO      ozinfo
  $FCPLN $PCPINFO     pcpinfo
  $FCPLN $AEROINFO    aeroinfo
  $FCPLN $SCANINFO    scaninfo
  $FCPLN $HYBENSINFO  hybens_locinfo
  $FCPLN $OBERROR     errtable

  # CRTM Spectral and Transmittance coefficients
  mkdir -p crtm_coeffs
  for file in `awk '{if($1!~"!"){print $1}}' satinfo | sort | uniq` ;do
    $FCPLN $RTMFIX/${file}.SpcCoeff.bin ./crtm_coeffs/
    $FCPLN $RTMFIX/${file}.TauCoeff.bin ./crtm_coeffs/
  done

  $FCPLN $RTMFIX/Nalli.IRwater.EmisCoeff.bin   ./crtm_coeffs/Nalli.IRwater.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.IRice.EmisCoeff.bin    ./crtm_coeffs/NPOESS.IRice.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.IRland.EmisCoeff.bin   ./crtm_coeffs/NPOESS.IRland.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.IRsnow.EmisCoeff.bin   ./crtm_coeffs/NPOESS.IRsnow.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.VISice.EmisCoeff.bin   ./crtm_coeffs/NPOESS.VISice.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.VISland.EmisCoeff.bin  ./crtm_coeffs/NPOESS.VISland.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.VISsnow.EmisCoeff.bin  ./crtm_coeffs/NPOESS.VISsnow.EmisCoeff.bin
  $FCPLN $RTMFIX/NPOESS.VISwater.EmisCoeff.bin ./crtm_coeffs/NPOESS.VISwater.EmisCoeff.bin
  $FCPLN $RTMFIX/FASTEM6.MWwater.EmisCoeff.bin ./crtm_coeffs/FASTEM6.MWwater.EmisCoeff.bin
  $FCPLN $RTMFIX/FASTEM5.MWwater.EmisCoeff.bin ./crtm_coeffs/FASTEM5.MWwater.EmisCoeff.bin
  $FCPLN $RTMFIX/AerosolCoeff.bin              ./crtm_coeffs/AerosolCoeff.bin
  $FCPLN $RTMFIX/CloudCoeff.bin                ./crtm_coeffs/CloudCoeff.bin

#----------------------------------------------------------------------------
# satbias and diag files
#----------------------------------------------------------------------------
  cp ${NWPDTGSAV}/satbias.${fgdtg10}     satbias_in
  if [ ! -s satbias_in ] ; then
    echo "$nowt $dtg g3dv_${optrun} $mem fail" >> ${STATUS}/g3dv_${optrun}.${dtg}.fail
    echo "cp ${NWPDTGSAV}/satbias.${fgdtg10} satbias  fail !!! stop" ; exit -1
  fi

  cp ${NWPDTGSAV}/satbias_pc.${fgdtg10}   satbias_pc
  if [ ! -s satbias_pc ] ; then
    echo "$nowt $dtg g3dv_${optrun} $mem fail" >> ${STATUS}/g3dv_${optrun}.${dtg}.fail
    echo "cp ${NWPDTGSAV}/satbias.${fgdtg10} satbias  fail !!! stop" ; exit -1
  fi

  cp ${NWPDTGSAV}/pcpbias.${fgdtg10}     pcpbias_in
  if [ ! -s pcpbias_in ] ; then
    echo "cp ${NWPDTGSAV}/pcpbias.${fgdtg10} pcpbias  fail !!!"
  fi

  cp ${NWPDTGSAV}/satbias_ang.${fgdtg10} satbias_angle
  if [ ! -s satbias_angle ] ; then
    echo "cp ${NWPDTGSAV}/satbias_ang.${fgdtg10} satbias_angle  fail !!!"
  fi

  USE_NEWRADBC=${USE_NEWRADBC:-'YES'}
  if [[ "$USE_NEWRADBC" = "YES" ]]; then
    cp -rf ${NWPDTGSAV}/radstat.${fgdtg10}.tar .
    listdiag=`tar xvf radstat.${fgdtg10}.tar | cut -d' ' -f2 | grep _ges`
    for type in $listdiag; do
      diag_file=`echo $type | cut -d',' -f1`
      fname=`echo $diag_file | cut -d'.' -f1`
      date=`echo $diag_file | cut -d'.' -f2`
      $UNCOMPRESS $diag_file
      fnameges=$(echo $fname|sed 's/_ges//g')
      mv $fname.$date $fnameges
    done
  fi
  if [ ! -s diag_* ] ; then
    echo "$nowt $dtg g3dv_${optrun} $mem fail"
    echo "get diag_* fail"
  fi

#----------------------------------------------------------------------------
#  CWB created observation data
#----------------------------------------------------------------------------
  DT="obs${dtg10}.dat"
  [[ -s ${NWPDTGGLB}/t${DT} ]] && cp ${NWPDTGGLB}/t${DT} cwbt.dat
  [[ -s ${NWPDTGGLB}/w${DT} ]] && cp ${NWPDTGGLB}/w${DT} cwbw.dat
  [[ -s ${NWPDTGGLB}/q${DT} ]] && cp ${NWPDTGGLB}/q${DT} cwbq.dat
  [[ -s ${NWPDTGGLB}/p${DT} ]] && cp ${NWPDTGGLB}/p${DT} cwbps.dat

#----------------------------------------------------------------------------
# NCEP Buffer file
#----------------------------------------------------------------------------
  let nt=1
  typeset -i nt
  nt=1
  while [ $nt -le $ntype ] ; do
    tmpdtyp=`echo $bufrlst | cut -d" " -f${nt} `
    tmpbufr=`echo $namelst | cut -d" " -f${nt} `
    cp ${NWPDTGGLB}/${mp}.${tmpbufr}.${dtg}  ${tmpbufr}
    nt=nt+1
  done

#----------------------------------------------------------------------------
# bogus obs
#----------------------------------------------------------------------------
  DD="obs${dtg10}.dat.bgs"
  [[ -s ${NWPDTGGLB}/t${DD} ]] && cp ${NWPDTGGLB}/t${DD} bgst.dat
  [[ -s ${NWPDTGGLB}/w${DD} ]] && cp ${NWPDTGGLB}/w${DD} bgsw.dat
  [[ -s ${NWPDTGGLB}/q${DD} ]] && cp ${NWPDTGGLB}/q${DD} bgsq.dat
  [[ -s ${NWPDTGGLB}/p${DD} ]] && cp ${NWPDTGGLB}/p${DD} bgsps.dat

#----------------------------------------------------------------------------
# Create GSI namelist gsiparm 
#----------------------------------------------------------------------------
  . ${NWPBINS}/global_gsiparm.ksh

#----------------------------------------------------------------------------
# run gsi
#----------------------------------------------------------------------------
  XLFRTEOPTS=""
  MPIEXEC="mpiexec -n $MPI"

  ${MPIEXEC} -of stdout -stdin gsiparm.anl  ${GSIexe}

  if [ $? != 0 ] ; then
    nowt=`date`
    echo "$nowt $dtg g3dv_${optrun} $mem fail" >> ${STATUS}/g3dv_${optrun}.${dtg}.fail
    echo "GG_global_gsi Fail !!!" ; exit -1
  else
    echo "GG_global_gsi OK !!!"
    nowt=`date`
    echo "$nowt $dtg g3dv_${optrun} $mem ok" >> ${STATUS}/g3dv_${optrun}.${dtg}.ok
  fi

  if [ ! -s ${NWPDTGSAV} ] ; then
    mkdir ${NWPDTGSAV}
  fi

#----------------------------------------------------------------------------
#-- stall satbias_angle for pre-dtg
#----------------------------------------------------------------------------
  mv stdout ${stdout_fn}
  cat fort.2*  >> ${stdout_fn}
  cat fort.2*  > ${GSISTAT}

  if [ $optrun = "MAIN" ] ; then
    cp satbias_out    ${NWPDTGSAV}/satbias.${dtg10}
    cp satbias_pc.out ${NWPDTGSAV}/satbias_pc.${dtg10}
    cp pcpbias_out    ${NWPDTGSAV}/pcpbias.${dtg10}
    cp siganl         ${NWPDTGSAV}/siganl.${dtg10}
    cp sfcanl.gsi     ${NWPDTGSAV}/sfcanl.${dtg10}
    cp sigf06         ${NWPDTGSAV}/sigf06.${dtg10}
    cp sfcf06         ${NWPDTGSAV}/sfcf06.${dtg10}
  fi
#----------------------------------------------------------------------------
#  pack diagnose files
#----------------------------------------------------------------------------
# Set up lists and variables for various types of diagnostic files.
ntype=3

diagtype[0]="conv"
diagtype[1]="pcp_ssmi_dmsp pcp_tmi_trmm"
diagtype[2]="sbuv2_n16 sbuv2_n17 sbuv2_n18 sbuv2_n19 gome_metop-a gome_metop-b omi_aura mls30_aura"
diagtype[3]="hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g12 sndrd2_g12 sndrd3_g12 sndrd4_g12 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 sndrd1_g14 sndrd2_g14 sndrd3_g14 sndrd4_g14 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 imgr_g14 imgr_g15 ssmi_f13 ssmi_f15 hirs4_n18 hirs4_metop-a amsua_n18 amsua_metop-a mhs_n18 mhs_metop-a amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_f16 ssmis_f17 ssmis_f18 ssmis_f19 ssmis_f20 iasi_metop-a hirs4_n19 amsua_n19 mhs_n19 seviri_m08 seviri_m09 seviri_m10 cris_npp cris-fsr_npp atms_npp hirs4_metop-b amsua_metop-b mhs_metop-b iasi_metop-b avhrr_n18 avhrr_metop-a amsr2_gcom-w1 gmi_gpm saphir_meghat ahi_himawari8"

diaglist[0]=listcnv
diaglist[1]=listpcp
diaglist[2]=listozn
diaglist[3]=listrad

diagfile[0]=$CNVSTAT
diagfile[1]=$PCPSTAT
diagfile[2]=$OZNSTAT
diagfile[3]=$RADSTAT

numfile[0]=0
numfile[1]=0
numfile[2]=0
numfile[3]=0

# Set diagnostic file prefix based on lrun_subdirs variable
if [ $lrun_subdirs = ".true." ]; then
   prefix=" dir.*/"
else
   prefix="pe*"
fi

# Collect diagnostic files as a function of loop and type.
if [ $optrun = "MAIN"  ]; then
  loops="01 03"
  DIAG_SUFFIX=""
else
  loops="01"
  if [ $mem -eq  0   ]; then
    DIAG_SUFFIX="_ensmean"
  else
    cmem3=`printf %03i ${mem}`
    DIAG_SUFFIX='_mem'${cmem3}
  fi
fi
 
for loop in $loops; do
   case $loop in
      01) string=ges;;
      03) string=anl;;
       *) string=$loop;;
   esac
   echo $(date) START loop $string >&2
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      for type in `echo ${diagtype[n]}`; do
         count=`ls ${prefix}${type}_${loop}* | $wc -l`
         if [ $count -gt 0 ]; then
            cat ${prefix}${type}_${loop}* > diag_${type}_${string}.${dtg10}${DIAG_SUFFIX}
            echo "diag_${type}_${string}.${dtg10}*" >> ${diaglist[n]}
            numfile[n]=`expr ${numfile[n]} + 1`
         fi
      done
   done
   echo $(date) END loop $string >&2
done

#  If requested, create obs_input tarball 
if [ $SELECT_OBS_TARBALL = YES ] ; then
  if [ $mem -eq  0   ]; then
    tar -cvf ${SELECT_OBS} obs_input.*
    cp  ${SELECT_OBS}  ${NWPDTGENS}
  fi
fi

# If requested, compress diagnostic files
if [ $DIAG_COMPRESS = YES ]; then
   echo $(date) START $COMPRESS diagnostic files >&2
   for file in `ls diag_*${dtg10}${DIAG_SUFFIX}`; do
      $COMPRESS $file
   done
   echo $(date) END $COMPRESS diagnostic files >&2
fi

# If requested, create diagnostic file tarballs
if [[ $DIAG_TARBALL = YES ]]; then
   echo $(date) START tar diagnostic files >&2
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      TAROPTS="-uvf"
      if [ ! -s ${diagfile[n]} ]; then
         TAROPTS="-cvf"
      fi
      if [ ${numfile[n]} -gt 0 ]; then
         tar $TAROPTS ${diagfile[n]} `cat ${diaglist[n]}`
      fi
      cp ${diagfile[n]}  ${SAVEDIR}
   done

   echo $(date) END tar diagnostic files >&2
fi



exit 

