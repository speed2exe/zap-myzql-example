# zap-myzql-example

## Run MySQL or MariaDB in Docker

```bash
# MySQL
docker run --name some-mysql --env MYSQL_ROOT_PASSWORD=password -p 3306:3306 -d mysql

# MariaDB
docker run --name some-mariadb --env MARIADB_ROOT_PASSWORD=password -p 3306:3306 -d mariadb
```

## Run Server
```bash
zig build run
```

## Test with curl
```bash
curl locahost:3000
```
