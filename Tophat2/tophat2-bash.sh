#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

JSON=/input/input-output.json
OUTPUT=/output

#create temporary directory in /tmp
TMP_DIR=$(mktemp -d)

#READ1 READ2 REF variables will be set from input-output.json file using JQ https://stedolan.github.io/jq/
REF=$(jq --raw-output '. | ."reference" // empty' ${JSON} | tr '\n' ' ')
OUTPUTDIR=$(jq --raw-output '. | ."Tophat2-outputdir" // empty' ${JSON} | tr '\n' ' ')
OUTPUTFILE=$(jq --raw-output '. | ."Tophat2-outputfile" // empty' ${JSON} | tr '\n' ' ')
CMD1="bowtie2-build ${REF} ${TMP_DIR}/bowtie2-index"

TYPE=$(jq --raw-output '. | ."read"."type" // empty' ${JSON} | tr '\n' ' ')
if [ ${TYPE} == "paired" ]
then
	READ1=$(jq --raw-output '. | ."read"."read-files"[]."read1" // empty' ${JSON} | tr '\n' ' ')
	READ2=$(jq --raw-output '. | ."read"."read-files"[]."read2" // empty' ${JSON} | tr '\n' ' ')
	CMD2="tophat2 -o ${OUTPUT}/${OUTPUTDIR} ${TMP_DIR}/bowtie2-index ${READ1} ${READ2}"
elif [ ${TYPE} == "single" ]
then
	READ=$(jq --raw-output '. | ."read"."read-files"[]."read" // empty' ${JSON} | tr '\n' ' ')
	CMD2="tophat2 -o ${OUTPUT}/${OUTPUTDIR} ${TMP_DIR}/bowtie2-index ${READ}"
fi
CMD3="cd ${OUTPUT}/${OUTPUTDIR} && mv -f accepted_hits.bam ${OUTPUTFILE}"

eval ${CMD1}
eval ${CMD2}
eval ${CMD3}
