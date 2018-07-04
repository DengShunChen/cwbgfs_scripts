#!/bin/ksh
if [ $# -eq 1 ]
then
 if [ $1 = v ]
 then
  vi fguess_gsi.input
  exec 7< fguess_gsi.input
 else
  vi $1
  exec 7< $1
 fi
  read -u7 aa
  dtg=`echo $aa | cut -d: -f2`
  read -u7 aa
  tau=`echo $aa | cut -d: -f2`
  read -u7 aa
  dmsin=`echo $aa | cut -d: -f2`
  read -u7 aa
  dmsout=`echo $aa | cut -d: -f2`
elif [ $# -eq  0 ]
then
  print -n "usage : gg2ge.ksh e"
  exit 3
else
  dtg=$1
  tau=$2
  dmsin=$3
  dmsout=$4
fi

set -x

${DMSPATH}/rdmscrt -l34 $dmsout

LPATH=`pwd`

cd $NWPWRKENS
export GM2GM_MASIN=$dmsin
export GM2GM_MASOUT=$dmsout
export GM2GM_BCK=$BCKENS


itau=`printf %04i $tau`

cat > gm2gm_namlsts.tpl << EOFgm2gm
&gm2gm_param
im=${LONA},
km30=30,
km40=${LEVS},
nx=${LONA_ENKF},
lev=${LEVS},
lmax=16,
&end

from im to nx
km30=30 is dummy
lmax=16 no need to change
EOFgm2gm

#M00im=`grep NLON ${gsiparm_main}  | cut -d"," -f4 | cut -d"=" -f2`
#M00nsig=`grep NLON ${gsiparm_main}  | cut -d"," -f5 | cut -d"=" -f2`
#ENKFim=`grep NLON ${gsiparm_innov}  | cut -d"," -f4 | cut -d"=" -f2`
#ENKFnsig=`grep NLON ${gsiparm_innov}| cut -d"," -f5 | cut -d"=" -f2`
#sed "s%M00im%${LONA}%g" gm2gm_namlsts.tpl | \
#sed "s%M00nsig%${LEVS}%g" | \
#sed "s%ENKFim%${LONA_ENKF}%g" | \
#sed "s%ENKFnsig%${LEVS}%g" > gm2gm_namlsts

export GM2GM_NAMLSTS=./gm2gm_namlsts

#M00jcap=`grep JCAP ${gsiparm_main}  | cut -d"=" -f 2 | cut -d"," -f 1`
#ENKFjcap=`grep JCAP ${gsiparm_innov}  | cut -d"=" -f 2 | cut -d"," -f 1`
((M00jcap=JCAPA+1))
((ENKFjcap=JCAPA_ENKF+1))

/usr/bin/time -p ${NWPBIN}/GENS_gm2gm_t${M00jcap}_t${ENKFjcap}_ana ${dtg} $itau
 if [ $? != 0 ]; then
  echo "GENSgg2ge : ${dtg}   gg2ge.ksh fail !!" > ${STATUS}/ENS_recenter.${dtg}
  echo "GENSgg2ge : ${dtg}  error occured: gg2ge.ksh fail !!"
  exit 2
 else
  echo "GENSgg2ge : ${dtg}   gg2ge.ksh sucess !!" > ${STATUS}/ENS_recenter.${dtg}
  echo "GENSgg2ge : ${dtg}   gg2ge.ksh sucess !!"
  exit 0
 fi
