FROM python:3.6-slim

RUN mkdir /app

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends gnupg2 jq wget vim curl postgresql-client

COPY /create-db-dump.sh /app/create-db-dump.sh
COPY /upload-dump-to-s3.py /app/upload-dump-to-s3.py

CMD ["tail", "-f", "/dev/null"]
