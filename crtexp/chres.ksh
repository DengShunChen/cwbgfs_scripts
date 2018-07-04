#!/bin/ksh

 export EXE_GM2GM_NOAH=${EXE_GM2GM_NOAH:-${MDIRCRT}/gm2gm_Noahq_${MACHINE}.exe}

 PJSUB=${PJSUB}

#================= change resolution : MAIN  ==============================
cd $WORKDIR_MAIN

cat > gm2gm_namlsts << EOFgm2gm
&gm2gm_param
dmsflagin='${silo_gfsflag}',
im=${silo_gfs_lon},
km=${silo_gfs_nlev},
dmsflagout='${gfsflag}',
nx=${LONB},
lev=${LEVS},
lmax=16,
/

from f1 to f2
lmax=16 no need to change


EOFgm2gm

#----

cat > chres << EOF
#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j

OMP=16
. /users/xa09/sample/setup_omp.${MACHINE} \$OMP

set -x
#-- input
export GM2GM_MASIN=MASOPSop@${DMSDB}

#-- output
export GM2GM_MASOUT=MASOPS@${DMSDB}

#-- terrrian data
export GM2GM_BCK=${BCKOPS}

rdmscrt -l34 GM2GM_MASOUT

cd ${WORKDIR_MAIN}
export NWPETC=${WORKDIR_MAIN}
export NWPETCGLB=${WORKDIR_MAIN}
export GM2GM_NAMLSTS=${WORKDIR_MAIN}/gm2gm_namlsts

/usr/bin/time -p ${EXE_GM2GM_NOAH} ${dtg_first} 0006

EOF

#-- execute
 ssh login13 -n "cd  ${WORKDIR_MAIN} ;  ${PJSUB} ${WORKDIR_MAIN}/chres"


#===============  change resolution : ENKF ===================================
cd $WORKDIR_ENKF
if [[ $opt_hyb -eq 1 ]] ; then

cat > gm2gm_namlsts << EOFgm2gm
&gm2gm_param
dmsflagin='${silo_ensflag}',
im=${silo_ens_lon},
km=${silo_ens_nlev},
dmsflagout='${ensflag}',
nx=${LONB_ENKF},
lev=${LEVS},
lmax=16,
/

from f1 to f2
lmax=16 no need to change

EOFgm2gm


typeset -Z3 mem
mem=1
while [[ $mem -le $ntotmem ]] ; do
cat > chres_m${mem} <<EOF
#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j

OMP=16
. /users/xa09/sample/setup_omp.${MACHINE} \$OMP

set -x
#-- input
export GM2GM_MASIN=MASOPSop_mem${mem}@${DMSDB}

#-- output
export GM2GM_MASOUT=MASOPS_mem${mem}@${DMSDB}

#-- terrrian data
export GM2GM_BCK=${BCKENS}

rdmscrt -l34 GM2GM_MASOUT

cd ${WORKDIR_ENKF}
export NWPETC=${WORKDIR_ENKF}
export NWPETCGLB=${WORKDIR_ENKF}
export GM2GM_NAMLSTS=${WORKDIR_ENKF}/gm2gm_namlsts

/usr/bin/time -p ${EXE_GM2GM_NOAH} $dtg_first 0006


EOF

 ssh login13 -n " cd ${WORKDIR_ENKF} ; ${PJSUB}  ${WORKDIR_ENKF}/chres_m${mem} "

 ((mem=mem+1))
done

fi  # end of opt_hyb


