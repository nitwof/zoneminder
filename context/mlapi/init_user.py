import os
from passlib.hash import bcrypt
from tinydb import TinyDB

username = os.getenv('MLAPI_USER')
password = os.getenv('MLAPI_PASSWORD')

db = TinyDB('./db/db.json')
users = db.table('users')
if username and password and not len(users):
  users.insert({
      'name': username,
      'password': bcrypt.hash(password)
  })
  print ('------- User: {} created ----------------'.format(username))