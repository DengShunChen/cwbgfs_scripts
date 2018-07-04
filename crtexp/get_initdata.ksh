#!/bin/ksh
#---------------------------------------------------------------------------------------
#
#   Get Operational data from silo (hsmsvr) 
#
#
#   Log : 
#   2017-01-04   Deng-Shun  -  Create
#   2017-05-04   Deng-Shun  -  Document
#  
#---------------------------------------------------------------------------------------
#set -x

    if [[ $silo_gfsflag =  'GH' ]] ; then
      export MASOPS=MASOPS@${DMSDB}
      for tau in 0 6 ; do 
        valid_dtg=`${MDIRCRT}/Caldtg.ksh $dtg_first -${tau}`
        valid_mm=`echo $valid_dtg | cut -c3-4`
        for vcor in M 0 ; do 
          if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs/MASOPS/20${valid_dtg}00000${tau}/*${silo_gfsflag}${vcor}G* ] ; then
            export MASOPS_silo=MASOPS${valid_dtg}${silo_gfsflag}${vcor}GP-000${tau}@GFSt511-${valid_mm}@archive@hsmsvr    # SILO
            ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_gfsflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
            if [ $? != 0 ] ; then
              export MASOPS_silo=MASOPS${valid_dtg}${silo_gfsflag}${vcor}GP-000${tau}@GFSt511-${valid_mm}@archive@hsmsvr1a    # SILO
              ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_gfsflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
            fi
          fi
        done
      done

    elif [[ $silo_gfsflag = 'GG' ]] ; then
      export MASOPS=MASOPSop@${DMSDB}
      ${DMSPATHx86}/rdmscrt ${MASOPS}
      for tau in 0 6 ; do 
        valid_dtg=`${MDIRCRT}/Caldtg.ksh $dtg_first -${tau}`
        valid_mm=`echo $valid_dtg | cut -c3-4`
        for vcor in M 0 ; do 
          if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs/MASOPSop/20${valid_dtg}00000${tau}/*${silo_gfsflag}${vcor}G* ] ; then
            export MASOPS_silo=MASOPS${valid_dtg}${silo_gfsflag}${vcor}GP@NWPDB-${valid_mm}@archive@hsmsvr    # SILO
            ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_gfsflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
            if [ $? != 0 ] ; then
              export MASOPS_silo=MASOPS${valid_dtg}${silo_gfsflag}${vcor}GP@NWPDB-${valid_mm}@archive@hsmsvr1a    # SILO
              ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_gfsflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
            fi
          fi
        done
      done

    else
      echo "Get initial data : Not Support this type of dms flag = $silo_gfsflag"
    fi

    if [ $opt_hyb -eq 1 ] ; then
      typeset -Z3 mem
      mem=1
      while [  ${mem} -le ${NTOTMEM} ] ; do
        if [[ $silo_ensflag = 'GG' ]] ; then
          export MASOPS=MASOPS_mem${mem}@${DMSDB}

          for tau in 0 6 ; do
            valid_dtg=`${MDIRCRT}/Caldtg.ksh $dtg_first -${tau}`
            valid_mm=`echo $valid_dtg | cut -c3-4`
            for vcor in M 0 ; do
              if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs/MASOPS_mem${mem}/20${valid_dtg}00000${tau}/*${silo_ensflag}${vcor}G* ] ; then
                export MASOPS_silo=MASOPS${valid_dtg}${silo_ensflag}${vcor}GP-${mem}@EKG-${valid_mm}@archive@hsmsvr    # SILO
                ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_ensflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
                if [ $? != 0 ] ; then
                  export MASOPS_silo=MASOPS${valid_dtg}${silo_ensflag}${vcor}GP-${mem}@EKG-${valid_mm}@archive@hsmsvr1a    # SILO
                  ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_ensflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
                fi 
              fi
            done
          done

        elif [[ $silo_ensflag = 'GE' ]] ; then
          export MASOPS=MASOPSop_mem${mem}@${DMSDB}
          ${DMSPATHx86}/rdmscrt ${MASOPS}
          for tau in 0 6 ; do
            valid_dtg=`${MDIRCRT}/Caldtg.ksh $dtg_first -${tau}`
            valid_mm=`echo $valid_dtg | cut -c3-4`
            for vcor in M 0 ; do
              if [ ! -s  ${DMSDBPATH}/${DMSDB}.ufs/MASOPSop_mem${mem}/20${valid_dtg}00000${tau}/*${silo_ensflag}${vcor}G* ] ; then
                export MASOPS_silo=MASOPS${valid_dtg}${silo_ensflag}${vcor}GP-${mem}@ENKF-${valid_mm}@archive@hsmsvr    # SILO
                ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_ensflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
                if [ $? != 0 ] ; then
                  export MASOPS_silo=MASOPS${valid_dtg}${silo_ensflag}${vcor}GP-${mem}@ENKF-${valid_mm}@archive@hsmsvr1a    # SILO
                  ssh ${DTMV#*ssh} -n ${DMSPATHx86}/rdmscpy -l34 -k"??????000${tau}${silo_ensflag}${vcor}G20${valid_dtg}*" $MASOPS_silo $MASOPS
                fi
              fi
            done
          done

        else
          echo "Get initial data : Not Support this type of dms flag = $silo_enssflag"
        fi

        ((mem=$mem+1))
      done
    fi
 
    # get satbias files
    scp $silouser@hsmsvr:/op/bak/archive/nwp/dgs/p_diagall.20${fgdtg}.tar.gz ${DTGSAV}
    if [ $? != 0 ] ; then
      scp $silouser@hsmsvr:/op/bak/archive/nwp/dgs_t511/p_diagall.20${fgdtg}_T511.tar.gz ${DTGSAV}
    fi
    cd ${DTGSAV}
    gunzip p_diagall.20${fgdtg}.tar.gz
    tar -xvf p_diagall.20${fgdtg}.tar satbias.20$fgdtg
    tar -xvf p_diagall.20${fgdtg}.tar satbias_ang.20$fgdtg
    rm -f  p_diagall.20${fgdtg}.tar.gz p_diagall.20${fgdtg}.tar
 
    # generate new biasfiles (should be turn off after operational use new biasfile)
    cp ${MDIRUTIL}/generate_new_biasfiles.ksh ${DTGSAV}
    cp ${MDIRUTIL}/write_biascr_option.x ${DTGSAV}
    ./generate_new_biasfiles.ksh ${fgdtg}   



 
