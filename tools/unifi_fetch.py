#!/usr/bin/env python
import MySQLdb
from unifi import Controller


c = Controller("10.13.37.42", "ole", "Hjemmeserver15", "8443", "v4", "default")

db = MySQLdb.connect(host="localhost",
                     user="lcs",
                      passwd="V26F5RfZ4Xk3",
                      db="lcs")
cur = db.cursor()

aps = []

for ap in c.get_aps():
    cur.execute('''INSERT into aps (`id`, `mac`, `ip`, `alias`) values (%s, %s, %s, %s)''', (ap['_id'], ap['mac'], ap['ip'], ap['name']))
