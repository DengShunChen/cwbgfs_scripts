#!/bin/ksh
if [ $# -eq 5 ]
then
  dtg=$1
  ckjob=$2
  ckiter=$3
  cksec=$4
  STATUS=$5
else
  echo "usage : ckwait.ksh dtg ckjob ckiter cksec"
  exit
fi


set -x
if [ -s ${STATUS}/${ckjob}.${dtg}.ok ] ; then
  exit 0
fi
if [ -s ${STATUS}/${ckjob}.${dtg}.fail ] ; then
  exit -1
fi

# wait
typeset -i nn
nn=1
while [ $nn -le $ckiter ] ; do
   if [ -s ${STATUS}/${ckjob}.${dtg}.ok ] ; then
      exit 0
   else
     if [ -s ${STATUS}/${ckjob}.${dtg}.fail ] ; then
       exit -1
     else
       nn=nn+1
       sleep $cksec
     fi
   fi
done

if [ ! -s ${STATUS}/${ckjob}.${dtg}.ok ] ; then
       exit -1
fi
exit 0
