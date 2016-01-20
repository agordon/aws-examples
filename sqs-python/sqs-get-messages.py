#!/usr/bin/env python

import boto
import boto.sqs
import sys
import json
from pprint import pprint
import codecs

codecs.getwriter('utf8')(sys.stdout)

qname = 'foobar'

# Requires AWS env variables, or metadata role, or ~/.aws/credentials file
s = boto.connect_sqs()
q = s.get_queue(qname)
if q is None:
    raise ValueError("Queue URL not found for queue name '%s'" % (qname))

# Instead of 'get_messages()' use the simpler 'read()'
msg = q.read()
if msg is None:
    sys.exit("No messages available from queue '%s'" % (qname))

print "queue ", msg.queue.name

try:
    data = json.loads(msg.get_body())
except ValueError as e:
    raise ValueError("received invalid JSON data from SQS queue '%s': msgid '%s' data '%s'" % \
                        (qname, msg.id, msg.get_body()))

print 'Get Data:', data

if not q.delete_message(msg):
    raise IOError("failed to delete SQS message from queue '%s' msgid '%s'" % (qname, msg.id))
