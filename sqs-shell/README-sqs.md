## Creating a queue

Using default AWS profile:

    $ ./sqs-create-queue.sh
    ----------------------------------------------------------------------
    |                             CreateQueue                            |
    +----------+---------------------------------------------------------+
    |  QueueUrl|  https://queue.amazonaws.com/498194832039/sqs_example   |
    +----------+---------------------------------------------------------+


Using a specific AWS profile:

    $ AWS_PROFILE=gordon ./sqs-create-queue.sh
    ----------------------------------------------------------------------
    |                             CreateQueue                            |
    +----------+---------------------------------------------------------+
    |  QueueUrl|  https://queue.amazonaws.com/498194832039/sqs_example   |
    +----------+---------------------------------------------------------+

Creating a custom named queue:

    $ QUEUE_NAME=foobar ./sqs-create-queue.sh
    ----------------------------------------------------------------------
    |                             CreateQueue                            |
    +----------+---------------------------------------------------------+
    |  QueueUrl|  https://queue.amazonaws.com/498194832039/foobar        |
    +----------+---------------------------------------------------------+

## Posting a JSON message

    $ ./sqs-post-msg.sh FOOBAR.txt 42
    ------------------------------------------------------------------------------
    |                                 SendMessage                                |
    +-----------------------------------+----------------------------------------+
    |         MD5OfMessageBody          |               MessageId                |
    +-----------------------------------+----------------------------------------+
    |  24280a5c7d8beca5223d7f2e3e00fa39 |  45022de6-9fd1-4874-b00c-c02f7382062a  |
    +-----------------------------------+----------------------------------------+


## Getting a message

    $ ./sqs-get-msg.sh
    FILENAME: FOOBAR.txt
    VALUE: 42
    RECEIPT-HANDLE: ib8MCWgVft3j+SGPsuD9qJ2qEh34dP1ujcmigqoY3QWRL0ZT7iYMDwE20VNONdlQ1aCGGTW9EhRGTiNk467apJDWoCNbgzZ3xC7ppZwN/tMNhNiv6Sya3tmupzEc+NmALSstKGTPTDsfPKM0EYHCNruQUfaO+j0trENyXjRH41HXSNF0FMHNkUlPyqkpKdeeiAMoshSxTIqTyFBy8L5cj8T8LTMGISW7h6uJyzaowN7TMqgYuhBgIvH5SW5hBrMYkzLmsOgQ/0laxn9nRSxiY5LQ0xCRSVGv1z9OdHsr1+4=

## Deleting a message

A message should be delete (=acked) after processing is complete.

    $ ./sqs-delete-msg.sh ib8MCWgVft3j+SGPsuD9qJ2qEh34dP1ujcmigqoY3QWRL0ZT7iYMDwE20VNONdlQ1aCGGTW9EhRGTiNk467apJDWoCNbgzZ3xC7ppZwN/tMNhNiv6Sya3tmupzEc+NmALSstKGTPTDsfPKM0EYHCNruQUfaO+j0trENyXjRH41HXSNF0FMHNkUlPyqkpKdeeiAMoshSxTIqTyFBy8L5cj8T8LTMGISW7h6uJyzaowN7TMqgYuhBgIvH5SW5hBrMYkzLmsOgQ/0laxn9nRSxiY5LQ0xCRSVGv1z9OdHsr1+4=

