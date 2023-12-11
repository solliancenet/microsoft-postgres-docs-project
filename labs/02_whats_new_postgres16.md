
# Hands on Lab: Working with the latest capabilities of Postgres 16

## Pre-requistes

- Azure Subscription
- Azure Database for PostgreSQL Flexible Server instanace
- pgAdmin or pgsql installed

## Developer Features

Add SQL/JSON constructors - The new functions JSON_ARRAY(), JSON_ARRAYAGG(), JSON_OBJECT(), and JSON_OBJECTAGG() are part of the SQL standard. 

```sql
TODO
```

Add SQL/JSON object checks - The IS JSON checks include checks for values, arrays, objects, scalars, and unique keys. 

```sql
TODO
```

Add aggregate function ANY_VALUE() which returns any value from a set 

```sql
TODO
```

Allow COPY into foreign tables to add rows in batches (Andrey Lepikhov, Etsuro Fujita) 

```sql
TODO
```

Allow a COPY FROM value to map to a column's DEFAULT (Israel Barth Rubio) 

Add options to createuser , the new options control the valid-until date, bypassing of row-level security, and role membership. 

## Infra Features

Allow parallelization of FULL and internal right OUTER hash joins 

Allow aggregate functions string_agg() and array_agg() to be parallelized (David Rowley) 

Add system view pg_stat_io view to track I/O statistics (Melanie Plageman) 

Add EXPLAIN option GENERIC_PLAN to display the generic plan for a parameterized query 

Use new VACUUM options to improve the performance 

Using pg_stat_io for enhanced IO monitoring. 