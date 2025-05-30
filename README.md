# DB Dump Agent

Dump & restore your database!

Run the agent:

```
docker run -d -v db-dump-avent:/data  -v db-dumps:/dump -p 1880:1880 -e SECRET_KEY=verysecretkey --name db-dump-agent saashup/db-dump-agent
```
