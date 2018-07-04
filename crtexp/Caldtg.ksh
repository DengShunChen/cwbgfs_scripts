#!/bin/ksh

fun_Get_DD ()
{
  case ${mm} in
    01|03|05|07|08|10|12) DD=31 ;;
    04|06|09|11) DD=30 ;;
    02) DD=28 ;;
  esac
  let aa1=yy%400
  let aa2=yy%100
  let aa3=yy%4
  if [[ ${aa3} = 0 && ${aa2} != 0 ]] || [[ ${aa1} = 0 ]]
  then
    leap=1
  else
    leap=0
  fi
  [[ ${leap} = 1 && ${mm} = "02" ]] && DD=29
}

fun_YY ()
{
  let yy=yy${Sym}1
}

fun_MM ()
{
  let mm=mm${Sym}1
  fun_Get_DD $mm
  if [ $mm -le 0 ]
  then
    fun_YY - 1
    let mm=mm+12
  elif [ $mm -gt 12 ]
  then
    fun_YY + 1 
    let mm=mm-12
  fi
}

fun_DD ()
{
  Sym=$1
  TTd=$2
  let dd=dd${Sym}TTd
  while [ ${dd} -le 0 ]
  do
    fun_MM - 1
    let dd=dd+DD
  done
  while [ ${dd} -gt ${DD} ]
  do
    let dd=dd-DD
    fun_MM + 1
  done
  ddt=${dd}
}

##### main program
##set -x
if [ $# != 2 ]
then
  echo "$0 yymmddhh [+|-]TT"
  exit 0
fi
dtg=$1
TT=$2

typeset -Z2 yy mm ddt hht 
yy=`echo ${dtg} | /bin/cut -c1-2`
mm=`echo ${dtg} | /bin/cut -c3-4`
dd=`echo ${dtg} | /bin/cut -c5-6`
hh=`echo ${dtg} | /bin/cut -c7-8`

fun_Get_DD $mm

let TTd=0
Sym=`echo ${TT} | /bin/cut -c1-1`
if [[ ${Sym} = "-" || ${Sym} = "+" ]]
then
  TTh=`echo ${TT} | /bin/cut -c2-`
else
  Sym="+"
  TTh=${TT}
fi

if [ ${TTh} -ge 24 ]
then
  let TTt=TTh%24
  let TTd=TTh/24
  fun_DD ${Sym} ${TTd}
  let hh=hh${Sym}TTt
else
  let hh=hh${Sym}TTh
fi

if [ ${hh} -lt 0 ]
then
  let hh=hh+24
  fun_DD "-" 1
elif [ ${hh} -ge 24 ]
then
  let hh=hh-24
  fun_DD "+" 1
else
  ddt=${dd}
fi
hht=${hh}

echo $yy$mm$ddt$hht 
exit 0
