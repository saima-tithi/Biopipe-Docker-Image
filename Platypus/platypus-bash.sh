#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

JSON=/input/input-output.json
OUTPUT=/output

#create temporary directory in /tmp
TMP_DIR=$(mktemp -d)

#READ1 READ2 REF variables will be set from bowtie2-input.json file using JQ https://stedolan.github.io/jq/
REF=$(jq --raw-output '. | ."reference" // empty' ${JSON} | tr '\n' ' ')
BAM=$(jq --raw-output '. | ."bam" // empty' ${JSON} | tr '\n' ' ')
OUTFILE=$(jq --raw-output '. | ."Platypus-outputfile" // empty' ${JSON} | tr '\n' ' ')

CMD1="export PATH=$PATH:/opt/bin"
CMD2="Platypus.py callVariants --bamFiles=${BAM} --refFile=${REF} --output=${TMP_DIR}/${OUTFILE}"

eval ${CMD1}
eval ${CMD2}

cp ${TMP_DIR}/${OUTFILE} ${OUTPUT}
