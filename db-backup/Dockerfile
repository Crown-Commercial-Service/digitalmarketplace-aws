FROM python:3.6.12-slim

RUN mkdir /app

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends gnupg2 jq wget vim curl 

# Create the file repository configuration:
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Update the package lists:
RUN apt-get update

# Install the version of PostgreSQL.
RUN apt-get -y install postgresql-client-12

COPY /create-db-dump.sh /app/create-db-dump.sh
COPY /upload-dump-to-s3.py /app/upload-dump-to-s3.py

CMD ["tail", "-f", "/dev/null"]
