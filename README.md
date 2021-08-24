# SumstatsQC

GWAS Summary Statistics Quality Control v0.1

## Background

Common variant GWAS have been ubiquitous in identifying underlying biology in numerous traits. Research at both consortia and biobank level had been important in driving large-scale discovery GWAS. Summary statistics uploaded in public repository have become an invaluable resource for downstream GWAS analysis, included identifying genetic correlation, for polygenic risk score prediction, Mendelian Randomization, fine-mapping etc. However, to further use these summary statistics for the above-mentioned downstream analysis, some level of quality control is required due to differing GWAS pipelines used for QC and imputation previously.  

## Overview

The SumstatsQC pipeline is divided into nine modules that is controlled by a main pipeline wrapper - "SumstatsQC". An additional utility module is available for archiving the completed SumstatsQC files into a google drive bucket if Google Drive SDK is set up in the user's system. The pipeline runs primarily in interactive mode, and the user has the option of performing the pipeline in "singlecpu" mode or "multicpu" mode that leverages on multhreaded operations. 

### Google cloud 

Analysis using the SumstatsQC pipeline was carried out at part of the manuscript "Dissecting Biological Pathways of Psychopathology using Cognitive Genomics" by Lam et al.,  implemented on a google cloud virtual machine. 

A single virtual machine was set up with 22 CPUs - analyses was carried out in interactive mode  (Run in Google Shell)

```
gcloud compute instances create vm-name --project=project-name --zone=us-central1-a --machine-type=n2-custom-22-88064 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --service-account=service@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=debian-9-stretch-v20210817 --image-project=debian-cloud --boot-disk-size=500GB --boot-disk-type=pd-balanced --boot-disk-device-name=bootdisk-name --reservation-affinity=any
```

### Setting up SumstatsQC pipeline  

```
git clone 



### Reference files 

Reference files are available for download at the following location: 

https://personal.broadinstitute.org/hhuang//public//sumstatsQC_reference/

### Dependencies

The pipeline is ran on bash and R. Required dependencies for R 
- dplyr
- tidyr
- data.table
- ggplot2
- qqman


### **Wrapper Module**

This is where the main input options pipeline is passed to the wrapper. Using the “--help” flag users would be able to view the options that are available for the SumstatsQC. 

```code block 1 - help command
SumstatsQC —help
```

```code block 2 - helpscript 
This script will help process reference panels
on GWAS summary statistics for downstream analysis

Please run the script as follows

./SumstatsQC.sh [OPTIONS]

  --help                              ### show this help and exit
  --batch={Y|N}                       ### use batch column definition
  --batchfile={batch.txt}             ### batch column definitions
  --sumstats={sumstatsfile.gz}        ### summary statistics
  --qt={Binary|Quantitative}          ### Types of traits
  --pop={1000g_eas,                   ### string based on EUR or EAS ancestry from 1000 Genomes
         1000g_eur} 
  --INFO_score=0.3                    ### Imputation quality score, could also be Rsq, default=0.3
  --AF=0.005                          ### Effect Allele frequency, default=0.005
  --AFB=0.15                          ### Allele frequency band, default=0.15
  --AMB=0.4                           ### Ambiguous allele AF threshold, default=0.4
  --prefix={prefix}                   ### phenotype name
  --multicpu={Y/N}                    ### allow multiple cpus for processing


exiting ...
```

1. *--batch={ Y | N }* 

   In this option users are allowed to state whether they are using a batch file for summary statistics quality. e.g. --batch=Y. When this flag is turned on, the pipeline would search for a batch file. The batch file contains the defined summary statistics columns. The rationale for having a batch file is to allow users who are interested in processing large number of summary statistics, with which the batch file would help facilitate quality control of a set of GWAS summary statistics with minimal user interaction. This allow standardization of the quality control procedures. An example of the batch file could be found as follows: 

   ```code block 3 - reveal batch file
   less batch.txt
   ```


   *Assign column numbers based on the external batch file [note the batch.txt file is a whitespace delimited file*

   | Standardized Col Names | Col Numbers from Sumstats | 
   | ---------------------- | ------------------------- |        
   | SNP                    | 1                         |
   | CHR                    | 2                         |
   | BP                     | 3                         |
   | A1                     | 4                         |
   | A2                     | 5                         |
   | FRQ                    | 6                         |
   | INFO                   | 7                         |
   | OR                     | 8                         |
   | SE                     | 9                         |
   | PVAL                   | 10                        |
   | Nca                    | 11                        |
   | Nco                    | 12                        |


   If the flag is indicated as --batch=N, the pipeline would print the headers of the summary statistics and the user would have the option of keying in the header definitions manually. This is useful if users so choose to perform summary statistics QC on the fly. Nevertheless, in most cases, users are advised to use the --batch=Y option. 

2. *--batchfile=batch.txt*

   The --batchfile flag allows users to specify the batchfile that defines the columns of the summary staitistics. The pipeline would read the column numbers. It is **important** to note that the order of the columns have to be pre-specified in the order diplayed in the the example above. 

3. *--sumstats=sumstats.gz*

   The pipeline would read gzipped summary statistics only. **Please make sure that the input summary statistics are gzipped compressed prior to starting the pipeline** 

4. *--multicpu={ Y | N }*

   The pipeline could be carried out in either single core mode (--multicpu=N); using only one cpu for the pipeline or the multicpu mode (--multicpu=Y) where all 22 chromosomes could be processed in parallel. 

5. *--qt={ Binary | Quantitative }*
   The SumstatsQC pipeline may be processed using the --qt=Binary or --qt=Quantitative mode. Binary and Quantitative refers to the phenotype that the summary statistics are indexing. The main difference is that the Binary mode allows for Nca (Sample size for cases) and Nco (Sample size for controls) to be represented in the final set of summary statistics. 

6. *--pop={ 1000g_eur | 1000g_eas }*
   The --pop flag specify the variant definitions either from the 1000 genomes EUR reference panel or the 1000 genomes EAS reference panel. The variant definition for the reference panel is as follows: 

   *1000 genomes EAS reference panel variant definition from chr 9*
   | SNP | N1  | A1  | F1  | SE1  | A2  | F2  | SE2 | N2  | CHR | BP  |
   | --- | --- | --- | --- | ---  | --- | --- | --- | --- | --- | --- |
   | chr9:10273 | 1008 | A | 0.001 | 0.000703943 | AAC | 0.999 | 0.000703943 | 1 | 9 | 10273 |
   | rs141734683 | 1008 | C | 0.272 | 0.00991071 | CT | 0.728 | 0.00991071 | 273 | 9 | 10362 |
   | rs56377469 | 1008 | G | 0.253 | 0.00968223 | C | 0.747 | 0.00968223 | 255 | 9 | 10469 | 
   | chr9:10684 | 1008 | T | 0.001 | 0.000703943 | G | 0.999 | 0.000703943 | 1 | 9 | 10684 |
   | rs368818808 | 1008 | A | 0.004 | 0.00140577 | C | 0.996 | 0.00140577 | 3 | 9 | 10716 |
   | chr9:11076 | 1008 | A | 0.004 | 0.00140577 | G | 0.996 | 0.00140577 | 3 | 9 | 11076 | 
   | chr9:11298 | 1008 | A | 0.001 | 0.000703943 | G | 0.999 | 0.000703943 | 1 | 9 | 11298 |
   | chr9:11379 | 1008 | C | 0.001 | 0.000703943 | G | 0.999 | 0.000703943 | 1 | 9 | 11379 | 
   | chr9:11981 | 1008 | C | 0.001 | 0.000703943 | T | 0.999 | 0.000703943 | 1 | 9 | 11981 |

7. *--prefix=pheno1_run1*
   The --prefix flag allows users to identify the summary statistics that are being processed by the SumstatsQC pipeline. **It is important that this flag is properly defined**. As the pipeline would attach the "prefix" variable, in this case, "pheno1_run1" to files that are generated by the pipeline. 

8. **Quality Control Parameters**

   There are four quality filter parameters that SumstatsQC uses to evaluate the quality of GWAS summary statistics. INFO, AF, AFB and AMB. We will explain each parameter briefly in this section. 

   *--INFO=0.3*

   This is the info score criteria. Most publicly available GWAS summary statistics would come with come with imputation quality metric for each variant. If not, users are advised to include a dummy column in the summary statistics. All variants below this threshold would be excluded by the SumstatsQC pipeline. The default is 0.3. However, depending on the requirements of the user, the threshold could be modified. 

   *--AF=0.005*

   The default allele frequency (AF) threshold for excluding variants is 0.005. Users may adjust this threshold according to their requirements. 

   *--AFB=0.15*

   The allele frequency boundary (AFB) threshold is the allele frequency difference between variant allele frequency indicated in the summary statistics and that within the reference panel. The AFB is computed using the absolute allele frequency difference. Variants that have greater that 0.15 difference between summary statistics and the reference panel are removed. 

   *--AMB=0.4*

   Variants with ambiguous alleles AT_CG are further evaluated based on their allele frequencies. Ambgious allele with allele frequencies that are greather than 0.4 are excluded. Depending on the requirements of the user, this threshold could be adjusted.

### **Output files**

The SumstatsQC saves and gzip intermediate and final QC files in a folder - prefix.SumstatsQC.files. Marker files (*.done) and log files are saved in the folder as well. As the pipeline is carried out, marker files are generated as each stage of the quality control procedure is completed. This would be crucial in troubleshooting the pipeline where necessary. The following is an example of files generated from the pipeline: 



#### Summary statistics standardization

In this step, columns within the summary statistics files are standardized according to the headers indicated above. No further filters are applied at this step, and this would include most of the original variants represented in the raw input. 

``` Sumstats Standardization step
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.1.gz
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.standardizecol.sumstats_qc.log
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.sumstats.standardize.done
```

#### Z-score computation 

Next, Z-scores are computed based on p-values. The direction of Z scores are assigned based on the original effect sizes indicated in the summary statistics. These Z-scores derived from P-values are considered standardized Z-scores.  

``` Compute Z-scores
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.2.gz
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.zscore.sumstats_qc.log
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.calculate.Z.done
```
#### Munge Referencel Panel and Sumstats

After computing Z-scores the pipeline would process both reference panel and summary statistics and attempt to match them in five different categories based on CHR:BP:A1:A2. i) Direct match - these variants merge directly from summary statistics with the reference panel ii) allele flip - these would match with the reference panel if there were an allele flip between A1 and A2 iii) alternate strand - variants that matched with the reference panel when strand was flipped iv) finally these included variants from the summary statistics that were not only strand flipped, but required allele flipping as well. The marker files and log files that are generated at this stage is represented as follows"

``` munge ref and sumstats
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.munge.ref.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.munge.sumstats.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.merge.ref.sumstats.done

gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.mungeref.sumstats_qc.log
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.mungestats.sumstats_qc.log
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.mergeref.sumstats_qc.log
```

#### Applying quality control filters on GWAS Summary statistics

After merging with the reference panel, the quality control filters are applied to the summary statistics as indicated above. 

``` Summary statistics QC intermediate files

# variants that fail p-value boundaries. Pvalues 0 or less than 0, or greater than 1 are ecluded

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.5.OB_pval.txt.gz

# autosomal variants that matched with the reference panel but have not yet been qc-ed

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.5.non-qc-ed.txt.gz

# variants that matched with alternate strands

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.ref.5.altstrand.qcparams.txt.gz

# variants that matched with alternate strand alleles that are also flipped

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.ref.5.altstrandflp.qcparams.txt.gz

# variants that have alleles flipped

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.ref.5.flip.qcparams.txt.gz

# variants that matched with reference panel directly

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.ref.5.match.qcparams.txt.gz

# variants that did not match with the referencel panel variants

   gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/sumstats_1.txt.qc.input.1000g_eur.pheno1_run1.sumstats.ref.5.unmatched.qcparams.txt.gz

# stage marker and log files

gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.applyqc.sumstats_qc.log
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.apply.qc.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.post.processing.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.postprc.sumstats_qc.log
```

#### Post-processing step

The post-processing step merges variants that passed qc into a single file. 
The pipeline then checks the file ones more time, to make sure the alleles are fully aligned with the reference panel. 
In addition, variants that have P-values or effect sizes indicated as "NA" or "Inf" are exlucded from the 'finalqc' file. 


``` Postprocessing step 
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.1000G.EUR.ref.SumstatsQC.AF_0.005.INFO_0.3.AFB_0.15.results.txt.gz
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.1000G.EUR.ref.SumstatsQC.AF_0.005.INFO_0.3.AFB_0.15.results.finalqc.txt.gz
```

Thereafter, the post-processing step also extracts variant information from variants that did not pass quality control criteria. The *.excluded.variants.txt.gz file contains of excluded variants in CHR:BP:A1:A2 format. An additional file *.excluded.variants.merged.txt.gz is generated with the qc status included.

``` excluded variants
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.excluded.variants.merged.txt.gz
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.excluded.variants.txt.gz
```

#### QC information extraction step

After QC procedures, a script reads all files that are output by the pipeline, and reads the number of variant count within each output file. This would be logged and eventually the information is concatenated in the SumstatsQC log file. 

``` extract info step
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.extract.qc.info.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.extractinfo.sumstats_qc.log
```

#### Visualization 

Towards the end of the pipeline, a number of plots are generated to visualize the SumstatsQC results. Histograms of the distribution of the INFO score as well as the allele frequency is generate. Scatterplots that show the variant allele frequencies reported the qc-ed summary statistics and that of the reference panel are plotted. Also scatteplots of the -log10P against allele frequencies are visualized to give a overview of the genetic architecture of the phenotype. Finally manhattan plots of the qc-ed variants, and those excluded by quality control procedures are generated to facilitate preliminary compraisons if crucial signals have been excluded by the quality control 

``` visualization
# Post QC Visulization plots
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Histogram_AF_QC.png
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Histogram_INFOSc.png
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Manhattanplot_QC.png
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Manhattanplot_wXvars.png
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Scatterplot_FRQ-F1.png
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1_SumstatsQC_Scatterplot_FRQ-minuslogP.png

# marker and log files from visualization
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.visualization.qc.info.done
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.visualz.sumstats_qc.log
```

#### SumstatsQC logfile

The final logfile is shown below. Users are encouraged to go through the logfile carefully after QC procedures. 
Our initial testing of the pipeline indicates that most sumstats yield between 7 to 10 million variants after QC procedures. 
This would be in the range of common GWAS variants. 

```logfile
gs://sumstatsqc_analysis_1/pheno1_run1.SumstatsQC.files/pheno1_run1.sumstats_qc.log
```
