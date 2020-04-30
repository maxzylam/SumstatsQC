#!/bin/bash

######################################
#### SumstatsQC Dev version 2 ########
#### Post processing step       ######
#### required parameters :           #
#### sumstats                        #
#### pop                             #
#### prefix                          #
#### AF                              #
#### INFO_score                      #
#### AFB                             #
######################################

# Notes: Have to sync the headers with the previous modules
# also have to consider having a file that show the variants that either failed QC 
# Or were excluded because they did not match with the reference panel. 

######################################
##### Define help script #############


    function helpscript {
        echo "This is the postprocessing module"
        echo "The module contains scripts that consolidate files across chr"
        echo "There should be several main outputs"
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


    echo "############################################" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
    echo "### SumstatsQC QC post processing ...    ###" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
    echo "############################################" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log

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
#### Post processing procedures ######
# Note after QC apply headers would be as follows
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc [Binary Trait]
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc [Quantitative Trait]

    # Consolidate processed files 
    
    if [ "$qt" == "Binary" ]; then 

        # Original non-qc-ed files (autosomes only)
        echo "UID SNP CHR BP A1 A2 FRQ INFO OR SE P Nca Nco Z" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.non-qc-ed.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i" | sed '1,1d' | awk '{if(\$11 > 0) print \$0}' | awk '{if(\$11 <= 1) print \$0}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.non-qc-ed.txt"
        done > $prefix.consolidate.processed.files.sh

        # out of bound pvalues
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i" | sed '1,1d' | awk '{if(\$11 <= 0) print \$0}' | awk '{if(\$11 > 1) print \$0}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.OB_pval.txt"
        done >> $prefix.consolidate.processed.files.sh

        # unmatched variants
        echo "UID SNP CHR BP A1 A2 FRQ INFO OR SE P Nca Nco Z Status" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.4.unmatched.chr"$i" | sed '1,1d' | awk '{print \$0, \"unmatched\"}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt"
        done >> $prefix.consolidate.processed.files.sh
 
        # Ref - Sumstats - Direct Match
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstat - Allele Flip 
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstats - altstrand
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc"  > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstats - altstrandflip
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc"  > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

    elif [ "$qt" == "Quantitative" ]; then
        
        # Original non-qc-ed files (autosomes only)
        echo "UID SNP CHR BP A1 A2 FRQ INFO BETA SE P NSample Z" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.non-qc-ed.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i" | sed '1,1d' | awk '{if(\$11 > 0) print \$0}' | awk '{if(\$11 <= 1) print \$0}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.non-qc-ed.txt"
        done > $prefix.consolidate.processed.files.sh

        # out of bound pvalues
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr"$i" | sed '1,1d' | awk '{if(\$11 <= 0) print \$0}' | awk '{if(\$11 > 1) print \$0}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.5.OB_pval.txt"
        done >> $prefix.consolidate.processed.files.sh

        # unmatched variants
        echo "UID SNP CHR BP A1 A2 FRQ INFO OR SE P NSample Z Status" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.4.unmatched.chr"$i" | sed '1,1d' | awk '{print \$0, \"unmatched\"}' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt"
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstats - Direct Match
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt

        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstat - Allele Flip 
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc" > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstats - altstrand
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc"  > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

        # Ref - Sumstats - altstrandflip
        echo "1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc"  > "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt
        
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.chr"$i" | sed '1,1d' >> "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt" 
        done >> $prefix.consolidate.processed.files.sh

    else
 
        echo ""
        echo "********************************************"
        echo "Can you tell me what type of sumstats you are trying to process??"
        echo "You can either use [Binary] or [Quantitative] - those are the only types I understand."
        echo "Thanks."
        echo "********************************************"
            helpscript
        exit 1

 
    fi

    # Read out QC passed variants 
    # Processed passed variants - align with minor allele
    # Filter using grep -v fail
    # [Binary]
        # Note after QC apply headers would be as follows
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc [Binary Trait]

    # >>> NEW cols <<<

        # 2-UID0 1-UID1 10-CHR:11-BP:4-A1:5-A2(UID2) 3-SNPref 9-SNP 10-CHR 11-BP 4-A1 5-A2 6-F1ref 14-FRQ 8-Status 15-INFO 16-OR 17-SE 18-P 19-Nca 20-Nco 21-Z 22-minuslog10P
    
    # [Quantitative]
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-SNP 10-CHR 11-BP 12-A1 13-A2 14-FRQ 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-AFdiff 22-AT_CG 23-AF_qc 24-INFOSc_qc 25-AFB_qc 26-AMB_qc [Quantitative Trait]

    # >>> NEW cols <<<

        # 2-UID0 1-UID1 10-CHR:11-BP:4-A1:5-A2(UID2) 3-SNPref 9-SNP 10-CHR 11-BP 4-A1 5-A2 6-F1ref 14-FRQ 8-Status 15-INFO 16-BETA 17-SE 18-P 19-NSample 20-Z 21-minuslog10P

    if [ "$qt" == "Binary" ]; then 

        # write header 
        echo "UID0 UID1 UID2 SNPref SNP CHR BP A1 A2 F1ref FRQ QCStatus INFO OR SE P Nca Nco Z minuslog10P" > $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt

        # match 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,\$21,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,\$20,(-1*\$21),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" > $prefix.merge.sumstatsqc.out.sh

        # flip 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,\$21,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,\$20, (-1*\$21),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # altstrand 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,\$21,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,\$20,(-1*\$21),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # altstrandflp
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,\$21,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,\$20,(-1*\$21),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # sort by CHR BP finalqc

        echo "cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt | awk '{if(\$1==\$2) print \$1,\$2,\$2,\$4,\$5,\$6,\$7,\$9,\$8,(1-\$10),(1-\$11),\$12,\$13,(-1*\$14),\$15,\$16,\$17,\$18,(-1*\$19),\$20; else if(\$2==\$3) print \$1,\$2,\$1,\$4,\$5,\$6,\$7,\$9,\$8,(1-\$10),(1-\$11),\$12,\$13,(-1*\$14),\$15,\$16,\$17,\$18,(-1*\$19),\$20; else print \$0}' | grep -v NA | grep -v na | grep -v Inf | grep -v inf | sed '1,1d' | sort -k 6 -g -k 7 -g | sed '1 i\UID0 UID1 UID2 SNPref SNP CHR BP A1 A2 F1ref FRQ QCStatus INFO OR SE P Nca Nco Z minuslog10P' > $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt" > $prefix.sort.sumstatsqc.out.sh

    elif [ "$qt" == "Quantitative" ]; then

        # write header 
        echo "UID0 UID1 UID2 SNPref SNP CHR BP A1 A2 F1ref FRQ QCStatus INFO BETA SE P NSample Z minuslog10P" > $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt

        # match 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,(-1*\$20),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" > $prefix.merge.sumstatsqc.out.sh

        # flip 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,(-1*\$20),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # altstrand 
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,(-1*\$20),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # altstrandflp
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt | sed '1,1d' | grep -v fail | awk '{if(\$14 < 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$4\":\"\$5), \$3,\$9,\$10,\$11,\$4,\$5,\$6,\$14,\$8,\$15,\$16,\$17,\$18,\$19,\$20,(-1*log(\$18)/log(10)); else if(\$14 > 0.50) print \$2, \$1,(\$10\":\"\$11\":\"\$5\":\"\$4),\$3,\$9,\$10,\$11,\$5,\$4,(1-\$6),(1-\$14),\$8,\$15,(-1*\$16),\$17,\$18,\$19,(-1*\$20),(-1*log(\$18)/log(10))}' >> $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt" >> $prefix.merge.sumstatsqc.out.sh

        # sort by CHR BP 

        #echo "cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt | grep -v NA | grep -v na | grep -v Inf | grep -v inf | sed '1,1d' | sort -k 6 -g -k 7 -g | sed '1 i\UID0 UID1 UID2 SNPref SNP CHR BP A1 A2 F1ref FRQ QCStatus INFO BETA SE P NSample Z minuslog10P' > $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt" > $prefix.sort.sumstatsqc.out.sh

        echo "cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.txt | awk '{if(\$1==\$2) print \$1,\$2,\$2,\$4,\$5,\$6,\$7,\$9,\$8,(1-\$10),(1-\$11),\$12,\$13,(-1*\$14),\$15,\$16,\$17,(-1*\$18),\$19; else if(\$2==\$3) print \$1,\$2,\$1,\$4,\$5,\$6,\$7,\$9,\$8,(1-\$10),(1-\$11),\$12,\$13,(-1*\$14),\$15,\$16,\$17,(-1*\$18),\$19; else print \$0}' | grep -v NA | grep -v na | grep -v Inf | grep -v inf | sed '1,1d' | sort -k 6 -g -k 7 -g | sed '1 i\UID0 UID1 UID2 SNPref SNP CHR BP A1 A2 F1ref FRQ QCStatus INFO BETA SE P NSample Z minuslog10P' > $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt" > $prefix.sort.sumstatsqc.out.sh

    
    else
 
        echo ""
        echo "********************************************"
        echo "Can you tell me what type of sumstats you are trying to process??"
        echo "You can either use [Binary] or [Quantitative] - those are the only types I understand."
        echo "Thanks."
        echo "********************************************"
            helpscript
        exit 1

 
    fi

    # Identify variants (autosome only) that were excluded from SumstatsQC procedures
    # 
    for i in {1..22}
        do 
        echo "cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt | awk '{if(\$6=="$i") print \$2}' > $prefix.qc.vars.chr"$i"" 
    done > $prefix.variants.qc.sh

    for i in {1..22}
        do
        echo "cat $sumstats_1.qc.input.$pop.$prefix.sumstats.5.non-qc-ed.txt | awk '{if(\$3=="$i") print \$1}' > $prefix.nonqc.vars.chr"$i"" 
    done > $prefix.variants.nonqc.sh
    
    for i in {1..22}
        do
        echo "awk 'FNR==NR{a[\$1]++;next}XXXa[\$1]' $prefix.qc.vars.chr"$i" $prefix.nonqc.vars.chr"$i" >> $prefix.excluded.variants.chr"$i""
    done | sed 's/XXX/\!/g' > $prefix.excluded.variants.sh 

    echo "UID" > $prefix.excluded.variants.txt
    for i in {1..22}
        do 
        echo "cat $prefix.excluded.variants.chr"$i" >> $prefix.excluded.variants.txt"
    done > $prefix.cat.excluded.variants.sh

    if [ "$multicpu" == "Y" ]; then 
        cat $prefix.variants.qc.sh | awk '{print $0, "&"}' > $prefix.variants.qc.multicpu.sh
        cat $prefix.variants.nonqc.sh | awk '{print $0, "&"}' > $prefix.variants.nonqc.multicpu.sh
        cat $prefix.excluded.variants.sh | awk '{print $0, "&"}' > $prefix.excluded.variants.multicpu.sh
    fi

    # characterize failed variants
    # Extract unmatched, failed vars for each categories
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.unmatched.qcparams.txt | sed '1,1d' | awk '{print \$1, \$11}' | sed '1 i\UID Punmatched' > $prefix.unmatched.vars.qcexclude.txt" > $prefix.extract.failed.vars.sh

    if [ "$qt" == "Binary" ]; then    
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$24, \$25, \$26, \$27}' | sed '1 i\UID Pmatch AFmatch INFOmatch AFBmatch AMBmatch' > $prefix.matched.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$24, \$25, \$26, \$27}' | sed '1 i\UID Pflip AFflip INFOflip AFBflip AMBflip' > $prefix.flip.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$24, \$25, \$26, \$27}' | sed '1 i\UID Pstrand AFstrand INFOstrand AFBstrand AMBstrand' > $prefix.altstrand.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$24, \$25, \$26, \$27}' | sed '1 i\UID Pstrandflp AFstrandflp INFOstrandflp AFBstrandflp AMBstrandflp' > $prefix.altstrandflp.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
    fi

    if [ "$qt" == "Quantitative" ]; then
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.match.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$23, \$24, \$25, \$26}' | sed '1 i\UID Pmatch AFmatch INFOmatch AFBmatch AMBmatch' > $prefix.matched.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.flip.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$23, \$24, \$25, \$26}' | sed '1 i\UID Pflip AFflip INFOflip AFBflip AMBflip' > $prefix.flip.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrand.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$23, \$24, \$25, \$26}' | sed '1 i\UID Pstrand AFstrand INFOstrand AFBstrand AMBstrand' > $prefix.altstrand.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh
        echo "cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.5.altstrandflp.qcparams.txt | grep fail | sed '1,1d' | awk '{print \$1, \$18, \$23, \$24, \$25, \$26}' | sed '1 i\UID Pstrandflp AFstrandflp INFOstrandflp AFBstrandflp AMBstrandflp' > $prefix.altstrandflp.vars.qcexclude.txt" >> $prefix.extract.failed.vars.sh

    fi

        echo "cat $prefix.excluded.variants.txt | sed '1,1d' | tr ':' ' ' | awk '{print \$1\":\"\$2\":\"\$3\":\"\$4, \$0}' | sed '1 i\UID CHR BP A1 A2' > $prefix.excluded.variants.chrbp.txt" >> $prefix.extract.failed.vars.sh

    if [ "$multicpu" == "Y" ]; then
        cat $prefix.extract.failed.vars.sh | awk '{print $0, "&"}' > $prefix.extract.failed.vars.multicpu.sh
    fi 

### Merge failed vars files

DIRECTORY=$(echo $PWD | sed 's_/_\\/_g')
EXVARS=$prefix.excluded.variants.chrbp.txt
UNMEX=$prefix.unmatched.vars.qcexclude.txt
MATCHEX=$prefix.matched.vars.qcexclude.txt
FLIPEX=$prefix.flip.vars.qcexclude.txt
STRANDEX=$prefix.altstrand.vars.qcexclude.txt
STRANDFLPEX=$prefix.altstrandflp.vars.qcexclude.txt
OUTEX=$prefix.excluded.variants.merged.txt

cat > merge_failed_vars << writescript

#! /usr/bin/Rscript

## Load R packages for Merging Files 

if(require("data.table")){
    print("data.table is loaded correctly")
} else {
    print("trying to install data.table")
    install.packages("data.table")
    if(require(data.table)){
        print("data.table installed and loaded")
    } else {
        stop("could not install data.table")
    }
}

if(require("dplyr")){
    print("dplyr is loaded correctly")
} else {
    print("trying to install data.table")
    install.packages("dplyr")
    if(require(dplyr)){
        print("dplyr installed and loaded")
    } else {
        stop("could not install dplyr")
    }
}

if(require("tidyr")){
    print("tidyr is loaded correctly")
} else {
    print("trying to install data.table")
    install.packages("tidyr")
    if(require(tidyr)){
        print("tidyr installed and loaded")
    } else {
        stop("could not install tidy")
    }
}

exvars <- fread("/DIRECTORY/EXVARS")
unmex <- fread("/DIRECTORY/UNMEX")
matchex <- fread("/DIRECTORY/MATCHEX")
flipex <- fread("/DIRECTORY/FLIPEX")
strandex <- fread("/DIRECTORY/STRANDEX")
strandflpex <- fread("/DIRECTORY/STRANDFLPEX")

merge1 <- full_join(exvars, unmex, by = "UID")
merge2 <- full_join(merge1, matchex, by = "UID")
merge3 <- full_join(merge2, flipex, by = "UID")
merge4 <- full_join(merge3, strandex, by = "UID")
merge5 <- full_join(merge4, strandflpex, by = "UID")

fwrite(merge5, file="/DIRECTORY/OUTEX", quote=FALSE, compress="none", sep=" ", na="NA")

writescript

dos2unix merge_failed_vars 

echo "cat merge_failed_vars | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/EXVARS/$EXVARS/g' | sed 's/UNMEX/$UNMEX/g' | sed 's/MATCHEX/$MATCHEX/g' | sed 's/FLIPEX/$FLIPEX/g' | sed 's/STRANDEX/$STRANDEX/g' | sed 's/STRANDFLPEX/$STRANDFLPEX/g' | sed 's/OUTEX/$OUTEX/g' > $prefix.merge_failed.vars.r" > $prefix.make.merge_failed.vars.sh

echo "R CMD BATCH --no-save $prefix.merge_failed.vars.r" >> $prefix.make.merge_failed.vars.sh


# Sanity checks
    # make code executable 

    chmod +x *.sh

    echo "initiating post-processing..."

######################################