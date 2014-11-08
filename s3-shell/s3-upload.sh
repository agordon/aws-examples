#!/bin/sh

## AWS S3 Examples
## Copyright (C) 2014 Assaf Gordon (assafgordon@gmail.com)
## License: GPLv3-or-later

die()
{
    BASE=$(basename -- "$0")
    echo "$BASE error: $@" >&2
    exit 1
}

set_aws_profile_param()
{
    ## Which AWS profile to use from configuration file (~/.aws/config) ?
    ## If empty, uses the [Default].
    AWS_PROFILE_PARAM=""
    test -n "$AWS_PROFILE" && AWS_PROFILE_PARAM="--profile $AWS_PROFILE"
}

usage()
{
    BASE=$(basename "$0")
    echo "Upload Files to AWS S3

Usage: $BASE BUCKET DIRECTORY FILE

Will upload FILE to aws's s3://BUCKET/DIRECTORY/FILE

Example:
  \$ $BASE superduper input/round1  patient0.bam

Will upload 'patient0.bam' to s3://superduper/input/round1/ .

If the upload is successsful, no output is printed to STDOUT,
and the program terminates with exit code 0.

The BUCKET must exist.
The DIRECTORY will be created if needed.
"
    exit 1
}

##
## Input Validation
##
test $# -eq 3 || usage
BUCKET="$1"
DIR="$2"
FILE="$3"

echo "$BUCKET" | grep -qE '^[A-Za-z0-9_\.\-]+$' \
    || die "bucket ($BUCKET) contains forbidden cahracters"
# Not strictly required, but useful to prevent havoc.
echo "$DIR" | grep -qE '^[A-Za-z0-9_\.\-\/]+$' \
    || die "destination directory ($DIR) contains forbidden cahracters"
# Trim backslashes from front/back of directory name
DIR=$(echo "$DIR" | sed -e 's;^/*;;' -e 's;/*$;;' -e 's;//*;/;g')

test -e "$FILE" \
    || die "input file '$FILE' not found"

BASEFILENAME=$(basename -- "FILE")
echo "$BASEFILENAME" | grep -qE '^[A-Za-z0-9_\.\-]+$' \
    || die "filename ($BASEFILENAME) contains forbidden cahracters"



##
## Hack note:
##  aws s3 upload ALWAYS output stuff to STDOUT.
##  if there's no error, we want to discard it.

TMPOUT=$(mktemp -t aws_upload.XXXXXX.log) \
    || die "failed to create temporary output file"
trap "rm -r \"$TMPOUT\"" EXIT

aws $AWS_PROFILE_PARAM \
    s3 cp \
	"$FILE" \
	"s3://$BUCKET/$DIR/$BASEFILENAME" >$TMPOUT 2>&1

# If there were any errors, print aws's output
if test "$?" -ne 0 ; then
    cat "$TMPOUT" >&2
    die "failed to upload file to AWS"
fi
