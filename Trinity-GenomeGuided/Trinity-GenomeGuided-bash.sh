#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

JSON=/input/input-output.json
OUTPUT=/output

#create temporary directory in /tmp
TMP_DIR=$(mktemp -d)

#Trinity genome guided assemlby uses the BAM file as input
BAM=$(jq --raw-output '. | ."bam" // empty' ${JSON} | tr '\n' ' ')
OUTPUTDIR=$(jq --raw-output '. | ."Trinity-GenomeGuided-outputdir" // empty' ${JSON} | tr '\n' ' ')
OUTPUTFILE=$(jq --raw-output '. | ."Trinity-GenomeGuided-outputfile" // empty' ${JSON} | tr '\n' ' ')

CMD1="Trinity --genome_guided_bam ${BAM} --genome_guided_max_intron 10000 --max_memory 16G --CPU 10 --output ${OUTPUT}/trinity-output"
CMD2="cd ${OUTPUT} && mv -f trinity-output ${OUTPUTDIR}"

eval ${CMD1}
eval ${CMD2}
