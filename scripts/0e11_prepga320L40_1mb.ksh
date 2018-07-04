#!/bin/ksh
if [ $# -eq 1 ]
then
  vi prepga320L40.input
  exec 7< prepga320L40.input

  read -u7 tmpvar
  fnconf=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  dateini=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  dateend=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  updatehr=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  ntau=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  taulst=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admsdb=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admshd=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  admstl=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  scoredb=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  exp=`echo $tmpvar | cut -d= -f2`
  read -u7 tmpvar
  subopt=`echo $tmpvar | cut -d= -f2`
elif [ $# -eq 12 ]
then
 fnconf=$1
 dateini=$2
 dateend=$3
 updatehr=$4
 ntau=$5
 taulst=$6
 admsdb=$7
 admshd=$8
 admstl=$9
 scoredb=${10}
 exp=${11}
 subopt=${12}
else
  echo 'please use prepanaga.ksh v'
  exit
fi

curdir=`pwd`
workdir=$curdir/tmp_${exp}
if [ ! -s $workdir ]
then
 mkdir $workdir ]
fi
cd $workdir

cat > prepaga << EOFprepaga
#!/bin/ksh
#PJM -L node=1
#####PJM -L rscunit=unit1
#PJM -L "elapse=0:40:00"
#PJM --no-stging
#PJM -j
set -x

. ${NWPBINS}/${fnconf}.set
. ${NWPBINS}/setup_mpi

cd $workdir
dtg0=$dateini
while [ \$dtg0 -le $dateend ]
do
  export tmpGA=tmpGA_${exp}@${scoredb}
  \${DMSPATH}/rdmscrt -l34 tmpGA
  tmpGAdmsfn=tmpGA_${exp}
    if [ $admstl = null ]
    then
      if [ $admshd = null ]
      then
        export adms=MASOPS@${admsdb}
        admsfn=MASOPS@${admsdb}
      else
        export adms=${admshd}\${dtg0}@${admsdb}
        admsfn=${admshd}\${dtg0}@${admsdb}
      fi
    else
      export adms=${admshd}\${dtg0}${admstl}@${admsdb}
      admsfn=${admshd}\${dtg0}${admstl}@${admsdb}
    fi
  typeset -i nt
  nt=1
  while [ \$nt -le $ntau ]
  do
    if [ $ntau -eq 1 ]
    then
      tau=$taulst
    else
      tau=\`echo $taulst | cut -d" " -f\$nt\`
    fi
cat > gg2ga.fil << EOFgg2gafil
B00010\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00100\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00030\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00040\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00310\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00320\${tau}${gfsflag}0g20\${dtg0}00H1179648
S00430\${tau}${gfsflag}0g20\${dtg0}00H1179648
S005A0\${tau}${gfsflag}0g20\${dtg0}00H1179648
S005A1\${tau}${gfsflag}0g20\${dtg0}00H1179648
S005C0\${tau}${gfsflag}0g20\${dtg0}00H1179648
S01100\${tau}${gfsflag}0g20\${dtg0}00H1179648
S015B0\${tau}${gfsflag}0g20\${dtg0}00H1179648
S02100\${tau}${gfsflag}0g20\${dtg0}00H1179648
SSL010\${tau}${gfsflag}0g20\${dtg0}00H1179648
W00100\${tau}${gfsflag}0g20\${dtg0}00H1179648
W00090\${tau}${gfsflag}0g20\${dtg0}00H1179648
W00091\${tau}${gfsflag}0g20\${dtg0}00H1179648
B00620\${tau}${gfsflag}0g20\${dtg0}00H1179648
B0062T\${tau}${gfsflag}0g20\${dtg0}00H1179648
B00630\${tau}${gfsflag}0g20\${dtg0}00H1179648
B00640\${tau}${gfsflag}0g20\${dtg0}00H1179648
B00650\${tau}${gfsflag}0g20\${dtg0}00H1179648
B00651\${tau}${gfsflag}0g20\${dtg0}00H1179648
B10200\${tau}${gfsflag}0g20\${dtg0}00H1179648
B10210\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00000\${tau}${gfsflag}0g20\${dtg0}00H1179648
925000\${tau}${gfsflag}0g20\${dtg0}00H1179648
850000\${tau}${gfsflag}0g20\${dtg0}00H1179648
700000\${tau}${gfsflag}0g20\${dtg0}00H1179648
500000\${tau}${gfsflag}0g20\${dtg0}00H1179648
400000\${tau}${gfsflag}0g20\${dtg0}00H1179648
300000\${tau}${gfsflag}0g20\${dtg0}00H1179648
250000\${tau}${gfsflag}0g20\${dtg0}00H1179648
200000\${tau}${gfsflag}0g20\${dtg0}00H1179648
150000\${tau}${gfsflag}0g20\${dtg0}00H1179648
100000\${tau}${gfsflag}0g20\${dtg0}00H1179648
070000\${tau}${gfsflag}0g20\${dtg0}00H1179648
050000\${tau}${gfsflag}0g20\${dtg0}00H1179648
030000\${tau}${gfsflag}0g20\${dtg0}00H1179648
020000\${tau}${gfsflag}0g20\${dtg0}00H1179648
010000\${tau}${gfsflag}0g20\${dtg0}00H1179648
007000\${tau}${gfsflag}0g20\${dtg0}00H1179648
005000\${tau}${gfsflag}0g20\${dtg0}00H1179648
003000\${tau}${gfsflag}0g20\${dtg0}00H1179648
002000\${tau}${gfsflag}0g20\${dtg0}00H1179648
001000\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00100\${tau}${gfsflag}0g20\${dtg0}00H1179648
925100\${tau}${gfsflag}0g20\${dtg0}00H1179648
850100\${tau}${gfsflag}0g20\${dtg0}00H1179648
700100\${tau}${gfsflag}0g20\${dtg0}00H1179648
500100\${tau}${gfsflag}0g20\${dtg0}00H1179648
400100\${tau}${gfsflag}0g20\${dtg0}00H1179648
300100\${tau}${gfsflag}0g20\${dtg0}00H1179648
250100\${tau}${gfsflag}0g20\${dtg0}00H1179648
200100\${tau}${gfsflag}0g20\${dtg0}00H1179648
150100\${tau}${gfsflag}0g20\${dtg0}00H1179648
100100\${tau}${gfsflag}0g20\${dtg0}00H1179648
070100\${tau}${gfsflag}0g20\${dtg0}00H1179648
050100\${tau}${gfsflag}0g20\${dtg0}00H1179648
030100\${tau}${gfsflag}0g20\${dtg0}00H1179648
020100\${tau}${gfsflag}0g20\${dtg0}00H1179648
010100\${tau}${gfsflag}0g20\${dtg0}00H1179648
007100\${tau}${gfsflag}0g20\${dtg0}00H1179648
005100\${tau}${gfsflag}0g20\${dtg0}00H1179648
003100\${tau}${gfsflag}0g20\${dtg0}00H1179648
002100\${tau}${gfsflag}0g20\${dtg0}00H1179648
001100\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00200\${tau}${gfsflag}0g20\${dtg0}00H1179648
925200\${tau}${gfsflag}0g20\${dtg0}00H1179648
850200\${tau}${gfsflag}0g20\${dtg0}00H1179648
700200\${tau}${gfsflag}0g20\${dtg0}00H1179648
500200\${tau}${gfsflag}0g20\${dtg0}00H1179648
400200\${tau}${gfsflag}0g20\${dtg0}00H1179648
300200\${tau}${gfsflag}0g20\${dtg0}00H1179648
250200\${tau}${gfsflag}0g20\${dtg0}00H1179648
200200\${tau}${gfsflag}0g20\${dtg0}00H1179648
150200\${tau}${gfsflag}0g20\${dtg0}00H1179648
100200\${tau}${gfsflag}0g20\${dtg0}00H1179648
070200\${tau}${gfsflag}0g20\${dtg0}00H1179648
050200\${tau}${gfsflag}0g20\${dtg0}00H1179648
030200\${tau}${gfsflag}0g20\${dtg0}00H1179648
020200\${tau}${gfsflag}0g20\${dtg0}00H1179648
010200\${tau}${gfsflag}0g20\${dtg0}00H1179648
007200\${tau}${gfsflag}0g20\${dtg0}00H1179648
005200\${tau}${gfsflag}0g20\${dtg0}00H1179648
003200\${tau}${gfsflag}0g20\${dtg0}00H1179648
002200\${tau}${gfsflag}0g20\${dtg0}00H1179648
001200\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00210\${tau}${gfsflag}0g20\${dtg0}00H1179648
925210\${tau}${gfsflag}0g20\${dtg0}00H1179648
850210\${tau}${gfsflag}0g20\${dtg0}00H1179648
700210\${tau}${gfsflag}0g20\${dtg0}00H1179648
500210\${tau}${gfsflag}0g20\${dtg0}00H1179648
400210\${tau}${gfsflag}0g20\${dtg0}00H1179648
300210\${tau}${gfsflag}0g20\${dtg0}00H1179648
250210\${tau}${gfsflag}0g20\${dtg0}00H1179648
200210\${tau}${gfsflag}0g20\${dtg0}00H1179648
150210\${tau}${gfsflag}0g20\${dtg0}00H1179648
100210\${tau}${gfsflag}0g20\${dtg0}00H1179648
070210\${tau}${gfsflag}0g20\${dtg0}00H1179648
050210\${tau}${gfsflag}0g20\${dtg0}00H1179648
030210\${tau}${gfsflag}0g20\${dtg0}00H1179648
020210\${tau}${gfsflag}0g20\${dtg0}00H1179648
010210\${tau}${gfsflag}0g20\${dtg0}00H1179648
007210\${tau}${gfsflag}0g20\${dtg0}00H1179648
005210\${tau}${gfsflag}0g20\${dtg0}00H1179648
003210\${tau}${gfsflag}0g20\${dtg0}00H1179648
002210\${tau}${gfsflag}0g20\${dtg0}00H1179648
001210\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00510\${tau}${gfsflag}0g20\${dtg0}00H1179648
925510\${tau}${gfsflag}0g20\${dtg0}00H1179648
850510\${tau}${gfsflag}0g20\${dtg0}00H1179648
700510\${tau}${gfsflag}0g20\${dtg0}00H1179648
500510\${tau}${gfsflag}0g20\${dtg0}00H1179648
400510\${tau}${gfsflag}0g20\${dtg0}00H1179648
300510\${tau}${gfsflag}0g20\${dtg0}00H1179648
250510\${tau}${gfsflag}0g20\${dtg0}00H1179648
200510\${tau}${gfsflag}0g20\${dtg0}00H1179648
150510\${tau}${gfsflag}0g20\${dtg0}00H1179648
100510\${tau}${gfsflag}0g20\${dtg0}00H1179648
070510\${tau}${gfsflag}0g20\${dtg0}00H1179648
050510\${tau}${gfsflag}0g20\${dtg0}00H1179648
030510\${tau}${gfsflag}0g20\${dtg0}00H1179648
020510\${tau}${gfsflag}0g20\${dtg0}00H1179648
010510\${tau}${gfsflag}0g20\${dtg0}00H1179648
007510\${tau}${gfsflag}0g20\${dtg0}00H1179648
005510\${tau}${gfsflag}0g20\${dtg0}00H1179648
003510\${tau}${gfsflag}0g20\${dtg0}00H1179648
002510\${tau}${gfsflag}0g20\${dtg0}00H1179648
001510\${tau}${gfsflag}0g20\${dtg0}00H1179648
H00550\${tau}${gfsflag}0g20\${dtg0}00H1179648
925550\${tau}${gfsflag}0g20\${dtg0}00H1179648
850550\${tau}${gfsflag}0g20\${dtg0}00H1179648
700550\${tau}${gfsflag}0g20\${dtg0}00H1179648
500550\${tau}${gfsflag}0g20\${dtg0}00H1179648
400550\${tau}${gfsflag}0g20\${dtg0}00H1179648
300550\${tau}${gfsflag}0g20\${dtg0}00H1179648
250550\${tau}${gfsflag}0g20\${dtg0}00H1179648
200550\${tau}${gfsflag}0g20\${dtg0}00H1179648
150550\${tau}${gfsflag}0g20\${dtg0}00H1179648
100550\${tau}${gfsflag}0g20\${dtg0}00H1179648
070550\${tau}${gfsflag}0g20\${dtg0}00H1179648
050550\${tau}${gfsflag}0g20\${dtg0}00H1179648
030550\${tau}${gfsflag}0g20\${dtg0}00H1179648
020550\${tau}${gfsflag}0g20\${dtg0}00H1179648
010550\${tau}${gfsflag}0g20\${dtg0}00H1179648
007550\${tau}${gfsflag}0g20\${dtg0}00H1179648
005550\${tau}${gfsflag}0g20\${dtg0}00H1179648
003550\${tau}${gfsflag}0g20\${dtg0}00H1179648
002550\${tau}${gfsflag}0g20\${dtg0}00H1179648
001550\${tau}${gfsflag}0g20\${dtg0}00H1179648
nomodata
EOFgg2gafil

   export indms=\$admsfn
   export outdms=\$tmpGAdmsfn@${scoredb}
   ${NWPBIN}/gg2ga
   nt=nt+1
 done

  dtg0=\`${NWPBINS}/0x01_Caldtg.ksh \${dtg0} $updatehr\`
done


exit
EOFprepaga
ls -l prepaga

if [ $subopt -eq 1 ]
then
 ${PJSUB} prepaga 
else
 chmod u+x prepaga
 ./prepaga
fi
exit
