#!/bin/bash

######################################
#### SumstatsQC Dev version 2 ########
#### Quality control parameters ######
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
        echo "This is the module where QC parameters are implemented"
        echo "flag options are dependent on the main module"
        echo ""
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
                --AMB)
                        AMB=$VALUE
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


    echo "##################################" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
    echo "### SumstatsQC QC param ...    ###" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
    echo "##################################" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log

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
#### AMB flip var ####################

    AMBflip=$(awk -v AMB=$AMB 'BEGIN{print 1-AMB}')
    AFflip=$(awk -v AF=$AF 'BEGIN{print 1-AF}')

#######################################
#### Process parameters ###############

    # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-UID 10-SNP 11-CHR 12-BP 13-A1 14-A2 15-FRQ 16-INFO 17-OR 18-SE 19-P 20-Nca 21-Nco 22-Z [Binary Trait]
    # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-UID 10-SNP 11-CHR 12-BP 13-A1 14-A2 15-FRQ 16-INFO 17-BETA 18-SE 19-P 20-NSample 21-Z [Quantitative Trait]

    # Calculate FRQ v F1 difference [col 23]
        # sqrt(($6-F1 - $15-FRQ)^2)
    # Identify Ambiguous SNPs [col 24]
        # if($4=="A" && $5=="T") print $0, "ambiguous_allele"; 
        #    else if($4=="T" && $5=="A") print $0, "ambiguous_allele"; 
        #    else if($4=="C" && $5=="G") print $0, "ambiguous_allele"; 
        #    else if($4=="G" && $5=="C") print $0, "ambiguous_allele"; 
        #    else print $0, "OK"}'
    # Identify variants that fail AF [col 25]
    # Identify variants that fail INFOSc [col 26]
    # Identify variants that fail AFB  [col 27]

    # Note after QC apply headers would be as follows
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-UID 10-SNP 11-CHR 12-BP 13-A1 14-A2 15-FRQ 16-INFO 17-OR 18-SE 19-P 20-Nca 21-Nco 22-Z 23-AFdiff 24-AT_CG 25-AF_qc 26-INFOSc_qc 27-AFB_qc 28-AMB_qc [Binary Trait]
        # 1-UID 2-UIDref 3-SNP 4-A1 5-A2 6-F1 7-F2 8-Status 9-UID 10-SNP 11-CHR 12-BP 13-A1 14-A2 15-FRQ 16-INFO 17-BETA 18-SE 19-P 20-NSample 21-Z 22-AFdiff 23-AT_CG 24-AF_qc 25-INFOSc_qc 26-AFB_qc 27-AMB_qc [Quantitative Trait]

        # apply parameters to matched variants
    if [ "$qt" == "Binary" ]; then   
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.match.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF && \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$23 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$24 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.match.qcparams.chr"$i""
        done > $prefix.QCapply.match.sh
        # apply paramenters to allele flip variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.flip.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$23 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$24 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.flip.qcparams.chr"$i""
        done > $prefix.QCapply.flip.sh
        # apply paramenters to alt strand variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrand.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$23 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$24 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.altstrand.qcparams.chr"$i""
        done > $prefix.QCapply.altstrand.sh
        # apply paramenters to alt strand flip variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrandflp.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$23 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$24 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.altstrandflp.qcparams.chr"$i""
        done > $prefix.QCapply.altstrandflp.sh
    fi

    if [ "$qt" == "Quantitative" ]; then 
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.match.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$22 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$23 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.match.qcparams.chr"$i""
        done > $prefix.QCapply.match.sh
        # apply paramenters to allele flip variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.flip.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$22 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$23 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.flip.qcparams.chr"$i""
        done > $prefix.QCapply.flip.sh
        # apply paramenters to alt strand variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrand.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$22 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$23 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.altstrand.qcparams.chr"$i""
        done > $prefix.QCapply.altstrand.sh
        # apply paramenters to alt strand flip variants
        for i in {1..22}
            do 
            echo "cat "$sumstats_1".qc.input."$pop".sumstats.ref.4.altstrandflp.chr"$i" | sed '1,1d' | awk '{print \$0, sqrt((\$6 - \$15)^2)}' | awk '{if(\$4==\"A\" && \$5==\"T\") print \$0, \"ambiguous\"; else if(\$4==\"T\" && \$5==\"A\") print \$0, \"ambiguous\"; else if(\$4==\"C\" && \$5==\"G\") print \$0, \"ambiguous\"; else if(\$4==\"G\" && \$5==\"C\") print \$0, \"ambiguous\"; else print \$0, \"OK\"}' | awk '{if(\$15 < $AF || \$15 > $AFflip) print \$0, \"AF_fail\"; else print \$0, \"OK\"}' | awk -v INFOSc=$INFO_score '{if(\$16 < INFOSc) print \$0, \"INFOSc_fail\"; else print \$0, \"OK\"}' | awk -v AFB=$AFB '{if(\$22 > AFB) print \$0, \"AFB_fail\"; else print \$0, \"OK\"}' | awk '{if(\$23 == \"ambiguous\" && \$15 > $AMB && \$15 < $AMBflip) print \$0, \"amb_fail\"; else print \$0, \"OK\"}' > "$sumstats_1".qc.input."$pop".sumstats.ref.5.altstrandflp.qcparams.chr"$i""
        done > $prefix.QCapply.altstrandflp.sh
    fi
    # Write multicpu code and use where appropriate

    if [ "$multicpu" == "Y" ]; then 
        cat $prefix.QCapply.match.sh | awk '{print $0, "&"}' > $prefix.QCapply.match_multicpu.sh
        cat $prefix.QCapply.flip.sh | awk '{print $0, "&"}' > $prefix.QCapply.flip_multicpu.sh
        cat $prefix.QCapply.altstrand.sh | awk '{print $0, "&"}' > $prefix.QCapply.altstrand_multicpu.sh
        cat $prefix.QCapply.altstrandflp.sh | awk '{print $0, "&"}' > $prefix.QCapply.altstrandflp_multicpu.sh
        chmod +x *.sh
        echo "applying QC paramenters to summary statistics..."
    else 
        chmod +x *.sh
        echo "applying QC paramenters to summary statistics..."
    fi


#######################################