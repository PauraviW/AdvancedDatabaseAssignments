 create database pwassignment7;
 
 \c pwassignment7;
 
 
 \qecho 'Question 1.a'
 
 create table R(a int, b int, c int);
 insert into R values (1,2,4), (3,4,5),(1,2,63),(1,2,63),(8,9,10),(11,23,55);
 
 \qecho 'encoding phase'
 create table encodingofR(key text, value jsonb);
 
 insert into encodingofR
 	select 'R' as key, json_build_object('a',a,'b',b,'c',c)::jsonb as value
 	from R;
\qecho 'table r' 
table r;
\qecho ''
 \qecho 'map function'
 create or replace function map(keyin text, valuein jsonb)
 returns table(keyout jsonb, valueout jsonb) as
 $$
	select json_build_object('a',valuein->'a','b', valuein->'b')::jsonb, json_build_object('Rel name', keyin::text)::jsonb;
 	-- select valuein::jsonb, json_build_object('Relname', keyin::text)::jsonb;
 $$language 'sql';
\qecho '' 
 \qecho 'reduce function'
 create or replace function reduce(keyin jsonb, valuein jsonb[])
 returns table (keyout text, valueout jsonb) as 
 $$
 	select 'Projection a,b(R)'::text, keyin;
	
 $$ language 'sql';
\qecho '' 
 \qecho 'simulation'
 with
 Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfR, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT (valueOut->'a')::int as A, (valueOut->'b')::int as b FROM Reduce_Phase order by 1, 2;

drop function map cascade;
drop function reduce cascade;
 
 \qecho 'Question 1.b'
\qecho ''

drop table R; 

create table R(a int); create table S(a int);

insert into R values (1),(2),(3),(4),(8),(9);
insert into S values (2),(4),(5);
\qecho 'Table R'
table r;
\qecho 'table S'
table S;
create table EncodingOfRandS(key text, value jsonb);

insert into encodingofRandS select 'R'::text as key, json_build_object('a', a)::jsonb as value
							from R
							union
							select 'S'::text as key, json_build_object('a', a)::jsonb as value
							from S;
\qecho 'encoding of R and S'
table encodingofRandS;

\qecho 'Map function'

create or replace function map(keyin text, valuein jsonb)
returns table(keyout jsonb, valueout jsonb) as
$$
	select valuein::jsonb, json_build_object('RelName', keyin::text)::jsonb;
$$ language 'sql';

\qecho 'reduce'
-- here i select values present onty in R and not in S
create or replace function reduce(keyin jsonb, valuesin jsonb[]) 
returns table(keyout text, valueout jsonb) as
$$
	SELECT 'R set difference S'::text, keyIn
	WHERE  array['{"RelName": "R"}']::jsonb[] <@ ValuesIn::jsonb[]
			and not array['{"RelName": "S"}']::jsonb[] <@ ValuesIn::jsonb[];
$$ language 'sql';

WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfRandS, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT valueOut->'a' as A FROM Reduce_Phase order by 1;
drop function map cascade;
drop function reduce cascade;
\qecho ''
\qecho 'Question 1.c'
\qecho ''

drop table R; 
drop table S;
drop table EncodingOfRandS cascade;
create table R(a int, b int); create table S(b int, c int);

insert into R values (1,2),(2,3),(3,4),(4,6),(5,5),(88,1),(10,2);
insert into S values (2,6),(4,3),(5,9),(78,9),(10,1);
\qecho 'table R'
table r;
\qecho 'table S'
table S;
create table EncodingOfRandS(key text, value jsonb);

insert into encodingofRandS select 'R'::text as key, json_build_object('a', a, 'b', b)::jsonb as value
							from R
							union
							select 'S'::text as key, json_build_object('c', c, 'b', b)::jsonb as value
							from S;
\qecho 'encoding of R and S'

table encodingofRandS;
\qecho 'map function'
create or replace function map(keyin text, valuein jsonb)
returns table(keyout jsonb, valueout jsonb) as 
$$
	select valuein->'b' as b, json_build_object('RelName', keyIn::text, 'a', valuein->'a')::jsonb
	where keyin = 'R'
	union
	select valuein->'b' as b, json_build_object('RelName', keyIn::text, 'c', valuein->'c')::jsonb
	where keyin = 'S';
$$ language sql;


\qecho 'reduce function'
-- create or replace function reduce(keyin jsonb, valuesin jsonb[])
-- i check if the keys a and c are present for the same value of b or not using lateral twice.
create function reduce(keyout jsonb, valueout jsonb[] )
returns table(key text, value jsonb) as 
$$
	select 'R semi join S'::text, jsonb_build_object('key', keyout, 'values', r.key ->'a')
	from lateral(select unnest(valueout) as key)r 
	join lateral(select unnest(valueout) as key)r1
	on (r.key ?& array['a'] and r1.key ?& array['c']);
$$ language 'sql';

\qecho 'simulation'
WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfRandS, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT value->'key' as b, value->'values' as a 
    FROM group_phase, lateral(select value from reduce(keyout, ValueOut) )r
)
SELECT  cast(a as int), cast(b as int)   FROM Reduce_Phase order by 1;


\qecho ' Question 1.d'
drop table R;
drop table S; 
create table R(a int); create table S(a int);create table T(a int);

insert into R values (1),(2),(3),(4),(6),(8),(10),(17);
insert into S values (2),(4),(5);
insert into T values (3),(1),(5);
\qecho 'table R'
table r;
\qecho 'table S'
table S;
\qecho 'table t'
table t;
create table EncodingOfRandSandT(key text, value jsonb);

insert into EncodingOfRandSandT select 'R'::text as key, json_build_object('a', a)::jsonb as value
							from R
							union
							select 'S'::text as key, json_build_object('a', a)::jsonb as value
							from S
							union
							select 'T'::text as key, json_build_object('a', a)::jsonb as value
							from T;
\qecho 'table EncodingOfRandSandT'
table EncodingOfRandSandT;

drop function map cascade;
drop function reduce cascade;

create or replace function map(keyin text, valuein jsonb)
returns table(keyout jsonb, valueout jsonb) as
$$
	select valuein::jsonb, json_build_object('RelName', keyin::text)::jsonb;
$$ language 'sql';
-- i check for values in R and not in S and T both to eliminate the SUT values 
\qecho 'reduce'
create or replace function reduce(keyin jsonb, valuesin jsonb[]) 
returns table(keyout text, valueout jsonb) as
$$
	SELECT 'R -  (S U T)'::text, keyIn
	WHERE  array['{"RelName": "R"}']::jsonb[] <@ ValuesIn::jsonb[] and
	       not array['{"RelName": "S"}']::jsonb[] <@ ValuesIn::jsonb[]
			and not  array['{"RelName": "T"}']::jsonb[] <@ ValuesIn::jsonb[];
$$ language 'sql';
\qecho ''

\qecho 'output'
WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   EncodingOfRandSandT, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
)
,
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT * FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT valueout->'a' as A FROM Reduce_Phase order by 1;


\qecho ''
\qecho ''
\qecho 'Question 2'
\qecho ''
\qecho ''

drop table R cascade;

create table r(a int, b int);

insert into r values(1,3),(2,4),(2,4),(3,4),(2,6);
insert into r values(2,6),(1,6),(1,7),(3,6),(5,7);



drop table encodingofr;
create table encodingofR(key jsonb, value jsonb);
 
insert into encodingofR
   select jsonb_build_object( 'RelName', 'R')::jsonb as key, jsonb_build_object('a',a,'b',b)::jsonb as value
   from R;
\qecho 'encodingOfR'
table encodingofR;
 
drop function map cascade;
drop function reduce cascade;



create or replace function map(keyin jsonb, valuein jsonb)
returns table(keyout jsonb, valueout jsonb) as
$$
  select valuein->'a'as keyout, jsonb_build_object('b', valuein -> 'b')::jsonb as valueout;
$$ language 'sql';


CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValuesIn jsonb[])
RETURNS TABLE(KeyOut jsonb, valuesout jsonb ) AS
$$
    SELECT  KeyIn::jsonb, jsonb_build_object('array_agg', array_to_json(array_agg(v -> 'b')),'count' ,cardinality(valuesin::jsonb[])::int) 
      from unnest(valuesIn) v
   where cardinality(valuesin::jsonb[]) >=2
            group by (keyin);
$$ LANGUAGE SQL;


WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   EncodingOfR, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
)
,
Reduce_Phase AS (
    SELECT r.KeyOut as a, r.valuesout->'array_agg' as b, r.valuesout->'count' as count
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut , valuesout  FROM Reduce(gp.KeyOut, gp.ValueOut)) r
  
)
SELECT * FROM Reduce_Phase order by 1;

\qecho ''
\qecho ''
\qecho 'Question 3'
drop table s;
drop table r;
create table r(k int, v int);
create table s(k int, w int);

insert into r values(1,2),(1,3),(2,3),(4,5),(5,0),(5,9);
insert into s values(1,5),(1,3),(2,2),(4,7),(8,9);

\qecho 'table r'
table r;
\qecho 'table s'
table s;
\qecho ''
\qecho ''
\qecho 'Question 3.a'
\qecho ''
\qecho '' 
--drop view cogroup;
create or replace view cogroup as
with 
	kvalues as (select r.k from r union select s.k from s),
	rv_values as (select r.k as key, array_agg(r.v) as v_values from r r
				  group by(r.k)
				 union
				 select k.k as key, '{}' as v_values
				 from kvalues k where k.k not in (select r.k from r) ),
	sw_values as (select s.k as key, array_agg(s.w) as w_values from s s
				  group by(s.k)
				 union
				 select k.k as key, '{}' as w_values
				 from kvalues k where k.k not in (select s.k from s) )
	select r1.key , jsonb_build_object('R',r1.v_values::integer[], 'S',s1.w_values::integer[]) as values
	from rv_Values r1 natural join sw_values s1;
\qecho 'cogroup view'
select * from cogroup;
\qecho 'question 3.b'

select distinct r.key, r.v 
from (select c1.key, v 
  from cogroup c1, jsonb_array_elements(values -> 'R') as v) R 
  natural join (select c2.key, w as values
     from cogroup c2, jsonb_array_elements(values -> 'S') as w) S;


\qecho 'Question 3.c'

with c1_values as (select key, array_agg(v) as r_values
				  from cogroup, jsonb_array_elements(values->'R')v
				  group by(key)),
c2_values as (select key, array_agg(v) as s_values
				  from cogroup, jsonb_array_elements(values->'S')v
				  group by(key))
select c1.key as rk, c2.key as sk
from c1_values c1, c2_values c2
where c1.r_values <@ c2.s_values;


\qecho 'Question 4.a'
create table a(x int); 
create table b(x int);
insert into a values(1),(2),(3),(4),(5);
insert into b values(3),(4),(5),(6),(7);

create or replace view cogroup1 as
with 
	kvalues as (select x from a union select x from b),
	a_values as (select x, array_agg(x) as aa_values from a
				  group by(x)
				 union
				 select x, '{}'
				 from kvalues  where x not in (select x from a) ),
	b_values as (select x, array_agg(x) as bb_values from b
				  group by(x)
				 union
				 select x, '{}'
				 from kvalues  where x not in (select x from b) )
	select a.x , jsonb_build_object('A',a.aa_values::integer[], 'B',b.bb_values::integer[]) as values
	from a_Values a natural join b_values b;
	
table cogroup1;

select c1.x as intersection
from cogroup1 c1  
where c1.values->'A' = c1.values->'B';


\qecho 'Question 4.b'


select x as symmetricDifference 
from cogroup1 
where values -> 'A' != values -> 'B'
order by 1;


drop table r cascade;
drop table s cascade;
\qecho ''
\qecho ''
\qecho 'Question 5'
create table enroll (sid text, cno text, grade text);
insert into enroll values 
     ('s100','c200', 'A'),
     ('s100','c201', 'B'),
     ('s100','c202', 'A'),
     ('s101','c200', 'B'),
     ('s101','c201', 'A'),
     ('s102','c200', 'B'),
     ('s103','c201', 'A'),
     ('s101','c202', 'A'),
     ('s101','c301', 'C'),
     ('s101','c302', 'A'),
     ('s102','c202', 'A'),
     ('s102','c301', 'B'),
     ('s102','c302', 'A'),
     ('s104','c201', 'D');

CREATE TYPE studentType AS (sid text);
CREATE TYPE courseType as (cno text);

CREATE TYPE gradeCoursesType AS (grade text, courses courseType[]);
CREATE TABLE studentGrades(sid text, gradeInfo gradeCoursesType[]);

CREATE TYPE gradeStudentsType AS (grade text, student studentType[]);
CREATE TABLE courseGrades(cno text, gradeInfo gradeStudentsType[]);

\qecho 'Question 5 a'
insert into courseGrades
with e as 
(select cno,grade, array_agg(row(sid):: studentType) as students 
from enroll
group by (cno, grade)),
f as (select cno, array_agg(row(grade, students)::gradeStudentsType) as gradeInfo
	 from e
	 group by (cno))
select * from f order by 1;

table coursegrades ;

\qecho 'Question 5 b'
insert into studentgrades
with e as (select c.cno, e.grade, e.student
		   from courseGrades c, unnest(c.gradeInfo) e),
f as (select cno, grade, g.sid
	 from e, unnest(e.student) g),
g as (select sid, grade, array_agg(row(cno)::coursetype) as courses
	 from f
	 group by (sid, grade)),
h as (select sid, array_agg(row(grade, courses)::gradeCoursesType) as gradeInfo
	 from g
	 group by (sid))
select * from h;

table studentgrades;

\qecho 'Question 5.c'
create table jcoursegrades( courseInfo jsonb); 
insert into jcoursegrades
with e as (select cno, grade, array_to_json(array_agg(json_build_object('sid',sid))) as students
		  from enroll
		  group by(cno, grade) order by 1),
	f as (select json_build_object('cno', cno, 'gradeInfo', array_to_json(array_agg(json_build_object('grade',grade, 'students', students)))) as courseInfo 
		 from e
		 group by(cno))
select * from f;
table jcoursegrades;

\qecho 'Question 5.d'
create table jstudentGrades(studentInfo jsonb); 

insert into jstudentgrades
with 
	e as (select j.courseInfo -> 'cno' as cno, g -> 'grade' as grade, c -> 'sid' as sid
		   from jcoursegrades j , jsonb_array_elements(j.courseInfo -> 'gradeInfo') g, jsonb_array_elements(g -> 'students')c),
	f as (select sid, grade, array_to_json(array_agg(json_build_object('cno',cno))) as courses
		 from e
		 group by (sid,grade)),
	g as (select sid, array_to_json(array_agg(json_build_object('grade',grade,'courses',courses))) as gradeInfo
		 from f
		 group by (sid)),
	h as (select json_build_object('sid', sid, 'gradeInfo', gradeInfo) as studentInfo
		 from g)
	select * from h;
table jstudentgrades;

\qecho 'Question 5.e'
-- student
create table student(sid text, sname text);
insert into student values('s100', 'Eric'),
						  ('s101', 'Nick'),
						  ('s102', 'Chris'),
						  ('s103', 'Dinska'),
						  ('s104', 'Zanna');
insert into student values('s105', 'Vince');
-- course
create table course(cno text, cname text, dept text);
insert into course values('c200', 'PL', 'CS'),
						 ('c201', 'Calculus', 'Math'),
						 ('c202', 'Dbs', 'CS'),
						 ('c301', 'AI', 'CS'),
						 ('c302', 'Logic', 'Philosophy');
						 
create table major(sid text, major text);
insert into major values('s100', 'French'),
						('s100', 'Theater'),
						('s100', 'CS'),
						('s102', 'CS'),
						('s103', 'CS'),
						('s103', 'French'),
						('s104', 'Dance'),
						('s105', 'CS');


with e as (select studentinfo->>'sid' as sid,  h->>'cno'::text as cno
		  from jstudentgrades,
		   jsonb_array_elements(studentInfo->'gradeInfo') k,
		  jsonb_array_elements(k->'courses') h),
	f as (select sid, dept, array_to_json(array_agg(json_build_object('cno', cno, 'cname', cname))) as courses
		  from e natural join course
		  group by (sid, dept)),
	g as (select  sid, sname, array_to_json(array(select json_build_object(dept, courses) from f where s.sid = f.sid)) as courseInfo
		  from student s)
select  json_build_object('sid', g.sid, 'sname',g.sname, 'courseInfo', g.courseInfo) from g natural join major m
where m.major = 'CS';



			  


\c postgres;
 
 drop database pwassignment7;