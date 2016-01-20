#!/usr/bin/env python
# -*- coding: latin1 -*-

import boto
import boto.sqs
from boto.sqs.message import Message
import sys
import json
from pprint import pprint
import codecs

sys.stdout = codecs.getwriter('latin1')(sys.stdout)
sys.stdin  = codecs.getreader('latin1')(sys.stdin)

qname = 'foobar'

# Requires AWS env variables, or metadata role, or ~/.aws/credentials file
s = boto.connect_sqs()
q = s.get_queue(qname)
if q is None:
    raise ValueError("Queue URL not found for queue name '%s'" % (qname))

data = { "id": 42,
         "name": "Foo \xD7\x90 Bar " }
json_data = json.dumps(data,ensure_ascii=False)
##### FUCK YOU PYTHON
print json_data.decode('latin1')

m = Message()
m.set_body(json_data)
q.write(m)
