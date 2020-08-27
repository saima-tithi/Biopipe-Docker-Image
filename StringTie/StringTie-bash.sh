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
OUTPUTDIR=$(jq --raw-output '. | ."StringTie-outputdir" // empty' ${JSON} | tr '\n' ' ')
OUTPUTFILE=$(jq --raw-output '. | ."StringTie-outputfile" // empty' ${JSON} | tr '\n' ' ')
  
OUTTAB=$(jq --raw-output '. | ."StringTie-outputfile.gene_abund.tab" // empty' ${JSON} | tr '\n' ' ')
OUTREFGTF=$(jq --raw-output '. | ."StringTie-outputfile.cov_ref.gtf" // empty' ${JSON} | tr '\n' ' ')

CMD1="cd ${OUTPUT} && mkdir ${OUTPUTDIR}"
CMD2="cd ${OUTPUT}/${OUTPUTDIR} && stringtie $BAM -G $GTF -v -p 20 -o ${OUTPUTFILE} -A ${OUTTAB} -C ${OUTREFGTF}"

eval ${CMD1}
eval ${CMD2}
