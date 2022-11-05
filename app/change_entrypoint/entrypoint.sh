#!/bin/bash

/usr/local/bin/summon -e ${ENV_SELECTOR} --provider /usr/local/bin/summon-conjur -f /app/secrets.yml python3 /app/app.py
