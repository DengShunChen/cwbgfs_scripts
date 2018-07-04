#!/bin/ksh
#set -x
#-------------------------------------------------------------------------------
#
#   Purpose : create CWB GFS enviroment for new experiment.
#
#   History : 
#     2015.02     W.M. Chen     Created.
#     2015.06.02  W.M. Chen     Update gsi,enkf and gfs.
#     2015.09.07  W.M. Chen     Difine DTMV for datamv 
#     2015.10.06  W.M. Chen     Prepare 1'st run data from userDefine/silo optionally
#     2016.01.19  W.M. Chen     Backup ncepbufr data files at NCEPBUFR directory
#                               backup ncepoz data files at NCEPOZ directory
#                               backup fgge files at CWBFGGE directory
#     2016.01.31  W.M. Chen     For Joaquin hurrican test,create new option opt_Wtyp 
#                               opt_Wtyp   =1   for Hurrican only check Wtyphoon${dtg}
#                                          =0   checkWtyphoon${dtg} for W-Pacific Ocean typhoon
#                               the exe file are different for the 2 situations.
#                                => opt_Wtyp should depend on the reloc.exe you used
#                               20160314, not used, since both typhoon${dtg}.dat and 
#                               Wtyphoon${dtg}.dat will be checked
#     2018.01.19  D.S. Chen     New version of creating 0000.config file for GFS Scripts                         
#     2018.01.22  D.S. Chen     Add comment and instructions 
#     2018.01.25  D.S. Chen     Bug-fix 
#     2018.02.24  D.S. Chen     Modify the out put message 
#
#   Definitions : 
#     expname         experiment name
#     dtg_first       the start date and time
#     inthr           interval in hours between 2 run for 
#                     post , it has to be 6
#                     major run, if you need to check 00/12Z only, inthr=12
#                            => will run, e.g., 14010100,14010112,14010200...
#                            if you need to check 00/06/12/18, inthr=6
#     MP              =P for post run
#                     =M for major run(not fully test yet!!) 
#     opt_hyb         =1   hybrid analysis. make sure l_hyb_ens=.true. in gsiparm_main
#                     =0   var analysis. make sure l_hyb_ens=.false. in gsiparm_main
#     fcstmode        = upd      6hrs fcst only
#                     = fd5      5 days fcst
#                      (it could be changed by vi 0100_gdas.input.${exp}
#                       during your update cycle run)
#     opt_crtworkdir  = 1, create work enviroment
#                     = 0, work enviroment exist, create config file only
#     opt_crtconfig   = 1, create config file
#                     = 0, do not create config file
#-------------------------------------------------------------------------------
  export expname='h3dtlmsdb'
  export dtg_first=17031500
  export inthr=6
  export MP=P
  export fcstmode=upd
  export opt_hyb=1
  export opt_crtworkdir=1
  export opt_crtconfig=1
#-----------------------------------
# USER          HPC user name
# SILOUSER      hsmsvr user name
# MACHINE       HPC machine name
# LGIN          Login node hostname
# DTMV          Data mover hostname for gerneral use
# PJSUB         HPC submiting (No need to change so far)
# SETMPI        HPC mpi setup file
# SETMPIOMP     HPC mpi+omp setup file
#-----------------------------------
  export USER='xb80'
  export SILOUSER='xb80'
  export MACHINE='fx100'
  export LGIN="login11"
  export DTMV="login11 ssh dm07"
  export PJSUB='pjsub -L rscgrp=research-x'
  export SETMPI="setup_mpi.${MACHINE}"
  export SETMPIOMP="setup_mpi+omp.${MACHINE}"
#-----------------------------------
#  set for experiment
#   DMSDBPATH   user's dms data base localtion 
#   REMWRK      user's working directory, should be in /data, /data1 or /data2
#   MDIR        GFS_Scripts location, which contains /dat /bin /scripts /crtexp /util
#   MDIRDAT     contains fixed files
#   MDIRBIN     contains executable
#   MDIRSCT     contains scripts
#   MDIRCRT     contains create experiment tools
#   MDIRUTIL    contains utility 
#   NWP         experimental location
#   NWPDAT      experimental fixed files
#   NWPDATANA   experimental GSI fixed file
#   NWPDATPERT  experimental GSI NMC perturbations
#   NWPBIN      experimental executables
#   NWPBINS     experimental scripts 
#   DTG         experimental main data pool
#   DTGWRK      experimental gsi working space
#   DTGSAV      experimental saving space
#   DTGENS      experimental ensemble data pool
#   DTGENSWRK   experimental ensemble working space
#   DTGENSSAV   experimental ensemble saving space
#   LOGDIR      contains experimental log files
#   STATUS      contains experimental status flags
#   GFSDIR      global model working space
#   REMWRK      MAIN working directory for gsi and gfs
#   TPDIR       directory with typhoon${dtg}.dat
#   WTPDIR      directory with Wtyphoon${dtg}.dat
#-----------------------------------
  export DMSDBPATH="/nwpr/gfs/xb80/data2/dmsdb"
  export REMWRK="/nwpr/gfs/xb80/data2/WORKDIR/rt512l60v_wrk"
  export MDIR="/nwpr/gfs/xb80/data2/CWBGFS"
  export MDIRDAT="${MDIR}/dat"
  export MDIRBIN="${MDIR}/bin"
  export MDIRSCT="${MDIR}/scripts"
  export MDIRCRT="${MDIR}/crtexp"
  export MDIRUTIL="${MDIR}/util"
  export NWP="${MDIR}/exp_${expname}"
  export NWPDAT="${MDIR}/dat"
  export NWPDATANA="${NWPDAT}/gsifix"
  export NWPDATPERT="${NWPDAT}/enspert"
  export NWPBIN="${MDIR}/bin"
  export NWPBINS="${NWP}/bins"
  export DTG="${NWP}/dtg"
  export DTGWRK="${NWP}/dtg_wrk"
  export DTGSAV="${NWP}/dtg_save"
  export DTGENS="${NWP}/dtg_ens"
  export DTGENSWRK="${NWP}/dtg_ens_wrk"
  export DTGENSSAV="${NWP}/dtg_ens_save"
  export LOGDIR="${NWP}/logdir"
  export STATUS="${NWP}/status"
  export GFSDIR="${NWP}/gfs"
  export TPDIR="/nwp/npcagfs/TYP/M00/dtg/ty"
  export WTPDIR="/nwp/npcagfs/TYP/M00/dtg/ty"
#-------------------------------------------------------------------------------
# model resolusion settings :
#   gfsflag       main analysis dms flag
#   JCAPB         main backgound total wave number
#   LONB          main backgound (dx) x-asix points
#   LATB          main backgound (dy) y-asix points  
#   JCAPA         main analysis total wave number
#   LONA          main analysis (dx) x-asix points
#   LATA          main analysis (dy) y-asix points
#   ensflag       main analysis dms flag
#   JCAPB_ENKF    ensemble backgound total wave number
#   LONB_ENKF     ensemble backgound (dx) x-asix points
#   LATB_ENKF     ensemble backgound (dy) y-asix points
#   JCAPA_ENKF    ensemble analysis total wave number
#   LONA_ENKF     ensemble analysis (dx) x-asix points
#   LATA_ENKF     ensemble analysis (dy) y-asix points
#   LEVS          model vertical levles 
#   NTOTMEM       total ensemble members
#-------------------------------------------------------------------------------
  # for model resolusion here is T511L60 
  export gfsflag='GH'
  export JCAPB=511
  export LONB=1536
  export LATB=768
  export JCAPA=511
  export LONA=1536
  export LATA=768

  # for model resolusion here is T319L60 
  export ensflag='GG'
  export JCAPB_ENKF=319
  export LONB_ENKF=960
  export LATB_ENKF=480
  export JCAPA_ENKF=319
  export LONA_ENKF=960
  export LATA_ENKF=480

  # model vertical levels 
  export LEVS=60

  # total members
  export NTOTMEM=36
#-------------------------------------------------------------------------------
# input dms file needed :
#     DMSFN                         : dms data file name
#     DMSDB                         : dms data base name
#     SNOWICE=SNOWICE@${NCEPECDB}   : snowice ana(dms) from NCEP
#                                     if data for analysis dtg not exist =>
#                                     will rdmscpy from NCEPGRID\${dtg0}_000-024@NCEPGRID-\${mm}@archive@hsmsvr1f"
#     SSTNMC@${NCEPECDB}            : sst ana(dms) from NCEP 
#                                     if data for analysis dtg not exist
#                                     (1) before 2013123118
#                                     will rdmscpy from MASOPS\${gdtg}GG0GM-0024@NWPDB-\${mm}@archive@hsmsvr1f and process
#                                     (2) after
#                                     will rdmscpy from  NCEPGRID\${dtg0}_000-024@NCEPGRID-\${mm}@archive@hsmsvr1f and proc
#
#     ECGRID@${NCEPECDB}            : EC ana/24hrs fcst data (dms)
#                                     if data for analysis dtg not exist
#                                     will rdmscpy from   ECGRID${dtg}@ECGRID-\${mm}@archive@hsmsvr1f
#     BCKDMSDB                      : CWB GFS model prefixed dms data base
#     CLMDMSDB                      : CWB GFS climatology dms data base 
#     SCOREDMSDB                    : score dms data base 
#-------------------------------------------------------------------------------
  export DMSFN=${expname}
  export DMSDB=${expname}
  export NCEPECDB="ncepec"
  export SNOWDMSFN='SNOWDMS'
  export SNOWDMS=${SNOWDMSFN}@${NCEPECDB}
  export SSTDMSFN='SSTDMS'
  export SSTDMS=${SSTDMSFN}@${NCEPECDB}
  export ECDMSFN='ECGRID'
  export ECDMS=${ECDMSFN}@${NCEPECDB}
  export BCKDMSDB=bckdms@${USER}
  export CLMDMSDB=t512l60@${USER}
  export SCOREDMSDB=${DMSDB}
#----------------------------------------------------------
# set for basic enviroment
#   BCKOPSFN      dms file name of BCKOPS for MAIN run
#   BCKENSFN      dms file name of BCKENS for ENKF run
#   BCKOPS        model prefixed dms path for MAIN run
#   BCKENS        model prefixed dms path for ENKF run
#----------------------------------------------------------
  export BCKOPSFN='BCKOPS'
  export BCKENSFN='BCKENKF'
  export BCKOPS=${BCKOPSFN}@${DMSDB}
  export BCKENS=${BCKENSFN}@${DMSDB}
#-----------------------------------
#--- for preparing initial data from operation!!
# climdmsdb     
# opt_getidata =0   do not need to prepare initial data
#              =1   get initial dms data from specific dms files
#                   and change resolution
#                   ex1: from operational parallel run at fx100
#                       start_dmsdb=NWPDB@${USER}@login11
#                       start_maindms=MASOPS
#                       start_enkfdms=MASOPS 
#                   ex2:  from prepared dms files at ${expname}
#                       start_dmsdb=${expname}
#                       start_maindms=MASOPSop
#                       start_enkfdms=MASOPSop
#                 define directory for bias files from :  
#                   start_biasdir=${MDIR}/opdiag
#              =2  get operational data from silo and change resolution (not tested!!!!)
#                 (from t320l40_t180l40 to t512l60_t320l60 now(201510))
#-----------------------------------
#-----------------------------------
# get initial data for exp run
#-----------------------------------
  export opt_getidata=2

  # needed when opt_getidata=1
  export start_biasdir="${MDIR}/newdiag"

  # needed when opt_getidata=2
  export silo_gfsflag="GH"
  export silo_gfs_lon=1536
  export silo_gfs_nlev=60

  export silo_ensflag="GG"
  export silo_ens_lon=960
  export silo_ens_nlev=60
#----------------------------------------------------------
#   opt_getBCK    =1, copy model prefixed dms ; =0, no copy
#   BCKOPSFN_op   the source of the model prefixed dms for MAIN run
#   BCKENSFN_op   the source of the model prefixed dms for ENKF run
#----------------------------------------------------------
  export opt_getBCK=1
  export BCKOPSFN_op="BCK_${gfsflag}@${BCKDMSDB}"
  export BCKENSFN_op="BCK_${ensflag}@${BCKDMSDB}"
#-----------------------------------
# set dir  for saving files locally
# opt_saveobs2loc  =1    will save observational files at local directory
#                  =0    will not save observational files  at local dir
# NCEPBUFR    for NCEP bufr files
# NCEPOZ      for NCEP oz files
# CWBFGGE     for CWBFGGE files 
#-----------------------------------
  export opt_saveobs2loc=0
  export NCEPBUFR="/nwpr/gfs/xb80/data2/ncepbufr"
  export NCEPOZ="/nwpr/gfs/xb80/data2/ncepbufr"
  export CWBFGGE="/nwpr/gfs/xb80/data2/fggedat"   # for major run 
#--------------------------------------------------------------
# gfs workdir from
#--------------------------------------------------------------
# export GFSFROM_MAIN=${MDIRDAT}/gfst512l60
# export GFSFROM_ENKF=${MDIRDAT}/gfst320l60
#--------------------------------------------------------------
# resource for analysis and fcst
#--------------------------------------------------------------
  # resource for MAIN gsi
#  export anode_main=48 ;  export ampi_main=128  ; export aomp_main=10
  export anode_main=66 ;  export ampi_main=192  ; export aomp_main=4

  # resource for ENKF gsi
  export anode_ens=8  ; export ampi_ens=32 ;  export aomp_ens=4  ; export agrp_ens=6

  # resource for ENKF enkf
  export enode=24 ; export empi=192 ; export eomp=4

  # resource for ENKF inflation
  export inode=3  ; export impi=48

  # resource for MAIN gfs
# export fnode_main=12   ;  export fmpi_main=96  ; export fomp_main=2
# export fnode_main=24   ;  export fmpi_main=192 ; export fomp_main=4
# export fnode_main=36   ;  export fmpi_main=288 ; export fomp_main=4
  export fnode_main=48   ;  export fmpi_main=288 ; export fomp_main=4

  # resource for ENKF gfs
  export fnode_enkf=12   ;  export fmpi_enkf=96 ; export fomp_enkf=2
#--------------------------------------------------------------
# executable path              
#   GSIexe          GSI
#   ENKFexe         ENKF
#   MODELexe        GFS model 
#   BOGexe          Typhoon Bogus
#   RELOCexe        Typhoon relocation 
#   NCEPOZexe       get NCEP ozone  (No need to change so far)
#   NCEP2DMSexe     convert NCEP sig file to CWB dms  (No need to change so far)
#   FGUESSexe       sig file (No need to change so far)
#   SFCGESexe       sfc file (No need to change so far)
#--------------------------------------------------------------
  export GSIexe="/nwpr/gfs/xb80/data/exp/EXP-4denv-sdbeta/src_newlib/global_gsi"
  export ENKFexe="/nwpr/gfs/xb80/data/exp/EXP-4denv-sdbeta/src_newlib/enkf/global_enkf"
  export MODELexe="${MDIR}/bin/GH_gfs"
  export BOGexe="${MDIR}/bin/GH_cbogusW"
  export RELOCexe="${MDIR}/bin/GH_relocW"
  export NCEPOZexe="/nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/fg/ncepoz/GH_gtncepoz"
  export NCEP2DMSexe="/nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/postproc/GH_ncep2dms_fx100"
  export FGUESSexe="/nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/fg/sigfg_gsi/GH_fguess_gsi"
  export SFCGESexe="/nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/fg/sfcfg_gsi/GH_sfcges_gsi"
#--------------------------------------------------------------
# fix input files setting for pre/post-process , the files should at ${MDIR}/dat/ana
#   namelist_sst            the namelist for getsst 
#   namelist_preoiqc        the namelist for GTS data
#   namelist_preana         the namelist for MAIN fguess and sfcgess
#   namelist_preana_ens     the namelist for ENKF fguess and sfcgess 
#   namelist_postana        the namelist for MAIN sig2dms 
#   namelist_postana_ens    the namelist for ENKF sig2dms 
#--------------------------------------------------------------
  export namelist_sst="${NWPDATANA}/namlsts.getsst"
  export namelist_preoiqc="${NWPDATANA}/namlsts.preoiqc"
  export namelist_preana="${NWPDATANA}/pre_ana.input"
  export namelist_preana_ens="${NWPDATANA}/pre_ana.input.ens"
  export namelist_postana="${NWPDATANA}/post_ana.input"
  export namelist_postana_ens="${NWPDATANA}/post_ana.input.ens"
#--------------------------------------------------------------
# obs type assimilated
#   ntype         Total numbler of bufr files will be used 
#   bufrlst       NCEP dump bufr file name
#   namelst       GSI input bufr file name
#--------------------------------------------------------------
  export ntype=10
  export bufrlst="prepbufr 1bamua    gpsro     airsev   mtiasi   atms     1bhrs4    1bmhs   goesfv    osbuv8"
  export namelst="prepbufr amsuabufr gpsrobufr airsbufr iasibufr atmsbufr hirs4bufr mhsbufr gsnd1bufr sbuvbufr"
#--------------------------------------------------------------
# gsi fix input files setting, the files should at ${MDIR}/dat/ana
#   fnsatinfo       GSI satellite info file
#   fnconvinfo      GSI convetional info file
#--------------------------------------------------------------
  export fnsatinfo="${NWPDATANA}/global_satinfo.txt"
  export fnconvinfo="${NWPDATANA}/global_convinfo.txt"
#-----------------------------------
# set for silo archive
#   silo0             HOME directory of silo user 
#   silo_dmspath      path for archive dms file scp hsmsvr (No use)
#   silo_diapath      path for archive diagnose files scp hsmsvr (No use)
#   dtmv_dmspath      path for archive dms file through datamv 
#   dtmv_diapath      path for archive diagnose files  through datamv
#   pSILODMSPATH      path where the post run dmsfiles from, for major run only
#-----------------------------------
  export silo0="/rs/bak/${SILOUSER}"
  export dtmv_dmspath0="${silo0}/dmsdir"
  export dtmv_diapath0="${silo0}/diadir"
  export dtmv_dmspath="${dtmv_dmspath0}/${expname}"
  export dtmv_diapath="${dtmv_diapath0}/${expname}"
  export pSILODMSPATH=NULL
  export pSILODIAPATH=NULL
#---------------------------------------------------------------------------
#  Post or major run ?
#   DMSTL         output dms tail for MAIN run 
#   DMSENSTL      output dms tail for ENKF run
#   pDMSFN        input dms tail for MAIN run
#   pDMSTL        input dms tail for ENKF run
#---------------------------------------------------------------------------
  if [[ ${MP} = "p" ]] ; then ; MP=P ; fi
  if [[ ${MP} = "m" ]] ; then ; MP=M ; fi

  if [[ $MP = "P" ]] ; then
    export DMSTL="${gfsflag}MGP"
    export DMSENSTL="${ensflag}MGP"
    export pDMSFN=NULL
    export pDMSTL=NULL
  elif [[ $MP = "M" ]] ; then
    export DMSTL="${gfsflag}MGM"
    export DMSENSTL="${ensflag}MGM"
    export pDMSFN=${DMSFN}
    export pDMSTL="${gfsflag}MGP"
  else
    echo "CREAT_GFSEXP : WARNING : Unknown MP = $MP"
  fi
#--------------------------------------------------------------
# setting for config
#--------------------------------------------------------------
#  optobs     =1  (1)get data from silo (2)oiqc for major run
#              0   data already at gsi working directory
#  optcdms    =1   archive dms to silo at $silo_dmspath
#              0   do not archive dms file
#  optcdia    =1   archive diagnose files to silo at $silo_diapath
#              0   do not archive diagnose file
#--------------------------------------------------------------
  export optobs=1
  export optcdms=1
  export optcdia=1
#==========================================================================================================================#
#*********************************    No Need to change below this line   ***********************************
#==========================================================================================================================#
#--------------------------------------------------------------
#  basic settings
#--------------------------------------------------------------
 export DMSPATH="/package/fx100/dms/dms.v4/bin"
 export DMSPATHx86="/package/dms/dms.v4/bin"
#--------------------------------------------------------------
# prepare dtg 
#--------------------------------------------------------------
  export dtg=$dtg_first 
  export mm=`echo $dtg | cut -c3-4`
  export fgdtg=`${MDIRCRT}/Caldtg.ksh $dtg_first -6`
  export fgmm=`echo $fgdtg | cut -c3-4`
#--------------------------------------------------------------
# create working env
#--------------------------------------------------------------
if [[ ${opt_crtworkdir} -eq 1 ]] ; then
  # create archive directory at silo
  echo "CREAT_GFSEXP : create archive "
  ssh datamv07  mkdir -p ${silo0}
  ssh datamv07  mkdir -p ${dtmv_dmspath0}
  ssh datamv07  mkdir -p ${dtmv_diapath0}
  ssh datamv07  mkdir -p ${dtmv_dmspath}
  ssh datamv07  mkdir -p ${dtmv_diapath}
  echo '==> press ENTER to continue...' ; read 
#-----------------------------------------------------------------------
# env setting - 
#
#  env description :
#    MDIR  -     bin      exe and script files
#                dat/ana  analysis fix file and namelist files
#                dat/obs  obs fix input files
#    REMWRK      working dir physically, usually ${HOME}/data/${model}/${exp}
#    NWP        local working director which ln -s to REMWRK
#            -   dtg, working directory for pre-gsi and post-gsi
#                dtg_wrk, working directory for gsi
#                dtg_save, directory to save diagnose files and bias files
#                logdir, logfiles
#-------------------------------------------------------------------------------------
  if [[ ! -s ${REMWRK} ]] ; then
    mkdir -p ${REMWRK}
  fi

  if [[  -s ${REMWRK}/${expname} ]] ; then
    echo "CREAT_GFSEXP : ${REMWRK}/${expname} exist, want to delete it? (y) or not(n)"
    read optrm
    echo "CREAT_GFSEXP : optrm="$optrm
    if [[ $optrm = "Y" || $optrm = "y" ]] ;then
      rm -f -r  ${REMWRK}/${expname}
      mkdir ${REMWRK}/${expname}
    else
      echo "CREAT_GFSEXP : ${REMWRK}/${expname} already exist, use old one(y) or not(n)"
      read optold
      echo "CREAT_GFSEXP : optold="$optold
      if [[ $optold = "N" || $optold = "n" ]] ;then
        echo "CREAT_GFSEXP : exit, try new exp(DMSFN) name"
        exit
      fi
    fi
  else
    mkdir ${REMWRK}/${expname}
  fi
  echo "CREAT_GFSEXP : create work env !"
  echo "CREAT_GFSEXP : rm -f ${NWP}"  ; rm -f ${NWP}
  echo "CREAT_GFSEXP : ln -fs ${REMWRK}/${expname} ${NWP}" ; ln -fs ${REMWRK}/${expname} ${NWP}
  echo '==> press ENTER to continue...' ; read 

  mkdir -p ${NWPBINS} ; cd ${NWPBINS}
  cp ${MDIRSCT}/* .
  cp ${MDIRSCT}/${SETMPI}     set_mpi
  cp ${MDIRSCT}/${SETMPIOMP}  set_mpi+omp

  if [[ ! -s ${DTGWRK} ]];then
    mkdir ${DTGWRK}  ; fi
  if [[ ! -s ${DTG} ]];then
    mkdir ${DTG}  ; fi
  if [[ ! -s ${DTGSAV} ]];then
    mkdir ${DTGSAV}  ; fi
  if [[ ! -s ${LOGDIR} ]];then
    mkdir ${LOGDIR}  ; fi
  if [[ ! -s ${STATUS} ]];then
    mkdir ${STATUS}  ; fi 

  if [[ ! -s ${DMSDBPATH}/${NCEPECDB}.ufs ]] ; then
      mkdir ${DMSDBPATH}/${NCEPECDB}.ufs 
  fi

  #--- if opt_hyb
  if [[ $opt_hyb -eq 1 ]] ; then
    echo "CREAT_GFSEXP : create ensemble work env !"
    # member run
    if [[ ! -s ${DTGENSWRK} ]];then
      mkdir ${DTGENSWRK}
      mem=1
      while [[ $mem -le $NTOTMEM ]] ; do
        cmem3=`printf %03i $mem`
        mkdir ${DTGENSWRK}/innov_${cmem3}
        ((mem=$mem+1))
      done
      mkdir ${DTGENSWRK}/innov_ensmean
    fi
    if [[ ! -s ${DTGENS}    ]] ; then ; mkdir ${DTGENS}    ; fi
    if [[ ! -s ${DTGENSSAV} ]] ; then ; mkdir ${DTGENSSAV} ; fi
  fi
  echo '==> press ENTER to continue...' ; read 
  #--- endif opt_hyb
#-----------------------------------------------------------------------
# create run.input
#-----------------------------------------------------------------------
echo "CREAT_GFSEXP : create 0100_gdas.input  !"
cat > 0100_gdas.input << EOFruninput
config filename                     =0000.config.${DMSFN}
the initial dtg for this exp        =${dtg_first}
the ending  dtg for this exp        =${dtg_first}
ForecastOption                      =${fcstmode}

EOFruninput

mv 0100_gdas.input ${NWPBINS}/0100_gdas.input.${DMSFN}

echo '==> press ENTER to continue...' ; read 

#--------------------------------------------------------------
#  for gfs forecast
#--------------------------------------------------------------
 
  #-------- create gfs workdir,namelist and gfsctl
  echo "CREAT_GFSEXP : create  M00 gfs !"
  rm -f -r $GFSDIR
  mkdir $GFSDIR
  cd $GFSDIR

  mkdir tmpdir
  rm -f  filist dms.log tmpdir/*


# ocards
  ${MDIRCRT}/create_ocards.sh ${GFSDIR}/ocards

# create filist 
cat > filist << EOFfilist
 &filst
 ifilin='MASOPS',
 ifilout='MASOPS',
 cwbout='${GFSDIR}/tmpdir/gfs_cwbout',
 bckfile='BCKOPS',
 phyout='${GFSDIR}/tmpdir/gfs_phyout',
 namlsts='${GFSDIR}/namlsts',
 crdate='${GFSDIR}/crdate',
 ocards='${GFSDIR}/ocards',
 &end
EOFfilist

  #-------- define ctl
  cd  $GFSDIR
  rm -f gfsctl.0012  gfsctl.0618

  echo "==> press ENTER to continue..." ; read
#-----------------------------------------------------------------------
# for typhoon relocate and bogus
#-----------------------------------------------------------------------

  echo "CREAT_GFSEXP : create typhoon related namelist and dmsfile !"
  if [ ${MP} = "M" -o ${MP} = "m" ] ;then
    RELOCATE="RE${pDMSFN}_dtg_${pDMSTL}@${DMSDB}"
    BGSOUT="BG${pDMSFN}_dtg_${pDMSTL}@${DMSDB}"
  else
    RELOCATE="RE${DMSFN}_dtg_${DMSTL}@${DMSDB}"
    BGSOUT="BG${DMSFN}_dtg_${DMSTL}@${DMSDB}"
  fi

cat > filistbogus00 << EOFbgs00
 &filst
 ifilin='RELOCATE'
 ifilout='BGSOUT'
 bckfile='BCKOPS'
 namlstsbogus='${GFSDIR}/namlstsbogus'
 crdate='${GFSDIR}/crdate'
 ocards='${GFSDIR}/ocards'
 &end
EOFbgs00

cat > filist_typ << EOFtyp
 &filst
 ifilin='MASOPS',
 ifilout='RELOCATE',
 cwbout='tmp/cwboutgfs0',
 bckfile='BCKOPS',
 phyout='tmp/phyoutgfs0',
 namlsts='${GFSDIR}/namlsts_typ',
 crdate='${GFSDIR}/crdate',
 ocards='${GFSDIR}/ocards',
 mapfn=' ',
 &end
EOFtyp
echo "==> press ENTER to continue..." ; read

#-----------------------------------------------------------------------
# create gfs working directory for ens member
#-----------------------------------------------------------------------
  if [ $opt_hyb -eq 1 ] ; then
    echo "CREAT_GFSEXP : create  Ensemble track directory ! "
    mkdir ${NWP}/trk
    echo "==> press ENTER to continue..." ; read

    echo "CREAT_GFSEXP : create  ENKF gfs !"
    mem=1
    while [[ ${mem} -le ${NTOTMEM} ]] ; do
      cd ${NWP}
      cmem3=`printf %03i $mem`
      GFSDIR_ENS=${NWP}/gfs_${cmem3}

      rm -f -r ${GFSDIR_ENS}
      mkdir ${GFSDIR_ENS}
      cd ${GFSDIR_ENS}

# create ocards
echo "CREAT_GFSEXP : Copy ocards ${GFSDIR_ENS}"
cp ${GFSDIR}/ocards ${GFSDIR_ENS}/ocards    

# create filist
cat > filist << EOFfilist
 &filst
 ifilin='MASOPS',
 ifilout='MASOPS',
 cwbout='${GFSDIR_ENS}/tmpdir/gfs_cwbout',
 bckfile='BCKOPS',
 phyout='${GFSDIR_ENS}/tmpdir/gfs_phyout',
 namlsts='${GFSDIR_ENS}/namlsts',
 crdate='${GFSDIR_ENS}/crdate',
 ocards='${GFSDIR_ENS}/ocards',
 &end
EOFfilist

      ((mem=${mem}+1))
    done
  fi
fi  # end of create working env
echo "CREAT_GFSEXP : create working env for exp $DMSFN successfully!!"
echo "==> press ENTER to continue..." ; read

#-----------------------------------------------------------------------
#-- create dms files
#-----------------------------------------------------------------------
echo "CREAT_GFSEXP : create dms files "
if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs ] ; then
  mkdir   ${DMSDBPATH}/${DMSDB}.ufs
  cd ${DMSDBPATH}/${DMSDB}.ufs
fi
ln -s ${DMSDBPATH}/${DMSDB}.ufs ${NWP}/dmsdb

if [ ! -s ${DMSDBPATH}/${DMSDB}.ufs/MASOPS ] ; then
  mkdir ${DMSDBPATH}/${DMSDB}.ufs/MASOPS
fi

if [[ $opt_hyb -eq 1 ]] ; then

  typeset -Z3 mem
  mem=1
  while [[ ${mem} -le $NTOTMEM ]] ; do
    if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs/MASOPS_mem${mem} ] ; then
      mkdir  ${DMSDBPATH}/${DMSDB}.ufs/MASOPS_mem${mem}
    fi 
    ((mem=$mem+1))
  done

  # ensemble resolution ananlysis 
  mkdir  ${DMSDBPATH}/${DMSDB}.ufs/MASOPS_ensres

fi
echo "CREAT_GFSEXP : create dmsfile for exp $DMSFN successfully!!"
echo "==> press ENTER to continue..." ; read

#-----------------------------------------------------------------------
#--- prepare for SCORE
#-----------------------------------------------------------------------
echo "CREAT_GFSEXP : prepare score and climatology related dmsfile "
if [ ! -s ${DMSDBPATH}/${SCOREDMSDB}.ufs  ] ; then
  mkdir  ${DMSDBPATH}/${SCOREDMSDB}.ufs 
  mkdir  ${DMSDBPATH}/${SCOREDMSDB}.ufs/CWBCLM
fi
if [ ! -e ${DMSDBPATH}/${SCOREDMSDB}.ufs/CWBCLM/*  ] ; then
  export adms=CWBCLM@${CLMDMSDB}
  export bdms=CWBCLM@${SCOREDMSDB}
  rdmscrt -l34 $bdms
  rdmscpy -l34 -k"*" $adms $bdms
fi
echo "==> press ENTER to continue..." ; read
#-----------------------------------------------------------------------
#--- prepare BCKOPS and BCKENKF
#-----------------------------------------------------------------------
echo "CREAT_GFSEXP : prepare model BCK dmsfile for main and ensemble resolution "
if [ $opt_getBCK -eq 1 ] ; then
  if [ ! -e ${DMSDBPATH}/${DMSDB}.ufs/${BCKOPSFN}/*  ] ; then
    export BCKMAIN=${BCKOPSFN}@${DMSDB}
    rdmscrt -l34  ${BCKMAIN}
    export BCKMAIN_op=${BCKOPSFN_op}
    rdmscpy -l34 -k"*" ${BCKMAIN_op} ${BCKMAIN}
  fi

  if [ ! -e ${DMSDBPATH}/${DMSDB}.ufs/${BCKENSFN}/*  ] ; then
    export BCKENKF=${BCKENSFN}@${DMSDB}
    rdmscrt -l34  ${BCKENKF}
    export BCKENKF_op=${BCKENSFN_op}
    rdmscpy -l34 -k"*" ${BCKENKF_op} ${BCKENKF}
  fi
fi
echo "==> press ENTER to continue..." ; read
#-----------------------------------------------------------------------
# create configure files : config.${DMSFN}
#-----------------------------------------------------------------------
if [[ ${opt_crtconfig} -eq 1 ]] ; then  
  echo "CREAT_GFSEXP : create config.${DMSFN}"
  . ${MDIRCRT}/get_0000.config.ksh
  echo "==> press ENTER to continue..." ; read 
fi
#-----------------------------------------------------------------------
#---- get initial data
#-----------------------------------------------------------------------
echo "CREAT_GFSEXP : get initial data"
if [[ $opt_getidata -ne 0 ]] ; then
  # get operational keys from operataion account
  if [[ $opt_getidata -eq 1 ]] ; then
    cp $start_biasdir/satbias.20$fgdtg ${DTG}_save
    cp $start_biasdir/satbias_ang.20$fgdtg ${DTG}_save
  elif [[ $opt_getidata -eq 2 ]] ; then

    . ${MDIRCRT}/get_initdata.ksh

    if [[ $? = 0 ]] ; then
      echo "CREAT_GFSEXP : Finish get initial data !"
    fi

    # Change Resolution 
    if [[ $silo_gfsflag != $gfsflag ]] ; then 
      echo "CREAT_GFSEXP : Start Change Resolution ! "
      # create working directory when needed
      export WORKDIR_MAIN=${MDIR}/WorkMain_${expname}
      if [[ ! -s $WORKDIR_MAIN ]] ; then
        mkdir $WORKDIR_MAIN
      fi
      export WORKDIR_ENKF=${MDIR}/WorkEnkf_${expname}
      if [[ ! -s $WORKDIR_ENKF ]] ; then
        mkdir $WORKDIR_ENKF
      fi
      . ${MDIRCRT}/chres.ksh    
    fi  # end of changing resolution 
  fi
fi  # end of getting initial data


exit
