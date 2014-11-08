#!/bin/sh

## AWS S3 Examples
## Copyright (C) 2014 Assaf Gordon (assafgordon@gmail.com)
## License: GPLv3-or-later

## Example of getting a message from an SQS queue,
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
    $BASE

Will get a job from the SQS queue,
printing the filename, value and receipt handle.

"
    exit 1
}

# Default name: sqs_example
QUEUE_NAME=${QUEUE_NAME:-sqs_example}

set_aws_profile_param

QUEUE_URL=$(get_queue_url "$QUEUE_NAME") || exit 1
JSON=$(aws $AWS_PROFILE_PARAM \
    --output=json \
    sqs receive-message \
    --queue-url "$QUEUE_URL") \
    || die "failed to receive-message from SQS queue '$QUEUE_NAME'"

# Number of messages
NUM=$(echo "$JSON" | jq '.Messages | length') \
    || die "failed to get number of messages from JSON: $JSON"

## Quit if no messages
test "$NUM" -eq 0 && die "no pending messages";

## We expect exactly one message
test "$NUM" -eq 1 \
    || die "got too many messages from SQS: $JSON"

## Extract Receipt Handle from JSON
RECEIPT=$(echo "$JSON" | jq -r '.Messages[] | .ReceiptHandle') \
    || die "failed to extract ReceiptHandle from JSON: $JSON"

## The Extract the body of the message - which is itself a JSON file.
BODY=$(echo "$JSON" | jq -r '.Messages[] | .Body') \
    || die "failed to extract message body from JSON: $JSON"
FILENAME=$(echo "$BODY" | jq -r '.filename') \
    || die "failed to extract job's filename from JSON: $JSON"
VALUE=$(echo "$BODY" | jq -r '.value') \
    || die "failed to extract job's value from JSON: $JSON"

echo "FILENAME: $FILENAME
VALUE: $VALUE
RECEIPT-HANDLE: $RECEIPT"

