#!/bin/bash

######################################
#### SumstatsQC Dev version 2 ########
#### Processing of Ref Panels ########
#### Required parameters :           #
#### pop                             #
#### sumstats                        #
#### prefix                          #
#### multicpu                        #
######################################

######################################
##### Define help script #############


    function helpscript {
        echo " This is the second module of the SumstatsQC pipeline"
        echo " The flags are dependent on the main module"
        echo " In this module the chosen reference panel would be processed"
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

        echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "##################################" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "### Reference panel munging... ###" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "##################################" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log

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
                #echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

        elif [ "$pop" = "1000g_eas" ]; then
                REFFILE=1000G.EAS.ref
                echo "You have indicated $pop"
                # write ref selection to logfile 
                #echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

        elif [ "$pop" = "hrc_eur" ]; then
                REFFILE=HRC.EUR.ref
                echo "You have indicated $pop"
                # write ref selection to logfile 
                #echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

        elif [ "$pop" = "sg10k_eas" ]; then
                REFFILE=SG10k.EAS.ref
                echo "You have indicated $pop"
                # write ref selection to logfile 
                #echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

        else 
                echo "Other populations are coming your way"
                exit 1

        fi


######################################

######################################
#### Process refpanel ################


    # 1SNP 2N1 3A1 4F1 5SE1 6A2 7F2 8SE2 9N2 10CHR 11BP > 
    # UID 1-SNP 3-A1 6-A2 4-F1 7-F2 Status
    
    # allele 'match' 
    for i in {1..22}
        do 
        echo "zcat $REFFILE.chr"$i".gz | sed '1,1d' | awk '{print \$10\":\"\$11\":\"\$3\":\"\$6, \$10\":\"\$11\":\"\$3\":\"\$6, \$1, \$3, \$6, \$4, \$7, \"match\"}' | sed '1 i\UID UIDref SNP A1 A2 F1 F2 Status' > $REFFILE.$prefix.match.chr"$i""
    done > $prefix.process_ref_panel.sh

    # 'allele flip'
    # UID 1-SNP 6-A2 3-A1 7-F2 4-F1 Status > note: head is changed to F1 F2 A1 A2 
    for i in {1..22}
        do 
        echo "zcat $REFFILE.chr"$i".gz | sed '1,1d' | awk '{print \$10\":\"\$11\":\"\$6\":\"\$3, \$10\":\"\$11\":\"\$3\":\"\$6, \$1, \$6, \$3, \$7, \$4, \"allele_flip\"}' | sed '1 i\UID UIDref SNP A1 A2 F1 F2 Status' > $REFFILE.$prefix.alleleflip.chr"$i""
    done >> $prefix.process_ref_panel.sh

    # 1SNP 2N1 3A1 4F1 5SE1 6A2 7F2 8SE2 9N2 10CHR 11BP > 
    # 1SNP 2N1 3A1 4F1 5SE1 6A2 7F2 8SE2 9N2 10CHR 11BP 12A1strand- 13A2strand- >
    # UID 1-SNP 3-A1 6-A2 4-F1 7-F2 Status > UID = CHR:BP:StrandA1:StrandA2
    # 'alt strand'
    for i in {1..22}
        do 
        echo "zcat $REFFILE.chr"$i".gz | sed '1,1d' | awk '{if(\$3==\"A\") print \$0, \"T\"; else if (\$3==\"C\") print \$0, \"G\"; else if (\$3==\"G\") print \$0, \"C\"; else if(\$3==\"T\") print \$0, \"A\"; else print \$0, \"NA\"}' | awk '{if(\$6==\"A\") print \$0, \"T\"; else if (\$6==\"C\") print \$0, \"G\"; else if (\$6==\"G\") print \$0, \"C\"; else if (\$6==\"T\") print \$0, \"A\"; else print \$0, \"NA\"}' | awk '{print \$10\":\"\$11\":\"\$12\":\"\$13, \$10\":\"\$11\":\"\$3\":\"\$6, \$1, \$3, \$6, \$4, \$7, \"altstrand\"}' | sed '1 i\UID UIDref SNP A1 A2 F1 F2 Status' > $REFFILE.$prefix.altstrand.chr"$i""
    done >> $prefix.process_ref_panel.sh

    # 'alt strand flip'
    # UID 1-SNP 6-A2 3-A1 7-F2 4-F1 Status > note: head is changed to F1 F2 A1 A2 
    # UID = CHR:BP:StrandA2:StrandA1
    for i in {1..22}
        do 
        echo "zcat $REFFILE.chr"$i".gz | sed '1,1d' | awk '{if(\$3==\"A\") print \$0, \"T\"; else if (\$3==\"C\") print \$0, \"G\"; else if (\$3==\"G\") print \$0, \"C\"; else if(\$3==\"T\") print \$0, \"A\"; else print \$0, \"NA\"}' | awk '{if(\$6==\"A\") print \$0, \"T\"; else if (\$6==\"C\") print \$0, \"G\"; else if (\$6==\"G\") print \$0, \"C\"; else if (\$6==\"T\") print \$0, \"A\"; else print \$0, \$6}' | awk '{print \$10\":\"\$11\":\"\$13\":\"\$12, \$10\":\"\$11\":\"\$3\":\"\$6, \$1, \$6, \$3, \$7, \$4, \"altstrandflp\"}' | sed '1 i\UID UIDref SNP A1 A2 F1 F2 Status' > $REFFILE.$prefix.altstrandflp.chr"$i""
    done >> $prefix.process_ref_panel.sh

    # Processing reference panel >>> 
        # 
        if [ "$multicpu" == "Y" ]; then
        
                cat $prefix.process_ref_panel.sh | awk '{print $0, "&"}' > $prefix.process_ref_panel_multicpu.sh
                chmod +x *.sh
                echo "Starting refpanel munge..." 
        else
                chmod +x *.sh
                echo "Starting refpanel munge..."
        
        fi



######################################
