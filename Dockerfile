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

USER node-red

WORKDIR /usr/src/node-red

COPY package.json /usr/src/node-red/package.json
RUN ln -s /usr/src/node-red/package.json /data/package.json

RUN npm install --omit=dev

COPY public /usr/src/node-red/public
COPY flows.json /usr/src/node-red/flows.json

COPY settings.js /data
COPY hosts.json /data
COPY dumps.json /data

ENV FLOWS=/usr/src/node-red/flows.json
ENV DATAPATH=/data
ENV APPPATH=/usr/src/node-red
ENV DUMP_DIRECTORY=/dumps
