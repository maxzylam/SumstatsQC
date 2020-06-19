#!/bin/bash

###############################################################
#### SumstatsQC Dev version 2 #################################
###############################################################

################################################################
##### Define help script #######################################
    # Notes: This is the main module of the sumstats QC pipeline
    # [module 1]
    # This module will perform basic functions for sumstatsQC 
    # for more complicated functions, the modules sources external scripts from 
    # other modules

    function helpscript {
        echo ""
        echo ""
        echo "This script will help process reference panels" 
        echo "on GWAS summary statistics for downstream analysis"
        echo ""
        echo "Please run the script as follows"
        echo ""
        echo "./SumstatsQC.sh [OPTIONS]"
        echo ""
        echo "  --help                              ### show this help and exit"
        echo "  --batch={Y|N}                       ### use batch column definition"
        echo "  --batchfile={batch.txt}             ### batch column definitions"
        echo "  --sumstats={sumstatsfile.gz}        ### summary statistics"
        echo "  --qt={Binary|Quantitative}          ### Types of traits"
        echo "  --pop={1000g_eas|1000g_eur|sg10k_eas|hrc_eur} ### string based on 1000G/HRC/SG10K"
        echo "  --INFO_score=0.3                    ### Imputation quality score could also be Rsq, default=0.3"
        echo "  --AF=0.005                          ### Effect Allele frequency, default=0.005"
        echo "  --AFB=0.15                          ### Allele frequency band, default=0.15"
        echo "  --AMB=0.35                           ### Ambiguous allele AF threshold, default=0.35"
        echo "  --prefix={prefix}                   ### phenotype name"
        echo "  --multicpu={Y/N}                    ### allow multiple cpus for processing"
        echo ""
        echo ""
        echo "exiting ..."
        echo ""
        echo ""
    }
######ok########################################################

###############################################################
#### Default parameters #######################################


 INFO_score=0.3
 AF=0.005
 AFB=0.15
 AMB=0.35
 DATE=$(date)
 USER=$(id -u -n)

######ok#######################################################

###############################################################
#### Assigned User parameters #################################



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

#####ok########################################################

###############################################################
#### Write Log File Header Here ###############################


    echo "################################" 2>&1 | tee $prefix.sumstats_qc.log
    echo "### SUMSTATS QUALITY CONTROL ###" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Analyst Initials : $USER" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Sumstats QC for $sumstats intiated on $DATE" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Welcome to SumstatsQC! ---" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "This pipeline would perform the following functions: " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "1. Summary statistics columns are first standardized based on either a batch.txt file" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   that describes the columns within a large number of summary statistics. Or if the " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   user is just QC-ing one set of summary statistics there is an interactive mode    " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   available to define columns on the fly." 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "2. Users have four options of reference panels to choose from 1000 genomes EUR;      " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   1000 genomes EAS; SG10K EAS and HRC EAS for their QC purposes. Users are advised  " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   to perform their QC on each of these reference panels to see which option best    " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   suit their summary statistics." 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log

    # Checking presence of sumstats file - Terminate at this point if sumstats file is not found
    if [ ! -f $sumstats ]; then
     echo "sumstats file not found!"
     echo "Please indicate your input sumstats file for processing"
     helpscript
     exit 1
    fi

    # Assign token to sumstats if sumstatsfile is found
    sumstats_1=$(echo "$sumstats" | sed 's/.gz//g')

#####ok########################################################

###############################################################
#### Assign summary stats column numbers for QC procedures ####

    if [ "$batch" = "Y" ]; then

        # Checking presence of batchfile - Terminate at this point if batchfile is not found
        if [ ! -f $batchfile ]; then
            echo "batchfile is not found!"
            echo "Please indicate --batch=N if you don't have an accompanying batchfile"
            echo "A batchfile is a plain text file with two columns"
            echo "the first column consists of the header names"
            echo "the second column consists of the respective numerical column number"
            exit 1
        fi
 
        # Assign column numbers based on the external batch file
        SNP=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '1,1p')
        CHR=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '2,2p')
        BP=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '3,3p')
        A1=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '4,4p')
        A2=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '5,5p')
        FRQ=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '6,6p')
        INFO=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '7,7p')
        OR=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '8,8p')
        SE=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '9,9p')
        PVAL=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '10,10p')
        Nca=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '11,11p')
        Nco=$(cat "$batchfile" | cut -d ' ' -f2 | sed -n '12,12p')

        # write assigned columns to logfile
        echo "Columns read from batch columns" 2>&1 | tee -a $prefix.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.sumstats_qc.log

    elif [ "$batch" = "N" ]; then

        echo "if you did not process sumstats based on batch columns" 2>&1 | tee -a $prefix.sumstats_qc.log
        echo "we will ask you a few questions before proceeding..." 2>&1 | tee -a $prefix.sumstats_qc.log
        echo ""
        zcat $sumstats | head -1 | tr ' ' '\n' | cat -n 2>&1 | tee -a $prefix.sumstats_qc.log
        echo ""
        echo "Can you confirm the following..."
        echo "You can hit ctrl+c if you make a mistake and then re-run the script...."
        echo ""
        echo "what's the SNP column number in your sumstats?"
        read SNP
        echo "what's the CHR column number in your sumstats?"
        read CHR
        echo "what's the BP column number in your sumstats?"
        read BP
        echo "what's the A1 column number in your sumstats?"
        read A1
        echo "what's the A2 column number in your sumstats?"
        read A2
        echo "what's the FRQ column number in your sumstats?"
        read FRQ
        echo "what's the INFO column number in your sumstats?"
        read INFO
        echo "what's the OR/BETA column number in your sumstats?"
        read OR
        echo "what's the SE column number in your sumstats?"
        read SE
        echo "what's the PVAL column number in your sumstats?"
        read PVAL
        echo "what's the Nca column number in your sumstats? Enter 0 if qt"
        read Nca
        echo "what's the Nco/N_qt column number in your sumstats?"
        read Nco

        else
        echo "You did not enter the appropriate parameters...Thank you please try again...."
        helpscript
        exit 1
    fi
#####ok########################################################

###############################################################
#### Assign population file ##### #############################


    # --pop={1000g_eas|1000g_eur|sg10k_eas|hrc_eur} <- Available options

    if [ "$pop" = "1000g_eur" ]; then
        REFFILE=1000G.EUR.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

    elif [ "$pop" = "1000g_eas" ]; then
        REFFILE=1000G.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log

    elif [ "$pop" = "hrc_eur" ]; then
        REFFILE=HRC.EUR.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

    elif [ "$pop" = "sg10k_eas" ]; then
        REFFILE=SG10k.EAS.ref
        echo "You have indicated $pop"
        # write ref selection to logfile 
        echo "Reference file = $REFFILE" 2>&1 | tee -a $prefix.sumstats_qc.log    

    else 
        echo "Other populations are coming your way"
        exit 1

    fi


#####ok########################################################

###############################################################
#### Log QC parameters ########################################

    echo "3. SumstatsQC would define the default QC parameters as follows" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "        > Allele frequency threshold: Exclude if < 0.005" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "        > INFO score - imputation quality threshold: Exclude if < 0.3" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "        > Allele frequency difference threshold: Exclude if > 0.15" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "   Note: Users may also define quality control thresholds using flags" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "          within the current software. The following are the QC " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "          thresholds used for this round of analysis. " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "#########################################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "# Your Sumstats QC variant inclusion parameters are -   " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "# INFO score > "$INFO_score"                            " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "# Allele frequency > "$AF"                              " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "# Allele Frequency Difference < "$AFB"                  " 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "#########################################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log

#####ok########################################################

###############################################################
#### Check Vars ##############################################

    # Check if R is installed
    checkR=$(which R | grep -o R > /dev/null &&  echo 1 || echo 0)
    if [ "$checkR" -eq "0" ]; then echo "R not installed on the system"; exit 1; else echo "R installed..standby..";fi

    # Variable checks
    if [ -z "$SNP" ]; then echo "SNP not assigned..exiting.."; exit 1; else echo "Column $SNP assigned as SNP" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$CHR" ]; then echo "CHR not assigned..exiting.."; exit 1; else echo "Column $CHR assigned as CHR" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$BP" ]; then echo "BP not assigned..exiting.."; exit 1; else echo "Column $BP assigned as BP" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$A1" ]; then echo "A1 not assigned..exiting.."; exit 1; else echo "Column $A1 assigned as A1" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$A2" ]; then echo "A2 not assigned..exiting.."; exit 1; else echo "Column $A2 assigned as A2" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$FRQ" ]; then echo "FRQ not assigned..exiting.."; exit 1; else echo "Column $FRQ assigned as FRQ" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$INFO" ]; then echo "INFO not assigned..exiting.."; exit 1; else echo "Column $INFO assigned as INFO" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$OR" ]; then echo "OR/BETA not assigned..exiting.."; exit 1; else echo "Column $OR assigned as OR/BETA" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$SE" ]; then echo "SE not assigned..exiting.."; exit 1; else echo "Column $SE assigned as SE" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$PVAL" ]; then echo "PVAL not assigned..exiting.."; exit 1; else echo "Column $PVAL assigned as PVAL" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$Nca" ]; then echo "Nca not assigned..exiting.."; exit 1; else echo "Column $Nca assigned as Nca" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$Nco" ]; then echo "Nco not assigned..exiting.."; exit 1; else echo "Column $Nco assigned as Nco/N_qt" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$pop" ]; then echo "pop not assigned..exiting.."; exit 1; else echo "Population assigned to $pop" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$sumstats" ]; then echo "sumstats not assigned..exiting.."; exit 1; else echo "sumstats=$sumstats" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$prefix" ]; then echo "prefix not assigned..exiting.."; exit 1; else echo "prefix=$prefix" 2>&1 | tee -a $prefix.sumstats_qc.log; fi
    if [ -z "$multicpu" ]; then echo "multicpu not assigned..exiting"; exit 1; else echo "multicpu=$multicpu" 2>&1 | tee -a $prefix.sumstats_qc.log; fi

#####ok########################################################

###############################################################
#### Munge Ref Panel ##########################################

    # Execute code for munging reference panel [module 2]
    # Writes the $prefix.process_ref_panel.sh code 
    if [ -f "$prefix".ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi
    
    if [ ! -f "$prefix".munge.ref.done ]; then

        echo "4. The selected "$pop" reference panel is now being processed by the pipeline" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "The following command is used: " 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "02_SumstatsQC_refpanel_munge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log

        (source ./02_SumstatsQC_refpanel_munge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu; wait)
     

        # Execute munge ref panel code
        if [ "$multicpu" == "Y" ]; then 
            (source ./$prefix.process_ref_panel_multicpu.sh; wait)

        else
            (source ./$prefix.process_ref_panel.sh; wait)
        fi

        # Clean up code 
        
        module2complete=$(cat $REFFILE.$prefix.altstrandflp.chr22 | wc | awk '{print $1}')

        if [ "$module2complete" -lt 10 ]; then 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Reference panel Munge Step         " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check that the reference panel had been    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   properly defined and that you are in the right    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   directory.                                        " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1

        else 
            echo "Reference panel had been munged and ready for sumstats qc procedures" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mungeref.sumstats_qc.log
            rm $prefix.process_ref_panel*.sh
            touch $prefix.munge.ref.done
            cat $prefix.mungeref.sumstats_qc.log >> $prefix.sumstats_qc.log
        fi

    else
        echo "Reference panel have been processed previously"
        cat $prefix.mungeref.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module ..."
    fi
#####ok########################################################

##############################################################
#### Standardize Summary statistics columns ##################

    if [ -f "$prefix".ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.sumstats.standardize.done ]; then
        
        echo "5. Standarding summary statistics - " 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        echo "   Column names within the summary statistics are standardized" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        echo "   based on column information provided by the user" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log

            ### For Binary Traits >>>

        if [ "$qt" == "Binary" ]; then

            # Write header to logfile

            echo "Processing Binary Trait (Odds Ratio) Summary Statistics" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        
            # Re-arrange Binary Trait Summary statistics

            zcat "$sumstats_1".gz | awk -v c1=$SNP -v c2=$CHR -v c3=$BP -v c4=$A1 -v c5=$A2 -v c6=$FRQ -v c7=$INFO -v c8=$OR -v c9=$SE -v c10=$PVAL -v c11=$Nca -v c12=$Nco '{print $c2":"$c3":"toupper($c4)":"toupper($c5), $c1,$c2,$c3,toupper($c4),toupper($c5),$c6,$c7,$c8,$c9,$c10,int($c11),int($c12)}' | sed '1,1d' | sed '1 i\UID SNP CHR BP A1 A2 FRQ INFO OR SE P Nca Nco' > "$sumstats_1".qc.input."$pop".$prefix.sumstats.1
        
            # Write Variant count for Pre-QC procedures
            totalsnpspreqc=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | cut -d ' ' -f1) - 1)
            echo "There are $totalsnpspreqc SNPs in PreQC Sumstats file "$sumstats_1".qc.input."$pop".$prefix.sumstats.1" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log

            # Convert file to linux readable format

            dos2unix "$sumstats_1".qc.input."$pop".$prefix.sumstats.1

            # Check file

            sumstatsfield=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | awk 'BEGIN{FS=" "}{if(NF!=13) print;}' | wc | awk '{print $1}')

            if [ "$sumstatsfield" -gt 0 ]; then 
                echo "case control sumstats does not have 13 fields - check!" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
                echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
                exit 1

            elif [ "$sumstatsfield" == 0 ]; then
                echo "Checked! All rows have 13 fields for case-control GWAS sumstats!" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
                echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        
            fi

            # Extract CASES and CONTROLS count
            CASES=$(awk '{print $12}' "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | sed '1,1d' | sort -r -g | head -1)
            CONTROLS=$(awk '{print $13}' "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | sed '1,1d' | sort -r -g | head -1)
            echo "There are "$CASES" Cases and "$CONTROLS" Controls reported as part of the GWAS sumstats" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log

            touch $prefix.sumstats.standardize.done

        fi
            # >>> Quantitative Traits

        if [ "$qt" == "Quantitative" ]; then 

            # Write header to logfile
            echo "Processing Quantitative Trait (Linear Regression) Summary Statistics" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        
            # Re-arrange Quantitative Trait Summary statistics 
            zcat "$sumstats_1".gz | awk -v c1=$SNP -v c2=$CHR -v c3=$BP -v c4=$A1 -v c5=$A2 -v c6=$FRQ -v c7=$INFO -v c8=$OR -v c9=$SE -v c10=$PVAL -v c11=$Nco '{print $c2":"$c3":"toupper($c4)":"toupper($c5),$c1,$c2,$c3,toupper($c4),toupper($c5),$c6,$c7,$c8,$c9,$c10,int($c11)}' | sed '1,1d' | sed '1 i\UID SNP CHR BP A1 A2 FRQ INFO BETA SE P N_qt' > "$sumstats_1".qc.input."$pop".$prefix.sumstats.1


            # Write Variant count for Pre-QC procedures
            totalsnpspreqc=$(expr $(wc -l "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | cut -d ' ' -f1) - 1)
            echo "There are $totalsnpspreqc SNPs in PreQC Sumstats file "$sumstats_1".qc.input."$pop".$prefix.sumstats.1" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        
            # Convert file to linux readable format
            dos2unix "$sumstats_1".qc.input."$pop".$prefix.sumstats.1
    
            # Check file
            sumstatsfield=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | awk 'BEGIN{FS=" "}{if(NF!=12) print;}' | wc | awk '{print $1}')

            if [ "$sumstatsfield" -gt 0 ]; then 
                echo "Quantitative trait sumstats does not have 12 fields - check!" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
                exit 1

            elif [ "$sumstatsfield" == 0 ]; then
                echo "Checked! All rows have 12 fields for Quantitative trait GWAS sumstats!" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
        
            fi
        
            # Extract SAMPLE count
            SAMPLE=$(awk '{print $12}' "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | sed '1,1d' | sort -r -g | head -1)
            echo "There are "$SAMPLE" samples reported as part of the GWAS sumstats" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log

            touch $prefix.sumstats.standardize.done
        fi

        if [ -z "$qt" ]; then 
            echo ""
            echo "********************************************"
            echo "Can you tell me what type of sumstats you are trying to process??"
            echo "You can either use [Binary] or [Quantitative] - those are the only types I understand."
            echo "Thanks."
            echo "********************************************"
                helpscript
            exit 1
        fi

        # clean up code 
        standardizationcomplete=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | wc | awk '{print $1}')

        if [ ! -f "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 ]; then

            echo "-------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Sumstats Column Standardization Step " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check that the columns have been defined     " 2>&1 | tee -a $prefix.ERROR.log
            echo "   appropriately.                                      " 2>&1 | tee -a $prefix.ERROR.log
            echo "-------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1

        elif [ "$standardizationcomplete" -lt 10 ]; then

            echo "-------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Sumstats Column Standardization Step " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check that the columns have been defined     " 2>&1 | tee -a $prefix.ERROR.log
            echo "   appropriately.                                      " 2>&1 | tee -a $prefix.ERROR.log
            echo "-------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1

        else 

            echo "Sumstats columns are now standardized" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.standardizecol.sumstats_qc.log
            cat $prefix.standardizecol.sumstats_qc.log >> $prefix.sumstats_qc.log

        fi
    
    else 
        echo "Summary Stats have been standardized previously"
        cat $prefix.standardizecol.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module ..."
    fi 

#####ok#######################################################

##############################################################
#### Compute Z score from p-value ############################

    # write R code for calculating Z scores from Pvalues 
    # Similar approach to METAL
    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.calculate.Z.done ]; then 
        echo "6. Standardized Z-scores are calculated based on the P-values" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        echo "   We can convert P-values via the qnorm function in R-stats" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        echo "   Thereafter, the direction is obtained from the reported effect sizes reported" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        echo "   Note: IF you have odds ratio, please make sure you have converted OR" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        echo "   to logOR prior to running sumstatsQC!" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log

        # Check file 
        sumstatslogorstatus=$(cat "$sumstats_1".qc.input."$pop".$prefix.sumstats.1 | awk '{if($9 < 0) print $0}' | wc | awk '{print $1}')

        if [ "$sumstatslogorstatus" == 0 ]; then
            echo "-------------------------------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo "WARNING! There are no -ve effect sizes, which might suggest OR is not converted" 2>&1 | tee -a $prefix.ERROR.log
            echo " SumstatsQC pipeline uses logOR effect sizes                                   " 2>&1 | tee -a $prefix.ERROR.log
            echo "-------------------------------------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
            exit 1
        else 
            echo "Initializing Z score calculation ..." 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        fi 

        # Write Rcode for Zscore calculation 

        if [ "$qt" == "Binary" ]; then
            echo "library(data.table)" > $prefix.p_to_z_convert.r
            echo "data <- fread(\""$sumstats_1".qc.input."$pop".$prefix.sumstats.1\")" >> $prefix.p_to_z_convert.r
            echo "data\$P <- as.numeric(data\$P)" >> $prefix.p_to_z_convert.r
            echo "data\$OR <- as.numeric(data\$OR)" >> $prefix.p_to_z_convert.r
            echo "data\$Z<-abs(qnorm(data\$P/2)) * (data\$OR/abs(data\$OR))" >> $prefix.p_to_z_convert.r
            echo "fwrite(data,file=\"$sumstats_1.qc.input.$pop.$prefix.sumstats.2\",quote=FALSE,compress=\"none\",na=\"NA\",sep=\" \")" >> $prefix.p_to_z_convert.r
        fi 

        if [ "$qt" == "Quantitative" ]; then 
            echo "library(data.table)" > $prefix.p_to_z_convert.r
            echo "data <- fread(\""$sumstats_1".qc.input."$pop".$prefix.sumstats.1\")" >> $prefix.p_to_z_convert.r
            echo "data\$P <- as.numeric(data\$P)" >> $prefix.p_to_z_convert.r
            echo "data\$BETA <- as.numeric(data\$BETA)" >> $prefix.p_to_z_convert.r
            echo "data\$Z<-abs(qnorm(data\$P/2)) * (data\$BETA/abs(data\$BETA))" >> $prefix.p_to_z_convert.r
            echo "fwrite(data,file=\"$sumstats_1.qc.input.$pop.$prefix.sumstats.2\",quote=FALSE,compress=\"none\",na=\"NA\",sep=\" \")" >> $prefix.p_to_z_convert.r
        fi 

        # Run Rcode for the calculation 
        R CMD BATCH --no-save $prefix.p_to_z_convert.r

        # Clean up R codes 
        if [ -f $sumstats_1.qc.input.$pop.$prefix.sumstats.2 ]; then

            rm $prefix.p_to_z_convert.r
            rm $prefix.p_to_z_convert.r.Rout
        
            echo "Z-scores calulated!" 2>&1 | tee -a $prefix.zscore.sumstats_qc.log
        
            touch $prefix.calculate.Z.done

            cat $prefix.zscore.sumstats_qc.log >> $prefix.sumstats_qc.log
        
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Z-Score computation Step            " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the accompanying R scripts are    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   defined appropriately.                            " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        fi 
    else 
        echo "Z-score calculation had been completed previously"
        cat $prefix.zscore.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module ... "
    fi


#######ok#####################################################

###############################################################
#### Munge Summary Statistics #################################

    # Execute code for munging sumstats [module 3]
    # write code $prefix.process_summary_statistics.sh
    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.munge.sumstats.done ]; then 
        echo "7. In munge sumstats step, SumstatsQC splits the summary statistics by CHR" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
        echo "   Note: We are only taking into consideration autosomal SNPs" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
        echo "         at this point. Chr23, Y, MT are excluded for now" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
        echo "   The command for this stage is as follows: " 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
        echo "   03_SumstatsQC_sumstats_munge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log

        (source ./03_SumstatsQC_sumstats_munge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu --qt=$qt; wait)

        # Execute munge sumstats code
        if [ "$multicpu" == "Y" ]; then 
            (source ./$prefix.process_summary_statistics_multicpu.sh; wait)
        else 
            (source ./$prefix.process_summary_statistics.sh; wait)
        fi
        
        
        # clean up code
        if [ -f "$sumstats_1".qc.input."$pop".$prefix.sumstats.3.chr22 ]; then
            rm $prefix.process_summary_statistics_multicpu.sh
            rm $prefix.process_summary_statistics.sh
            touch $prefix.munge.sumstats.done
            echo "Summary Stats Seperated by Chr..." 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mungestats.sumstats_qc.log
            cat $prefix.mungestats.sumstats_qc.log >> $prefix.sumstats_qc.log
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Munge Summary Stats Step           " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the file names and columnns in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the sumstats file is defined appropriately.       " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        fi 

    else 
        echo "Sumstats have been munged previously"
        cat $prefix.mungestats.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module"
    fi

########ok#####################################################

###############################################################
#### Merge Ref and Sumstats ###################################

    # Execute code for merging reference panel and sumstats [module 4]
    # write code $prefix.RefSumstats_merge1.sh

    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.merge.ref.sumstats.done ]; then
        echo "8. Combining the reference panel with GWAS summary statistics ... " 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   There are four major categories of merging that would take place in the current module" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   Variants, that are an exact match based on CHR:BP:A1:A2, variants that have allele flips" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   , variants on alternate strands, and variants on alternate strands that are flipped" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   This module would also output variants that are unmatched. It would be advisable to " 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   parallelize this module." 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   The command for the module :" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "   04_SumstatsQC_refsumstats_merge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log

        (source ./04_SumstatsQC_refsumstats_merge.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --multicpu=$multicpu --qt=$qt; wait)

        # Execute Ref and Sumstats Merge scripts 
        if [ "$multicpu" == "Y" ]; then
            (source ./$prefix.RefSumstats_merge1_multicpu.sh; wait)
            (source ./$prefix.RefSumstats_merge2_multicpu.sh; wait)
            (source ./$prefix.RefSumstats_merge3_multicpu.sh; wait)
            (source ./$prefix.RefSumstats_merge4_multicpu.sh; wait)
        else
            (source ./$prefix.RefSumstats_merge1_singlecpu.sh; wait)
            (source ./$prefix.RefSumstats_merge2_singlecpu.sh; wait)
            (source ./$prefix.RefSumstats_merge3_singlecpu.sh; wait)
            (source ./$prefix.RefSumstats_merge4_singlecpu.sh; wait)
        fi

        # Execute consolidate matched variants
            (source ./$prefix.consolidate.matched.var1.sh; wait)
            (source ./$prefix.consolidate.matched.var2.sh; wait)
            (source ./$prefix.consolidate.matched.var3.sh; wait)
            (source ./$prefix.consolidate.matched.var4.sh; wait)

        # Sort unique variants and then split them up by chr
            (source ./$prefix.consolidate.match.var.uniq.sh; wait) 

            autosomalchr=$(wc $sumstats_1.qc.input.$pop.$prefix.sumstats.3.chr* | tail -1 | awk '{print $1-22}') 
            echo "There are $autosomalchr variants from the $prefix sumstats that are autosomal;" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            matchsuccess=$(cat $prefix.matched.variants.uniq.txt | sed '1,1d' | wc | awk '{print $1}')
            echo "There are $matchsuccess variants from the $prefix sumstats that matched with the reference panel;" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        # Identify unmatch variants
        #if [ "$multicpu" == "Y" ]; then 
        #    (source ./$prefix.reverse.matching_multicpu.sh; wait)
        #else
            (source ./$prefix.reverse.matching.sh; wait)
           
            matchfail=$(wc $sumstats_1.qc.input.$pop.$prefix.sumstats.ref.4.unmatched.chr* | tail -1 | awk '{print $1-22}')  
            echo "There are $matchfail variants from the $prefix sumstats that DID NOT match with the reference panel;" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
        #fi

        # clean up code 

        if [ -f "$sumstats_1".qc.input."$pop".$prefix.sumstats.ref.4.unmatched.chr22 ]; then

            rm $prefix.RefSumstats_merge*.sh
            rm $prefix.consolidate.matched.var*.sh
            rm $prefix.consolidate.match.var.uniq.sh
            rm $prefix.reverse.matching*.sh


            # clean up ref files 

            rm $REFFILE.$prefix.match.chr*
            rm $REFFILE.$prefix.alleleflip.chr*
            rm $REFFILE.$prefix.altstrand.chr*
            rm $REFFILE.$prefix.altstrandflp.chr*

            touch $prefix.merge.ref.sumstats.done

            echo "Merging of Reference Panel variants and Sumstats is complete..." 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.mergeref.sumstats_qc.log
            cat $prefix.mergeref.sumstats_qc.log >> $prefix.sumstats_qc.log
    
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Reference Sumstats Merge Step      " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the file names and columnns in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the sumstats file is defined appropriately.       " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        fi 

    else 
        echo "Merging of Reference Panel and sumstats have been completed previously"
        cat $prefix.mergeref.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module"
    fi
    
#########ok####################################################

###############################################################
#### Apply QC parameters ######################################

    # Execute code for applying QC parameters to summary statistics [module 5]
    # writes the $prefix.QCapply.*.sh code 

    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.apply.qc.done ]; then
        echo "9. QC parameters module" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "   To recap summary statistics are filtered based on AF < $AF; INFO_score < $INFO_score" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "   AF difference with reference panel > $AFB. Also ambiguous AT_GC variants with an allele" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "   frequency threshold of $AMB would be excluded" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "   The command for this module is :" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "   05_SumstatsQC_QCparameters.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score --qt=$qt --multicpu=$multicpu" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log

        (source ./05_SumstatsQC_QCparameters.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score --qt=$qt --multicpu=$multicpu; wait)

        # Execute apply QC parameters code 
        if [ "$multicpu" == "Y" ]; then 
            (source ./$prefix.QCapply.match_multicpu.sh; wait)
            (source ./$prefix.QCapply.flip_multicpu.sh; wait)
            (source ./$prefix.QCapply.altstrand_multicpu.sh; wait)
            (source ./$prefix.QCapply.altstrandflp_multicpu.sh; wait)
        else 
            (source ./$prefix.QCapply.match.sh; wait)
            (source ./$prefix.QCapply.flip.sh; wait)
            (source ./$prefix.QCapply.altstrand.sh; wait)
            (source ./$prefix.QCapply.altstrandflp.sh; wait)
        fi  

        # Clean up code
        if [ -f $sumstats_1.qc.input.$pop.$prefix.sumstats.ref.5.altstrandflp.qcparams.chr22 ]; then
            rm $prefix.QCapply.match*.sh
            rm $prefix.QCapply.flip*.sh
            rm $prefix.QCapply.altstrand*.sh

            # Clean up files 

            rm $prefix.matched.variants.txt
            rm $prefix.matched.variants.uniq.txt

            touch $prefix.apply.qc.done
            echo "QC parameters applied to summary statistics..." 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.applyqc.sumstats_qc.log
            cat $prefix.applyqc.sumstats_qc.log >> $prefix.sumstats_qc.log
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - Apply QC parameters Step           " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the file names and columnns in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the sumstats file is defined appropriately.       " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            #exit 1
        fi
    else 
        echo "QC parameters applied to summary statistics previously"
        cat $prefix.applyqc.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to next module ..."
    fi
##########ok###################################################

###############################################################
#### Post processing scripts [module 6]
   
    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi
    
    if [ ! -f $prefix.post.processing.done ]; then 
        echo "10. In the post-processing module, files that have gone through summary statistics QC are consolidated" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "    These files include: " 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      non-qc-ed autosomal variants file" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      match variants file = these include variants with exact match with ref panel" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      flip variants file = these include allele flipped variants" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      altstrand variants file = these include variants on alternate allele strand" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      altstrandflp variant file = these include variants that are on alternate allele strand and flipped" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      unmatched variant file = these include variants that are not matched with the ref panel" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      finalqc variant file = these include variants that have been quality controlled and sorted CHR and BP" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "    The command for this post-procesisng module is as follows:" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "      06_SumstatsQC_Postprocessing.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log

        # Run post processing scripts
            (source ./06_SumstatsQC_Postprocessing.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score; wait)
        # Consolidate sumstats
            (source ./$prefix.consolidate.processed.files.sh; wait)
        # output QC-ed sumstats
            (source ./$prefix.merge.sumstatsqc.out.sh; wait)
        # Sort sumstats by chr and bp
            (source ./$prefix.sort.sumstatsqc.out.sh; wait) 
        

        # Extract failed snps for master file 
        if [ "$multicpu" == "Y" ]; then  
            (source ./$prefix.extract.failed.vars.multicpu.sh; wait)
        fi 

        #### Note: There is a chance that all variants in the summary statistics matches with reference panel, the $prefix.unmatched.vars.qcexclude.txt file would end up empty. This is likely to create problems in the downstream pipeline. This set of scripts will attempt to mitigate that problem by reading the first 10 rows in the chr1 reference panel for the UID, Punmatched will be indicated as NA. 

        checkqcexcludefile=$(cat $prefix.unmatched.vars.qcexclude.txt | wc | awk '{print $1}')

        if [ "$checkqcexcludefile" -lt 5 ]; then 
            (source ./$prefix.dummy.unmatched.sh)
        fi

        # Generate master merge file
        
            (source ./$prefix.make.merge_master.vars.sh)

        # clean up code
        if [ -f $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt ]; then 
            rm $prefix.merge.sumstatsqc.out.sh
            rm $prefix.consolidate.processed.files.sh
            rm $prefix.sort.sumstatsqc.out.sh
            rm $prefix.extract.failed.vars.sh
            rm $prefix.extract.failed.vars.multicpu.sh
            rm $prefix.dummy.unmatched.sh
            rm $prefix.unmatched.vars.qcexclude.txt
            rm $prefix.altstrand.vars.qcexclude.txt
            rm $prefix.altstrandflp.vars.qcexclude.txt
            rm $prefix.flip.vars.qcexclude.txt
            rm $prefix.matched.vars.qcexclude.txt
            rm $prefix.qc.vars.txt
            rm merge_failed_vars
            rm $prefix.make.merge_master.vars.sh
            rm $prefix.merge_failed.vars.r

            

            touch $prefix.post.processing.done
            echo "Post processing step is complete..." 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
            echo "" 2>&1 | tee -a $prefix.postprc.sumstats_qc.log
            cat $prefix.postprc.sumstats_qc.log >> $prefix.sumstats_qc.log
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - File consolidation Step            " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the file names and columnns in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the sumstats file is defined appropriately.       " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        fi
        
    else 
        echo "QC files were consolidated previously"
        cat $prefix.postprc.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module..."
    fi
###########ok##################################################

###############################################################
#### Extract QC information [module 7]

    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.extract.qc.info.done ]; then 
        echo "11. Diagnostic information from the QC-ed summary statistics files are extracted in this module" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "    Users are encouraged to pay attention to the number of variants that are being excluded" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "    this is to make sure that the pipeline is performing as expected. A 0 count or unusually" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "    large count for one or more of the files would indicate a potential problem with either the" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "    GWAS sumstats that is being QC-ed; or certain parameters in the pipeline were not entered correctly"  2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "    The command for this module is : " 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "      07_SumstatsQC_extractqcinfo.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score= $INFO_score" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log

        # Extract information
            (source ./07_SumstatsQC_extractqcinfo.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score; wait)
            
            sumstats_ref_finalqc=$(cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt | wc | awk '{print $1}')

        if [ -z "$sumstats_ref_finalqc" ]; then
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - QC Diagnostic information Step     " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the file names and columnns in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the sumstats file is defined appropriately.       " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        else 
            echo "Diagnostic information extracted..."  2>&1 | tee -a $prefix.extractinfo.sumstats_qc.log
            touch $prefix.extract.qc.info.done
            cat $prefix.extractinfo.sumstats_qc.log >> $prefix.sumstats_qc.log
        fi
    else
        echo "Diagnostic parameters for the QC had been extracted previously"
        cat $prefix.extractinfo.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module"
    fi
############ok#################################################

###############################################################
#### Post QC visualization [module 8]

    if [ -f $prefix.ERROR.log ]; then 
        echo "OOPS something went awry ..."
        echo ""
        cat $prefix.ERROR.log
        exit 1
    fi

    if [ ! -f $prefix.visualization.qc.info.done ]; then
        echo "12. SumstatQC visualization module" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "    This module performs visualization of post-qc summary stats to allow users" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "    to evaluate the results of the finalqc file" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log 
        echo "    The visualization also shows a pre and post qc manhattan plot to give an overall" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "    feel of how excluded variants has an impact on the final results of the summary statistics" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "    The command for the module is:" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "      08_SumstatsQC_visualization.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score --multicpu=$multicpu" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
        echo "" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log

        # Run visualization scripts
            (source ./08_SumstatsQC_visualization.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --AMB=$AMB --INFO_score=$INFO_score --multicpu=$multicpu; wait)

        # Run multicpu codes
        if [ "$multicpu" == "Y" ]; then
            (source ./$prefix.visualization.multicpu.sh; wait)
        else 
            (source ./$prefix.visualization.singlecpu.sh; wait)
        fi

        # Clean up code 
        if [ -f "$prefix"_SumstatsQC_Manhattanplot_wXvars.png ]; then
            rm $prefix.visualization*sh
            rm $prefix*r
            rm $prefix*Rout
            rm scatterplot_F1ref_FRQ
            rm histogram_infosc
            rm histogram_af
            rm scatterplot_F1_minuslogP
            rm manhattanplotqc
            rm manhattanplotxvars
            touch $prefix.visualization.qc.info.done
            cat $prefix.visualz.sumstats_qc.log >> $prefix.sumstats_qc.log
        else 
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            echo " WARNING! ERROR - QC Visualization Step              " 2>&1 | tee -a $prefix.ERROR.log
            echo " > Please check if the Rscripts and parameters in    " 2>&1 | tee -a $prefix.ERROR.log
            echo "   the Rscripts accurately indicates files and       " 2>&1 | tee -a $prefix.ERROR.log
            echo "   variables                                         " 2>&1 | tee -a $prefix.ERROR.log
            echo "-----------------------------------------------------" 2>&1 | tee -a $prefix.ERROR.log
            exit 1
        fi
    else 
        echo "Visualization for QC is complete"
        cat $prefix.visualz.sumstats_qc.log >> $prefix.sumstats_qc.log
        echo "Moving on to the next module ..."
    fi

##############ok###############################################

###############################################################
#### SumstatsQC Complete! #####################################

    echo "#############################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "### SUMSTATS QUALITY CONTROL - COMPLETE ! ###" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "#############################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Check SumstatsQC stage completed - " 2>&1 | tee -a $prefix.sumstats_qc.log
    ls -tr1 $prefix*.done 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "----------------------------------------------" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Please consult https://github.com/maxzylam/SumstatsQC-dev-1 for further details" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "with regards to the SumstatsQC pipeline" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Sumstats QC for $sumstats completed on $(date)" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "Thank you for using SumstatsQC" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "- Max Lam, PhD" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "- The Broad Institute, Massachusetts, USA" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "- Stanley Center for Psychiary Research" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "- Feinstitute Institutes of Medical Research, New York, USA" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "- The Zucker Hillside Hospital" 2>&1 | tee -a $prefix.sumstats_qc.log

################ok#############################################

###############################################################
#### Cleanup Data #############################################

    # Run cleanup script 

        (source ./09_SumstatsQC_cleanup.sh --sumstats=$sumstats --pop=$pop --prefix=$prefix --qt=$qt --AF=$AF --AFB=$AFB --INFO_score=$INFO_score --multicpu=$multicpu; wait)

    # Run multicpu gzip 
    if [ "$multicpu" == "Y" ]; then 
        (source ./$prefix.gzip.cleanup.multicpu.sh; wait)
    else 
        (source ./$prefix.gzip.cleanup.singlecpu.sh; wait)
    fi

    # move gzip files to folder

    mv $prefix*txt.gz $prefix.SumstatsQC.files
    mv $sumstats_1*txt.gz $prefix.SumstatsQC.files
    mv $prefix*sumstats*gz $prefix.SumstatsQC.files
    mv $sumstats_1*sumstats*gz $prefix.SumstatsQC.files
    rm $prefix.gzip.cleanup.multicpu.sh
    #rm $prefix*done

###############ok##############################################
