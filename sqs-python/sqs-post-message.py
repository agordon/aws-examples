#!/usr/bin/env python

import boto
import boto.sqs
from boto.sqs.message import Message
import sys
import json
from pprint import pprint

qname = 'foobar'

# Requires AWS env variables, or metadata role, or ~/.aws/credentials file
s = boto.connect_sqs()
q = s.get_queue(qname)
if q is None:
    raise ValueError("Queue URL not found for queue name '%s'" % (qname))

data = { "id": 42, "name": "Foo Bar" }
json_data = json.dumps(data)

m = Message()
m.set_body(json_data)
q.write(m)
