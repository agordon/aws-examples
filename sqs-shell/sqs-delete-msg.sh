#!/bin/sh

## Example of deleting a message from an SQS queue,
## simulating a completed 'job'.
##

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
    $BASE RECEIPT-HANDLE

Will delete an SQS message with the given receipt-handle.
The RECEIPT-HANDLE is printed using 'sqs-get-msg.sh' when a message
is received.
"
    exit 1
}

# Default name: sqs_example
QUEUE_NAME=${QUEUE_NAME:-sqs_example}

test -z "$1" && usage
RECEIPT="$1"

set_aws_profile_param

QUEUE_URL=$(get_queue_url "$QUEUE_NAME") || exit 1
aws $AWS_PROFILE_PARAM \
    --output=json \
    sqs delete-message \
    --queue-url "$QUEUE_URL" \
    --receipt-handle "$RECEIPT" \
    || die "failed to delete-message from SQS queue '$QUEUE_NAME'"


