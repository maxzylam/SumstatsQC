#!/bin/bash
######################################
#### SumstatsQC Dev version 2 ########
#### Extract QC info step       ######
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
        echo "In this module a series of diagnostic information are extracted from the QC-ed"
        echo "summary statistics file."
        echo ""
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


    echo "############################################" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
    echo "### SumstatsQC Diagnostic information... ###" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
    echo "############################################" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

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
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

    elif [ "$pop" = "1000g_eas" ]; then
        REFFILE=1000G.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

    elif [ "$pop" = "hrc_eur" ]; then
        REFFILE=HRC.EUR.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log    

    elif [ "$pop" = "sg10k_eas" ]; then
        REFFILE=SG10k.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        # echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log    

    else 
        echo "Other populations are coming your way"
        exit 1

    fi


######################################

######################################
#### QC variables to be extracted

    # Merge with ref panel 
    
        # Number of Autosomes that we begin SumstatsQC with
        sumstats_ref_autosomes=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.non-qc-ed.txt | cut -d ' ' -f1) - 1)
        echo "There are $sumstats_ref_autosomes AUTOSOMAL variants from chr 1-22 that we begin SumstatQC pipeline with" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of variant that have out-of-bounds pvalues
        sumstats_OB_pval=$(wc "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.OB_pval.txt | awk '{print $1}')
        echo "There are $sumstats_OB_pval variants with OUT OF BOUNDS P-values" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of the variants that matched 
        sumstats_ref_match=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt | cut -d ' ' -f1) - 1)
        echo "There are $sumstats_ref_match variants directly matching from $prefix sumstats with $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        
        # Number of variants that were unmatched
        sumstats_ref_unmatched=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt | cut -d ' ' -f1) - 1)
        echo "There are $sumstats_ref_unmatched variants which did not match with $REFFILE" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of unmatched variants that are indels
        sumstats_ref_indels=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt | sed '1,1d' | awk '{if(length($5) > 1 || length($6) >1) print $0}' | wc | awk '{print $1}') 
        echo "There are $sumstats_ref_indels variants that did not match with $REFFILE were indels" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of the variants that were flipped

        sumstats_ref_flip=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt | cut -d ' ' -f1) - 1)
        echo "There are $sumstats_ref_flip variants from $prefix sumstats that have alleles flipped" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of the variants that had alt strand [minus ambiguous]

        sumstats_ref_altstrand=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt | sed '1,1d' | wc | awk '{print $1}')
        echo "There are $sumstats_ref_altstrand variants from $prefix sumstats that were on the alternate strand" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of the variants that had alt strand flp [minus ambiguous]

        sumstats_ref_altstrandflp=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt | sed '1,1d' | wc | awk '{print $1}')
        echo "There are $sumstats_ref_altstrandflp variants from $prefix sumstats that were on the alternate strand and flipped" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
    
    # From qcparams files 
        # Number of variants fail INFO_score 
        sumstats_ref_TOTAL_INFOSc_fail=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep INFOSc_fail | wc | awk '{print $1}')
        
        echo "There are $sumstats_ref_TOTAL_INFOSc_fail variants from $prefix sumstats that failed the INFO_score < $INFO_score threshold" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of variants fail AF

        sumstats_ref_TOTAL_AF_fail=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep AF_fail | wc | awk '{print $1}')
        
        echo "There are $sumstats_ref_TOTAL_AF_fail variants from $prefix sumstats that failed the AF < $AF threshold" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of variants fail ambiguous alleles 

        sumstats_ref_TOTAL_amb_fail=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep amb_fail | wc | awk '{print $1}')
        
        echo "There are $sumstats_ref_TOTAL_amb_fail variants from $prefix sumstats that are considered ambiguous based on AT_CG and AF of > $AMB"  2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of variants fail allele freq difference

        sumstats_ref_TOTAL_AFB_fail=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep AFB_fail | wc | awk '{print $1}')
        
        echo "There are $sumstats_ref_TOTAL_AFB_fail variants from $prefix sumstats that have allele frequency differences > $AFB from $REFFILE"  2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Number of variants with allele freq = 0.5

        sumstats_ref_TOTAL_AF_05=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | awk '{if($7==0.5) print $0}' | wc | awk '{print $1}')

        echo "There are $sumstats_ref_TOTAL_AF_05 variants from $prefix sumstats that have allele frequencies of 0.5. These are also excluded at the final qc step"  2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Total variants excluded after QC procedures 

        totalexclude=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep -v passed | awk '{print $2}' | wc | awk '{print $1}')

        echo "There are $totalexclude variants from $prefix sumstats that were excluded from the QC procedures carried out as part of the current pipeline" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Dupvar

        cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | awk '{print $2}' | uniq -c | awk '{if($1>1) print $0}' > $prefix.dupvar.txt

        dupvar=$(wc $prefix.dupvar.txt | awk '{print $1}')

        echo "Note that there are $dupvar variants that are duplicated - please check if these might be relevant for your purposes" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log


    # From final QC file 
        # Total number of variants passing QC
        sumstats_ref_finalqc=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt | sed '1,1d' | awk '{print $5}' | wc | awk '{print $1}')

        echo "There are $sumstats_ref_finalqc variants that passed QC procedures" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log


######################################