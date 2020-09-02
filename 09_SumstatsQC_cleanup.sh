#!/bin/bash
######################################
#### SumstatsQC Dev version 2 ########
#### Data cleaning step         ######
#### required parameters :           #
#### sumstats                        #
#### pop                             #
#### prefix                          #
#### AF                              #
#### INFO_score                      #
#### AFB                             #
######################################


######################################
##### Define help script #############


    function helpscript {
        echo ""
        echo "SumstatQC data cleaning module"
        echo "This module will zip and archive essential files from the SumstatsQC pipeine"
        echo "intermediate files would be removed"
    }
######################################

######################################
#### Assigned User parameters ########


    while [ "$1" != "" ];do
        PARAM=`echo $1 | awk -F= '{print $1}'`
        VALUE=`echo $1 | awk -F= '{print $2}'`
        case $PARAM in
                -h | --help)
                        helpscript
                        exit 1
                        ;;
                --batch)
                        batch=$VALUE
                        ;;
                --batchfile)
                        batchfile=$VALUE
                        ;;
                --sumstats)
                        sumstats=$VALUE
                        ;;
                --pop)
                        pop=$VALUE
                        ;;
                --qt)
                        qt=$VALUE
                        ;;
                --INFO_score)
                        INFO_score=$VALUE
                        ;;
                --AF)
                        AF=$VALUE
                        ;;
                --AFB)
                        AFB=$VALUE
                        ;;
                --prefix)
                        prefix=$VALUE
                        ;;
                --multicpu)
                        multicpu=$VALUE
                        ;;
                $)
                        echo "ERROR:unknown parameter \ "$PARAM\ ""
                        helpscript
                esac
                shift
    done

######################################

######################################
#### Write Log File Header Here ######


    echo "############################################" 
    echo "### SumstatsQC post-qc data cleanup ...  ###" 
    echo "############################################" 

    # Assign token to sumstats if sumstatsfile is found
    sumstats_1=$(echo "$sumstats" | sed 's/.gz//g')

######################################

######################################
#### Assign population file token ####


    # --pop={1000g_eas|1000g_eur|sg10k_eas|hrc_eur} <- Available options

    if [ "$pop" = "1000g_eur" ]; then
        REFFILE=1000G.EUR.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

    elif [ "$pop" = "1000g_eas" ]; then
        REFFILE=1000G.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

    elif [ "$pop" = "hrc_eur" ]; then
        REFFILE=HRC.EUR.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

    elif [ "$pop" = "sg10k_eas" ]; then
        REFFILE=SG10k.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

    else 
        echo "Other populations are coming your way"
        exit 1

    fi


######################################

######################################
#### Clean up data ###################

    # Make directory for sumstatsQC

    mkdir $prefix.SumstatsQC.files

    # Move visualization plots into the folder 

    mv $prefix*png $prefix.SumstatsQC.files
    mv $prefix*log $prefix.SumstatsQC.files
    mv $prefix*done $prefix.SumstatsQC.files
    # rm chr files 

    rm $sumstats_1*chr*

    # GZIP files 

    if [ "$multicpu" == "Y" ]; then 
        ls $prefix*.txt | awk '{print "gzip", $1, "&"}' > $prefix.gzip.cleanup.multicpu.sh
        #ls $sumstats_1*txt | awk '{print "gzip", $1, "&"}' >> $prefix.gzip.cleanup.multicpu.sh
        #ls $prefix*sumstats* | awk '{print "gzip", $1, "&"}' >> $prefix.gzip.cleanup.multicpu.sh
        ls $sumstats_1*sumstats* | awk '{print "gzip", $1, "&"}' >> $prefix.gzip.cleanup.multicpu.sh
        chmod +x *.sh
        echo "gzipping..."
    else 
        ls $prefix*.txt | awk '{print "gzip", $1}' > $prefix.gzip.cleanup.singlecpu.sh
        #ls $sumstats_1*txt | awk '{print "gzip", $1}' >> $prefix.gzip.cleanup.singlecpu.sh
        #ls $prefix*sumstats* | awk '{print "gzip", $1}' >> $prefix.gzip.cleanup.singlecpu.sh
        ls $sumstats_1*sumstats* | awk '{print "gzip", $1}' >> $prefix.gzip.cleanup.singlecpu.sh
        chmod +x *.sh
        echo "gzipping..."
    fi



######################################