set content `cat data/nbagames.json`
create temp table t ( j jsonb );
insert into t values (:'content');
select * from t;