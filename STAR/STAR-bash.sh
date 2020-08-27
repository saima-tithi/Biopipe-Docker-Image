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
GTF=$(jq --raw-output '. | ."gtf-annotation" // empty' ${JSON} | tr '\n' ' ')
OUTPUTDIR=$(jq --raw-output '. | ."STAR-outputdir" // empty' ${JSON} | tr '\n' ' ')
OUTPUTPREFIX=$(jq --raw-output '. | ."STAR-outputprefix" // empty' ${JSON} | tr '\n' ' ')
OUTPUTFILE=$(jq --raw-output '. | ."STAR-outputfile" // empty' ${JSON} | tr '\n' ' ')
CMD1="STAR --runMode genomeGenerate --genomeDir ${TMP_DIR} --genomeFastaFiles ${REF} --sjdbGTFfile ${GTF}"
CMD2="cd ${OUTPUT} && mkdir ${OUTPUTDIR}"

TYPE=$(jq --raw-output '. | ."read"."type" // empty' ${JSON} | tr '\n' ' ')
if [ ${TYPE} == "paired" ]
then
	READ1=$(jq --raw-output '. | ."read"."read-files"[]."read1" // empty' ${JSON} | tr '\n' ' ')
	READ2=$(jq --raw-output '. | ."read"."read-files"[]."read2" // empty' ${JSON} | tr '\n' ' ')
	CMD3="cd ${OUTPUT}/${OUTPUTDIR} && STAR --genomeDir ${TMP_DIR} --readFilesIn ${READ1} ${READ2} --outSAMstrandField intronMotif --outFileNamePrefix ${OUTPUTPREFIX} --outSAMtype BAM SortedByCoordinate"
elif [ ${TYPE} == "single" ]
then
	READ=$(jq --raw-output '. | ."read"."read-files"[]."read" // empty' ${JSON} | tr '\n' ' ')
	CMD3="cd ${OUTPUT}/${OUTPUTDIR} && STAR --genomeDir ${TMP_DIR} --readFilesIn ${READ} --outSAMstrandField intronMotif --outFileNamePrefix ${OUTPUTPREFIX} --outSAMtype BAM SortedByCoordinate"
fi
CMD4="cd ${OUTPUT}/${OUTPUTDIR} && mv -f STAR-outputAligned.sortedByCoord.out.bam ${OUTPUTFILE}"

eval ${CMD1}
eval ${CMD2}
eval ${CMD3}
eval ${CMD4}
