#!/bin/ksh
#
#  copy gfs fix files to experimental directory
#

set -x 

export EXPNAME="h4dctl"
export EXPNAME_FROM="h3dsdblag"
export MDIR="/nwpr/gfs/xb80/data/CWBGFS"
export MDIRDAT="${MDIR}/dat"
export NWP=${MDIR}/exp_${EXPNAME}
export NWP_FROM=${MDIR}/exp_${EXPNAME_FROM}


export GFSFROM_MAIN=${MDIRDAT}/gfst512l60
export GFSFROM_ENKF=${MDIRDAT}/gfst320l60

export opt_hyb=${opt_hyb:-1}
export ntotmem=${ntotmem:-36}

#-------- create gfs workdir,namelist and gfsctl
  echo " create  M00 gfs       now .... (enter)" ; read

  GFSDIR=${NWP}/gfs
  GFSFROM_MAIN=${NWP_FROM}/gfs
 # rm -f -r $GFSDIR
  if [ ! -e ${GFSDIR} ] ; then
    mkdir ${GFSDIR}
  fi

  cd ${GFSDIR}
  cp  -r ${GFSFROM_MAIN}/*  ${GFSDIR}

  if [ ! -e tmpdir ] ; then
    mkdir tmpdir
  fi

  rm -f  filist dms.log tmpdir/*

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
  cd  ${GFSDIR}
  rm -f gfsctl.0012  gfsctl.0618

#-----------------------------------------------------------------------
# for typhoon relocate and bogus
#-----------------------------------------------------------------------
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

#-----------------------------------------------------------------------
# create gfs working directory for ens member
#-----------------------------------------------------------------------
  if [ $opt_hyb -eq 1 ] ; then
    echo " create  Ensemble track directory      now .... (enter)" ; read
    if [ ! -e  ${NWP}/trk ] ; then
      mkdir ${NWP}/trk
    else
      echo "ensemble track directory was existing"
    fi

    echo " create  ENKF gfs      now .... (enter)" ; read
    cd ${NWP}
    mem=1
    while [  ${mem} -le $ntotmem ] ; do
      cmem3=`printf %03i $mem`
      GFSDIR=${NWP}/gfs_${cmem3}
      GFSFROM_ENKF=${NWP_FROM}/gfs_${cmem3}

      cp -rf  ${GFSFROM_ENKF} ${GFSDIR}
      cd ${GFSDIR}
      rm -rf  filist dms.log tmpdir
      
      if [ ! -e tmpdir ] ; then
        mkdir tmpdir
      fi


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

      ((mem=${mem}+1))
    done
  fi


