#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -N run_gm2gm
#PJM -L "rscgrp=research-x"
#PJM -j 

#-- enviornmental settings 
machine=fx100
OMP=16
. /users/xa09/sample/setup_omp.${machine} $OMP
caldtg="${HOME}/bin/Caldtg.ksh"


dtg=15061500
fcst_int=0006
dtg_pre6=`$caldtg $dtg -6`

inres=GG
injcap=319
inlon=960
inlevs=40
indmshd=MASOPSop
indmstl=${inres}MGM
indmsdb=MASOPSop

outres=GJ
outjcap=853
outlon=2560
outlevs=60
outdmshd=T853chres
outdmstl=${outres}MGM
outdmsdb=MASOPSop


#-- local path 
USRPATH=`pwd`
export USRPATH

#-- input 

#export GM2GM_MASIN=${indmshd}${dtg}${indmstl}@${indmsdb}
export GM2GM_MASIN=${indmshd}@${indmsdb}

#-- output
#export GM2GM_MASOUT=${outdmshd}${dtg}${outdmstl}@${outdmsdb}
export GM2GM_MASOUT=${outdmshd}@${outdmsdb}

#-- pre-procese
rdmspurge -f GM2GM_MASOUT
rdmscrt l-34 GM2GM_MASOUT

export GM2GM_BCK=BCK${outjcap}_${outres}@bckdms

export NWPETC=${USRPATH}
export NWPETCGLB=${USRPATH}

#-- namlsts file 
export GM2GM_NAMLSTS=${USRPATH}/gm2gm_namlsts

cat > gm2gm_namlsts << EOFgm2gm
&gm2gm_param
dmsflagin='${inres}',
im=${inlon},
km=${inlevs},
dmsflagout='${outres}',
nx=${outlon},
lev=${outlevs},
lmax=16,
/

lmax=16 no need to change

EOFgm2gm

#-- run 
export MODEL=${USRPATH}
/usr/bin/time -p $MODEL/gm2gm_Noahq_${machine}.exe $dtg $fcst_int

