#!/bin/sh

##
## Example of Creating SQS queue from the command line.
## See 'aws sqs create-queue help' for details about the attributes.
##

set_aws_profile_param()
{
    ## Which AWS profile to use from configuration file (~/.aws/config) ?
    ## If empty, uses the [Default].
    AWS_PROFILE_PARAM=""
    test -n "$AWS_PROFILE" && AWS_PROFILE_PARAM="--profile $AWS_PROFILE"
}

# Default name: sqs_example
QUEUE_NAME=${QUEUE_NAME:-sqs_example}

# Default 4KB.
# For this example, we assume messages contain short JSON file with file names,
# not actual raw data.
MAX_MESSAGE_SIZE=4096

# Default: 4 days
#  after 4 days, unprocessed messages will be discarded.
MESSAGE_RETENTION_PERIOD=345600


# Defualt: 12 hours.
#   An un-deleted (un-acked) message will re-appear in the queue after
#   12 hours.
VISIBILITY_TIMEOUT=43200

ATTR="MaximumMessageSize=$MAX_MESSAGE_SIZE,\
MessageRetentionPeriod=$MESSAGE_RETENTION_PERIOD,\
VisibilityTimeout=$VISIBILITY_TIMEOUT"

set_aws_profile_param

aws $AWS_PROFILE_PARAM sqs create-queue --queue-name "$QUEUE_NAME" \
    --attributes "$ATTR"
