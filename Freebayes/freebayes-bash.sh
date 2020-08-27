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
OUTFILE=$(jq --raw-output '. | ."Freebayes-outputfile" // empty' ${JSON} | tr '\n' ' ')

CMD1="freebayes -f ${REF} -b ${BAM} > ${TMP_DIR}/${OUTFILE}"

eval ${CMD1}

cp ${TMP_DIR}/${OUTFILE} ${OUTPUT}
