sumstats=$1
Reference_Allele=$2
output=$3


    ### SumstatsQC utility

    printf "\n#############################################/n#### SumstatsQC Utility for Generating Batch File \n#############################################\n\n" 2>&1 | tee $output.batch.log
    printf "Analysis Initials = $(id -u -n)" 2>&1 | tee -a $output.batch.log
    printf "Date Bathfile generated = $(date)" 2>&1 | tee -a $output.batch.log

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
            printf "SNP $SNP" > $output.batch.txt
            
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Chr | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then CHR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep CHR | awk '{print $2}'); fi
            if [ -z "$CHR" ]; then echo "CHR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$CHR" ]; then CHR=unknown; fi
            printf "CHR $CHR" >> $output.batch.txt

            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep BP | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Pos | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep POS | awk '{print $2}'); fi
            if [ -z "$BP" ]; then BP=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep position | awk '{print $2}'); fi
            if [ -z "$BP" ]; then echo "BP is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$BP" ]; then BP=unknown; fi
            printf "BP $BP" >> $output.batch.txt


            if [ "$Reference_Allele" == "R" ]; then
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep A2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep a2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep allele2 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NEA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep alt | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ALT | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                printf "A1 $A1" >> $output.batch.txt
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep A1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep a1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep allele1 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ref | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep REF | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi 
                printf "A2 $A2" >> $output.batch.txt

            else 
                
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep A1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep a1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Allele1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep alele1 | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EA | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ref | awk '{print $2}'); fi
                if [ -z "$A1" ]; then A1=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep REF | awk '{print $2}'); fi
                if [ -z "$A1" ]; then echo "A1 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A1" ]; then A1=unknown; fi
                printf "A1 $A1" >> $output.batch.txt

                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep A2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Allele2 | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NEA | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NON_EFFECT_ALLELE | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep alt | awk '{print $2}'); fi
                if [ -z "$A2" ]; then A2=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ALT | awk '{print $2}'); fi
                if [ -z "$A2" ]; then echo "A2 is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
                if [ -z "$A2" ]; then A2=unknown; fi
                printf "A2 $A2" >> $output.batch.txt
            fi

            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep AF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ALT_freq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep EFFECT_ALLELE_FREQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Freq1 | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Frq | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep FRQ | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then FRQ=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep MAF | awk '{print $2}'); fi
            if [ -z "$FRQ" ]; then echo "FRQ is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$FRQ" ]; then FRQ=unknown; fi
            printf "FRQ $FRQ" >> $output.batch.txt

            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep info | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep INFO | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep OncoArray_imputation_r2 | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then INFO=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Rsq | awk '{print $2}'); fi
            if [ -z "$INFO" ]; then echo "INFO is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$INFO" ]; then INFO=unknown; fi
            printf "INFO $INFO" >> $output.batch.txt
            
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Beta | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep BETA | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Effect | awk '{print $2}'); fi
            if [ -z "$OR" ]; then OR=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep OR | awk '{print $2}'); fi
            if [ -z "$OR" ]; then echo "OR is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$OR" ]; then OR=unknown; fi
            printf "OR $OR" >> $output.batch.txt

            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep SE | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep se | awk '{print $2}'); fi
            if [ -z "$SE" ]; then SE=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep StdErr | awk '{print $2}'); fi
            if [ -z "$SE" ]; then echo "SE is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$SE" ]; then SE=unknown; fi
            printf "SE $SE" >> $output.batch.txt       

            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w P | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep P_BOLT | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep pval | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep p.value | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then PVAL=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Pvalue | awk '{print $2}'); fi
            if [ -z "$PVAL" ]; then echo "PVAL is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$PVAL" ]; then PVAL=unknown; fi
            printf "PVAL $PVAL" >> $output.batch.txt 

            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Nca | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then Nca=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ncase | awk '{print $2}'); fi
            if [ -z "$Nca" ]; then echo "Nca is not assigned...defaulting to 0...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nca" ]; then Nca=0; fi
            printf "Nca $Nca" >> $output.batch.txt 

            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NCo | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NCO | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Nco | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep NControls | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep ncontrols | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep Neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep neff | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then Nco=$(zcat $sumstats | head -1 | tr ' ' '\n' | cat -n | awk '{print $2,$1}' | grep -w N | awk '{print $2}'); fi
            if [ -z "$Nco" ]; then echo "Nco is not assigned...please check sumstats..."; fi 2>&1 | tee -a $output.batch.log
            if [ -z "$Nco" ]; then Nco=unknown; fi
            printf "Nco $Nco" >> $output.batch.txt 

    printf "\n#############################################/n#### SumstatsQC Utility for Generating Batch File \n#############################################\n\n" 2>&1 | tee -a $output.batch.log