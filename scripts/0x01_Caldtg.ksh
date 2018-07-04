#!/bin/ksh

#=================== function ===================================#

#---- fun_Get_DD : set the total days to the specific month 
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
  if [[ ${aa3} = 0 && ${aa2} != 0 ]] || [[ ${aa1} = 0 ]] ; then
    leap=1
  else
    leap=0
  fi
  [[ ${leap} = 1 && ${mm} = "02" ]] && DD=29
}

#---- fun_YY  : set years 
fun_YY ()
{
  let yy=yy${Sym}1
}

#---- fun_MM  : set month
fun_MM ()
{
  let mm=mm${Sym}1
  fun_Get_DD $mm
  if [ $mm -le 0 ] ; then
    fun_YY - 1
    let mm=mm+12
  elif [ $mm -gt 12 ] ; then
    fun_YY + 1 
    let mm=mm-12
  fi
}

#---- fun_DD  : set days
fun_DD ()
{
  Sym=$1
  TTd=$2
  let dd=dd${Sym}TTd
  while [ ${dd} -le 0 ] ; do
    fun_MM - 1
    let dd=dd+DD
  done
  while [ ${dd} -gt ${DD} ] ; do
    let dd=dd-DD
    fun_MM + 1
  done
  ddt=${dd}
}

#=================== MAIN PROGRAM ===================================#
# input 
if [ $# != 2 ] ; then
  echo "$0 yymmddhh [+|-]TT"
  exit 0
else
  dtg=$1
  TT=$2
fi

# set origianl date time to vaiables 
typeset -Z2 yy mm ddt hht 
yy=`echo ${dtg} | /bin/cut -c1-2`
mm=`echo ${dtg} | /bin/cut -c3-4`
dd=`echo ${dtg} | /bin/cut -c5-6`
hh=`echo ${dtg} | /bin/cut -c7-8`

# set the total days of the month
fun_Get_DD $mm

# check forward or backward evolving  
let TTd=0
Sym=`echo ${TT} | /bin/cut -c1-1`
if [[ ${Sym} = "-" || ${Sym} = "+" ]] ; then
  TTh=`echo ${TT} | /bin/cut -c2-`
else
  Sym="+"
  TTh=${TT}
fi

# if evolving huours is great than 24 hours, calculate the equivalent days and hours. 
if [ ${TTh} -ge 24 ] ; then
  let TTt=TTh%24
  let TTd=TTh/24
  # evolving days 
  fun_DD ${Sym} ${TTd}
  let hh=hh${Sym}TTt
else
  let hh=hh${Sym}TTh
fi

# adjust days and hours 
if [ ${hh} -lt 0 ] ; then
  let hh=hh+24
  fun_DD "-" 1
elif [ ${hh} -ge 24 ] ; then
  let hh=hh-24
  fun_DD "+" 1
else
  ddt=${dd}
fi
hht=${hh}

# out put the final results 
echo $yy$mm$ddt$hht 


exit 0
