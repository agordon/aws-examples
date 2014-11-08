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
    echo "Downloads Files from AWS S3

Usage: $BASE BUCKET DIRECTORY REMOTE-FILE LOCAL-FILE

Will download s3://BUCKET/DIRECTORY/REMOTE-FILE to LOCAL-FILE

Example:
  \$ $BASE superduper input/round1 patient0.bam /tmp/foo.bam

Will download s3://superduper/input/round1/patient0.bam and save it as
/tmp/foo.bam .

If the download is successsful, no output is printed to STDOUT,
and the program terminates with exit code 0.
"
    exit 1
}

##
## Input Validation
##
test $# -eq 4 || usage
BUCKET="$1"
DIR="$2"
REMOTEFILE="$3"
LOCALFILE="$4"

echo "$BUCKET" | grep -qE '^[A-Za-z0-9_\.\-]+$' \
    || die "bucket ($BUCKET) contains forbidden cahracters"
# Not strictly required, but useful to prevent havoc.
echo "$DIR" | grep -qE '^[A-Za-z0-9_\.\-\/]+$' \
    || die "destination directory ($DIR) contains forbidden cahracters"
# Trim backslashes from front/back of directory name
DIR=$(echo "$DIR" | sed -e 's;^/*;;' -e 's;/*$;;' -e 's;//*;/;g')

BASEFILENAME=$(basename -- "$REMOTEFILE")
echo "$BASEFILENAME" | grep -qE '^[A-Za-z0-9_\.\-]+$' \
    || die "filename ($BASEFILENAME) contains forbidden cahracters"

test -e "$LOCALFILE" \
    && die "local file ($LOCALFILE) already exists. " \
            "cowardly refusing to overwrite it.".

##
## Hack note:
##  aws s3 download ALWAYS output stuff to STDOUT.
##  if there's no error, we want to discard it.

TMPOUT=$(mktemp -t aws_download.XXXXXX.log) \
    || die "failed to create temporary output file"
trap "rm -r \"$TMPOUT\"" EXIT

aws $AWS_PROFILE_PARAM \
    s3 cp \
	"s3://$BUCKET/$DIR/$BASEFILENAME" \
    "$LOCALFILE" >$TMPOUT 2>&1

# If there were any errors, print aws's output
if test "$?" -ne 0 ; then
    cat "$TMPOUT" >&2
    die "failed to download file to AWS"
fi
