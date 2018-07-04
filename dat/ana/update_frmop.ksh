#/bin/ksh

path1=./
path2=/nwpr/gfs/gfspar/gdas/dat/ana
path3=/nwp/npcagfs3/GFS/EKG/dat/ana

filelist=`ls $path1` 

for file in $filelist ;  do

  if [[ -s $path2/$file ]] ; then
    echo " --> diff $path1/$file $path2/$file"
    diff $path1/$file $path2/$file
    if [ $? -ne 0 ] ; then
     cp $path2/$file $path1/$file
    fi
  fi 
#  if [[ -s $path3/$file ]] ; then
#    echo " --> diff $path1/$file $path3/$file"
#    diff $path1/$file $path3/$file
#    if [ $? -ne 0 ] ; then
#      cp $path3/$file $path1/$file
#    fi
#  fi 

done

