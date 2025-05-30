FROM nodered/node-red:4.0.9-debian

USER root

RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN . /etc/os-release && sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
RUN apt update && apt install -y \
    postgresql-client-14 \
    postgresql-client-15 \
    postgresql-client-16 \
    postgresql-client-17

COPY package.json /data
COPY package-lock.json /data
COPY public /data/public
COPY flows.json /data
COPY settings.js /data
COPY hosts.json /data

WORKDIR /data

RUN npm ci --omit=dev

WORKDIR /usr/src/node-red

ENV DATAPATH=/data
