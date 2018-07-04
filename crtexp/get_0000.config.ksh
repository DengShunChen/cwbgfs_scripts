#!/bin/ksh
# ----- document block 
#
# enviornmetal settings for gfs scripts 
#
#
#
# ------ end of document block 

#set -x

export NWPBINS=${NWPBINS:-'./'}
export DMSFN=${DMSFN:-'CWBGFS'}

cd ${NWPBINS}

cat << EOF > 0000.config.${DMSFN}
#--------------------------------------------------------------
## promote 
#--------------------------------------------------------------
  export SECONDS="\$(date '+3600*%H+60*%M+%S')"
   typeset -Z2 _h _m _s
   _hh="(SECONDS/3600)%24" _mm="(SECONDS/60)%60" _ss="SECONDS%60"
   _time='\${_x[(_s=_ss)==(_m=_mm)==(_h=_hh)]}\$_h:\$_m:\$_s'
  export PS4="(\`hostname\`) [\$_time] "
#--------------------------------------------------------------
## all
#--------------------------------------------------------------
  export LGIN='${LGIN:-"login13"}'
  export DTMV='${DTMV:-"login13 ssh datamv07.cwb.gov.tw"}'
  export PJSUB='${PJSUB:-'pjsub -L rscgrp=research-x'}'
  export TPDIR=${TPDIR:-"/nwp/npcagfs/TYP/M00/dtg/ty"}
  export WTPDIR=${WTPDIR:-"/nwp/npcagfs/TYP/M00/dtg/ty"}
  export DMSPATH=${DMSPATH:-"/package/fx100/dms/dms.v4/bin"}
  export DMSPATHx86=${DMSPATHx86:-"/package/dms/dms.v4/bin"}

  export MDIR=${MDIR:-}
  export REMWRK=${REMWRK:-}
  export MP=${MP:-'P'}
  export DMSFN=${DMSFN:-}
  export DMSTL=${DMSTL:-}
  export DMSENSTL=${DMSENSTL:-}

  export NTOTMEM=${NTOTMEM:-36}

  export exp=${exp:-${DMSFN}}
  export model=${model:-'t512l60v'}
  export inthr=${inthr:-6}

  export UPDATEHR_MAIN=${UPDATEHR_MAIN:-6}
  export UPDATEHR_ENS=${UPDATEHR_ENS:-6}
  export UPDATEHR_LAG=${UPDATEHR_LAG:-12}    
  export LAGGED_HR=${LAGGED_HR:-$((${UPDATEHR_LAG:-12}-${UPDATEHR_MAIN:-6}))}

  export SILOUSER=${SILOUSER:-`whoami`}

  # for model resolusion here is T511L60 
  export gfsflag=${gfsflag:-GH}
  export JCAPB=${JCAPB:-511}
  export JCAPA=${JCAPA:-511}
  export LONA=${LONA:-1536}
  export LATA=${LATA:-768}
  export LONB=${LONB:-1536}
  export LATB=${LATB:-768}

  # for model resolusion here is T319L60 
  export ensflag=${ensflag:-GG}
  export JCAPB_ENKF=${JCAPB_ENKF:-319}
  export JCAPA_ENKF=${JCAPA_ENKF:-319}
  export LONA_ENKF=${LONA_ENKF:-960}
  export LATA_ENKF=${LATA_ENKF:-480}
  export LONB_ENKF=${LONB_ENKF:-960}
  export LATB_ENKF=${LATB_ENKF:-480}

  # model vertical levels 
  export LEVS=${LEVS:-60}

  export ggflag=${ggflag:-"${gfsflag}0G"}
#--------------------------------------------------------------
# exe files
#--------------------------------------------------------------
  export GSIexe=${GSIexe:-"${MDIR}/bin/GH_global_gsi"}
  export ENKFexe=${ENKFexe:-"${MDIR}/bin/GENS_global_enkf"}
  export MODELexe=${MODELexe:-"${MDIR}/bin/GH_gfs"}
  export RELOCexe=${RELOCexe:-"${MDIR}/bin/GH_relocW"}
  export BOGexe=${BOGexe:-"${MDIR}/bin/GH_cbogusW"}
  export NCEPOZexe=${NCEPOZexe:-"${MDIR}/bin/GH_gtncepoz"}
  export NCEP2DMSexe=${NCEP2DMSexe:-"${MDIR}/bin/GH_ncep2GM30_gsi"}
  export FGUESSexe=${FGUESSexe:-"${MDIR}/bin/GH_fguess_gsi"}
  export SFCGESexe=${SFCGESexe:-"${MDIR}/bin/GH_sfcges_gsi"}
#--------------------------------------------------------------
## env
#--------------------------------------------------------------
  export MODEL=${MODEL:-'GFS'}
  export MEMBER=${MEMBER:-'M00'}
  export NWP=${NWP:-}
  export DB_NAME=${DB_NAME:-${DMSDB}}
  export DB_PATH=${DB_PATH:-${DMSDBPATH}}
  export SCOREDB_NAME=${SCOREDB_NAME:-${SCOREDMSDB}}
  export DTG=${DTG:-${NWP}/dtg}
  export NWPDTG=${NWPDTG:-"${NWP}/dtg"}
#----------------
## research 
#----------------
  export NWPDAT=${NWPDAT:-"${MDIR}/dat"}
  export NWPBIN=${NWPBIN:-"${MDIR}/bin"}
  export NWPWRK=${NWPWRK:-"${NWP}/dtg_wrk"}
  export NWPTRK=${NWPTRK:-"${NWP}/trk"}
  export NWPWRKENS=${NWPWRKENS:-"${NWP}/dtg_ens_wrk"}
  export NWPDTGGLB=${NWPDTGGLB:-"${NWP}/dtg"}
  export NWPDTGENS=${NWPDTGENS:-"${NWP}/dtg_ens"}
  export NWPDTGSAV=${NWPDTGSAV:-"${NWP}/dtg_save"}
  export NWPSAVENS=${NWPSAVENS:-"${NWP}/dtg_ens_save"}
  export NWPBINS=${NWPBINS:-"${NWP}/bins"}
  export NWPETC=${NWPETC:-"${NWP}/dtg"}
  export NWPETCGLB=${NWPETCGLB:-"${NWP}/gfs"}
  export NWPOIDGS=${NWPOIDGS:-"${NWP}/dtg"}
  export NWPOIGLB=${NWPOIGLB:-"${NWP}/dtg"}
  export NWPDATANA=${NWPDATANA:-"${MDIR}/dat/gsifix"}
  export NWPDATPERT=${NWPDATPERT:-"${MDIR}/dat/enspert"}
  export NWPETCEVL=${NWPETCEVL:-"${MDIR}/dat/eval"}
  export NWPDATEVL=${NWPDATEVL:-"${NWP}/dtg"}
#--------------------------------------------------------------
## directory for local observations files
#--------------------------------------------------------------
  export NCEPBUFR=${NCEPBUFR:-"${HOME}/data2/ncepbufr"}
  export NCEPOZ=${NCEPOZ:-"${HOME}/data2/ncepbufr"}
  export CWBFGGE=${CWBFGGE:-"${HOME}/data2/fggedat"}
#--------------------------------------------------------------
## DMS files
#--------------------------------------------------------------
  export MASOPS=${MASOPS:-"MASOPS@\${DB_NAME}"}
  export MASOPS_ensres=${MASOPS_ensres:-"MASOPS_ensres@\${DB_NAME}"}
  export MASOPSOI=${MASOPSOI:-"MASOPSOI@\${DB_NAME}"}

  export pDMSFN=${pDMSFN:-"NULL"}
  export pDMSTL=${pDMSTL:-"NULL"}
  export pSILODMSPATH=${pSILODMSPATH:-"NULL"}
  export pSILODIAPATH=${pSILODIAPATH:-"NULL"}
  export RELOCATE=${RELOCATE:-"RE${pDMSFN}_dtg_${pDMSTL}@${DMSDB}"}
  export BGSOUT=${BGSOUT:-"BG${pDMSFN}_dtg_${pDMSTL}@${DMSDB}"}

  export SSTDMSFN=${SSTDMSFN:-"SSTDMS"}
  export SSTDMS=${SSTDMS:-"SSTDMS@ncepec"}
  export BCKOPS=${BCKOPS:-"BCKOPS@${DMSDB}"}
  export BCKENS=${BCKENS:-"BCKENKF@${DMSDB}"}
  export ITUPDATE=${ITUPDATE:-6}

#-------------------------------
# opt_hyb=1   hybrid 
#        =0   var 
# opt_Wtyp   =1   for Hurrican only check Wtyphoon${dtg}
#            =0   checkWtyphoon${dtg} for W-Pacific Ocean typhoon
#-------------------------------
  export opt_hyb=${opt_hyb:-0}
  export opt_Wtyp=${opt_Wtyp:-0}  # NOT YET READY
  export opt_saveobs2loc=${opt_saveobs2loc:-0}
#-------------------------------
# setting run option for each step
#-------------------------------
  export opt_prepdat=${opt_prepdat:-1}
  export opt_prepcwbobs=${opt_prepcwbobs:-1}
  export opt_gtoz=${opt_gtoz:-1}
  export opt_fguess=${opt_fguess:-1}
  export optens_fguess=${optens_fguess:-1}
  export opt_cbogus=${opt_cbogus:-1}
  export opt_g3dvar=${opt_g3dvar-1}
  export opt_g3dvar2=${opt_g3dvar2:-1}
  export opt_ncep2gm=${opt_ncep2gm:-1}
  export opt_gfs=${opt_gfs:-1}
  export opt_ens=${opt_ens:-1}
  export opt_innov=${opt_innov:-1}
  export opt_enkf=${opt_enkf:-1}
  export opt_inflation=${opt_inflation:-1}
  export opt_recenter=${opt_recenter:-1}
  export optensres_fguess=${optensres_fguess:-1}
  export optens_ncep2gm=${optens_ncep2gm:-1}
  export optens_fcst=${optens_fcst:-1}
  export opt_diag=${opt_diag:-1}
#-------------------------------
# Data assimilation options
#-------------------------------
  export opt_lag=${opt_lag:-0}
  export opt_4denvar=${opt_4denvar:-0}
  export opt_sdbeta=${opt_sdbeta:-0}
  export opt_newsst=${opt_newsst:-0}
#-------------------------------
# clean files  options
#    optcdms     option for clearing dms files(1:yes, 0:no)
#    optcdia     option for clearing diagnose files(1:yes, 0:no)
#    optarc      =1 arc to silo(1:yes, 0:no)
#    DB_PATH     user loc dmsdb path
#    SILODMSPATH  silo path for dms tar file to archive to
#    SILODIAPATH  silo path for diagnose files to archive to
#-------------------------------
  export optcdms=${optcdms:-1}
  export optcdia=${optcdia:-1}
  export optarc=${optarc:-1}

  export SILODMSPATH=${SILODMSPATH:-''}
  export SILODIAPATH=${SILODIAPATH:-''}
  export DTMVDMSPATH=${DTMVDMSPATH:-${dtmv_dmspath}}
  export DTMVDIAPATH=${DTMVDIAPATH:-${dtmv_diapath}}
#------------------------------------------------------------------------
#  gsi setup
#------------------------------------------------------------------------
  export NWPDATOBS=${NWPDATOBS:-"${NWPDAT}/obs"}
  export CRTM=${CRTM:-"${NWPDATANA}/CRTM_REL-2.0.5"}
  export gsiparm_main=${gsiparm_main:-"${NWPDATANA}/gsiparm_posthyb.input"}
  export gsiparm_innov=${gsiparm_innov:-"${NWPDATANA}/gsiparm_innov.input.2015op"}
  export fnsatinfo=${fnsatinfo:-"${NWPDATANA}/global_satinfo.txt"}
  export fnconvinfo=${fnconvinfo:-"${NWPDATANA}/global_convinfo.txt"}

  export namelist_preana=${namelist_preana:-"${NWPDATANA}/pre_ana.input"}
  export namelist_preana_ens=${namelist_preana_ens:-"${NWPDATANA}/pre_ana.input.ens"}
  export namelist_postana=${namelist_postana:-"${NWPDATANA}/post_ana.input"}
  export namelist_postana_ens=${namelist_postana_ens:-"${NWPDATANA}/post_ana.input.ens"}
  export namelist_sst=${namelist_sst:-"${NWPDATANA}/namlsts.getsst"}
  export namelist_preoiqc=${namelist_preoiqc:-"${NWPDATANA}/namlsts.preoiqc"}

  export anode_main=${anode_main:-48}
  export ampi_main=${ampi_main:-192}
  export aomp_main=${aomp_main:-4}
  export anode_ens=${anode_ens:-8}
  export ampi_ens=${ampi_ens:-32}
  export aomp_ens=${aomp_ens:-4}
  export agrp_ens=${agrp_ens:-6}
  export enode=${enode:-24}
  export empi=${empi:-192}
  export eomp=${eomp:-4}
  export inode=${inode:-3}
  export impi=${impi:-48}
  export fnode_main=${fnode_main:-48}
  export fmpi_main=${fmpi_main:-288}
  export fomp_main=${fomp_main:-4}
  export fnode_enkf=${fnode_enkf:-12}
  export fmpi_enkf=${fmpi_enkf:-96}
  export fomp_enkf=${fomp_enkf:-2}

#----------------------------------------------------------------
# prepare NCEP,EC  data option
# optpregfs       prepare SST and SNOWDMS before GFS run
# optec           for EC
# optsnowice      for SNOWDMS from NCEP
# opt =1    prepare at each run, will download from silo to default dms file
#     =0    ready at default dms file
#           ECGRID for  EC grid data
#           SNOWDMS for NCEP snowice data 
#           SST     for NCEP SST
#  (you could use prep_snowice.ksh to prepare SNOWDMS first,
#                 cpsiloop_sst.ksh to prepare from operation first,
#                 prep_ec.ksh to prepare EC first.)
#
#
#----------------------------------------------------------------
  export optobs=${optobs:-1}

  # obs type to get
  export ntype=${ntype:-6}
  export bufrlst="${bufrlst:-"prepbufr 1bamua    gpsro     airsev   mtiasi   atms     1bhrs4    1bmhs   goesfv    osbuv8"}"
  export namelst="${namelst:-"prepbufr amsuabufr gpsrobufr airsbufr iasibufr atmsbufr hirs4bufr mhsbufr gsnd1bufr sbuvbufr"}"

  # default dmsfn
  export NCEPECDB=${NCEPECDB:-"ncepec"}
  export ECDMSFN=${ECDMSFN:-"ECGRID"}
  export ECDMS=${ECDMS:-}
  export SNOWDMS=${SNOWDMS:-}
#----------------------------------------------------------------
# env for gsi run
#----------------------------------------------------------------
  export DTGSAV=${DTGSAV:-"\${NWPDTGSAV}"}
  export DTGENS=${DTGENS:-"\${NWPDTGENS}"}
  export LOGDIR=${LOGDIR:-"\${NWP}/logdir"}
  export STATUS=${STATUS:-"\${NWP}/status"}
  export GFSDIR=${GFSDIR:-"\${NWP}/gfs"}
#----------------------------------------------------------------
# env for oiqc and gfs
#-- for match operation env definition(some script from oper)
#----------------------------------------------------------------
  export ITUPDATE=${ITUPDATE:-6}
  export NWPOIGLB=${NWPOIGLB:-"\${NWPDTG}"}
  export FIXDIR=${FIXDIR:-"\$\{NWPDAT\}/gfsfix"}
#----------------------------------------------------------------
# prepare for typhoon.dat if exist
#----------------------------------------------------------------
  if [ -s ${TPDIR}/typhoon_dtg_.dat ] ; then
    cp ${TPDIR}/typhoon_dtg_.dat \${GFSDIR}
    cp ${TPDIR}/typhoon_dtg_.dat \${NWPDTG}
  fi
  if [ -s ${WTPDIR}/Wtyphoon_dtg_.dat ] ; then
    cp ${WTPDIR}/Wtyphoon_dtg_.dat \${GFSDIR}
    cp ${WTPDIR}/Wtyphoon_dtg_.dat \${NWPDTG}
  fi
#----------------------------------------------------------------
#- check experiment name, the first character should not be numeric.
#----------------------------------------------------------------
  first_char=`echo ${DMSFN} | cut -c1-1`
  expr \$first_char + 1 2> /dev/null
  if [ \$? = 0 ] ; then
    echo "Val was numeric"
    export EXP_NAME="gfs_${DMSFN}"
  else
    echo "Val was non-numeric"
    export EXP_NAME="${DMSFN}"
  fi
#----------------------------------------------------------------

EOF





