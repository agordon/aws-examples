## Uploading a file

Syntax:

    $ ./s3-upload.sh BUCKET DEST-DIR LOCAL-FILE

Example:

    $ ./s3-updload.sh gordon input/round1/ /home/gordon/projects/patient0.bam

Will upload `/home/gordon/projects/patient0.bam` into `s3://gordon/input/round1/patient0.bam`
(assuming bucket `gordon` already exists).


## Downloading a file

    $ ./s3-download.sh gordon input/round1 patient0.bam /tmp/test.bam

Will download `s3://gordon/input/round1/patient0.bam` to local file `/tmp/test.bam`.

## Listing avaiable/accessible buckets:

    $ aws s3 ls
    gordon
    teamerlich

# Listing content of a bucket

    $ aws s3 ls s3://gordon
        PRE input/

    $ aws s3 ls --recursive s3://gordon
    2014-11-08 02:48:00        354 input/round1/patient0.bam

