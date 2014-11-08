#!/bin/sh

## AWS S3 Examples
## Copyright (C) 2014 Assaf Gordon (assafgordon@gmail.com)
## License: GPLv3-or-later

## Example of posting a message to an SQS queue,
## simulating a 'job'.
##
## For this example, each 'job' consists of a filename (assumed to be already
## available on S3 or elsewhere) and a numeric parameter.
##
## The assumption is that a 'worker' on AWS EC2 instance will get this job,
## will download the file, and process it (using another script),
## giving the filename and numeric value as command-line arguments to some
## script.

die()
{
    BASE=$(basename -- "$0")
    echo "$BASE: error: $@" >&2
    exit 1
}

set_aws_profile_param()
{
    ## Which AWS profile to use from configuration file (~/.aws/config) ?
    ## If empty, uses the [Default].
    AWS_PROFILE_PARAM=""
    test -n "$AWS_PROFILE" && AWS_PROFILE_PARAM="--profile $AWS_PROFILE"
}


get_queue_url()
{
    test -n "$1" || die "missing QUEUE_NAME param to get_queue_url()"

    ## Get Qeueu URL from AWS (as JSON reposonse)
    __tmp=$(aws $AWS_PROFILE_PARAM \
                --output=json \
                sqs get-queue-url --queue-name "$1") \
        || die "failed to get queue URL for '$1'"


    ## return queue URL as a string)
    echo "$__tmp" | jq -r '.QueueUrl' \
        || die "failed to extract queue URL from JSON for '$1'"
}

usage()
{
    BASE=$(basename -- "$0")
    echo "SQS Example
Usage:
    $BASE  FILENAME   VALUE

Will queue a JSON 'job' message (containing the filename and value)
to an AWS SQS quque.
"
    exit 1
}

# Default name: sqs_example
QUEUE_NAME=${QUEUE_NAME:-sqs_example}

set_aws_profile_param

FILENAME="$1"
VALUE="$2"
test -z "$FILENAME" || test -z "$VALUE" && usage

echo "$FILENAME" | grep -qE '^[A-Za-z0-9\.\_\=\/]+$' \
    || die "filename '$FILENAME' contains forbidden characters."
echo "$VALUE" | grep -qE '^[0-9]+$' \
    || die "value '$VALUE' is not an integer numeric value."

## Create a boiler-plate JSON message
JSON="{ \"filename\" : \"$FILENAME\", \"value\": $VALUE }"


QUEUE_URL=$(get_queue_url "$QUEUE_NAME") || exit 1
aws $AWS_PROFILE_PARAM \
    sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body "$JSON"
