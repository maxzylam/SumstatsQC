#!/bin/bash

######################################
#### SumstatsQC Dev version 2 ########
#### Merge sumstats with ref by chr ##
#### required parameters :           #
#### sumstats                        #
#### pop                             #
#### prefix                          #
######################################

######################################
##### Define help script #############


    function helpscript {
        echo "This module would merge the various versions of the"
        echo "processed reference panel with the sumstats"
        echo "Note: This module is going to be very slow if one is using"
        echo "a single core CPU"
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


    echo "##################################" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
    echo "### RefSumstats Merging ...    ###" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
    echo "##################################" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log

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
#### Merge Ref and sumstats ##########
        
        # Exact Match
        for i in {1..22}
                do  
                echo "awk 'NR==FNR{s=\$1;a[s]=\$0;next} a[\$1]{print \$0 \" \" a[\$1]}' "$sumstats_1".qc.input."$pop".sumstats.3.chr"$i" $REFFILE.$prefix.match.chr"$i" > "$sumstats_1".qc.input."$pop".sumstats.ref.4.match.chr"$i""
        done > $prefix.RefSumstats_merge1.sh

        # Allele flip 
        for i in {1..22}
                do  
                echo "awk 'NR==FNR{s=\$1;a[s]=\$0;next} a[\$1]{print \$0 \" \" a[\$1]}' "$sumstats_1".qc.input."$pop".sumstats.3.chr"$i" $REFFILE.$prefix.alleleflip.chr"$i" > "$sumstats_1".qc.input."$pop".sumstats.ref.4.flip.chr"$i""
        done >> $prefix.RefSumstats_merge2.sh

        # Alt Strand 
        for i in {1..22}
                do  
                echo "awk 'NR==FNR{s=\$1;a[s]=\$0;next} a[\$1]{print \$0 \" \" a[\$1]}' "$sumstats_1".qc.input."$pop".sumstats.3.chr"$i" $REFFILE.$prefix.altstrand.chr"$i" > "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrand.chr"$i""
        done >> $prefix.RefSumstats_merge3.sh
        
        # Alt Strand Allele Flip
        for i in {1..22}
                do  
                echo "awk 'NR==FNR{s=\$1;a[s]=\$0;next} a[\$1]{print \$0 \" \" a[\$1]}' "$sumstats_1".qc.input."$pop".sumstats.3.chr"$i" $REFFILE.$prefix.altstrandflp.chr"$i" > "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrandflp.chr"$i""
        done >> $prefix.RefSumstats_merge4.sh

        #### Execute merge >>>>
        
        if [ "$multicpu" == "Y" ]; then
        
                cat $prefix.RefSumstats_merge1.sh | awk '{print $0, "&"}' > $prefix.RefSumstats_merge1_multicpu.sh
                cat $prefix.RefSumstats_merge2.sh | awk '{print $0, "&"}' > $prefix.RefSumstats_merge2_multicpu.sh
                cat $prefix.RefSumstats_merge3.sh | awk '{print $0, "&"}' > $prefix.RefSumstats_merge3_multicpu.sh
                cat $prefix.RefSumstats_merge4.sh | awk '{print $0, "&"}' > $prefix.RefSumstats_merge4_multicpu.sh
                chmod +x *.sh
                echo "merging sumstats..."
        else
                chmod +x *.sh
                echo "merging sumstats..."
        fi


######################################

######################################
#### Consolidate merged variants #####

        # Print match variants
        for i in {1..22}
                do 
                echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.match.chr"$i" | awk '{print \$1}' | sed '1,1d' >> $prefix.matched.variants.txt"
        done > $prefix.consolidate.matched.var1.sh

        # Print Allele flip variants
        for i in {1..22}
                do 
                echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.flip.chr"$i" | awk '{print \$1}' | sed '1,1d' >> $prefix.matched.variants.txt"
        done >> $prefix.consolidate.matched.var2.sh

        # Print Alt Strand variants
        for i in {1..22}
                do 
                echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrand.chr"$i" | awk '{print \$1}' | sed '1,1d' >> $prefix.matched.variants.txt"
        done >> $prefix.consolidate.matched.var3.sh

        # Print Alt Strand Flip variants
        for i in {1..22}
                do 
                echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrandflp.chr"$i" | awk '{print \$1}' | sed '1,1d' >> $prefix.matched.variants.txt"
        done >> $prefix.consolidate.matched.var4.sh       


        # Sort Uniq
                echo "cat $prefix.matched.variants.txt | sort | uniq -c | awk '{print \$2}' >> $prefix.matched.variants.uniq.txt" > $prefix.consolidate.match.var.uniq.sh
                chmod +x *.sh
######################################

######################################
#### Read out unmatched vars #########

        # Read unmatched variants
        for i in {1..22}
        do 
                echo "awk 'FNR==NR{a[\$1]++;next}XXXa[\$1]' $prefix.matched.variants.uniq.txt "$sumstats_1".qc.input."$pop".sumstats.3.chr"$i" > "$sumstats_1".qc.input."$pop".sumstats.ref.4.unmatched.chr"$i""
        done | sed 's/XXX/\!/g' > $prefix.reverse.matching.sh

        #vim $prefix.reverse.matching.sh -c ":%s/XXX/\!/g" -c ":wq"

        
        # Execute code for unmatched variants
        if [ "$multicpu" == "Y" ]; then 
                cat $prefix.reverse.matching.sh | awk '{print $0, "&"}' > $prefix.reverse.matching_multicpu.sh
                chmod +x *.sh
                echo "identifying unmatched variants"
        else 
                chmod +x *.sh
                echo "identifying unmatched variants"
        fi
######################################