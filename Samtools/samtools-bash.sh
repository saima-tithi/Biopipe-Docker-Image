#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

JSON=/input/input-output.json
OUTPUT=/output

#READ1 READ2 REF variables will be set from bowtie2-input.json file using JQ https://stedolan.github.io/jq/
REF=$(jq --raw-output '. | ."reference" // empty' ${JSON} | tr '\n' ' ')
SAM=$(jq --raw-output '. | ."sam" // empty' ${JSON} | tr '\n' ' ')
DICT=$(jq --raw-output '. | ."dict" // empty' ${JSON} | tr '\n' ' ')
OUTFILE=$(jq --raw-output '. | ."samtools-outputfile" // empty' ${JSON} | tr '\n' ' ')

CMD1="samtools view -bS ${SAM} | samtools sort - -o ${OUTPUT}/${OUTFILE}"
CMD2="samtools index -b ${OUTPUT}/${OUTFILE}"
CMD3="samtools dict ${REF} -o ${DICT}"

eval ${CMD1}
eval ${CMD2}
eval ${CMD3}
