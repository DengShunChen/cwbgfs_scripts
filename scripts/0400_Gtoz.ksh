#!/bin/ksh 
#--------------------------------------------------------------------
# purpose  prepare ozone
# dtg      date-time-group of analysis dtg
# optrun   option for main run
#          =MAIN   main run
#          =ENS   EnKF run
#--------------------------------------------------------------------
if [ $# = 4 ]
then
  fnconf=$1
  dtg=$2
  optrun=$3
  optsub=$4
else
  echo "Gtozfrt.ksh fnconf dtg optrun  optsub"
  exit
fi

cd $LOGDIR
rm -f gtoz_${optrun}
cat > gtoz_${optrun} << EOFgtoz
#PJM -L node=1
#PJM -L node-mem=unlimited
#PJM --no-stging
#PJM -L "elapse=3:00:00"
#PJM -j

. ${NWPBINS}/setup_mpi
. ${NWPBINS}/${fnconf}.set

set -x

if [ $opt_gtoz -ne 1 ]  ; then
  nowt=\`date\`
  echo "\$nowt $dtg Gtoz ok" >> ${STATUS}/gtoz_${optrun}.${dtg}.ok
  exit
fi

cd ${DTG}
#-------------------------------------------------------------------------------
#   dtg and namelist
#-------------------------------------------------------------------------------
 rm -f validcrdate
 if [ ${MP} = "M" -o ${MP} = "m"  ] ; then
   rm -f validcrdate
   fdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24 \`
 else
   fdtg=${dtg}
 fi

#--------------------------------------------------------------------
# namelist
#-------------------------------------------------------------------------------
 if [ $optrun = "MAIN" ] ; then
   WORKDIR=${NWPDTGGLB}
   cd \${WORKDIR}
   cp ${namelist_preana}   .
 elif [ $optrun = "ENS" ] ; then
   WORKDIR=${NWPDTGENS}
   cd \${WORKDIR}
   cp ${namelist_preana_ens} pre_ana.input.tmp
   cat pre_ana.input.tmp | sed "s/tau=\(.*\)/tau=${UPDATEHR_ENS}./g" > pre_ana.input
 elif [ $optrun = "LAG" ] ; then
   WORKDIR=${NWPDTGENS}
   cd \${WORKDIR}
   cp ${namelist_preana_ens} pre_ana.input.tmp
   cat pre_ana.input.tmp | sed "s/tau=\(.*\)/tau=${UPDATEHR_LAG}./g" > pre_ana.input
 else
   echo "optrun="$optrun", it must be 1 or 2, something wrong!! exit!!!"
   exit -1
 fi

#--------------------------------------------------------------------
# siglevel 
#--------------------------------------------------------------------
 nsig=\`grep nsigcwb pre_ana.input  | cut -d"=" -f 2 | cut -d"," -f 1\`
 cp ${NWPDATANA}/global_siglevel.cwbl\${nsig}.txt sigicwb.dat

#---------------------------------------------------------------------------
# checking for ncep ozone data
#---------------------------------------------------------------------------
 pjob=oz
 cjob=gtoz_${optrun}
 ${NWPBINS}/0x00_ckwait.ksh $dtg \$pjob 100 6 $STATUS
 if [ \$? -ne 0 ] ; then
    nowt=\`date\`
    echo "download ozone data failed !! using one day before data"

    fdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24 \`
 fi

#---------------------------------------------------------------------------
 cd \${WORKDIR}
 if [ -e fort.30 ] ; then 
   rm -f fort.30
 elif [ -e ncepoz.sig ]; then
   rm -f ncepoz.sig
 fi

 ln -fs \${NWPDTG}/ncepoz.\${fdtg} fort.30 

 export XLFRTEOPTS="namelist=new"
# ${NWPBIN}/${gfsflag}_gtncepoz < pre_ana.input
# /nwpr/gfs/xb80/data/exp/GFS_Scripts_Maintain/src/fg/ncepoz/${gfsflag}_gtncepoz < pre_ana.input
 ${NCEPOZexe} < pre_ana.input

 if [ \$? = 0 ] ; then
    if [ -e fort.32 ] ; then
      mv fort.32 o3_${optrun}.20${dtg}
    elif [ -e ncepoz.cwb ]; then
      mv ncepoz.cwb o3_${optrun}.20${dtg}
    else
      nowt=\`date\`
      echo "\$nowt $dtg Gtoz_${optrun} fail" >> ${STATUS}/gtoz_${optrun}.${dtg}.fail
      exit -1
    fi
 else
   fdtg=\`${NWPBINS}/0x01_Caldtg.ksh ${dtg} -24 \`
   cp o3_${optrun}.20\${fdtg} o3_${optrun}.20${dtg}
 fi

if [ \$? -eq 0 ] ; then
  nowt=\`date\`
  echo "\$nowt $dtg Gtoz_${optrun} ok" >> ${STATUS}/gtoz_${optrun}.${dtg}.ok
else
  nowt=\`date\`
  echo "\$nowt $dtg Gtoz_${optrun} fail" >> ${STATUS}/gtoz_${optrun}.${dtg}.fail
  exit -1
fi

exit 0
EOFgtoz_${optrun}
if [ $optsub -eq 1 ] ; then
  ${PJSUB} gtoz_${optrun}
fi
exit

