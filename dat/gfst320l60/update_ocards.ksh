#!/bin/ksh
#set -x

export cwbgfs=/nwpr/gfs/xb80/data2/CWBGFS
export expname=h4dtlm72


export target_file=ocards_h4dtlm
export destin_file=ocards
export target=${cwbgfs}/dat/gfst320l60
export destin=${cwbgfs}/exp_${expname}

#----------------------------------------------------#
typeset -Z3 mem
((mem=1))
while [ $mem -le 36 ] ; do 

  todir=${destin}/gfs_${mem}

  echo cp ${target}/${target_file} ${todir}/${destin_file}
  cp ${target}/${target_file} ${todir}/${destin_file}

  ((mem=mem+1))
done
exit
