sumstats=$1
Reference_Allele=$2
output=$3


    ### SumstatsQC utility

    printf "\n#############################################\n#### SumstatsQC Utility for Generating Batch File \n#############################################\n\n" 2>&1 | tee $output.batch.log
    printf "\nAnalysis Initials = $(id -u -n)\n" 2>&1 | tee -a $output.batch.log
    printf "\nDate file generated = $(date)\n" 2>&1 | tee -a $output.batch.log
    printf "\nSumstats File = $sumstats\n\n" 2>&1 | tee -a $output.batch.log

        # Check fields 

            sumstatsfields=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | wc | awk '{print $1}')

            failedfields=$(zcat $sumstats | awk -v fields=$sumstatsfields '{if(NF!=fields) print $0}' | wc | awk '{print $1}')

            if [ "$failedfields" -gt 1000 ]; then

                echo "Something seems wrong with the sumstats" 2>&1 | tee -a $output.batch.log
                exit 1

            else 

                echo "Proceeding with Automated column definition...." 2>&1 | tee -a $output.batch.log

            fi 
        # Define SNP 
            
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx MARKER | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx MarkerName | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx rsid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx RSID | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Rsid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx rs_id | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx SNP | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Snp | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx snp | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx SNPID | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx snpid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx variant | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Variants | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx varid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ID | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then echo "SNP is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$SNP" ]; then SNP=unknown; fi 
            echo "SNP $SNP" > $output.batch.txt

        # Define CHR    

            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx CHR | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx CHROM | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then echo "CHR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$CHR" ]; then CHR=unknown; fi
            echo "CHR $CHR" >> $output.batch.txt


        # Define BP

            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx BP | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx POS | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx position | awk '{print $2}'); fi
            if [ -z "$BP" ]; then echo "BP is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$BP" ]; then BP=unknown; fi
            echo "BP $BP" >> $output.batch.txt

        # Define Alleles

            if [ "$Reference_Allele" == "R" ]; then
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx A2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx a2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NEA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx alt | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ALT | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                echo "A1 $A1" >> $output.batch.txt

                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx A1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx a1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ref | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx REF | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi 
                echo "A2 $A2" >> $output.batch.txt

            else 
                
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx A1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx a1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Allele1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx alelle1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ref | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx REF | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                echo "A1 $A1" >> $output.batch.txt

                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx A2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Allele2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NEA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx alt | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ALT | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A2 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi
                echo "A2 $A2" >> $output.batch.txt
            fi

        # Define Frequency

            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx AF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ALT_freq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EFFECT_ALLELE_FREQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Freq1 | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Frq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx FRQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx MAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx AF_Allele2 | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx MAF_UKB | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx meta_frq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx effectAlleleFreq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then echo "FRQ is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$FRQ" ]; then FRQ=unknown; fi
            echo "FRQ $FRQ" >> $output.batch.txt

        # Define INFO 

            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx info | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx INFO | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx OncoArray_imputation_r2 | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Rsq | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx IMPINFO | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx INFO_UKB | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then echo "INFO is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$INFO" ]; then INFO=unknown; fi
            echo "INFO $INFO" >> $output.batch.txt
        
        # Define OR

            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx BETA | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Effect | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx EFFECT | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx OR | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx LnOR | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx mtag_beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then echo "OR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$OR" ]; then OR=unknown; fi
            echo "OR $OR" >> $output.batch.txt

        # Define SE 

            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx SE | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx se | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx StdErr | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx mtag_se | awk '{print $2}'); fi
            if [ -z "$SE" ]; then echo "SE is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$SE" ]; then SE=unknown; fi
            echo "SE $SE" >> $output.batch.txt       

        # Define PVAL

            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx P | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx P_BOLT | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx pval | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx PVAL | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Pval | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -v NA | grep -wx p.value | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Pvalue | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx P.value | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx mtag_pval | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then echo "PVAL is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$PVAL" ]; then PVAL=unknown; fi
            echo "PVAL $PVAL" >> $output.batch.txt 

        # Define Nca 

            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Nca | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCa | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCA | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCAS | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx nca | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Nca | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then echo "Nca is not assigned...defaulting to 0...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nca" ]; then Nca=0; fi
            echo "Nca $Nca" >> $output.batch.txt 

        # Define Nco

            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCo | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCO | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NCON | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx NControls | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx ncontrols | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx N | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx n_complete_samples | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx TotalN | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx Weight | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | sed 's/\./_/g' | cat -n | awk '{print $2,$1}' | grep -wx WEIGHT | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then echo "Nco is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nco" ]; then Nco=unknown; fi
            echo "Nco $Nco" >> $output.batch.txt 
        
        # Define qt

            if [ -z "$qt" ]; then 
                
                qt=$(cat $output.batch.txt | grep Nca | awk '{print $2}')

                    if [ -f $output.qt.txt ]; then 
                        rm $output.qt.txt
                    fi

                    if [ "$qt" == "0" ]; then 
                        echo "Quantitative" >> $output.qt.txt
                    else 
                        echo "Binary" >> $output.qt.txt
                    fi
            fi


        # logger 
            printf "\n BATCHFILE \n------------------\n\n" 2>&1 | tee -a $output.batch.log
            cat $output.batch.txt 2>&1 | tee -a $output.batch.log
            printf "\n------------------\n\n" 2>&1 | tee -a $output.batch.log

    printf "\n#############################################\n#### SumstatsQC Utility Complete\041\041 \n#############################################\n\n" 2>&1 | tee -a $output.batch.log