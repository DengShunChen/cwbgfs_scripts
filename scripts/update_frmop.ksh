#/bin/ksh

path1=/nwpr/gfs/xb80/data2/CWBGFS/exp_h4dallobs/bins/

path2=./

#path3=/nwp/npcagfs3/GFS/EKG/bin
filelist=`ls $path1` 


for file in $filelist ;  do

  if [[ -s $path2/$file ]] ; then
    echo "file --> $file"
    diff $path1/$file $path2/$file
    
    read

#   if [ $? -ne 0 ] ; then
#    cp -i $path2/$file $path1/$file
#   fi
  fi 
#  if [[ -s $path3/$file ]] ; then
#    echo "file --> $file"
#    diff $path1/$file $path3/$file
#    if [ $? -ne 0 ] ; then
#      cp -i $path3/$file $path1/$file
#    fi
#  fi 

done

