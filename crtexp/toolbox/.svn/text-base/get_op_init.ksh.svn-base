#/bin/bash
#--------------------------------------------------------------------------
#  Propse : download operational initial data from silo (T319L40)
#
#
#
#
#--------------------------------------------------------------------------
 set -x

 #-- control 
 dtg_first=${dtg_first:-16070200}
 expname=${expname:-eboost}
 dmsdb=${dmsdb:-T511GFS}
 forGFS=${forGFS:-'false'}

#-- evironmental settings
 USER=${USER:-`whoami`}
 MACHINE=${MACHINE:-fx100}
 LGIN=${LGIN:-login07}
 DTMV=datamv08
 RDMSROOT=${RDMSROOT:-/package/dms/dms.v4/bin}
 DMSDBPATH=${DMSDBPATH:-${HOME}/data/dmsdb}
 MDIR=${MDIR:-`cd .. ; pwd`}

#-- make working directory
 WORKDIR=${WORKDIR:-/nwpr/gfs/xb80/data/WORKDIR/get_init}
 WORK_MAIN=$WORKDIR/main
 WORK_ENKF=$WORKDIR/enkf

#-- download operational data from silo 
 #-- silo settings
 SiloUser=${SiloUser:-xb80}
 SiloServer=${SiloServer:-hsmsvr}
 opt_gm2gm=${opt_gm2gm:-0}
 
 #-- hybrid 
 opt_hyb=${opt_hyb:-1}
 ntotmem=${ntotmem:-36}

#-- inout dms resolution 
 start_gfsflag=${start_gfsflag:-GH}
 start_ensflag=${start_ensflag:-GG}
 start_maindms=${start_maindms:-${expname}${dtg_first}${start_gfsflag}MGM}
 start_enkfdms=${start_enkfdms:-${expname}${dtg_first}${start_ensflag}MGM}
 start_maindmsdb=${start_maindmsdb:-$dmsdb}
 start_enkfdmsdb=${start_enkfdmsdb:-$dmsdb}
 
#-- output dms resolution (20160802)
 end_gfsflag=${end_gfsflag:-GH}
 end_ensflag=${end_ensflag:-GG}
 if [ $forGFS = 'true' ]  ; then
  end_maindms=MASOPS
  end_enkfdms=MASOPS
 else
  end_maindms=${expname}${dtg_first}${end_gfsflag}MGM
  end_enkfdms=${expname}${dtg_first}${end_ensflag}MGM
 fi
 end_maindmsdb=${end_maindmsdb:-$expname}
 end_enkfdmsdb=${end_enkfdmsdb:-$expname}

#-- backgound dms data
 bckdmsdb=${bckdmsdb:-bckdms@$USER}
 BCKMAIN=${BCKMAIN:-BCK_${end_gfsflag}@${bckdmsdb}}
 BCKENKF=${BCKENKF:-BCK_${end_ensflag}@${bckdmsdb}}

#-- download satellite bias correction data
 opt_satbias=${opt_satbias:-0}
 DMSFN=${DMSFN:-$expname}
 NWP=${NWP:-${MDIR}/exp_${DMSFN}}
 DTG=${DTG:-${NWP}/dtg}
 
#--------------------------------------------------------------------------------#
 if [ $start_gfsflag -ne $end_gfsflag ] ; then
   opt_gm2gm = 1 
 fi
 if [ $start_ensflag -ne $end_ensflag ] ; then
   opt_gm2gm = 1 
 fi

 if [ ! -e $WORKDIR ] ;  then
   mkdir $WORKDIR
   mkdir $WORK_MAIN
   mkdir $WORK_ENKF
 else
   mkdir $WORK_MAIN
   mkdir $WORK_ENKF
 fi

 if [ $MACHINE = 'fx100' ] ; then
   RSCGRP=${RSCGRP:-'research-x'}
 else 
   RSCGRP=${RSCGRP:-'research'}
 fi 

 if [ ! -e ${DMSDBPATH}/${start_maindmsdb}.ufs ] ; then
   ssh $DTMV $RDMSROOT/rdmsdbcrt -pufs ${start_maindmsdb}
 fi

 export MASOPS=${start_maindms}@${start_maindmsdb}
 export datadir=${DMSDBPATH}/${start_maindmsdb}.ufs/${start_maindms}
 if [ ! -e ${datadir} ]  ;  then 
   ssh $DTMV $RDMSROOT/rdmscrt -l34 $MASOPS
 fi  
 
 for Mor0 in 'M' '0' ; do 
   for ForA in '6' '0'  ; do
     fgdtg=` ~/bin/Caldtg.ksh ${dtg_first} -${ForA}`
     fgmm=`echo $fgdtg | cut -c3-4`
     if [ ! -e   ${datadir}/20${fgdtg}00000${ForA}/*${start_gfsflag}${Mor0}G* ] ; then
       if  [ $start_gfsflag -eq  'GG' ] ; then
         export MASOPS_silo=MASOPS${fgdtg}${start_gfsflag}${Mor0}GP@NWPDB-${fgmm}@archive@${SiloServer}
         ssh $DTMV $RDMSROOT/rdmscpy -l34 -k"??????000${ForA}${start_gfsflag}?G20${fgdtg}*" $MASOPS_silo $MASOPS
       elif [ $start_gfsflag -eq  'GH' ] ; then
         export MASOPS_silo=MASOPS${fgdtg}${start_gfsflag}${Mor0}GP-000${ForA}@GFSt511-${fgmm}@archive@${SiloServer}
         ssh $DTMV $RDMSROOT/rdmscpy -l34 -k"??????000${ForA}${start_gfsflag}?G20${fgdtg}*" $MASOPS_silo $MASOPS
       else
         echo "Get initial data : Not Support this type of dms flag = $start_gfsflag"
       fi
     else
       echo "--> ${datadir}/20${fgdtg}00000${ForA}/*${start_gfsflag}${Mor0}G* exist !!"
     fi
   done 
 done


 if [ $opt_satbias -eq 1 ] ; then
   fgdtg=` ~/bin/Caldtg.ksh ${dtg_first} -6`
   fgmm=`echo $fgdtg | cut -c3-4`
   ssh $DTMV scp xb80@${SiloServer}:/bak/op/nwp/archive/nwp/dgs/p_diagall.20${fgdtg}.tar.gz ${DTG}_save
   cd ${DTG}_save
   gunzip p_diagall.20${fgdtg}.tar.gz
   tar -xvf p_diagall.20${fgdtg}.tar satbias.20$fgdtg
   tar -xvf p_diagall.20${fgdtg}.tar satbias_ang.20$fgdtg
   rm -f  p_diagall.20${fgdtg}.tar.gz p_diagall.20${fgdtg}.tar
 fi

 if [ $opt_hyb -eq 1 ] ; then
   typeset -Z3 mem
   mem=1
   while [  ${mem} -le $ntotmem ] ; do
     echo "member = $mem"
     export MASOPS=${start_enkfdms}_mem${mem}@${start_maindmsdb}
     export datadir=${DMSDBPATH}/${start_maindmsdb}.ufs/${start_enkfdms}_mem${mem}
     if [ ! -e ${datadir} ]  ;  then
       ssh $DTMV $RDMSROOT/rdmscrt -l34 $MASOPS
     fi    

     for Mor0 in 'M' '0' ; do 
       for ForA in '6' '0' ; do
         fgdtg=` ~/bin/Caldtg.ksh ${dtg_first} -${ForA} `
         fgmm=`echo ${fgdtg} | cut -c3-4`
         if [ ! -e  ${datadir}/20${fgdtg}00000${ForA}/*${start_ensflag}${Mor0}G* ] ;  then
           if  [ $start_ensflag -eq  'GE' ] ; then
             export MASOPSop=MASOPS${fgdtg}${start_ensflag}${Mor0}GP-${mem}@ENKF-${fgmm}@archive@${SiloServer}1a
             ssh $DTMV $RDMSROOT/rdmscpy -l34 -k"??????000${ForA}${start_ensflag}?G20${fgdtg}*" $MASOPSop $MASOPS
           elif [ $start_ensflag -eq  'GG' ] ; then
             export MASOPSop=MASOPS${fgdtg}${start_ensflag}${Mor0}GP-${mem}@ENKF-${fgmm}@archive@${SiloServer}1a
             ssh $DTMV $RDMSROOT/rdmscpy -l34 -k"??????000${ForA}${start_ensflag}?G20${fgdtg}*" $MASOPSop $MASOPS
           else
             echo "Get initial data : Not Support this type of dms flag = $start_ensflag"   
           fi
        else
          echo "--> ${datadir}/20${fgdtg}00000${ForA}/*${start_ensflag}${Mor0}G* exist !!"
        fi
       done
     done
 
     ((mem=$mem+1))
   done
 fi

 if [ $opt_gm2gm -eq 1 ] ; then

cat > $WORK_MAIN/gm2gm_namlsts << EOFgm2gm
&gm2gm_param
ggdef1='${start_gfsflag}0G',
gmdef1='${start_gfsflag}MG',
km=40,
ggdef2='${end_gfsflag}0G',
gmdef2='${end_gfsflag}MG',
lev=60,
lmax=16,
&end

from im to nx
from f1 to f2
km30=30 is dummy
lmax=16 no need to change

EOFgm2gm

cat > $WORK_MAIN/t3tot5 << EOFt3to5
#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j

. ~/etc/setup_mpi.${MACHINE}

set -x
export GM2GM_MASIN=${start_maindms}@${start_maindmsdb}
export GM2GM_MASOUT=${end_maindms}@${end_maindmsdb}

rdmspurge -f GM2GM_MASOUT
rdmscrt -l34 GM2GM_MASOUT

export GM2GM_BCK=${BCKMAIN}

cd ${WORK_MAIN}
export NWPETC=${WORK_MAIN}
export NWPETCGLB=${WORK_MAIN}

#-- namlsts file
export GM2GM_NAMLSTS=${WORK_MAIN}/gm2gm_namlsts

/usr/bin/time -p ${MDIR}/crtexp/gm2gm_Noahq_${MACHINE}.exe $dtg_first 0006
EOFt3to5

    pjsub  -L rscgrp=$RSCGRP -o ${WORK_MAIN}/t320l40tot512l60.log $WORK_MAIN/t3tot5

#-------------------------------------------------------------
# change resolution : ENKF
#-------------------------------------------------------------
   if [ $opt_hyb -eq 1 ] ; then

     typeset -Z3 mem
     mem=1

cat > $WORK_ENKF/gm2gm_namlsts << EOFgm2gm
&gm2gm_param
ggdef1='${start_ensflag}0G',
gmdef1='${start_ensflag}MG',
km=40,
ggdef2='${end_ensflag}0G',
gmdef2='${end_ensflag}MG',
lev=60,
lmax=16,
&end

from im to nx
from f1 to f2
km30=30 is dummy
lmax=16 no need to change

EOFgm2gm

     while [ $mem -le $ntotmem ] ; do

cat > $WORK_ENKF/ct1to3m${mem} <<EOFct1to3
#!/bin/ksh
#PJM -L "node=1"
#PJM -L "elapse=1:00:00"
#PJM -j

. ~/etc/setup_mpi.${MACHINE}

set -x
export GM2GM_MASIN=${start_enkfdms}_mem${mem}@${start_enkfdmsdb}
export GM2GM_MASOUT=${end_enkfdms}_mem${mem}@${end_enkfdmsdb}

rdmspurge -f GM2GM_MASOUT
rdmscrt -l34 GM2GM_MASOUT

export GM2GM_BCK=$BCKENKF

cd $WORK_ENKF
export NWPETC=${WORK_ENKF}
export NWPETCGLB=${WORK_ENKF}

#-- namlsts file
export GM2GM_NAMLSTS=${WORK_ENKF}/gm2gm_namlsts

/usr/bin/time -p ${MDIR}/crtexp/gm2gm_Noahq_${MACHINE}.exe $dtg_first 0006
exit
EOFct1to3

       pjsub  -L rscgrp=$RSCGRP -o ${WORK_ENKF}/t180tot320${mem}.log $WORK_ENKF/ct1to3m${mem}

       ((mem=mem+1))
     done
   fi
 fi
