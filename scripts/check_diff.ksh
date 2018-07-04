#/bin/ksh

path1=./
path2=${1}

filelist=`ls $path1` 

for file in $filelist ;  do
  if [[ -s $path2/$file ]] ; then
   # echo "file --> $file"
    echo "---------------------------------------------------------------"
    diff $path1/$file $path2/$file

    if [ $? -ne 0 ] ; then
      echo "CHECK_DIFF : *** $file are DIFFERENT ***"
    else
      echo "CHECK_DIFF : $file are the same"
    fi
  fi 
done

