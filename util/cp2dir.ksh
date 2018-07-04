 
  filename='namlsts'
  ini_mem=1
  end_mem=36

  mem=$ini_mem
  while [ $mem -le $end_mem ] ; do
 
    cmem3=`printf %03i $mem`
    echo "cp $filename to gfs_$cmem3"

    cp $filename gfs_$cmem3
 
    ((mem=mem+1))
  done
  
 

