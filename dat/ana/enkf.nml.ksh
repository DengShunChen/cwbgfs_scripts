#!/bin/ksh 
if [ $# -ne 2 ] ; then
   echo "usage : enkf.nml.ksh dtg datapath"
   exit
else
   dtg=$1
   datapath=$2
fi

cat > enkf.nml << EOFenkf
 &nam_enkf
  datestring="${dtg}",
  datapath="${datpath}",
  analpertwtnh=0.85,analpertwtsh=0.85,analpertwttr=0.85,
  covinflatemax=1.e2,covinflatemin=1,pseudo_rh=.true.,iassim_order=0,
  corrlengthnh=2000,corrlengthsh=2000,corrlengthtr=2000,
  lnsigcutoffnh=2.0,lnsigcutoffsh=2.0,lnsigcutofftr=2.0,
  lnsigcutoffpsnh=2.0,lnsigcutoffpssh=2.0,lnsigcutoffpstr=2.0,
  lnsigcutoffsatnh=2.0,lnsigcutoffsatsh=2.0,lnsigcutoffsattr=2.0,
  obtimelnh=1.e30,obtimelsh=1.e30,obtimeltr=1.e30,
  saterrfact=1.0,numiter=3,
  sprd_tol=1.e30,paoverpb_thresh=0.98,
  nlons=540,nlats=272,nlevs=40,nanals=36,nvars=5,
  deterministic=.true.,sortinc=.true.,lupd_satbiasc=.false.,
  reducedgrid=.true.,readin_localization=.true.
 /
 &END
 &satobs_enkf
  sattypes_rad(1) = 'amsua_n15',     dsis(1) = 'amsua_n15',
  sattypes_rad(2) = 'amsua_n18',     dsis(2) = 'amsua_n18',
  sattypes_rad(3) = 'amsua_aqua',    dsis(3) = 'amsua_aqua',
  sattypes_rad(4) = 'amsua_metop-a', dsis(4) = 'amsua_metop-a',
  sattypes_rad(5) = 'iasi_metop-a',  dsis(5) = 'iasi616_metop-a',
 /
 &END
 &ozobs_enkf
 /
 &END
EOFenkf
exit
