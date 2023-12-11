# Hands on Lab: Working with the latest capabilities of Postgres 16

In this lab you will explore the new developer and infrastructure features of PostgreSQL 16.

## Pre-requistes

- [Azure subscription](https://azure.microsoft.com/free/)
- [Resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Database for PostgreSQL Flexible Server instanace](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal)
- [pgAdmin](https://www.pgadmin.org/download/)

## Setup

- Open pgAdmin, download and run the `create-load.sql` script to preload the database.
- Review the new items added to the database:
  - TODO

## Developer Features

### Add SQL/JSON constructors

The new functions JSON_ARRAY(), JSON_ARRAYAGG(), JSON_OBJECT(), and JSON_OBJECTAGG() are part of the SQL standard and PostgreSQL 16.  Run the following commands:

- TODO

```sql
TODO
```

### Add SQL/JSON object checks

The IS JSON checks include checks for values, arrays, objects, scalars, and unique keys.

```sql
TODO
```

### Aggragte funtion ANY_VALUE()

Add aggregate function ANY_VALUE() which returns any value from a set

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

Allow parallelization of FULL and internal right OUTER hash joins

Allow aggregate functions string_agg() and array_agg() to be parallelized (David Rowley)

Add system view pg_stat_io view to track I/O statistics (Melanie Plageman)

Add EXPLAIN option GENERIC_PLAN to display the generic plan for a parameterized query

Use new VACUUM options to improve the performance

Using pg_stat_io for enhanced IO monitoring.