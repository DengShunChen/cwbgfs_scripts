#!/bin/ksh
#
# This script wants to copy ozone(M??560) to first guest(6 hours forecast)  
#


 adtg=15061500
 fdtg=`/nwpr/gfs/xb80/bin/Caldtg.ksh ${adtg} -6`
 mem_ini=1
 mem_end=36

 mem=${mem_ini}

 while(( ${mem} <= ${mem_end} )) ; do 
   mem3d=`printf %3.3i ${mem}`
   echo "--> member = ${mem3d}"
    if [ ! -e MASOPS_mem${mem3d}/20${fdtg}000006/M??560* ] ; then
      echo "Copying files ...."
      cp MASOPS_mem${mem3d}/20${adtg}000000/M??560* MASOPS_mem${mem3d}/20${fdtg}000006/
    fi
   ((mem=mem+1))
 done

 echo "--> MASOPS"
 if [ ! -e MASOPS/20${fdtg}000006/M??560* ] ; then
   echo "Copying files ...."
   cp MASOPS/20${adtg}000000/M??560* MASOPS/20${fdtg}000006/
 fi 
