# Hands on Lab: Working with the latest capabilities of Postgres 16

In this lab you will explore the new developer and infrastructure features of PostgreSQL 16.

## Pre-requistes

- [Azure subscription](https://azure.microsoft.com/free/)
- [Resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Database for PostgreSQL Flexible Server instanace](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal)
- [pgAdmin](https://www.pgadmin.org/download/)
- `psql` access
- Perform Lab 01 steps

## Setup

- Open a command prompt, run the following command to connect to your database:

```cmd
psql -h PREFIX-pg-flex-eastus-16.postgres.database.azure.com -U s2admin -d airbnb
```

- Run the following command to import the data to the server

```sql
CREATE TABLE temp_calendar (data jsonb);
CREATE TABLE temp_listings (data jsonb);
CREATE TABLE temp_reviews (data jsonb);

\COPY temp_calendar (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\calendar.json';
\COPY temp_listings (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\listings.json';
\COPY temp_reviews (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\reviews.json';

CREATE TABLE listings (listing_id varchar(50), data jsonb);
CREATE TABLE reviews (listing_id varchar(50), data jsonb);
CREATE TABLE calendar (listing_id varchar(50), data jsonb);

INSERT INTO listings
SELECT replace(data['id']::varchar(50), '"', ''), data::jsonb
FROM temp_listings;

INSERT INTO reviews
SELECT replace(data['listing_id']::varchar(50), '"', ''), data::jsonb
FROM temp_reviews;

INSERT INTO calendar
SELECT replace(data['listing_id']::varchar(50), '"', ''), data::jsonb
FROM temp_calendar;
```

- Review the new items added to the database:

```sql
select * from listings;
select * from reviews;
select * from calendar;
```

## Developer Features

There are several developer based changes in PostgreSQL. Here we explore some of them.

- [Function Json](https://www.postgresql.org/docs/16/functions-json.html)

### Add SQL/JSON object checks

The `IS JSON` checks include checks for values, arrays, objects, scalars, and unique keys.

- Run the following pre-16 commands:

```sql
SELECT
   listing_id,
   pg_typeof(data),
   pg_typeof(data ->> 'id')
FROM
   listings LIMIT 1;
```

- The use of `->` and `->>` are pre-Postgres 14 commands used to navigate a json heiarchy.  The same query can also be written in Postgre 14 and higher, note the usage of the `[` `]`:

```sql
SELECT
   listing_id,
   pg_typeof(data),
   pg_typeof(data['id'])
FROM
   listings LIMIT 1;
```

- In Postgres 16, you can now use the following:

```sql
SELECT
   listing_id,
   data IS JSON,
   data['id'] IS JSON
FROM
   listings LIMIT 1;
```

- Additionally, you can get more granular about the type of JSON.

```sql
SELECT
   listing_id,
   data IS JSON ARRAY,
   data['id'] IS JSON OBJECT
FROM
   listings LIMIT 1;
```

### Add SQL/JSON constructors

In this series of steps, you will review the new functions `JSON_ARRAY()`, `JSON_ARRAYAGG()`, `JSON_OBJECT()`, and `JSON_OBJECTAGG()` that are part of the SQL standard and now PostgreSQL 16.  

- Run the following pre-16 commands:

```sql
SELECT
   json_array(data['id'])
FROM
   listings;
```

```sql

```

### Aggragte funtion ANY_VALUE()

The `ANY_VALUE()` function is a PostgreSQL aggregate function that helps optimize queries when utilizing GROUP BY clauses. The function will return an arbitrary non-null value in a given set of values.

Prior to PostgreSQL 16, when using GROUP BY, all non-aggregated columns from the SELECT statement were included in the GROUP BY clause as well. Pre-16 PostgreSQL would throw an error if a non-aggregated column is not added in the GROUP BY clause.

The following is an example of pre-16 syntax:

```sql
SELECT country,MAX(city) as city_name,SUM(population) as total_population from city_data group by country limit 10;
```

This is the new v16 syntax:

```sql
SELECT country,ANY_VALUE(city) as city_name, SUM(population) from city_data as total_population group by country ;
```

### COPY from foreign tables

Allow COPY into foreign tables to add rows in batches

```sql
TODO
```

### Allow a COPY FROM value to map to a column's DEFAULT

### Add options to createuser

The new options control the valid-until date, bypassing of row-level security, and role membership.

```sql
select count(*) from sales_order so1 FULL OUTER JOIN sales_order so2 USING (id)
```

## Infra Features

### Allow parallelization of FULL and internal right OUTER hash joins

The more things you can do in parallel the faster you will get results.  As is the case when performing `FULL` and internal rigth `OUTER` joins.  Previous to PostgreSQL these would not have been executed in parallel and the costs where more to perform them.

With this change, any queries you were performing using these joins will now run drastically faster.

Here are some examples of performing these types of joins:

```sql
select count(*) from sales_order so1 FULL OUTER JOIN sales_order so2 USING (id)
```

### Allow aggregate functions string_agg() and array_agg() to be parallelized

Aggregate functions typically perform some kind of mathmatical operation on a column or set of columns.  If you were to calculate several aggregates at once, you could probably imagine that doing each one in a serialized manner would likely take much longer than doing it in a parallel manner.

Not all aggregate functions have supported this type of optimization, as such with the `string_agg()` and `array_agg()` functions.  In PostgreSQL 16, this support was added and per the description on the code commit **adds combine, serial and deserial functions for the array_agg() and string_agg() aggregate functions, thus allowing these aggregates to
partake in partial aggregations.  This allows both parallel aggregation to
take place when these aggregates are present and also allows additional
partition-wise aggregation plan shapes to include plans that require
additional aggregation once the partially aggregated results from the
partitions have been combined.**

The following is an example of a query that performs aggregates with the two functions included.  If this were to run on a pre-16 version, the query would be much slower than in version 16.

```sql
TODO
```

To compare between versions, you can use the `EXPLAIN` command to see that the query plan in 16 will display a `FINALIZE GroupAggregate` versus a much more costly pre-16 `HashAggregate`.

For a more in-depth look at the code change for this feature, reference [here](https://git.postgresql.org/gitweb/?p=postgresql.git;a=commitdiff;h=16fd03e956540d1b47b743f6a84f37c54ac93dd4).

### Add EXPLAIN option GENERIC_PLAN to display the generic plan for a parameterized query

Previously, attempting to get an execution plan for a parameterized query was fairly complicated.  For example, using a prepared statement will have several executions which may required you to execute those all seperately and then put the results together.  Using the new feature will elimenate those extra steps.

Attempt to get an execution plan for a parameterized query using the old way:

```sql
EXPLAIN SELECT * FROM pg_class WHERE relname = $1;
```

You should get an error.

To get an execution plan for a parametrized query, run the following:

```sql
EXPLAIN (GENERIC_PLAN) SELECT * FROM pg_class WHERE relname = $1;
```

> Note the use of the parenthesis.  The old way (shown above) was to not utilize parenthesis and is only for backwards compatability. Newer options such as `GENERIC_PLAN` will only work with the new syntax.

As you can see above, you can use parameter placeholders like `$1` instead of an unknown or variable value. However, there are certain restrictions:

- You can use parameters only with the statements SELECT, INSERT, UPDATE, DELETE and VALUES.
- You can only use parameters instead of constants (literals). You can’t use parameters instead of identifiers (object names) or keywords, among other things.

### Use new VACUUM options to improve the performance

The PostgreSQL `VACUUM` command is used to garbage-collect and analyze databases.  It works by removing `dead` tuples left over by large changes to a database (such as frequently updated tables). By removing the gaps between the data, you can speed up the performance of specific operations and increase your disk space.

Once of the new features to `VACUUM` in Postgres 16 is the ability to update the cost limit on the fly.  This will allow people that run large production databases that may be running out of disk space a bit too quickly; which if to occur, would likely take down the production system. to get VACUUM to execute faster. During a `VACUUM` is could be that it is not running as fast as it needs to because of the cost limit.

By allowing the change during the operation, you can speed up the `VACUUM` operation without restarting it.

These server parameters are called `vacuum_cost*` or `auto_vacuum_vacuum_cost*`. The default for the `vacuum_cost_limit` is `200` and `auto_vacuum_vacuum_cost` is `-1` which indicates to use the default vacuum cost limit.

Perform the following steps to see how this could potentially work:

Start a vacuum operation:

```sql
vacuum analyze
```

While the operation is executing, run the following command to increase the cost limits:

```sql
SET autovacuum_vacuum_cost_limit TO 300;
SET vacuum_cost_limit TO 400;
```

> NOTE: These can also be set in the Azure Portal.

Use the following command to monitor the vacuum operations:

```sql
select schemaname,relname,n_dead_tup,n_live_tup,round(n_dead_tup::float/n_live_tup::float*100) dead_pct,autovacuum_count,last_vacuum,last_autovacuum,last_autoanalyze,last_analyze from pg_stat_all_tables where n_live_tup >0;
```

For more information on Azure Database for PostgreSQL Flexible Server autovacuum features read [Autovacuum Tuning in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-autovacuum-tuning).

For a more in-depth look at the code change for this feature, reference [here](https://git.postgresql.org/gitweb/?p=postgresql.git;a=commitdiff;h=7d71d3dd080b9b147402db3365fe498f74704231).

### Using pg_stat_io for enhanced IO monitoring

`pg_stat_io` is a new catalog view that displays statsitcs around `reads` and `writes` and as of Postgres 16, `extends` information.

Per the [postgresql documentation](https://www.postgresql.org/docs/devel/monitoring-stats.html#MONITORING-PG-STAT-IO-VIEW) : "The pg_stat_io view will contain one row for each combination of backend type, target I/O object, and I/O context, showing cluster-wide I/O statistics. Combinations which do not make sense are omitted.

Currently, I/O on relations (e.g. tables, indexes) is tracked. However, relation I/O which bypasses shared buffers (e.g. when moving a table from one tablespace to another) is currently not tracked."

Run the following command to see the information available:

```sql
select * from pg_stat_io
```

Using `pgbench` you can generate some IO data:

```sql
pgbench -i -s 10 postgres
```

Again, run the previous command to see the newly generated IO information:

```sql
select * from pg_stat_io
```

Some common uses for this data include:

    - Review if high evictions are occuring.  If so, shared buffers should be increased.
    - Large number of fsyncs by client backends could indicate misconfiguration of the shared buffers and/or the checkpointer