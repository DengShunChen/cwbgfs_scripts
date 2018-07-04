#!/bin/ksh
curdir=`pwd`
dtg=15091800
opt_cpfrop=1
locDMSDB=t512l60

fgdtg=`Caldtg.ksh $dtg -6`
if [ $opt_cpfrop -eq 1 ] ; then
  export adms=MASOPS@NWPDB@ncsagfs@login11
  export bdms=MASOPSop@GGG
  rdmscrt -l34 bdms
  rdmscpy -l34 -k"??????0006G?MG20${fgdtg}*" adms bdms
  rdmscpy -l34 -k"??????0006G?0G20${fgdtg}*" adms bdms

  rdmscpy -l34 -k"??????0000G?MG20${dtg}*" adms bdms
  rdmscpy -l34 -k"??????0000G?0G20${dtg}*" adms bdms
fi


cat > ct3tot5 << EOFchg
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j 

. ~/etc/setup_mpi.fx100

set -x
export GM2GM_MASIN=MASOPSop@GGG
export GM2GM_MASOUT=MASOPS@${locDMSDB}

rdmspurge -f GM2GM_MASOUT
rdmscrt -l34 GM2GM_MASOUT

#export GM2GM_BCK=BCK320_GG@bckdms
export GM2GM_BCK=BCK512_GH@bckdms

export NWPETC=${curdir}
export NWPETCGLB=${curdir}

/usr/bin/time -p ${curdir}/t320l40_t512l60Noahq.exe $dtg 0006
EOFchg

pjsub  -o ${curdir}/chgr_t320l40_t512l60.log   ct3tot5 
exit
