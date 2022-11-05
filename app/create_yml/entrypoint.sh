#!/bin/bash

cat << EOF >> /app/secrets.yml
APP_USERNAME: !var ${SECRET_PATH_1}
APP_PASSWORD: !var ${SECRET_PATH_2}
EOF

chmod 644 /app/secrets.yml

/usr/local/bin/summon --provider /usr/local/bin/summon-conjur -f /app/secrets.yml python3 /app/app.py
