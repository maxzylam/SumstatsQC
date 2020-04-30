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
                $)
                        echo "ERROR:unknown parameter \ "$PARAM\ ""
                        helpscript
                esac
                shift
    done


#############################################

    # Archive folder
    if [ -z "$prefix" ]; then echo "prefix not assigned..exiting.."; exit 1; else echo "prefix=$prefix"; fi
    if [ -z "$bucket" ]; then echo "bucket not assigned..exiting.."; exit 1; else echo "bucket=$bucket"; fi

    echo "Archiving SumstatsQC folder .... to"

    echo "Google Cloud Bucket Location = $bucket"

    gsutil cp -r $prefix.SumstatsQC.files $bucket

    echo "Folder has been archived"
    
    while [ 1 ]; do 
        read -p "Delete folder (y/n)?" CONT1
        if [ "$CONT1" == "y" ]; then
            echo "Deleting ...."
                rm -r $prefix.SumstatsQC.files
            break
        elif [ "$CONT1" == "n" ]; then 
            echo "abort delete folder ...."
            exit 1
        else 
            echo "respond to y or n ? "
        fi
    done

    