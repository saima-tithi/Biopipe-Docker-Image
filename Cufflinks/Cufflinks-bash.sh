#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

JSON=/input/input-output.json
OUTPUT=/output

#create temporary directory in /tmp
TMP_DIR=$(mktemp -d)

#REF GTF BAM variables will be set from input-output.json file using JQ https://stedolan.github.io/jq/
REF=$(jq --raw-output '. | ."reference" // empty' ${JSON} | tr '\n' ' ')
GTF=$(jq --raw-output '. | ."gtf-annotation" // empty' ${JSON} | tr '\n' ' ')
BAM=$(jq --raw-output '. | ."bam" // empty' ${JSON} | tr '\n' ' ')
OUTPUTDIR=$(jq --raw-output '. | ."Cufflinks-outputdir" // empty' ${JSON} | tr '\n' ' ')
OUTPUTFILE=$(jq --raw-output '. | ."Cufflinks-outputfile" // empty' ${JSON} | tr '\n' ' ')

CMD1="cufflinks --num-threads 4 --GTF-guide $GTF --library-type fr-unstranded --output-dir ${OUTPUT}/${OUTPUTDIR} $BAM"
CMD2="cd ${OUTPUT}/${OUTPUTDIR} && mv -f transcripts.gtf ${OUTPUTFILE}"

eval ${CMD1}
eval ${CMD2}
