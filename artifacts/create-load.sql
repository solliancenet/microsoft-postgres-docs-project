CREATE TABLE temp (data jsonb);

\COPY temp (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\nbagames.json';

CREATE TABLE games (_id varchar(50), date timestamp, teams jsonb);

INSERT INTO games
SELECT replace(data['_id']['$oid']::varchar(50), '"', ''), cast(to_timestamp(replace(data['date']['$date']::varchar(50), '"', ''), 'yyyy-mm-dd"T"hh24:mi:ss') as date), data['teams']::jsonb
FROM temp;

select * 
from games