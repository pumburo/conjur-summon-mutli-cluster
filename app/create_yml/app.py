import os, time, sys

try:
    username = os.environ['APP_USERNAME']
    password = os.environ['APP_PASSWORD']
except:
    username = "Can not pull username"
    password = "Can not pull password"

while True:
    print(username)
    print(password)
    sys.stdout.flush()
    os.chdir('.')
    time.sleep(10)