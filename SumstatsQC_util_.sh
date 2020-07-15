sumstats=$1
Reference_Allele=$2
output=$3


    ### SumstatsQC utility

    printf "\n#############################################\n#### SumstatsQC Utility for Generating Batch File \n#############################################\n\n" 2>&1 | tee $output.batch.log
    printf "\nAnalysis Initials = $(id -u -n)\n" 2>&1 | tee -a $output.batch.log
    printf "\nDate file generated = $(date)\n" 2>&1 | tee -a $output.batch.log
    printf "\nSumstats File = $sumstats\n\n" 2>&1 | tee -a $output.batch.log

        # Check fields 

            sumstatsfields=$(zcat $sumstats | head -1 | tr ' ' '\n' | wc | awk '{print $1}')

            failedfields=$(zcat $sumstats | awk -v fields=$sumstatsfields '{if(NF!=fields) print $0}' | wc | awk '{print $1}')

            if [ "$failedfields" -gt 1000 ]; then

                echo "Something seems wrong with the sumstats" 2>&1 | tee -a $output.batch.log
                exit 1

            else 

                echo "Proceeding with Automated column definition...." 2>&1 | tee -a $output.batch.log

            fi 
        # Define SNP 
            
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep MARKER | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep MarkerName | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep rsid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep rs_id | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep SNP | awk '{print $2'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep SNPID | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep variant | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Variants | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then SNP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep varid | awk '{print $2}'); fi
            if [ -z "$SNP" ]; then echo "SNP is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$SNP" ]; then SNP=unknown; fi 
            echo "SNP $SNP" > $output.batch.txt

        # Define CHR    

            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep CHR | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then echo "CHR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$CHR" ]; then CHR=unknown; fi
            echo "CHR $CHR" >> $output.batch.txt


        # Define BP

            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep BP | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep POS | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep position | awk '{print $2}'); fi
            if [ -z "$BP" ]; then echo "BP is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$BP" ]; then BP=unknown; fi
            echo "BP $BP" >> $output.batch.txt

        # Define Alleles

            if [ "$Reference_Allele" == "R" ]; then
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w A2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w a2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w NEA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w alt | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w ALT | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                echo "A1 $A1" >> $output.batch.txt

                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w A1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w a1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w EA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w ref | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w REF | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi 
                echo "A2 $A2" >> $output.batch.txt

            else 
                
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w A1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w a1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Allele1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w alelle1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w EA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w ref | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w REF | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                printf "A1 $A1" >> $output.batch.txt

                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w A2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Allele2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w NEA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w alt | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w ALT | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A2 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi
                echo "A2 $A2" >> $output.batch.txt
            fi

        # Define Frequency

            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w AF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ALT_freq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w EAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EFFECT_ALLELE_FREQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Freq1 | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Frq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w FRQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w MAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then echo "FRQ is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$FRQ" ]; then FRQ=unknown; fi
            echo "FRQ $FRQ" >> $output.batch.txt

        # Define INFO 

            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep info | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep INFO | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep OncoArray_imputation_r2 | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Rsq | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then echo "INFO is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$INFO" ]; then INFO=unknown; fi
            echo "INFO $INFO" >> $output.batch.txt
        
        # Define OR

            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep BETA | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Effect | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w OR | awk '{print $2}'); fi
            if [ -z "$OR" ]; then echo "OR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$OR" ]; then OR=unknown; fi
            echo "OR $OR" >> $output.batch.txt

        # Define SE 

            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w SE | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w se | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep StdErr | awk '{print $2}'); fi
            if [ -z "$SE" ]; then echo "SE is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$SE" ]; then SE=unknown; fi
            echo "SE $SE" >> $output.batch.txt       

        # Define PVAL

            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w P | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep P_BOLT | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep pval | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep p.value | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Pvalue | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then echo "PVAL is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$PVAL" ]; then PVAL=unknown; fi
            echo "PVAL $PVAL" >> $output.batch.txt 

        # Define Nca 

            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w Nca | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then echo "Nca is not assigned...defaulting to 0...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nca" ]; then Nca=0; fi
            echo "Nca $Nca" >> $output.batch.txt 

        # Define Nco

            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NCo | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NCO | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NControls | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ncontrols | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w N | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep n_complete_samples | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then echo "Nco is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nco" ]; then Nco=unknown; fi
            echo "Nco $Nco" >> $output.batch.txt 

        # logger 
            printf "\n BATCHFILE \n------------------\n\n" 2>&1 | tee -a $output.batch.log
            cat $output.batch.txt >> $output.batch.log
            printf "\n------------------\n\n" 2>&1 | tee -a $output.batch.log

    printf "\n#############################################\n#### SumstatsQC Utility Complete\041\041 \n#############################################\n\n" 2>&1 | tee -a $output.batch.log