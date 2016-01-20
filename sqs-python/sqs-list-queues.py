#!/usr/bin/env python

import boto
import boto.sqs
from pprint import pprint

# Requires AWS env variables, or metadata role, or ~/.aws/credentials file
s = boto.connect_sqs()
qurl = s.get_all_queues()
pprint(qurl)
