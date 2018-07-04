#!/bin/ksh

  # controls for innovation 
  export lrun_select_obs=${lrun_select_obs:-".false."}
  export lrun_innovate=${lrun_innovate:-".false."}
  export lrun_subdirs=${lrun_subdirs:-".true."}        # run GSI with scratch files in sub-directories

  #  Set script / GSI control parameters
  export use_gfs_nemsio=${use_gfs_nemsio:-".false."}   # run GSI with NEMSIO input/output

  # controls for 4DEnVar 
  export l4densvar=${l4densvar:-".false."}             # run GSI in hybrid 4D ensemble-variational mode
  export lwrite4danl=${lwrite4danl:-".false."}         # .false. = write single analysis at center time
  export DOIAU=${DOIAU:-"NO"}                          # run global_cycle for IAU

  # scale-dependent weighting 
  export lsdbeta=${lsdbeta:-".false."}

  # model vertical levels 
  LEVS=${LEVS:-60}

  # for model resolusion here is T511L60 
  JCAP=${JCAP:-511}
  JCAP_A=${JCAP_A:-511} 
  LONA=${LONA:-1536}
  LATA=${LATA:-768}
  LONB=${LONB:-1536}
  LATB=${LATB:-768}

  # for model resolusion here is T319L60 
  JCAP_ENKF=${JCAP_ENKF:-319}
  JCAP_A_ENKF=${JCAP_A_ENKF:-319}
  LONA_ENKF=${LONA_ENKF:-960}
  LATA_ENKF=${LATA_ENKF:-480}
  LONB_ENKF=${LONB_ENKF:-960}
  LATB_ENKF=${LATB_ENKF:-480}

  CDATE=${CDATE:-16080101}

if [ $lrun_innovate = .true. ] ;  then
  # Forecast Horizontal Resolution
  export JCAP=${JCAP_ENKF:-511}            # Backgorund 
  export JCAP_A=${JCAP_A_ENKF:-511}        # Analysis

  # Forecast Vertical Resolution
  export LEVS=${LEVS:-60}

  # These are for the T511L60  (A : Analysis, B : Background)
  export LATA=${LATA_ENKF:-$LATB}
  export LONA=${LONA_ENKF:-$LONB}
  export NLAT_A=${NLAT_A_ENKF:-$(($LATA+2))}
  export NLON_A=${NLON_A_ENKF:-$LONA}
  export DELTIM=${DELTIM:-$((3600/($JCAP_A/20)))}
 
  # Time Step
  export DELTIM=${DELTIM:-180}

  # PDS Grid Designator
  export IGEN=${IGEN:-82}

  lrun_select_obs=${lrun_select_obs:-.false.}
  # Set namelist jobs for ensemble data selection
  if  [ $lrun_select_obs = .true. ] ;  then
    suffix=${suffix-'.selectobs'}
    export USE_NEWRADBC=${USE_NEWRADBC:-YES}
    export SETUP="miter=0,niter=1,lread_obs_save=.true.,lread_obs_skip=.false.,lwrite_predterms=.true.,lwrite_peakwt=.true.,reduce_diag=.true.,passive_bc=.false.,"
    export BKGVERR="bkgv_flowdep=.false.,"
    export STRONGOPTS="tlnmc_option=0,nstrong=0,nvmodes_keep=0,baldiag_full=.false.,baldiag_inc=.false.,"
    export OBSQC="tcp_width=60.0,tcp_ermin=2.0,tcp_ermax=12.0,qc_noirjaco3_pole=.true.,"
    export OBSINPUT="dmesh(1)=225.0,dmesh(2)=225.0,"
  else
    suffix=${suffix-'.innovate'}
    export USE_NEWRADBC=${USE_NEWRADBC:-YES}
    export SETUP="miter=0,niter=1,lread_obs_save=.false.,lread_obs_skip=.true.,lwrite_predterms=.true.,lwrite_peakwt=.true.,reduce_diag=.true.,passive_bc=.false.,"
    export BKGVERR="bkgv_flowdep=.false.,"
    export STRONGOPTS="tlnmc_option=0,nstrong=0,nvmodes_keep=0,baldiag_full=.false.,baldiag_inc=.false.,"
    export OBSQC="tcp_width=60.0,tcp_ermin=2.0,tcp_ermax=12.0,qc_noirjaco3_pole=.true.,"
    export OBSINPUT="dmesh(1)=225.0,dmesh(2)=225.0,"
  fi

else
  suffix=${suffix-'.analysis'}
  # Forecast Horizontal Resolution
  export JCAP=${JCAP:-511}            # Backgorund 
  export JCAP_A=${JCAP_A:-511}        # Analysis
  
  # Forecast Vertical Resolution
  export LEVS=${LEVS:-60}
  
  # These are for the T511L60  (A : Analysis, B : Background)
  export LATA=${LATA:-$LATB}
  export LONA=${LONA:-$LONB}
  export NLAT_A=${NLAT_A:-$(($LATA+2))}
  export NLON_A=${NLON_A:-$LONA}
  export DELTIM=${DELTIM:-$((3600/($JCAP_A/20)))}
  
  # Set hybrid and ensemble resolution parameters
  export DOHYBVAR=${DOHYBVAR:-YES}
  
  export NMEM_ENS=${NMEM_ENS:-36}
  export JCAP_ENS=${JCAP_ENS:-319}
  export NLAT_ENS=${NLAT_ENS:-482}
  export NLON_ENS=${NLON_ENS:-960}
  
  # Time Step
  export DELTIM=${DELTIM:-90}
  
  # Surface cycle
  export use_ufo=${use_ufo:-.true.}
  export SNOW_NUDGE_COEFF=${SNOW_NUDGE_COEFF:-'-2.'}
  
  # PDS Grid Designator
  export IGEN=${IGEN:-82}
  
  
  if [ $lsdbeta = .true. ] ; then
    SDBETA="l_sdbeta=.true.,jcap_sdwgt_start=80,jcap_sdwgt_end=120,"
  fi


  # Set namelist jobs for hybrid 3dvar-ensemble analysis
  export HYBRID_ENSEMBLE=""
  if [[ "$DOHYBVAR" = "YES" ]]; then
    export SDBETA=${SDBETA:-}
    export HYBRID_ENSEMBLE="l_hyb_ens=.true.,n_ens=${NMEM_ENS},beta1_inv=0.25,s_ens_h=800.,s_ens_v=-0.8,generate_ens=.false.,uv_hyb_ens=.true.,jcap_ens=$JCAP_ENS,nlat_ens=$NLAT_ENS,nlon_ens=$NLON_ENS,aniso_a_en=.false.,jcap_ens_test=$JCAP_ENS,readin_localization=.false.,oz_univ_static=.false., ${SDBETA}"
    export STRONGOPTS="tlnmc_option=2,"
  fi

  # 4DEnVar setup
  SETUP_4DVAR=""
  if [ $l4densvar = .true. ] ; then
    SETUP_4DVAR="niter(1)=50,niter(2)=150,niter_no_qc(1)=25,l4densvar=.true.,ens4d_nstarthr=3,nhr_obsbin=1,nhr_assimilation=6,lwrite4danl=${lwrite4danl},"
    export JCOPTS="ljc4tlevs=.true.,"
    export STRONGOPTS="tlnmc_option=3,"
  fi

  export SETUP="$SETUP_4DVAR $SETUPGFS"

fi

#-------------------------------------------------------------
# Control 
#-------------------------------------------------------------
SETUP=${SETUP:-}
GRIDOPTS=${GRIDOPTS:-}
BKGVERR=${BKGVERR:-}
ANBKGERR=${ANBKGERR:-}
JCOPTS=${JCOPTS:-}
STRONGOPTS=${STRONGOPTS:-}
OBSINPUT=${OBSINPUT:-}
SUPERRAD=${SUPERRAD:-}
LAGDATA=${LAGDATA:-}
HYBRID_ENSEMBLE=${HYBRID_ENSEMBLE:-}
RAPIDREFRESH_CLDSURF=${RAPIDREFRESH_CLDSURF:-}
CHEM=${CHEN:-}
SINGLEOB=${SINGLEOB:-}


#-------------------------------------------------------------
# Create global_gsi namelist
#-------------------------------------------------------------
cat <<EOF > gsiparm.anl${suffix}
 &SETUP
   miter=2,niter(1)=100,niter(2)=100,
   niter_no_qc(1)=50,niter_no_qc(2)=0,
   write_diag(1)=.true.,write_diag(2)=.false.,write_diag(3)=.true.,
   qoption=2,
   gencode=$IGEN,factqmin=5.0,factqmax=0.005,deltim=$DELTIM, clip_supersaturation=.true.,
   iguess=-1,
   nst_gsi=0,nst_tzr=0,nstinfo=0,fac_dtl=0,fac_tsl=0,
   oneobtest=.false.,retrieval=.false.,l_foto=.false.,
   use_pbl=.false.,use_compress=.true.,nsig_ext=12,gpstop=50.,
   use_gfs_nemsio=${use_gfs_nemsio},lrun_subdirs=${lrun_subdirs},
   crtm_coeffs_path='./crtm_coeffs/',
   newpc4pred=.false.,adp_anglebc=.false.,angord=4,passive_bc=.true.,use_edges=.false.,
   diag_precon=.true.,step_start=1.e-3,emiss_bc=.true.,thin4d=.false.,
   $SETUP
 /
 &GRIDOPTS
   JCAP_B=$JCAP,JCAP=$JCAP_A,NLAT=$NLAT_A,NLON=$NLON_A,nsig=$LEVS,
   regional=.false.,nlayers(59)=3,nlayers(60)=6,
   $GRIDOPTS
 /
 &BKGERR
   vs=0.7,
   hzscl=1.7,0.8,0.5,
   hswgt=0.45,0.3,0.25,
   bw=0.0,norsp=4,
   bkgv_flowdep=.true.,bkgv_rewgtfct=1.5,
   bkgv_write=.false.,
   cwcoveqqcov=.false.,
   $BKGVERR
 /
&ANBKGERR
   anisotropic=.false.,
   $ANBKGERR
 /
 &JCOPTS
   ljcdfi=.false.,alphajc=0.0,ljcpdry=.true.,bamp_jcpdry=5.0e7,
   $JCOPTS
 /
 &STRONGOPTS
   tlnmc_option=2,nstrong=1,nvmodes_keep=8,period_max=6.,period_width=1.5,
   $STRONGOPTS
 /
 &OBSQC
   dfact=0.75,dfact1=3.0,noiqc=.true.,oberrflg=.false.,c_varqc=0.02,
   use_poq7=.true.,qc_noirjaco3_pole=.true.,
   aircraft_t_bc=.false.,biaspredt=1000.0,upd_aircraft=.false.,
   $OBSQC
 /
 &OBS_INPUT
   dmesh(1)=145.0,dmesh(2)=150.0,dmesh(3)=100.0,time_window_max=3.0,
   $OBSINPUT
 /
OBS_INPUT::
!  dfile          dtype       dplat       dsis                dval    dthin dsfcalc
   prepbufr       ps          null        ps                  0.0     0     0
   prepbufr       t           null        t                   0.0     0     0
   prepbufr       q           null        q                   0.0     0     0
   prepbufr       pw          null        pw                  0.0     0     0
   prepbufr       uv          null        uv                  0.0     0     0
   prepbufr       spd         null        spd                 0.0     0     0
   prepbufr       dw          null        dw                  0.0     0     0
   prepbufr       sst         null        sst                 0.0     0     0
   gpsrobufr      gps_ref     null        gps                 0.0     0     0
   cwbw.dat       cwbuv       null        cwbuv               0.0     0     0
   cwbt.dat       cwbt        null        cwbt                0.0     0     0
   bgst.dat       bgst        null        t                   0.0     0     0
   bgsw.dat       bgsuv       null        uv                  0.0     0     0
   bgsq.dat       bgsq        null        q                   0.0     0     0
   bgsps.dat      bgsps       null        ps                  0.0     0     0
   amsuabufr      amsua       n15         amsua_n15           0.0     1     1
   amsuabufr      amsua       n18         amsua_n18           0.0     1     1
   amsuabufr      amsua       metop-a     amsua_metop-a       0.0     1     1
   airsbufr       amsua       aqua        amsua_aqua          0.0     1     1
   iasibufr       iasi        metop-a     iasi616_metop-a     0.0     1     1
   airsbufr       airs        aqua        airs281SUBSET_aqua  0.0     1     1
   atmsbufr       atms        npp         atms_npp            0.0     1     0
::
&SUPEROB_RADAR
   $SUPERRAD
 /
 &LAG_DATA
   $LAGDATA
 /
 &HYBRID_ENSEMBLE
   $HYBRID_ENSEMBLE
 /
  ensemble_path='./ensemble_data/',
 &RAPIDREFRESH_CLDSURF
   dfi_radar_latent_heat_time_period=30.0,
   $RAPIDREFRESH_CLDSURF
 /
 &CHEM
   $CHEM
 /
 &SINGLEOB_TEST
   maginnov=0.1,magoberr=0.1,oneob_type='t',
   oblat=45.,oblon=180.,obpres=1000.,obdattim=${CDATE},
   obhourset=0.,
   $SINGLEOB
 /
EOF




