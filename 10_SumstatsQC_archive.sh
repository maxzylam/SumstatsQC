#!/bin/bash

    function helpscript {
        echo ""
        echo "SumstatsQC folder that is completed would be archived to google cloud" 
        echo "bucket"
    }

    while [ "$1" != "" ];do
        PARAM=`echo $1 | awk -F= '{print $1}'`
        VALUE=`echo $1 | awk -F= '{print $2}'`
        case $PARAM in
                -h | --help)
                        helpscript
                        exit 1
                        ;;
                --prefix)
                        prefix=$VALUE
                        ;;
                --bucket)
                        bucket=$VALUE
                        ;;
                --archive)
                        archive=$VALUE
                        ;;
                $)
                        echo "ERROR:unknown parameter \ "$PARAM\ ""
                        helpscript
                esac
                shift
    done


#############################################

    # Archive folder
    
    if [ "$archive" == "Y" ]; then
    
        # find folder

        finalfolder=$(ls | grep $prefix.SumstatsQC.files)

        if [ "$finalfolder" == "$prefix.SumstatsQC.files" ]; then 

            echo "Found folder....."

            if [ -z "$prefix" ]; then echo "prefix not specified"; exit 1; else echo "checking prefix..."; fi
            if [ -z "$bucket" ]; then echo "bucket not specified"; exit 1; else echo "checking bucket..."; fi

            gsutil mv $prefix.SumstatsQC.files $bucket

            rm -r $prefix.SumstatsQC.files
        
        else

            echo "Can't seem to find sumstatsQC folder with completed files"
            echo "Perhaps something broke during the QC procedure. Now exiting..."
            exit 1
        
        fi 

    fi