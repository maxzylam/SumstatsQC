git commit -a -m "Changes to be committed"
git push
gsutil cp *.sh gs://summary-stats-qc-impute-1/quality-control-reffiles/WORKING_FOLDER
gsutil cp SumstatsQC gs://summary-stats-qc-impute-1/quality-control-reffiles/WORKING_FOLDER
