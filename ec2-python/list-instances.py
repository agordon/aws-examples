#!/usr/bin/env python

import boto.ec2

conn = boto.ec2.connect_to_region('us-east-1')

revs = conn.get_all_reservations()
for r in revs:
    ins = r.instances
    for i in ins:
        instance_tag = i.tags.get('Name','(no tag)')
        print r, i.id, i.instance_type, instance_tag
