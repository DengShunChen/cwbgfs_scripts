#!/bin/ksh
if [ $# -eq 1 ]
then
  if [ $1 = "v" ]
  then
    vi score320ga_exp.input
    exec 7< score320ga_exp.input
  else
    vi $1
    exec 7< $1
  fi
  read -u7 tmpvar
  fnconf=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  dateini=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  dateend=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  updatehr=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  namelist=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  flag=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admshd=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admstl=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admsdb=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  exp=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  subopt=`echo $tmpvar | cut -d= -f2`
elif [ $# -eq 0 ] 
then
    echo " "
    echo " usage : 0100_score320.ksh fnconf dateini dateend updhr namlst flg dmshd dmstl dmsdb scrdb exp subopt"
    echo " "
    exit
  exit
else 
fnconf=$1
dateini=$2
dateend=$3
updatehr=$4
namelist=$5
flag=$6
admshd=$7
admstl=$8
admsdb=$9
exp=${10}
subopt=${11}
fi


cd ${LOGDIR}
cat > scr << EOFscr
#!/bin/ksh
#PJM -L node=1
####PJM -L rscunit=unit1
#PJM -L elapse=1:00:00
#PJM --no-stging
#PJM -j
. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi
set -x

export NWPETCEVL=${NWPDAT}/eval

scorework=${NWP}/dtg_score
if [ -s \${scorework}  ] ; then
  rm -f -r \${scorework}
fi
mkdir \${scorework}
cd \$scorework

export MASOPS=tmpGA_${exp}@${SCOREDB_NAME}
${DMSPATH}/rdmscrt -l34 MASOPS
export SCORE=score_${exp}@${SCOREDB_NAME}
${DMSPATH}/rdmscrt -l34 SCORE

rm -f \$NWPETCEVL/namelist.input
cp \$NWPETCEVL/${namelist} \$NWPETCEVL/namelist.input

typeset -i count
tmpdtg=$dateini
while [ \$tmpdtg -le $dateend ]
do 
#-----------------
#GG2GA
#-----------------
    hh=\`echo \$tmpdtg | cut -c7-8\`
   if [ \$hh = 12 -o \$hh = 00 ] ; then
     ${NWPBINS}/0e11_prepga320L40_1mb.ksh ${fnconf} \${tmpdtg} \${tmpdtg} 12 7 "0000 0006 0024 0048 0072 0096 0120 0144 0168 0192" ${admsdb} null null  ${SCOREDB_NAME} ${exp} 0 
   else
     ${NWPBINS}/0e11_prepga320L40_1mb.ksh ${fnconf} \${tmpdtg} \${tmpdtg} 12 2 "0000 0006" ${admsdb} null null  ${SCOREDB_NAME} ${exp} 0 
   fi
   if [ \$? -ne 0 ] ; then 
     nowt=\`date\`
     echo "\$nowt \$tmpdtg 0e11_prepga320L40_1mb.ksh fail!! " >> ${STATUS}/score320.ksh.\${tmpdtg}.fail
     exit -1
   fi
    cd \${scorework}
    export MASOPS=tmpGA_${exp}@${SCOREDB_NAME}
    export SCORE=score_${exp}@${SCOREDB_NAME}
    export CWBCLM=CWBCLM@${SCOREDB_NAME}
    ${NWPBIN}/DG_Pd_score \$tmpdtg
   if [ \$? -ne 0 ] ; then 
     nowt=\`date\`
     echo "\$nowt \$tmpdtg DG_Pd_score fail!! " >> ${STATUS}/score320.ksh.\${tmpdtg}.fail
     exit -1
   else
     echo "\$nowt \$tmpdtg DG_Pd_score OK!! " >> ${STATUS}/score320.ksh.\${tmpdtg}.ok
   fi

   tmpdtg=\`${NWPBINS}/0x01_Caldtg.ksh \${tmpdtg} $updatehr\`
   echo dtg=\$tmpdtg
done

echo "score ok, exit"
exit
EOFscr

if [ $subopt -eq 1 ]
then
  ssh ${LGIN} ${PJSUB} ${LOGDIR}/scr
else
  chmod u+x ${LOGDIR}/scr
  ${LOGDIR}/scr
fi

exit

