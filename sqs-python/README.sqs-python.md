## Installation

    sudo pip install boto

## Creating a new Queue

The `boto.sqs.connection.create_queue()` function does not allow changing
some of the important attributes of a queue (any attribute except
`VisibilityTimeout`). So don't use it. Use the shell version instead
(`aws sqs create-queue` - see example in `sqs-shell/sqs-create-queue.sh`).

## AWS Key Configuration

Use AWS environment variables,
or metadata role (when running in an instance),
or `~/.aws/credentials` (which is similar in syntax to `~/.aws/config`).
