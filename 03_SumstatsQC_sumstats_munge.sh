#!/bin/bash

######################################
#### SumstatsQC Dev version 2 ########
#### Split Sumstats into chr  ########
#### required parameters :           #
#### sumstats                        #
#### pop                             #
#### prefix                          #
######################################

######################################
##### Define help script #############


    function helpscript {
        echo "This is the third module of the SumstatsQC pipeline"
        echo "flag options are carried over from the main module"
        echo "This module would split the autosomal variants by CHR"
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


    echo "##################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "### Sumstats munging...        ###" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "##################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log

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
#### Split Sumstats into chr #### ####

        # Generate scripts for splitting sumstats by chr
        # also in this step CHR:BP:A1:A2 is being computed
        # Only for chromosomes 1-22 
        
        if [ "$qt" == "Binary" ]; then          
                for i in {1..22}
                        do 
                        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.2 | sed '1,1d' | awk '{if(\$3=="$i") print \$0}' | sed '1 i\UID SNP CHR BP A1 A2 FRQ INFO OR SE P Nca Nco Z' > "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i""
                done > $prefix.process_summary_statistics.sh
        fi

        if [ "$qt" == "Quantitative" ]; then
                for i in {1..22}
                        do 
                        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.2 | sed '1,1d' | awk '{if(\$3=="$i") print \$0}' | sed '1 i\UID SNP CHR BP A1 A2 FRQ INFO BETA SE P NSample Z' > "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i""
                done > $prefix.process_summary_statistics.sh
        fi

        # Run split chr scripts
        if [ "$multicpu" == "Y" ]; then 

                cat $prefix.process_summary_statistics.sh | awk '{print $0, "&"}' > $prefix.process_summary_statistics_multicpu.sh
                chmod +x *.sh
                echo "Starting sumstats munge..." 
        else
                chmod +x *.sh
                echo "Starting sumstats munge..." 
        fi

######################################