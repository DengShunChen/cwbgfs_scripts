#!/bin/ksh
#-------------------------------------------------------
# GFS model run script
#-------------------------------------------------------
export dtg=${dtg:-$1}
export GFSWRK=${GFSWRK:-${GFSDIR}}
export NWPETC=${GFSWRK}
export NWPETCGLB=${GFSWRK}
export FIXDIR=${FIXDIR:-${FIXDIR}}
export GFSDAT=${GFSDAT:-${FIXDIR}}
export GLB_TYPHINI=${GLB_TYPHINI:-${GFSWRK}}
export GLB_WTYPHINI=${GLB_WTYPHINI:-${GFSWRK}}

export BCKOPS=${BCKOPS:-'??'}
export MASOPS=${MASOPS:-'??'}
export O3FORC=${O3FORC:-${FIXDIR}/global_o3prdlos.f77}
export O3CLIM=${O3CLIM:-${FIXDIR}/global_o3clim.txt}
export AEROSOL_FILE=${AEROSOL_FILE:-${FIXDIR}/global_climaeropac_global.txt}
export EMMISSIVITY_FILE=${EMMISSIVITY_FILE:-${FIXDIR}/global_sfc_emissivity_idx.txt}

export XLFRTEOPTS=${XLFRTEOPTS:-namelist=old}
export TARGET_CPU_LIST=${TARGET_CPU_LIST:--1}
export MEMORY_AFFINITY=${MEMORY_AFFINITY:-MCM}

export MODEL_PARAM=${MODEL_PARAM:-''}
export MODLST=${MODLST:-''}
export DMSFLAG=${DMSFLAG:-'??'} 
export LON=${LON:-${LONB}}
export MPI=${MPI:-''}
export RUN_MODE=${RUN_MODE:-'MAIN'}

export opt_4denvar=${opt_4denvar:-0}
export opt_lag=${opt_lag:-0}
#-------------------------------------------------------

# Enter working directory
cd ${GFSWRK}

# Create date recorder
echo $dtg > crdate

# Copy fix files
cp $O3FORC fort.28
cp $O3CLIM fort.48
cp $AEROSOL_FILE  aerosol.dat
cp $EMMISSIVITY_FILE sfc_emissivity_idx.txt
cp $FIXDIR/* ${GFSWRK}

# Copy typhoon data
if [ -s ${NWPDTG}/typhoon${dtg}.dat ] ; then
  cp -rf ${NWPDTG}/typhoon${dtg}.dat ${GLB_TYPHINI}
fi
if [ -s ${NWPDTG}/Wtyphoon${dtg}.dat ] ; then
  cp -rf ${NWPDTG}/Wtyphoon${dtg}.dat ${GLB_WTYPHINI}
fi

# initialization for gfsctl 
echo "000" >  ${GFSWRK}/gfsctl

# for analysis cycling 
if [[ ${opt_4denvar} = 1 ]] ; then
  echo "003" >>  ${GFSWRK}/gfsctl
  echo "004" >>  ${GFSWRK}/gfsctl
  echo "005" >>  ${GFSWRK}/gfsctl
  echo "006" >>  ${GFSWRK}/gfsctl
  echo "007" >>  ${GFSWRK}/gfsctl
  echo "008" >>  ${GFSWRK}/gfsctl
  echo "009" >>  ${GFSWRK}/gfsctl
else
  echo "006" >>  ${GFSWRK}/gfsctl
fi


#--- for forecasting
if [ ${RUN_MODE} = "MAIN" ] ; then
  hh=`echo ${dtg} | cut -c7-8`
  if [ $hh -eq 12 -o $hh -eq 00 ] ; then      
    echo "024" >>  ${GFSWRK}/gfsctl
    echo "048" >>  ${GFSWRK}/gfsctl
    echo "072" >>  ${GFSWRK}/gfsctl
    echo "096" >>  ${GFSWRK}/gfsctl
    echo "120" >>  ${GFSWRK}/gfsctl
  fi
elif [ ${RUN_MODE} = "ENS" ] ; then
  if [[ ${opt_lag} = 1 ]] ; then
    if [[ ${opt_4denvar} = 1 ]] ; then
     #echo "009" >>  ${GFSWRK}/gfsctl  # already be specified, if running 4denvar
      echo "010" >>  ${GFSWRK}/gfsctl
      echo "011" >>  ${GFSWRK}/gfsctl
      echo "012" >>  ${GFSWRK}/gfsctl
      echo "013" >>  ${GFSWRK}/gfsctl
      echo "014" >>  ${GFSWRK}/gfsctl
      echo "015" >>  ${GFSWRK}/gfsctl
      export MODLST_TAUREG='taureg=15.0'
    else
      echo "012" >>  ${GFSWRK}/gfsctl
      export MODLST_TAUREG='taureg=12.0'
    fi
  fi
fi

#-- GFS model
if  [ $DMSFLAG = 'GG'  ] ; then
  export MODLST_RES='dt=180., hfilt=1.7556e14,'
elif [ $DMSFLAG = 'GH'  ] ; then
  export MODLST_RES='dt=90., hfilt=1.3259e13,'
elif  [ $DMSFLAG = 'GJ'  ] ; then
  export MODLST_RES='dt=30., hfilt=1.7237e12,'
fi

export MODLST="${MODLST_RES} ${MODLST_TAUREG}"

# Create global model namelist
cat <<EOF > ${GFSWRK}/namlsts
 &model_param
   nx=${LON}, lev=${LEVS}, ncld=3, nout=6000, io_quilting=t,
   ${MODEL_PARAM}
 /

 &modlst
   taui=0.0, taue=12.0, tauo=1.0, taup=6.0, taureg=9.0,
   hdiff=t, cstar=f, update=t, lzadv=t, lsimpl=t,
   tfilt=0.05, ksgeo=2, yesdia=t, 
   dopbl=t, docup=t, dorad=t, dolsp=t,doshl=t, dodry=f, 
   dograv=t, donnmi=t, doincr=t,
   cutfreq=3, nnmivm=3,
   frad=1.0, ldiag=0, idg=40, jdg=108,
   itypbl=0, numreduce=8, ptmeans=800.,
   ptop=0.1, 
   nmcup=3, nmpbl=3, nmland=2, nmshl=2,
   ktcup=20, cgw=1.2e-4,
   doo3l=t, irad=2, ioutsigr=1,
   domfc=f,
   ggdef='${DMSFLAG}0G',
   gmdef='${DMSFLAG}MG',
   ${MODLST}
 /
 
EOF

# Running 
FCT_MODEL=${MODELexe}
/usr/bin/time -p mpiexec -n ${MPI}  ${FCT_MODEL}



