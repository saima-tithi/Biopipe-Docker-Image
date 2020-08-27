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
OUTFILE=$(jq --raw-output '. | ."BWA-outputfile" // empty' ${JSON} | tr '\n' ' ')
CMD1="bwa index ${REF}"

eval ${CMD1}

TYPE=$(jq --raw-output '. | ."read"."type" // empty' ${JSON} | tr '\n' ' ')
if [ ${TYPE} == "paired" ]
then
	READ1=$(jq --raw-output '. | ."read"."read-files"[]."read1" // empty' ${JSON} | tr '\n' ' ')
	READ2=$(jq --raw-output '. | ."read"."read-files"[]."read2" // empty' ${JSON} | tr '\n' ' ')
	CMD2="bwa aln ${REF} ${READ1} > ${TMP_DIR}/bwa-read1.sai"
	CMD3="bwa aln ${REF} ${READ2} > ${TMP_DIR}/bwa-read2.sai"
	eval ${CMD2}
	eval ${CMD3}
	CMD4="bwa sampe ${REF} ${TMP_DIR}/bwa-read1.sai ${TMP_DIR}/bwa-read2.sai ${READ1} ${READ2} > ${TMP_DIR}/${OUTFILE}"
elif [ ${TYPE} == "single" ]
then
	READ=$(jq --raw-output '. | ."read"."read-files"[]."read" // empty' ${JSON} | tr '\n' ' ')
	CMD2="bwa aln ${REF} ${READ} > ${TMP_DIR}/bwa-read.sai"
	eval ${CMD2}
	CMD4="bwa samse ${REF} ${TMP_DIR}/bwa-read.sai ${READ} > ${TMP_DIR}/${OUTFILE}"
fi

eval ${CMD4}

cp ${TMP_DIR}/${OUTFILE} ${OUTPUT}
