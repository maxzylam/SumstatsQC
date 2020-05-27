#!/bin/bash
######################################
#### SumstatsQC Dev version 2 ########
#### visualization step         ######
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
        echo "SumstatQC visualization module"
        echo "This module performs visualization of post-qc summary stats to allow users"
        echo "to evaluate the results of the finalqc file"
        echo "The visualization also shows a pre and post qc manhattan plot to give an overall"
        echo "feel of how excluded variants has an impact on the final results of the summary statistics"
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


    echo "############################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "### SumstatsQC post-qc visualization ... ###" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "############################################" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log
    echo "" 2>&1 | tee -a $prefix.sumstats_qc.log

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
#### Visualizations ##################

cat $prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results_mastercopy.txt | grep -v pass | awk '{print $2,$3,$4,$11}' > $prefix.xvar.txt

DIRECTORY=$(echo $PWD | sed 's_/_\\/_g')
FINALQCFILE=$prefix.$REFFILE.SumstatsQC.AF_$AF.INFO_$INFO_score.AFB_$AFB.results.finalqc.txt
EXFILE=$prefix.xvar.txt
PREFIX=$prefix

### Check variables 

echo "############################" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "#### VISUALIZATIONS ########" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "############################" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "DIRECTORY = $DIRECTORY" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "FINALQCFILE = $FINALQCFILE" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "EXFILE = $EXFILE" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log
echo "PHENO = $PREFIX" 2>&1 | tee -a $prefix.visualz.sumstats_qc.log


# Histograms
# Histogram_AF
cat > histogram_af << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/FINALQCFILE")

## Initialize figure [QC file]
png("/DIRECTORY/PREFIX_SumstatsQC_Histogram_AF_QC.png",height=15,width=15,units="cm",res=400,pointsize=3)


mu1 <- sumstats %>% summarize(median_FRQ=median(FRQ))

sumstats %>% ggplot(., aes(x=FRQ)) + geom_density(alpha=0.4) + geom_vline(data=mu1, aes(xintercept=median_FRQ), linetype="dashed") + labs(title="Post-QC Procedures Allele Frequency",x="Allele Frequency", y = "Density") + theme(axis.text.x = element_text(angle = 90, hjust = 1))

dev.off()

writescript


# Histogram_INFOSc

cat > histogram_infosc << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/FINALQCFILE")

## Initialize figure 
png("/DIRECTORY/PREFIX_SumstatsQC_Histogram_INFOSc.png",height=15,width=15,units="cm",res=400,pointsize=3)

mu1 <- sumstats %>% summarize(median_INFOSc=median(INFO))

sumstats %>% ggplot(., aes(x=INFO)) + geom_density(alpha=0.4) + geom_vline(data=mu1, aes(xintercept=median_INFOSc), linetype="dashed") + labs(title="Post-QC Procedures INFO score",x="INFO Score", y = "Density") + theme(axis.text.x = element_text(angle = 90, hjust = 1))

dev.off()

writescript

    
# Scatterplots
        
# Firef ~ FRQ
cat > scatterplot_F1ref_FRQ << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/FINALQCFILE")

## Initialize figure 
png("/DIRECTORY/PREFIX_SumstatsQC_Scatterplot_FRQ-F1.png",height=15,width=15,units="cm",res=400,pointsize=3)

sumstats %>% ggplot(., aes(x=F1ref, y=FRQ)) + geom_point() + geom_smooth(method=lm, color="red") + labs(title="SumstatsQC Final data: A1 Allele Frq ~ Ref A1 Allele Frq",x="Ref A1 Allele Frq", y = "Sumstats A1 Allele Frq")

dev.off() 

writescript

# minuslog10P ~ F1

cat > scatterplot_F1_minuslogP << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/FINALQCFILE")

## Initialize figure 
png("/DIRECTORY/PREFIX_SumstatsQC_Scatterplot_FRQ-minuslogP.png",height=15,width=25,units="cm",res=400,pointsize=3)

sumstats %>% ggplot(., aes(x=FRQ, y=minuslog10P)) + geom_point() + labs(title="SumstatsQC Final data: A1 Allele Frq ~ minuslog10P", x="F1 Allele Freq", y = "-log10P")

dev.off() 

writescript

# Manhattanplot

cat > manhattanplotxvars << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

if(require("qqman")){
    print("qqman is loaded correctly")
} else {
    print("trying to install qqman")
    install.packages("qqman")
    if(require(qqman)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install qqman")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/EXFILE")


## scanning the snps to highlight


## Initialize figure 
png("/DIRECTORY/PREFIX_SumstatsQC_Manhattanplot_wXvars.png",height=15,width=30,units="cm",res=400,pointsize=3)


manhattan(sumstats,suggestiveline=FALSE,cex.axis=0.95,main='')

dev.off()

writescript



cat > manhattanplotqc << writescript
#! /usr/bin/Rscript

## Load R packages for visualization 

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

if(require("gridExtra")){
    print("gridExtra is loaded correctly")
} else {
    print("trying to install gridExtra")
    install.packages("gridExtra")
    if(require(gridExtra)){
        print("gridExtra installed and loaded")
    } else {
        stop("could not install gridExtra")
    }
}

if(require("ggplot2")){
    print("ggplot2 is loaded correctly")
} else {
    print("trying to install ggplot2")
    install.packages("ggplot2")
    if(require(ggplot2)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install ggplot2")
    }
}

if(require("qqman")){
    print("qqman is loaded correctly")
} else {
    print("trying to install qqman")
    install.packages("qqman")
    if(require(qqman)){
        print("ggplot2 installed and loaded")
    } else {
        stop("could not install qqman")
    }
}

## Read in summary statistics 
sumstats <- fread("/DIRECTORY/FINALQCFILE")

## include columns
gwas <- sumstats %>% select(., SNP=UID0, CHR, BP, P)
gwas <- gwas %>% na.omit()

## Initialize figure 
png("/DIRECTORY/PREFIX_SumstatsQC_Manhattanplot_QC.png",height=15,width=30,units="cm",res=400,pointsize=3)


manhattan(gwas,col=c("lightskyblue2","midnightblue"),suggestiveline=FALSE,cex.axis=0.95,main='')

dev.off()

writescript



# Assign values to variables 

dos2unix histogram_af
dos2unix histogram_infosc
dos2unix scatterplot_F1ref_FRQ
dos2unix scatterplot_F1_minuslogP
dos2unix manhattanplotxvars
dos2unix manhattanplotqc
 
echo "cat histogram_af | sed 's/PREFIX/$PREFIX/g' | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/FINALQCFILE/$FINALQCFILE/g' > $prefix.histogram_af.r" > $prefix.visualization.sh

echo "cat histogram_infosc | sed 's/PREFIX/$PREFIX/g' | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/FINALQCFILE/$FINALQCFILE/g' > $prefix.histogram_infosc.r" >> $prefix.visualization.sh          

echo "cat scatterplot_F1ref_FRQ | sed 's/PREFIX/$PREFIX/g' | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/FINALQCFILE/$FINALQCFILE/g' > $prefix.scatterplot_F1ref_FRQ.r" >> $prefix.visualization.sh

echo "cat scatterplot_F1_minuslogP | sed 's/PREFIX/$PREFIX/g' | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/FINALQCFILE/$FINALQCFILE/g' > $prefix.scatterplot_F1_minuslogP.r" >> $prefix.visualization.sh

echo "cat manhattanplotxvars | sed 's/PREFIX/$PREFIX/g' | sed 's/EXFILE/$EXFILE/g' | sed 's/DIRECTORY/$DIRECTORY/g' > $prefix.manhattanplotxvars.r" >> $prefix.visualization.sh

echo "cat manhattanplotqc | sed 's/PREFIX/$PREFIX/g' | sed 's/DIRECTORY/$DIRECTORY/g' | sed 's/FINALQCFILE/$FINALQCFILE/g' > $prefix.manhattanplotqc.r" >> $prefix.visualization.sh

bash $prefix.visualization.sh 

# write multicpu code 
    if [ "$multicpu" == "Y" ]; then
        ls $prefix.hist*.r | awk '{print "R CMD BATCH --no-save", $0, "&"}' > $prefix.visualization.multicpu.sh 
        ls $prefix.scat*.r | awk '{print "R CMD BATCH --no-save", $0, "&"}' >> $prefix.visualization.multicpu.sh
        ls $prefix.manh*.r | awk '{print "R CMD BATCH --no-save", $0, "&"}' >> $prefix.visualization.multicpu.sh 
        chmod +x *.sh
        echo "plotting post-qc visualization"
    else 
        ls $prefix.hist*.r | awk '{print "R CMD BATCH --no-save", $0}' > $prefix.visualization.singlecpu.sh
        ls $prefix.scat*.r | awk '{print "R CMD BATCH --no-save", $0}' >> $prefix.visualization.singlecpu.sh
        ls $prefix.manh*.r | awk '{print "R CMD BATCH --no-save", $0}' >> $prefix.visualization.singlecpu.sh
        chmod +x *.sh
        echo "plotting post-qc visualization"
    fi


######################################