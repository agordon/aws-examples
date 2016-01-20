#!/usr/bin/env python

import boto
from pprint import pprint

bucket_name = 'foobar'

conn = boto.connect_s3()
try:
    mybucket = conn.get_bucket(bucket_name)
except Exception as e:
    raise ValueError("failed to connect to bucket '%s': %s" % ( bucket_name, str(e)))

for key in mybucket.list(prefix="public",marker="/"):
    print "s3://", key.bucket.name, "/", key.key, "\t", key.size
