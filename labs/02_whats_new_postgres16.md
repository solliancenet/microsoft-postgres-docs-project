# Hands on Lab: Working with the latest capabilities of Postgres 16

In this lab you will explore the new developer and infrastructure features of PostgreSQL 16.

## Pre-requistes

- [Azure subscription](https://azure.microsoft.com/free/)
- [Resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Database for PostgreSQL Flexible Server instanace](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal)
- [pgAdmin](https://www.pgadmin.org/download/)

## Setup

- Open a command prompt, run the following command to connect to your database:

```cmd
psql -h dev-pg-eastus2-001.postgres.database.azure.com -U s2admin -d sportsdata
```

- Run the following command to import the data to the server

```sql
CREATE TABLE temp (data jsonb);

\COPY temp (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\nbagames.json';

CREATE TABLE games (_id varchar(50), date timestamp, teams jsonb);

INSERT INTO games
SELECT replace(data['_id']['$oid']::varchar(50), '"', ''), cast(to_timestamp(replace(data['date']['$date']::varchar(50), '"', ''), 'yyyy-mm-dd"T"hh24:mi:ss') as date), data['teams']::jsonb
FROM temp;
```

- Open pgAdmin, download and run the `create-load.sql` script to preload the database.
- Review the new items added to the database:

```sql
select * 
from games
```

## Developer Features

### Add SQL/JSON object checks

The `IS JSON` checks include checks for values, arrays, objects, scalars, and unique keys.

- Run the following pre-16 commands:

```sql
SELECT
   _id,
   pg_typeof(teams),
   pg_typeof(teams ->> 'id')
FROM
   games LIMIT 1;
```

- The use of `->` and `->>` are pre-Postgres 14 commands used to navigate a json heiarchy.  The same query can also be written in Postgre 14 and higher, note the usage of the `[` `]`:

```sql
SELECT
   _id,
   pg_typeof(teams),
   pg_typeof(teams['id'])
FROM
   games LIMIT 1;
```

- In Postgres 16, you can now use the following:

```sql
SELECT
   _id,
   teams IS JSON,
   teams['id'] IS JSON
FROM
   games LIMIT 1;
```

- Additionally, you can get more granular about the type of JSON.

```sql
SELECT
   _id,
   teams IS JSON ARRAY,
   teams['id'] IS JSON OBJECT
FROM
   games LIMIT 1;
```

### Add SQL/JSON constructors

In this series of steps, you will review the new functions `JSON_ARRAY()`, `JSON_ARRAYAGG()`, `JSON_OBJECT()`, and `JSON_OBJECTAGG()` that are part of the SQL standard and now PostgreSQL 16.  

- Run the following pre-16 commands:

```sql
SELECT
   json_array(teams['id'])
FROM
   games;
```

```sql

```

### Aggragte funtion ANY_VALUE()

Add aggregate function `ANY_VALUE()` which returns any value from a set

```sql
TODO
```

### COPY from foreign tables

Allow COPY into foreign tables to add rows in batches

```sql
TODO
```

### Allow a COPY FROM value to map to a column's DEFAULT

### Add options to createuser

The new options control the valid-until date, bypassing of row-level security, and role membership.

## Infra Features

### Allow parallelization of FULL and internal right OUTER hash joins

```sql
TODO
```

### Allow aggregate functions string_agg() and array_agg() to be parallelized (David Rowley)

```sql
TODO
```

### Add system view pg_stat_io view to track I/O statistics (Melanie Plageman)

```sql
TODO
```

### Add EXPLAIN option GENERIC_PLAN to display the generic plan for a parameterized query

```sql
TODO
```

### Use new VACUUM options to improve the performance

```sql
TODO
```

### Using pg_stat_io for enhanced IO monitoring

```sql
TODO
```