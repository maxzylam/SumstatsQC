#############################################
#### Setup File #############################
#############################################

#############################################
#### Introduction ###########################

    function helpscript {
        echo "Welcome to SumstatsQC pipeline ! "
        echo "This setup script would set up files that are necessary for SumstatsQC ... "
        echo ""
        echo "Please navigate to the folder you would like the files to be installed ...."
    }

#############################################

#############################################
#### Prompt to continue

    helpscript 

    while [ 1 ]; do 
        read -p "Continue (y/n)?" CONT1
        if [ "$CONT1" == "y" ]; then
            echo "Continuing installation ...."
            break
        elif [ "$CONT1" == "n" ]; then 
            echo "exiting installation ...."
            exit 1
        else 
            echo "respond to y or n ? "
        fi
    done
#############################################

#############################################
#### Download Sumstats scripts

    read -p "Download SumstatsQC scripts (y/n)?" CONT2
        if [ "$CONT2" == "y" ]; then
            echo "Downloading scripts ...."
                gsutil cp gs://quality-control-reffiles/WORKING_FOLDER/SumstatsQC $(pwd)
                gsutil cp gs://quality-control-reffiles/WORKING_FOLDER/*SumstatsQC*sh $(pwd)
            echo "Make bash script executable ... "
                dos2unix *.sh
                chmod +x *.sh
                dos2unix SumstatsQC
                chmod +x SumstatsQC

        elif [ "$CONT2" == "n" ]; then 
            echo "exiting installation ...."
            exit 1
        else 
            echo "respond to y or n ? "
        fi
#############################################

#############################################
#### Download Reference Panel

    read -p "Download 1000Genomes EAS Ref Variants (y/n)?" CONT3
        if [ "$CONT3" == "y" ]; then
            echo "Continuing installation ...."
            echo "Downloading 1000 Genomes EAS reference variants .... "
                gsutil cp gs://quality-control-reffiles/REFERENCE_1000G_EAS/1000G*gz $(pwd)
        elif [ "$CONT3" == "n" ]; then 
            echo "Skipping 1000 Genomes EAS reference variants ...."
        else 
            echo "respond to y or n ? "
        fi

    read -p "Download 1000Genomes EUR Ref Variants (y/n)?" CONT4
        if [ "$CONT4" == "y" ]; then
            echo "Continuing installation ...."
            echo "Downloading 1000 Genomes EUR reference variants ...."
                gsutil cp gs://quality-control-reffiles/REFERENCE_1000G_EUR/1000G*gz $(pwd)
        elif [ "$CONT4" == "n" ]; then 
            echo "Skipping 1000 Genomes EUR reference variants ...."
        else 
            echo "respond to y or n ? "
        fi
    read -p "Download HRC EUR Ref Variants (y/n)?" CONT5
        if [ "$CONT5" == "y" ]; then
            echo "Continuing installation ...."
            echo "Downloading HRC EUR reference variants ...."
                gsutil cp gs://quality-control-reffiles/REFERENCE_HRC_EUR/HRC*chr*gz $(pwd)
        elif [ "$CONT5" == "n" ]; then 
            echo "Skipping HRC EUR reference variants ...."
        else 
            echo "respond to y or n ? "
        fi
    read -p "Download SG10K EAS Ref Variants (y/n)?" CONT6
        if [ "$CONT6" == "y" ]; then
            echo "Continuing installation ...."
            echo "Downloading SG10K EAS reference variants ...."
                gsutil cp gs://quality-control-reffiles/REFERENCE_SG10K_EAS/SG10k.EAS.ref.chr*.gz $(pwd)
        elif [ "$CONT6" == "n" ]; then 
            echo "Skipping SG10K EAS reference variants ...."
        else 
            echo "respond to y or n ? "
        fi

#############################################

