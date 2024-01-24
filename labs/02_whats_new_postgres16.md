# Hands on Lab: Working with the latest developer capabilities of Postgres 16

- [Hands on Lab: Working with the latest developer capabilities of Postgres 16](#hands-on-lab-working-with-the-latest-developer-capabilities-of-postgres-16)
  - [Prerequisites](#prerequisites)
  - [Exercise 1: Setup and Configuration](#exercise-1-setup-and-configuration)
    - [Task 1: Create tables and data](#task-1-create-tables-and-data)
  - [Exercise 2: Developer Features](#exercise-2-developer-features)
    - [Task 1: Add SQL/JSON object checks](#task-1-add-sqljson-object-checks)
    - [Task 2: Exploring JSON\_ARRAY, JSON\_ARRAYAGG and JSON\_OBJECT](#task-2-exploring-json_array-json_arrayagg-and-json_object)
    - [Task 3: Creating Indexes](#task-3-creating-indexes)
    - [Task 4: Using Full Text + GIN indexes](#task-4-using-full-text--gin-indexes)
    - [Task 5: Aggregate function ANY\_VALUE()](#task-5-aggregate-function-any_value)
  - [Exercise 3: COPY Features](#exercise-3-copy-features)
    - [Task 1: Configuring server parameters](#task-1-configuring-server-parameters)
    - [Task 2: COPY batch\_size support](#task-2-copy-batch_size-support)
    - [Task 3: Allow a COPY FROM value to map to a column's DEFAULT](#task-3-allow-a-copy-from-value-to-map-to-a-columns-default)
  - [Exercise 4: Performance Features](#exercise-4-performance-features)
    - [Task 1: Allow parallelization of FULL and internal RIGHT OUTER hash joins](#task-1-allow-parallelization-of-full-and-internal-right-outer-hash-joins)
    - [Task 2: Allow aggregate functions string\_agg() and array\_agg() to be parallelized](#task-2-allow-aggregate-functions-string_agg-and-array_agg-to-be-parallelized)
    - [Task 3: Add EXPLAIN option GENERIC\_PLAN to display the generic plan for a parameterized query](#task-3-add-explain-option-generic_plan-to-display-the-generic-plan-for-a-parameterized-query)
    - [Task 4: Using pg\_stat\_io for enhanced IO monitoring](#task-4-using-pg_stat_io-for-enhanced-io-monitoring)
    - [Task 5: Using Query Store](#task-5-using-query-store)
  - [Exercise 5: PgBouncer](#exercise-5-pgbouncer)
    - [Task 1: Enable PgBouncer and PgBouncer Metrics](#task-1-enable-pgbouncer-and-pgbouncer-metrics)
    - [Task 2: Performance without PgBouncer](#task-2-performance-without-pgbouncer)
    - [Task 3: Performance with PgBouncer](#task-3-performance-with-pgbouncer)
  - [Exercise 6: Other Features (Optional)](#exercise-6-other-features-optional)
    - [Task 1: New options for CREATE USER](#task-1-new-options-for-create-user)
    - [Task 2: Use new VACUUM options to improve VACUUM performance](#task-2-use-new-vacuum-options-to-improve-vacuum-performance)

In this lab you will explore the new developer and infrastructure features of PostgreSQL 16.

## Prerequisites

- Perform Lab 01 steps

## Exercise 1: Setup and Configuration

In this exercise you will create some tables and use the COPY command to move data into those tables.  The data is in JSON format and not SQL format so the usage of `jsonb` data type with be required to import the data into a temporary table.  We will use this initial data to run some queries to transform the data such that we can utilize the new JSON syntax in PostgreSQL 16.

### Task 1: Create tables and data

1. In your lab virtual machine, open a command prompt, run the following command to connect to your database, be sure to replace `PREFIX` with your lab information:

    ```cmd
    psql -h PREFIX-pg-flex-eastus-16.postgres.database.azure.com -U s2admin -d airbnb
    ```

2. Run the following commands to create the tables and import the data to the server.  Notice the usage of `json` files to do the import using the `COPY` command. Once into a temporary table, we than do some massaging:

    > NOTE: These paths are Windows based and you may need to adjust based on your environment (WSL, Linux, etc)

    ```sql
    DROP TABLE IF EXISTS temp_calendar;
    DROP TABLE IF EXISTS temp_listings;
    DROP TABLE IF EXISTS temp_reviews;
    
    CREATE TABLE temp_calendar (data jsonb);
    CREATE TABLE temp_listings (data jsonb);
    CREATE TABLE temp_reviews (data jsonb);

    \COPY temp_calendar (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\calendar.json';
    \COPY temp_listings (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\listings.json';
    \COPY temp_reviews (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\reviews.json';    
    
    DROP TABLE IF EXISTS listings;
    DROP TABLE IF EXISTS calendar;
    DROP TABLE IF EXISTS reviews;

    CREATE TABLE listings (
        listing_id int,
       	name varchar(50),
       	street varchar(50),
       	city varchar(50),
        state varchar(50),
        country varchar(50),
        zipcode varchar(50),
        bathrooms int,
        bedrooms int,
        latitude decimal(10,5), 
        longitude decimal(10,5), 
        summary varchar(2000),
        host_id varchar(2000),
        host_url varchar(2000),
        listing_url varchar(2000),
        room_type varchar(2000),
        amenities jsonb,
       	host_verifications jsonb,
        data jsonb);

    CREATE TABLE reviews (
        id int, 
        listing_id int, 
        reviewer_id int, 
        reviewer_name varchar(50), 
        date date,
        comments varchar(2000)
        );

    CREATE TABLE calendar (
        listing_id int, 
        date date,
        price decimal(10,2), 
        available varchar(50)
        );

    INSERT INTO listings
    SELECT 
        data['id']::int, 
        replace(data['name']::varchar(50), '"', ''),
        replace(data['street']::varchar(50), '"', ''),
        replace(data['city']::varchar(50), '"', ''),
        replace(data['state']::varchar(50), '"', ''),
        replace(data['country']::varchar(50), '"', ''),
        replace(data['zipcode']::varchar(50), '"', ''),
        data['bathrooms']::int,
        data['bedrooms']::int,
        data['latitude']::decimal(10,5),
        data['longitude']::decimal(10,5),
        replace(data['summary']::varchar(50), '"', ''),        
        replace(data['host_id']::varchar(50), '"', ''),
        replace(data['host_url']::varchar(50), '"', ''),
        replace(data['listing_url']::varchar(50), '"', ''),
        replace(data['room_type']::varchar(50), '"', ''),
        data['amenities']::jsonb,
        data['host_verifications']::jsonb,
        data::jsonb
    FROM temp_listings;    
    
    INSERT INTO reviews
    SELECT 
        data['id']::int,
        data['listing_id']::int,
        data['reviewer_id']::int,
        replace(data['reviewer_name']::varchar(50), '"', ''), 
        to_date(replace(data['date']::varchar(50), '"', ''), 'YYYY-MM-DD'),
        replace(data['comments']::varchar(2000), '"', '')
    FROM temp_reviews;
    
    INSERT INTO calendar
    SELECT 
        data['listing_id']::int,
        to_date(replace(data['date']::varchar(50), '"', ''), 'YYYY-MM-DD'),
        data['price']::decimal(10,2),
        replace(data['available']::varchar(50), '"', '')
    FROM temp_calendar;
    ```

    ![Alt text](media/02_01_insert_table_data.png)

    > NOTE: We are storing data in the tables as JSONB for lab purposes.  In the real world, you may not want to do something like this as with normal columns, PostgreSQL maintains statistics about the distributions of values in each column of the table – most common values (MCV), NULL entries, histogram of distribution. Based on this data, the PostgreSQL query planner makes smart decisions on the plan to use for the query. At this point, PostgreSQL does not store any stats for JSONB columns or keys. This can sometimes result in poor choices like using nested loop joins vs. hash joins.

3. Switch to pgAdmin
4. Navigate to **Databases->airbnb->Schemas->public->Tables**
5. Right-click the **Tables** node, select **Query Tool**

    ![Alt text](media/query_tool.png)

6. Run each of the following commands to see the imported data after its tranformation.  Note that we did not fully expand the JSON into all possible column so as to show the new JSON syntax later:

    ```sql
    select top 10 * from listings;
    select top 10 * from reviews;
    select top 10 * from calendar;
    ```

7. ![Alt text](media/02_01_select_queries.png)

## Exercise 2: Developer Features

There are several developer based changes in PostgreSQL 16 as related to SQL syntax. In this exercise we explore several of them including the new SQL standard JSON functions.

- [Function Json](https://www.postgresql.org/docs/16/functions-json.html)

### Task 1: Add SQL/JSON object checks

1. In pgAdmin, run the following pre-16 commands. The use of `->` and `->>` are pre-Postgres 14 commands used to navigate a json hierarchy:

    ```sql
    SELECT
       listing_id,
       pg_typeof(data),
       pg_typeof(data ->> 'id')
    FROM
       listings LIMIT 1;
    ```

    ![Alt text](media/02_02_json_01.png)

2. The same query can also be written in Postgres 14 and higher, note the usage of the bracket notation `[]`:

    ```sql
    SELECT
       listing_id,
       pg_typeof(data),
       pg_typeof(data['id'])
    FROM
       listings LIMIT 1;
    ```

    ![Alt text](media/02_02_json_02.png)

3. In Postgres 16, you can now use the SQL standard `IS JSON` syntax.  The `IS JSON` checks include checks for values, arrays, objects, scalars, and unique keys:

    ```sql
    SELECT
       listing_id,
       data IS JSON,
       data['id'] IS JSON
    FROM
       listings LIMIT 1;
    ```

    ![Alt text](media/02_02_json_03.png)

4. Additionally, you can get more granular about the type of JSON.

    ```sql
    SELECT
       listing_id,
       data IS JSON ARRAY,
       data['id'] IS JSON OBJECT
    FROM
       listings LIMIT 1;
    ```

    ![Alt text](media/02_02_json_04.png)

5. When combining the above, you can create intricate `CASE` statements based on the target type:

    ```sql
    SELECT
       CASE
        WHEN
            data -> 'street' IS JSON ARRAY
        THEN
            (data -> 'street')[0]
        WHEN
            data -> 'street' IS JSON OBJECT
        THEN
            data -> 'street'
        WHEN
            data IS JSON SCALAR
        THEN
            data
        ELSE
            data -> 'street'
       END
       AS primary_address
    FROM
       listings;
    ```

6. Finally, much of the basic JSON functionality that has existed pre-PG16 is still available and can also be used.  In this example, you are using the containment operator (where one json document is contained inside another) to select data:

    ```sql
    SELECT *
    from listings
    where
    host_verifications @> '["email"]'::jsonb;
    ```

### Task 2: Exploring JSON_ARRAY, JSON_ARRAYAGG and JSON_OBJECT

In this series of steps, you will review the new functions `JSON_ARRAY()`, `JSON_ARRAYAGG()`, and `JSON_OBJECT()` that are part of the SQL standard and now PostgreSQL 16.  

1. In pgAdmin, run the following PostgreSQL 16 commands:

    ```sql
    SELECT
       json_array(data['id'], name, bedrooms, city, state)
    FROM
       listings;
    ```

    ![Alt text](media/02_02_json_05.png)

    ```sql
    SELECT
        json_arrayagg(data['id'])
    FROM
        listings;
    ```

    ![Alt text](media/02_02_json_06.png)

2. You can also convert regular types into JSON using the `JSON_OBJECT` function.  The following will take several data types and create a JSON object from them:

    ```sql
    SELECT json_object(ARRAY[1, 'a', true, row(2, 'b', false)]::TEXT[]);
    ```

    ![Alt text](media/02_02_json_07.png)

3. Additionally, you can use the `json_agg` combined with `row_to_json` to convert a series of columns in a select statement into json:

    ```sql
    select 
    	bedrooms,
    	json_agg(row_to_json((name, street))) as jData
	from 
        listings
	group by 
        bedrooms
    ```

There are many other types of funtions and operators in PostgreSQL that you can utilize when working with JSON data.  You can reference the latest information for PG16 in the [9.16. JSON Functions and Operators](https://www.postgresql.org/docs/16/functions-json.html) documentation.

### Task 3: Creating Indexes

Indexes help increase query performance.  

1. Run the following query, notice the usage of a `Seq Scan` on the table, also record the costs:

    ```sql
        EXPLAIN ANALYZE select *
        from listings l, calendar c
        where l.city = 'seattle'
        and l.listing_id = c.listing_id
        and l.listing_id = 241032
    ```

2. Create an index on the `listing_id`` column:

    ```sql
    CREATE INDEX listings_listing_id ON listings (listing_id);
    ```

3. Re-run the query to see the Sequential Scan is now removed and a Index Scan is now used improving the costs:

    ```sql
        EXPLAIN ANALYZE select *
        from listings l, calendar c
        where l.city = 'seattle'
        and l.listing_id = c.listing_id
        and l.listing_id = 241032
    ```

### Task 4: Using Full Text + GIN indexes

Although indexes on JSON data is not new to PG16 (available since 8.2 with JSON support since 9.2), it is a valuable feature to be aware of when working with PostgreSQL and JSON. GIN indexes can be used to efficiently search for keys or key/value pairs occurring within a large number of jsonb documents (datums). Two GIN "operator classes" are provided, offering different performance and flexibility trade-offs.

1. Run the following query:

    ```sql
    ALTER TABLE listings 
    ADD COLUMN ts_summary tsvector
    GENERATED ALWAYS AS (to_tsvector('english', summary)) STORED;
    ```

2. In pgAdmin, run the following command:

    ```sql
    CREATE INDEX ts_idx ON listings USING GIN (ts_summary);
    ```

3. Again, re-run the query, you should see a performance increase in the query:

    ```sql
    SELECT *
    FROM listings
    WHERE ts_summary @@ to_tsquery('amazing');
    ```

### Task 5: Aggregate function ANY_VALUE()

The `ANY_VALUE()` function is a PostgreSQL aggregate function that helps optimize queries when utilizing GROUP BY clauses. The function will return an arbitrary non-null value in a given set of values. It effectively informs PostgreSQL that any value from the group is acceptable, resolving the ambiguity and allowing the query to execute successfully.

Prior to PostgreSQL 16, when using GROUP BY, all non-aggregated columns from the SELECT statement were included in the GROUP BY clause as well. Pre-16 PostgreSQL would throw an error if a non-aggregated column is not added in the GROUP BY clause.

1. The following is an example of pre-16 syntax (**will throw error**):

    ```sql
    SELECT 
        l.city,
        c.price
    FROM 
        listings l, calendar c
    where 
        l.listing_id = c.listing_id
    GROUP 
        BY l.city
    ```

    ![Alt text](media/02_02_aggregate.png)

2. Modify the query to utlize the new `ANY_VALUE` function:

    ```sql
    SELECT 
        l.city,
        ANY_VALUE(c.price)
    FROM 
        listings l, calendar c
    where 
        l.listing_id = c.listing_id
    GROUP 
        BY l.city
    ```

    ![Alt text](media/02_02_aggregate_02.png)

3. Keep in mind that the `ANY_VALUE` is the selection of an non-null item from the group, and does not act the same if you did the full `group by` clause:

    ```sql
    select
        l.city,
        c.price
    from 
        listings l, calendar c
    where 
        l.listing_id = c.listing_id
    group 
        by l.city, c.price
    ```

## Exercise 3: COPY Features

### Task 1: Configuring server parameters

In order to demonstrate some of the existing and new features of Azure Databse for PostgreSQL, we will have you modify some server parameters to support this lab.  Note that you may or may not need to do this when running your own environments and appications.

1. Under **Settings**, select **Server parameters**.
2. In the tabs, select **All**
3. Search for **azure.extensions**
4. Enable the **POSTGRES_FDW** extension.

    ![Alt text](media/01_13_server_params_fdw.png)

5. Select **Save**.
6. In the dialog, select **Save and Restart**

### Task 2: COPY batch_size support

It is now possible to batch insert multiple records with the COPY statement for a foreign table using the `postgres_fdw` module.  Previously, this would insert a single record at a time from the foreign table which is much less efficient then doing multiple records.

1. Setup the foreign table (windows), be sure to replace the `PREFIX` value:

    ```sql
    SET PGPASSWORD=Seattle123Seattle123
    psql -h PREFIX-pg-flex-eastus-14.postgres.database.azure.com -d airbnb -U s2admin -p 5432 -a -w -f C:\microsoft-postgres-docs-project\artifacts\sql\createdb.sql
    ```

2. Configure a new foriegn table (be sure to replace `PREFIX`):

    ```sql
    CREATE EXTENSION IF NOT EXISTS postgres_fdw;
    
    CREATE SERVER postgres14
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'PREFIX-pg-flex-eastus-14.postgres.database.azure.com', dbname 'airbnb');
    
    CREATE USER MAPPING FOR s2admin
    SERVER postgres14
    OPTIONS (user 's2admin', password 'Seattle123Seattle123');
    
    create schema postgres14;
    ```

3. Now import the schema from the remote Azure Database for PostgreSQL Flexible Server:

    ```sql
    IMPORT FOREIGN SCHEMA public LIMIT TO (reviews)
    FROM SERVER postgres14 INTO postgres14;
    ```

    > NOTE: You must have the **Allow public access from any Azure service within Azure to this server** enabled on the Postgres 14 server for the command to successfully execute.

4. Use the new batch feature to use `COPY` to copy values from the foreign table:

    ```sql
    ALTER SERVER postgres14 options (add batch_size '10');
    
    \COPY postgres14.reviews (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\reviews.json';
    ```

For a more in-depth look at the code change for this feature, reference [here](https://git.postgresql.org/gitweb/?p=postgresql.git;a=commitdiff;h=97da48246d34807196b404626f019c767b7af0df).

### Task 3: Allow a COPY FROM value to map to a column's DEFAULT

The new `COPY FROM` `DEFAULT` parameter syntax allows for the import of data into a table using a common token in the source data.

1. Review the `C:\microsoft-postgres-docs-project\artifacts\data\default.csv` file, notice the usage of the `\D` in the source data:

    ![Alt text](media/02_02_copy_from_default.png)

2. Run the following command to import the data:

    ```sql
    CREATE TABLE default_test(c1 INT PRIMARY KEY, c2 TEXT DEFAULT 'the_default_value') ;
    
    COPY default_test FROM 'C:\microsoft-postgres-docs-project\artifacts\data\default.csv'; WITH (format csv, default '\D', header);
    ```

3. Run the following command to review the results of the `COPY FROM` command:

    ```cmd
    SELECT
        *
    FROM
        default_test
    ```

Notice every entry from the source file with the default of '\D' was converted to the `DEFAULT` value from the column definition.

## Exercise 4: Performance Features

### Task 1: Allow parallelization of FULL and internal RIGHT OUTER hash joins

In general, the more things you can do in parallel the faster you will get results.  As is the case when performing `FULL` and internal `RIGHT OUTER` joins.  Previous to PostgreSQL these would not have been executed in parallel and the costs were more to perform than the parallezation setup.

With this change, many queries you were performing using these joins will now run drastically faster.

1. Switch to pgAdmin
2. Run the following commands to setup some sample tables and data on the PG16 instance.

    ```sql
    DROP TABLE IF EXISTS left_table;
    DROP TABLE IF EXISTS right_table;
    
    create table left_table (x int, y int);
    create table right_table (x int, y int);
    
    insert into left_table
    select (case x % 4 when 1 then null else x end), x % 10
    from generate_series(1,5000) x;
    
    insert into right_table
    select (case x % 4 when 1 then null else x end), x % 10
    from generate_series(1,5000) x;
    ```

3. Ensure that your instance is enabled and configured for parallel hash joins, this is the default for instances, but depending is always worth verifying.  You should see the following values.
   - parallel_type_cost = `0.1`
   - parallel_setup_cost = `1000`
   - max_parallel_workers_per_gather = `2`
   - enable_parallel_hash = `on`

    ```sql
    show parallel_tuple_cost;
    show parallel_setup_cost;
    show max_parallel_workers_per_gather;
    show enable_parallel_hash;
    ```

    > NOTE: If the table values are very small, the effort of doing a parallel operation may be more than the effort to do a non-parallel execution.  The tables and rows above should be enough to generate a Parallel Hash Full Join plan.

4. Run the following command to see the execution plan of the the select statement:

    ```sql
    EXPLAIN analyze SELECT
    	*
    FROM
    	left_table lt
    FULL OUTER JOIN right_table rt
            ON lt.x = rt.x
    ```

5. In the execution plan, you should notice the use of a `Parallel Hash Full Join`.  

    ![Alt text](media/parallel_full_outer_join.png)

6. In previous versions of PostgreSQL, you would see a regular `Hash Full Join`.

Full JOINs are commonly used to find the differences between 2 tables. Prior to Postgres 16, parallelism was not implemented for full hash JOINs, which made them slower to execute. [(link to commit)](https://github.com/postgres/postgres/commit/11c2d6fdf)

### Task 2: Allow aggregate functions string_agg() and array_agg() to be parallelized

Aggregate functions typically perform some kind of mathematical operation on a column or set of columns.  If you were to calculate several aggregates at once, you could probably imagine that doing each one in a serialized manner would likely take much longer than doing it in a parallel manner.

Not all aggregate functions have supported this type of optimization, as such with the `string_agg()` and `array_agg()` functions.  In PostgreSQL 16, this support was added and per the description on the code commit **adds combine, serial and deserial functions for the array_agg() and string_agg() aggregate functions, thus allowing these aggregates to
partake in partial aggregations.  This allows both parallel aggregation to
take place when these aggregates are present and also allows additional
partition-wise aggregation plan shapes to include plans that require
additional aggregation once the partially aggregated results from the
partitions have been combined.**

The following is an example of a query that performs aggregates with the two functions included.  If this were to run on a pre-16 version, the query would be much slower than in version 16.

1. In pgAdmin, run the following:

    ```sql
    drop table is exists agg_test;

    create table agg_test (x int, y int);
    
    insert into agg_test
    select (case x % 4 when 1 then null else x end), x % 10
    from generate_series(1,5000) x;
    ```

2. Run a select statement against it to review the data generated:

    ```sql
    SELECT
        y,
        string_agg(x::text, ',') AS t,
        string_agg(x::text::bytea, ',') AS b,
        array_agg(x) AS a,
        array_agg(ARRAY[x]) AS aa
    FROM
        agg_test
    GROUP BY
        y;
    ```

    ![Alt text](media/02_03_query_01.png)

3. Review the `EXPLAIN` plan details, notice the `HashAggregate` plan and the costs:

    ```sql
    EXPLAIN SELECT
        y,
        string_agg(x::text, ',') AS t,
        string_agg(x::text::bytea, ',') AS b,
        array_agg(x) AS a,
        array_agg(ARRAY[x]) AS aa
    FROM
        agg_test
    GROUP BY
        y;
    ```

    ![Alt text](media/02_03_query_02.png)

4. In order to show how this works, you will need to set the parallel setup costs parameters to the following.  **Note that this is only for this lab and not a suggestion for performing in your development or production environments**:

    ```sql
    set parallel_setup_cost TO 0;
    set parallel_tuple_cost TO 0;
    set parallel_leader_participation TO 0;
    set min_parallel_table_scan_size = 0;
    ```

5. Again, review the `EXPLAIN` plan details, notice the new `Finalize GroupAggregate` plan and the significantly reduced costs:

    ```sql
    EXPLAIN SELECT
        y,
        string_agg(x::text, ',') AS t,
        string_agg(x::text::bytea, ',') AS b,
        array_agg(x) AS a,
        array_agg(ARRAY[x]) AS aa
    FROM
        agg_test
    GROUP BY
        y;
    ```

    ![Alt text](media/02_03_query_03.png)

For a more in-depth look at the code change for this feature, reference [here](https://git.postgresql.org/gitweb/?p=postgresql.git;a=commitdiff;h=16fd03e956540d1b47b743f6a84f37c54ac93dd4).

### Task 3: Add EXPLAIN option GENERIC_PLAN to display the generic plan for a parameterized query

Previously, attempting to get an execution plan for a parameterized query was fairly complicated.  For example, using a prepared statement will have several executions which may required you to execute all the sub-executions separately and then put the results together. Using the new PG16 feature will eliminate those extra steps when attempting to find performance issues with parameterized queries.

1. Run the following command to attempt to get an execution plan for a parameterized query using the pre-16 method:

    ```sql
    EXPLAIN SELECT * FROM pg_class WHERE relname = $1;
    ```

2. You should get an error.

    ![Alt text](media/02_04_query_01.png)

3. To get an execution plan for a parametrized query, run the following:

    ```sql
    EXPLAIN (GENERIC_PLAN) SELECT * FROM pg_class WHERE relname = $1;
    ```

    ![Alt text](media/02_04_query_02.png)

    > Note the use of the parenthesis.  The old way (shown above) was to not utilize parenthesis and is only for backwards compatibility. Newer options such as `GENERIC_PLAN` will only work with the new syntax.

As you can see above, you can use parameter placeholders like `$1` instead of an unknown or variable value. However, there are certain restrictions:

- You can use parameters only with the statements SELECT, INSERT, UPDATE, DELETE and VALUES.
- You can only use parameters instead of constants (literals). You can’t use parameters instead of identifiers (object names) or keywords, among other things.

### Task 4: Using pg_stat_io for enhanced IO monitoring

`pg_stat_io` is a new catalog view that displays statistics around `reads` and `writes` and as of Postgres 16, `extends` information.

Per the [postgresql documentation](https://www.postgresql.org/docs/devel/monitoring-stats.html#MONITORING-PG-STAT-IO-VIEW) : "The pg_stat_io view will contain one row for each combination of backend type, target I/O object, and I/O context, showing cluster-wide I/O statistics. Combinations which do not make sense are omitted.

Currently, I/O on relations (e.g. tables, indexes) is tracked. However, relation I/O which bypasses shared buffers (e.g. when moving a table from one tablespace to another) is currently not tracked."

1. Run the following command to see the information available:

    ```sql
    select * from pg_stat_io order by writes desc;
    ```

2. Using `pgbench` you can generate some IO data (~750MB of data):

    ```sql
    pgbench -i -s 50 -h PREFIX-pg-flex-eastus-16.postgres.database.azure.com -p 5432 -U s2admin -d airbnb
    ```

3. Again, run the previous command to see the newly generated IO information.

    ```sql
    select * from pg_stat_io order by writes desc;
    ```

4. You should see the backend_type `client_backend` values change to be much higher:

    ![Alt text](media/pg_stat_io.png)

5. `pg_stat_io` will also break apart the operations into more granular statistics via the `context` column.  The `pgbench` test above generated context values in the `vacuum` and `bulkwrite` context categories.  When using basic DDL commands, the values will go into different context categories.
6. Run the following command to create some more test data using basic DDL `INSERT`:

    ```sql
        insert into agg_test
        select (case x % 4 when 1 then null else x end), x % 10
        from generate_series(1,200000) x;
    ```

7. Again, run the previous command to see the newly generated IO information.

    ```sql
    select * from pg_stat_io order by writes desc;
    ```

8. Review the backendtype of `client_backend`, object of `relation`, context of `normal` and the `extends` column value.  Because you were adding data to an existing table, you are performing `extends` operations.

Some common uses for this data include:

- Review if high evictions are occurring.  If so, shared buffers should be increased.
- Large number of fsyncs by client backends could indicate misconfiguration of the shared buffers and/or the checkpointer.

### Task 5: Using Query Store

In lab 1 you enabled the Query Store via server parameters.  As you were working with Lab 2, you executed several actions against the database.

1. Run the following to see what the most expensive queries were:

    ```sql
    SELECT * FROM query_store.qs_view; 
    ```

2. You should see a series of queries:

TODO

For more information on the query store feature, reference [Monitor performance with the Query Store](https://learn.microsoft.com/en-us/azure/postgresql/single-server/concepts-query-store)

## Exercise 5: PgBouncer

PgBouncer is a well known and supported 3rd party open-source, community-developed project. PgBouncer is commonly used to reduce resource overhead by managing a pool of connections to PostgreSQL, making it ideal for environments with high concurrency and frequent short-lived connections. It enables optimization by reducing the load on PostgreSQL server caused by too many connections.

References:

- https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-pgbouncer

### Task 1: Enable PgBouncer and PgBouncer Metrics

You can use PgBouncer metrics to monitor the performance of the PgBouncer process, including details for active connections, idle connections, total pooled connections, and the number of connection pools. Each metric is emitted at a 1-minute interval and has up to 93 days of history. Customers can configure alerts on the metrics and also access the new metrics dimensions to split and filter metrics data by database name. PgBouncer metrics are disabled by default. For PgBouncer metrics to work, both the server parameters pgbouncer.enabled and metrics.pgbouncer_diagnostics must be enabled. These parameters are dynamic and don't require an instance restart.

- Browse to the Azure Portal and your **PREFIX-pg-flex-eastus-16** resource
- Under **Settings**, select **Server parameters**
- Search for the `pgbouncer.enabled` dynamic parameters
- Toggle the setting to `TRUE`

    ![Alt text](media/02_03_enable_pgbouncer.png)

- Search for the `metrics.pgbouncer_diagnostics` dynamic parameters
- Toggle the setting to `TRUE`
- Select **Save**

### Task 2: Performance without PgBouncer

1. Switch to the Azure Portal
2. Browse to the `PREFIX-pg-flex-eastus-16.postgres.database.azure.com` instance
3. Under **Monitoring** select **Metrics**
4. For the **Metric**, under the **TRAFFIC** category, select **Active client connections**
5. Select **Add metric**
6. Under the **PGBOUNCER** category, select **Active client connections**
7. In the top right, select the time to be **Last 30 minutes** then select **Apply**
8. Switch to a command prompt
9. Run the following commands to execute a `pgbench` test directly against the database server, when prompted enter the password.  Notice the use of the `-c` parameter that will create 1000 different connections, be sure to replace `PREFIX` with your lab information:

    ```sql
    pgbench -c 100 -T 120 -h PREFIX-pg-flex-eastus-16.postgres.database.azure.com -p 5432 -U wsuser -d airbnb
    ```

10. Switch back to the Metrics window, after a minute, you should see the active connections increase.
11. Stop the test or wait for it to finish.

### Task 3: Performance with PgBouncer

1. Switch back to the command prompt.
2. Run the following commands to execute a `pgbench` test against the PgBouncer instance, when prompted enter the password. Notice the change of the port to the PgBouncer port of `6432`, be sure to replace `PREFIX` with your lab information:

    ```sql
    pgbench -c 100 -T 120 -h PREFIX-pg-flex-eastus-16.postgres.database.azure.com -p 5432 -U wsuser -d airbnb
    ```

3. Switch back to the metrics window.  After a minute, you should see that the server active connections will max out and the PgBouncer active client connections will increase to handle the load on behalf of the server.

## Exercise 6: Other Features (Optional)

### Task 1: New options for CREATE USER

The new options for `CREATE USER` control the valid-until date, bypassing of row-level security, and role membership.

1. Run the following commands:

    ```sql
    CREATE USER adminuser1 CREATEROLE REPLICATION CREATEDB;
    
    \connect postgres adminuser1
    
    CREATE USER user_repl1 REPLICATION; 
    
    CREATE USER user_db1 CREATEDB;
    ```

2. Additionally, you can now do `VALID UNTIL`. The VALID UNTIL clause defines an expiration time for a password only, not for the user account.  Run the following:

    ```sql
    CREATE USER john WITH PASSWORD 'Seattle123Seattle123' VALID UNTIL '2025-01-01';
    ```

    > NOTE: Although it is possible to do assign the `BYPASSRLS` for a user in PostgreSQL 16, Azure Database for PostgreSQL Flexible Server does not support this feature.

### Task 2: Use new VACUUM options to improve VACUUM performance

The PostgreSQL `VACUUM` command is used to garbage-collect and analyze databases.  It works by removing `dead` tuples left over by large changes to a database (such as frequently updated tables). By removing the gaps between the data, you can speed up the performance of specific operations and increase your disk space.

Once of the new features to `VACUUM` in Postgres 16 is the ability to update the cost limit on the fly.  This will allow people that run large production databases that may be running out of disk space a bit too quickly; which if to occur, would likely take down the production system. to get VACUUM to execute faster. During a `VACUUM` is could be that it is not running as fast as it needs to because of the cost limit.

By allowing the change during the operation, you can speed up the `VACUUM` operation without restarting it.

These server parameters are called `vacuum_cost*` or `auto_vacuum_vacuum_cost*`. The default for the `vacuum_cost_limit` is `200` and `auto_vacuum_vacuum_cost` is `-1` which indicates to use the default vacuum cost limit.

Perform the following steps to see how this could potentially work:

1. Execute the following to start a vacuum operation:

    ```sql
    vacuum analyze;
    ```

2. While the operation is executing, run the following command to increase the cost limits.  Note that in pre-16 versions, this command would have no effect on currently running operations, in 16, this action applies during the execution:

    ```sql
    SET vacuum_cost_limit TO 400;
    ```

    > NOTE: These can also be set in the Azure Portal.

3. Use the following command to monitor the vacuum operations:

    ```sql
    select schemaname,relname,n_dead_tup,n_live_tup,round(n_dead_tup::float/n_live_tup::float*100) dead_pct,autovacuum_count,last_vacuum,last_autovacuum,last_autoanalyze,last_analyze from pg_stat_all_tables where n_live_tup >0;
    ```

For more information on Azure Database for PostgreSQL Flexible Server autovacuum features read [Autovacuum Tuning in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-autovacuum-tuning).

For a more in-depth look at the code change for this feature, reference [here](https://git.postgresql.org/gitweb/?p=postgresql.git;a=commitdiff;h=7d71d3dd080b9b147402db3365fe498f74704231).
