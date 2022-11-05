FROM nginx
ARG namespace
MAINTAINER Mahmut Gur

RUN apt-get update && \
    apt-get install -y python3

RUN mkdir /app

COPY summon /usr/local/bin/summon
COPY summon-conjur /usr/local/bin/summon-conjur
COPY secrets.yml /app/secrets.yml
COPY app.py /app/app.py
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod 644 /app/secrets.yml
RUN chmod a+x /app/entrypoint.sh
RUN chmod +x /usr/local/bin/summon
RUN chmod +x /usr/local/bin/summon-conjur

ENTRYPOINT ["/app/entrypoint.sh"]