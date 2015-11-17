#!/usr/bin/env python
import MySQLdb
from unifi import Controller


c = Controller("unifi.area.sdok.no", "username", "password", "8443", "v4", "default")

db = MySQLdb.connect(host="localhost",
                     user="lcs",
                      passwd="db_password",
                      db="lcs")
cur = db.cursor()

aps = []

for ap in c.get_aps():
    cur.execute('''INSERT into aps (`id`, `mac`, `ip`) values (%s, %s, %s)''', (ap['_id'], ap['mac'], ap['ip']))
