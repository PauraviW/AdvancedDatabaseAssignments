create database pwassignment8;
\c pwassignment8;

\qecho 'Question 1'
create table tree (parent int, child int);
insert into tree values (1,2),(1,3), (1,4), (2,5), (2,6), (3,7), (5,8), (7,9), (9,10);

table tree;
drop table if exists anc cascade;
create table ANC(A int, D int, distance int);
create or replace function new_ANC_pairs()
returns table (A integer, D integer) AS
$$
   (select parent, c.A
    from   ANC c JOIN tree ON c.A = child)
   except
   (select  A, D
    from    ANC);
$$ LANGUAGE SQL;

create or replace function distance(v1 int, v2 int)
returns bigint as 
$$
declare dist int;
  begin
  drop table if exists temp1;
	create table temp1(A integer, D integer, distance int);
  	drop table if exists ANC;   
    create table ANC(A integer, D integer, distance int);
    drop table if exists temp2;
	create table temp2(A integer, D integer, distance int);
    insert into ANC select parent, child, 1 from tree where child = v1;
   	
	while exists(select new_ANC_pairs())
   	loop
     dist = (select max(d.distance) from anc d limit 1);
	 insert into ANC select a, d, dist+1 from new_ANC_pairs();
     end loop;
     insert into temp1 select * from ANC;
     delete from ANC;
     if v2 in (select t.a from temp1 t) then return (select t.distance from temp1 t where t.a = v2);
	 end if;

  insert into ANC select parent, child, 1 from tree where child = v2;
    while exists(select new_ANC_pairs())
   loop
   dist = (select distinct max(d.distance) from anc d);
   insert into ANC select a, d, dist+1 from new_ANC_pairs();
   end loop;
    insert into temp2 select * from ANC;
   if v1 in (select t.a from temp2 t) then return (select t.distance from temp2 t where t.a = v1);
   end if;
   dist := (select min(t1.distance + t2.distance) from temp1 t1 join temp2 t2 on(t1.a = t2.a));
   return dist;
  end;

$$ language 'plpgsql';


create or replace view v as ( select t.parent as vertex from tree t
				 union
				 select t.child as vertex from tree t);
select distinct v1.vertex as v1, v2.vertex as v2, distance(v1.vertex, v2.vertex) as distance 
from v v1, v v2 
where v1.vertex <> v2.vertex order by 3,1,2; 

	
    
   
   

\qecho 'Question 2'  

create table graph (source int, target int);
--insert into graph values (1,2), (1,3), (1,4), (3,4), (2,5), (3,5), (5,4), (3,6), (4,6);
--insert into graph values(1,2),(1,3),(1,4),(1,5);
INSERT INTO Graph VALUES 
(      1 ,      2),
(      1 ,      3),
(      1 ,      4),
(      3 ,      4),
(      2 ,      5),
(      3 ,      5),
(      5 ,      4),
(      3 ,      6),
(      4 ,      6);
create or replace function topological_sort() returns table(index int, target int) as
$proc$

declare v record;
		i int;
		val record;
	begin
		drop table if exists temp cascade;
		create table temp(a int, d int, distance int );
		insert into temp
		with recursive path(a , d , distance ) as 
		(
			select source, source, 0
			 from graph
			union
			select p.A, g.target, p.distance+1
    		from   path p JOIN graph g ON p.D = g.source
		)
		select * from path;
		delete from temp c1
		where c1.distance < (select max(c2.distance) from temp c2 where c1.d=c2.d);
		drop table if exists temp1 cascade;
		create table temp1(index int, target int);
		
		for v in select array_agg(d) as vals from temp  group by (distance) order by distance
		loop
			for val in (select * from unnest(v.vals)b order by random())
			loop
			i := (select count(*) from temp1)+1;
			insert into temp1 values (i, val.b);
			end loop;
		end loop;
		return query select * from temp1;
	end;
$proc$ language 'plpgsql';

select * from topological_sort();

select * from topological_sort();

\qecho 'question 3'
create table partsubpart(pid int, sid int, quantity int);
create table basicpart(pid int, weight int);

INSERT INTO partSubPart VALUES
(   1,   2,        4),
(   1,   3,        1),
(   3,   4,        1),
(   3,   5,        2),
(   3,   6,        3),
(   6,   7,        2),
(   6,   8,        3);

INSERT INTO basicPart VALUES
(   2,      5),
(   4,     50),
(   5,      3),
(   7,      6),
(   8,     10);
drop function  if exists aggregatedWeight;
create or replace function aggregatedWeight(p integer) 
returns bigint as 
$$
declare tot_weight int;
begin
	drop table if exists temp1 cascade;

	create table temp1 (sid int, pid int, quantity int);
	insert into temp1
		with recursive included_parts(sid, pid, quantity) as (
		select sid, pid, quantity 
		from partSubPart p 
		where p.pid = aggregatedWeight.p
		union all 
		select p.sid, p.pid, p.quantity 
		from included_parts i, partSubPart p 
		where p.pid = i.sid
	) select * from included_parts;


	create view part_weights as 
		select t1.pid, sum(quantity*weight) as pWeight 
		from temp1 t1, basicPart b
		where b.pid = t1.sid
		group by (t1.pid);


	create view unit_Weights as 
	select t1.sid, sum(quantity*p.pweight) as uweight  
	from temp1 t1, part_weights p
	where t1.sid = p.pid
	group by (t1.sid);
	
	drop table if exists all_weights cascade;
	create table all_weights(weight int);
	insert into all_weights select sum(k.uweight) from (select sid, uweight from unit_Weights uc
													 union
													 select pid as sid, pWeight as unit_Weight 
													 from part_weights bpc2 
													 where bpc2.pid not in (select sid 
		    										 from unit_Weights)
													  union 
													   select pid as sid, weight as unit_weight
													   from basicPart 
													   where pid = aggregatedWeight.p)k;
		
	
	
	tot_weight := (select weight from all_weights limit 1);
	return tot_weight;
	end;
	$$ language 'plpgsql';

select distinct pid, AggregatedWeight(pid)
from   (select pid from partSubPart union select pid from basicPart) q order by 1;


\qecho 'question 4'
create table document(doc text , words text[]);
delete from  document;
insert into document values 
('d7', '{C,B,A}'),
('d1', '{A,B,C}'),
('d8', '{B,A}'),
('d4', '{B,B,A,D}'),
('d2', '{B,C,D}'),
('d6', '{A,D,G}'),
('d3', '{A,E}'),
('d5', '{E,F}');
table document;

create function frequentSets(t int) returns table(words text[]) as 
$proc$
	begin
	create or replace function count_words(w text[]) returns bigint as
	$$
		declare 
		c int;
		begin
		c :=(select count(*) from document d where w <@ d.words);
		return c;
		end;
	$$ language 'plpgsql';
	
	create or replace function order_array(w text[]) returns 	text[] as
	$$
		declare 
		c text[];
		begin
		c :=(SELECT array_agg(b)
			FROM (
				SELECT b 
				FROM unnest(w)b
				ORDER BY b
				)g);
		return c;
		end;
	$$ language 'plpgsql';
	
	drop table if exists temp_table; 
	create table temp_table(words text[]);
	insert into temp_table
		with recursive freq_words(words , count) as 
				((select '{}'::text[] as S,0
				 union
				 select array_agg(distinct v), count_words(array_agg(v)) 
				from document d, unnest(d.words)v
				where count_words(array[v]) >= t
				group by (v)
				 )
				union
				select order_array(b.words || word), count_words(b.words || word)
				from document d, unnest(d.words) word, freq_words b
				where  count_words(b.words || word) >= t and word not in (select n from unnest(b.words) n ))
			select f.words from freq_words f;
	return query select * from temp_table;
	end;
$proc$ language 'plpgsql';

\qecho 'frequent 1 set'
select frequentSets(1);
\qecho 'frequent 2 set'
select frequentSets(2);
\qecho 'frequent 3 set'
select frequentSets(3);
\qecho 'frequent 4 set'
select frequentSets(4);
\qecho 'frequent 5 set'
select frequentSets(5);
\qecho 'frequent 6 set'
select frequentSets(6);
\qecho 'frequent 7 set'
select frequentSets(7);

\qecho 'Question 5'
create table points(pid int, x int, y int);
INSERT INTO Points VALUES
(   1 , 0 , 0),
(   2 , 2 , 0),
(   3 , 4 , 0),
(   4 , 6 , 0),
(   5 , 0 , 2),
(   6 , 2 , 2),
(   7 , 4 , 2),
(   8 , 6 , 2),
(   9 , 0 , 4),
(  10 , 2 , 4),
(  11 , 4 , 4),
(  12 , 6 , 4),
(  13 , 0 , 6),
(  14 , 2 , 6),
(  15 , 4 , 6),
(  16 , 6 , 6),
(  17 , 1 , 1),
(  18 , 5 , 1),
(  19 , 1 , 5),
(  20 , 5 , 5);
drop function kmeans cascade;
create or replace function kmeans(k int) returns table(ii int, ccx float, ccy float) as 
$proc$
	declare 
	high float;
	low float;
	temp_val1 float;
	temp_val2 float;
	update_centroid_x float;
	update_centroid_y float;
	i int;
	v record;
	max_iter int;
	new_centroid int;
	new_centroids jsonb[];
	old_centroids jsonb[];
	temp_val float;
	temp_centroid int;
	begin
	i := 1;
	--high := (select x from points);
	--low := (select y from points);
	
	-- centroid table
	drop table if exists centroids;
	create table centroids(cid int, cx float, cy float);
	while (i <= cast(k as float))
		loop
		temp_val1 := (SELECT x from points order by random() limit 1);
		temp_val2 := (SELECT y from points order by random() limit 1);
		insert into centroids values(i, temp_Val1, temp_Val2);
		i := i+1;
		end loop;
	
	-- random assignment
	drop table if exists assignment;
	create table assignment(pid int, cid int);
	for v in (select * from points p)
		loop
		temp_centroid := (select c.cid from centroids c order by random() limit 1);
		insert into assignment values(v.pid, temp_centroid);
		end loop;
	-- min euclidean distance
	drop function if exists min_euclid_dist;
	create or replace function min_euclid_dist(xx float, yy float) returns bigint as 
	$$	
		declare
		c int;
		min_dist float;
		begin
			min_dist := (select distinct min(sqrt(pow(c1.cx-xx,2)+pow(c1.cy-yy,2))) FROM CENTROIDS c1);
			c := (select distinct c.cid from centroids c
					 where sqrt(pow((c.cx - xx), 2)+ pow((c.cy - yy), 2)) = min_dist limit 1);
			--RAISE NOTICE 'VALUES (%,%, %)', xx,yy, c;	  
			return c;
		end;
	$$ language 'plpgsql';
	
	-- stopping check
	
	create or replace function stopping_conditions(i int, old_centroids jsonb[], new_centroids jsonb[]) returns boolean as 
	$$
	begin
	if (i >= 1000 or old_centroids = new_centroids) then return FALSE; --then return FALSE;
	else return TRUE;
	end if;
	end;																		
	$$ language 'plpgsql';
	-- kmeans 
	i := 0;
	new_centroids := (select array_agg(jsonb_build_object('x',null, 'y',null)));
	old_centroids := (SELECT array_agg(jsonb_build_object('x',c.cx,'y',cy))
					  FROM (
				            SELECT *
				            FROM centroids d
				            ORDER BY 1
				            )c);
	
																			 
	while (select stopping_conditions(i, new_centroids, old_centroids))
		loop
		old_centroids := (SELECT array_agg(jsonb_build_object('x',c.cx,'y',cy))
					  FROM (
				            SELECT *
				            FROM centroids d
				            ORDER BY 1
				            )c);
		for v in (select * from points p)
			loop
			new_centroid := (select min_euclid_dist(v.x, v.y));
		   update assignment set cid = new_centroid where pid = v.pid; 
			new_centroid := (select distinct f.cid from assignment f where f.pid = v.pid);
			end loop;
		
		for v in (select * from centroids)
		loop
		
		update_centroid_x := (select distinct avg(p.x) from points p, assignment a
								   where p.pid = a.pid and a.cid = v.cid group by(a.cid));
		if update_centroid_x is not null then
		update centroids set cx = update_centroid_x where cid = v.cid;
		end if;
		update_centroid_y := (select distinct avg(p.y) from points p, assignment a
								   where p.pid = a.pid and v.cid=a.cid group by(a.cid));
		if update_centroid_y is not null then
		update centroids set cy = update_centroid_y where cid = v.cid;
		end if;
		
																			 
		end loop;
		i := i + 1;
		new_centroids := (SELECT array_agg(jsonb_build_object('x',c.cx,'y',c.cy))
					  FROM (
				            SELECT *
				            FROM centroids d
				            ORDER BY 1
				            )c);
		end loop;
	return query select b.cid as id, b.cx as x, b.cy as y from centroids b;
	end;
$proc$ language 'plpgsql';
select * from kmeans(4);

\c postgres;
drop database pwassignment8;