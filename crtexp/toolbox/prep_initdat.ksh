#!/bin/ksh
set -x
opt_hyb=0
fgdtg=15032906
DMSDB_exp=t5Vairstp0

#--------------
# dms file
#--------------
export frdms=MASOPS@t512init
export todms=MASOPS@${DMSDB_exp}
rdmscrt -l34 frdms
rdmscpy -l34 -k"??????0006????20${fgdtg}*" frdms todms

#--------------
# bias files
#--------------
cd ${HOME}/data/t512l60hb_wrk/${DMSDB_exp}/dtg_save
cp  ${HOME}/data/t512l60hb_wrk/${DMSDB_exp}/dtg_save/*bias*${fgdtg} .

exit
