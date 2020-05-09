create database pwassignment6;

\c pwassignment6;

create table book(bookno int primary key,
				  title text, 
				  price int);
create table cites(
	bookno int , 
	citedbookno int,
	primary key (bookno, citedbookno),
	foreign key (bookno) references Book(bookno),
	foreign key (citedbookno) references Book(bookno));

create table student(sid int primary key, 
					 sname text);

create table major(sid int,
				   major text,
				  primary key (sid, major),
				  foreign key (sid) references Student(sid));
create table buys(sid int,
				  bookno int,
				 primary key (sid, bookno),
				 foreign key (sid) references Student(sid),
				 foreign key (bookno) references book(bookno));

INSERT INTO student VALUES
(1001,'Jean'),
(1002,'Maria'),
(1003,'Anna'),
(1004,'Chin'),
(1005,'John'),
(1006,'Ryan'),
(1007,'Catherine'),
(1008,'Emma'),
(1009,'Jan'),
(1010,'Linda'),
(1011,'Nick'),
(1012,'Eric'),
(1013,'Lisa'),
(1014,'Filip'),
(1015,'Dirk'),
(1016,'Mary'),
(1017,'Ellen'),
(1020,'Ahmed');

INSERT INTO book VALUES(2001,'Databases',40),
(2002,'OperatingSystems',25),
(2003,'Networks',20),
(2004,'AI',45),
(2005,'DiscreteMathematics',20),
(2006,'SQL',25),
(2007,'ProgrammingLanguages',15),
(2008,'DataScience',50),
(2009,'Calculus',10),
(2010,'Philosophy',25),
(2012,'Geometry',80),
(2013,'RealAnalysis',35),
(2011,'Anthropology',50),
(3000,'MachineLearning',40);



INSERT INTO buys VALUES
(1001,2002),
(1001,2007),
(1001,2009),
(1001,2011),
(1001,2013),
(1002,2001),
(1002,2002),
(1002,2007),
(1002,2011),
(1002,2012),
(1002,2013),
(1003,2002),
(1003,2007),
(1003,2011),
(1003,2012),
(1003,2013),
(1004,2006),
(1004,2007),
(1004,2008),
(1004,2011),
(1004,2012),
(1004,2013),
(1005,2007),
(1005,2011),
(1005,2012),
(1005,2013),
(1006,2006),
(1006,2007),
(1006,2008),
(1006,2011),
(1006,2012),
(1006,2013),
(1007,2001),
(1007,2002),
(1007,2003),
(1007,2007),
(1007,2008),
(1007,2009),
(1007,2010),
(1007,2011),
(1007,2012),
(1007,2013),
(1008,2007),
(1008,2011),
(1008,2012),
(1008,2013),
(1009,2001),
(1009,2002),
(1009,2011),
(1009,2012),
(1009,2013),
(1010,2001),
(1010,2002),
(1010,2003),
(1010,2011),
(1010,2012),
(1010,2013),
(1011,2002),
(1011,2011),
(1011,2012),
(1012,2011),
(1012,2012),
(1013,2001),
(1013,2011),
(1013,2012),
(1014,2008),
(1014,2011),
(1014,2012),
(1017,2001),
(1017,2002),
(1017,2003),
(1017,2008),
(1017,2012),
(1020,2012);

INSERT INTO cites VALUES(2012,2001),
(2008,2011),
(2008,2012),
(2001,2002),
(2001,2007),
(2002,2003),
(2003,2001),
(2003,2004),
(2003,2002),
(2012,2005);



INSERT INTO major VALUES
(1001,'Math'),
(1001,'Physics'),
(1002,'CS'),
(1002,'Math'),
(1003,'Math'),
(1004,'CS'),
(1006,'CS'),
(1007,'CS'),
(1007,'Physics'),
(1008,'Physics'),
(1009,'Biology'),
(1010,'Biology'),
(1011,'CS'),
(1011,'Math'),
(1012,'CS'),
(1013,'CS'),
(1013,'Psychology'),
(1014,'Theater'),
(1017,'Anthropology');

\qecho 'Question 3'
-- original query
\qecho 'Query Translation'
select s.sid, s.sname
from student s
where s.sid in (select m.sid from major m where m.major = 'CS') and
				exists (select 1
				from cites c, book b1, book b2
				where (s.sid,c.bookno) in (select t.sid, t.bookno from buys t) and
											c.bookno = b1.bookno and c.citedbookno = b2.bookno and
											b1.price < b2.price);
-- taking in the IN clause
select s.sid, s.sname
from student s, major m
where s.sid = m.sid and m.major = 'CS' and exists (select 1
													from cites c, book b1, book b2
													where (s.sid,c.bookno) in (select t.sid, t.bookno from buys t) and
																				c.bookno = b1.bookno and c.citedbookno = b2.bookno and
																				b1.price < b2.price);
--taking in the Exists clause
select distinct s.sid, s.sname
from student s, major m, cites c, book b1, book b2
where s.sid = m.sid and 
m.major = 'CS' and 
c.bookno = b1.bookno and 
c.citedbookno = b2.bookno and
b1.price < b2.price and (s.sid,c.bookno) in (select t.sid, t.bookno from buys t) ;
-- taking in the IN clause
-- select distinct s.sid, s.sname
-- from student s, major m, cites c, book b1, book b2, buys t
-- where s.sid = m.sid and m.major = 'CS' and c.bookno = b1.bookno and c.citedbookno = b2.bookno and
-- b1.price < b2.price and s.sid = t.sid and t.bookno = b1.bookno;

-- using natural joins and joins
-- select distinct s.sid, s.sname
-- from (student s natural join major m natural join buys t) 
-- 	join cites c on (c.bookno = t.bookno)
-- 	join book b1 on (c.bookno = b1.bookno)
-- 	join book b2 on (c.citedbookno = b2.bookno and b1.price<b2.price)
-- 	where m.major = 'CS';

-- eliminating the where clause
with CSmajor as (select m.sid from major m where m.major = 'CS')
    select distinct s.sid, s.sname
    from (student s natural join CSmajor natural join buys t) 
    join cites c on (c.bookno = t.bookno)  
    join book b1 on (b1.bookno = c.bookno )  
    join book b2 on (b2.bookno = c.citedbookno and b1.price < b2.price);

\qecho 'Query Optimization'
\qecho 'take out only the booknos and price and make a common join of student, CS majors and buys'
with  csmajor as 
          (select m.sid from major m where m.major = 'CS'),
      T as 
          (select distinct s.sid, s.sname, b.bookno 
           from student s 
                natural join csmajor c 
                natural join buys b),
      B as 
          (select distinct bookno, price from book),
      C as 
          (select c.bookno 
           from cites c
           join book b1 on (c.bookno=b1.bookno)
           join book b2 on (c.citedbookno = b2.bookno and b1.price<b2.price))
      
      select distinct t.sid, t.sname
      from T join  C on (t.bookno = c.bookno)
      order by 1,2;

\qecho ''
\qecho 'Question 4'
\qecho ''

-- taking in the in query
select distinct s.sid, s.sname, m.major
from student s, major m, buys t, book b
where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60 and 
s.sid not in (select m.sid from major m where m.major = 'CS') and
s.sid <> ALL (select t.sid
from buys t, book b
where t.bookno = b.bookno and b.price < 30);

-- eliminating the not in clause
select distinct q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, m.major, t.bookno, b.*
	from student s, major m, buys t, book b
	where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60 
	and s.sid <> ALL (select t.sid
	from buys t, book b
	where t.bookno = b.bookno and b.price < 30)
	except
	select distinct s.sid, s.sname, m.major, t.bookno, b.*
	from student s, major m, buys t, book b, major m1
	where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60 and m1.sid = s.sid and m1.major = 'CS')q;

\qecho 'eliminating the not all clause by joining with the except clause'
select distinct q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, m.major, t.bookno
	from student s, major m, buys t, book b
	where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60 
	except
	select distinct q1.sid, q1.sname, q1.major, q1.bookno
	from (
	select distinct s.sid, s.sname, m.major, t.bookno, b.price, b.title
	from student s, major m, buys t, book b, major m1
	where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60 and m1.sid = s.sid and m1.major = 'CS'
	union
	select distinct s.sid, s.sname, m.major, t.bookno, b.price, b.title
	from student s, major m, buys t, book b, buys t1, book b1
	where s.sid = m.sid and s.sid = t.sid and t.bookno = b.bookno and b.price < 60  and t1.bookno = b1.bookno and b1.price < 30
	and s.sid = t1.sid
	)q1)q;

-- replacing with natural joins
-- select q.sid, q.sname, q.major
-- from (select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t natural join book b
-- 	where b.price < 60 
-- 	except
-- 	select distinct q1.sid, q1.sname, q1.major
-- 	from (
-- 	select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t natural join book b 
-- 		 join major m1 on (m1.sid = s.sid and m1.major = 'CS') 
-- 	where    b.price < 60  
-- 	union
-- 	select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t natural join book b
-- 		join (buys t1 natural join book b1) on (s.sid = t1.sid and b1.price < 30)
-- 	where  b.price < 60 
-- 	)q1)q;

\qecho 'eliminating the where clause'
select distinct q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t
	join book b on (t.bookno = b.bookno and b.price < 60 )
	except
	select distinct q1.sid, q1.sname, q1.major
	from (
	select distinct s.sid, s.sname, m.major, t.bookno, b.title, b.price
	from student s natural join major m natural join buys t 
		 join book b on (t.bookno = b.bookno and b.price < 60 )
		 join major m1 on (m1.sid = s.sid and m1.major = 'CS') 
	union
	select distinct s.sid, s.sname, m.major, t.bookno, b.title, b.price
	from student s natural join major m natural join buys t 
		join book b on (t.bookno = b.bookno and b.price < 60 ) 
		join buys t1 on(s.sid = t1.sid)
		join book b1 on (b1.bookno = t1.bookno and b1.price < 30)
	)q1)q;

\qecho 'Optimization'
\qecho ' take out only the prices and booknos from books and CS majors. Keeping only the relevant attributes'
-- with 
-- CSMajors as (select m.sid from major m where m.major = 'CS'),
-- booklessthan60 as (select b.bookno, b.price from book b where b.price < 60),
-- booklessthan30 as (select b.bookno, b.price from book b where b.price < 30)
-- select q.sid, q.sname, q.major
-- from (select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t
-- 	join booklessthan60 b on (t.bookno = b.bookno)
-- 	except
-- 	select distinct q1.sid, q1.sname, q1.major
-- 	from (
-- 	select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t 
-- 		 join booklessthan60 b on (t.bookno = b.bookno  )
-- 		 join CSMajors m1 on (m1.sid = s.sid) 
-- 	union
-- 	select distinct s.sid, s.sname, m.major
-- 	from student s natural join major m natural join buys t 
-- 		join booklessthan60 b on (t.bookno = b.bookno  ) 
-- 		join buys t1 on(s.sid = t1.sid)
-- 		join booklessthan30 b1 on (b1.bookno = t1.bookno)
-- 	)q1)q;

-- convert joins in natural joins
\qecho 'Convert to natural joins'
with 
CSMajors as (select m.sid from major m where m.major = 'CS'),
booklessthan60 as (select b.bookno, b.price from book b where b.price < 60),
booklessthan30 as (select b.bookno, b.price from book b where b.price < 30)
select q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t
	natural join booklessthan60 b
	except
	select distinct q1.sid, q1.sname, q1.major
	from (
	select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t 
		 natural join booklessthan60 b 
		 join CSMajors m1 on (m1.sid = s.sid) 
	union
	select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t 
		natural join booklessthan60 b  
		join buys t1 on(s.sid = t1.sid)
		join booklessthan30 b1 on (b1.bookno = t1.bookno)
	)q1)q;

\qecho 'taking out common oprations in a view'
with 
CSMajors as (select m.sid from major m where m.major = 'CS'),
booklessthan60 as (select b.bookno, b.price from book b where b.price < 60),
booklessthan30 as (select b.bookno, b.price from book b where b.price < 30)
select q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t
	natural join booklessthan60 b
	except
	select distinct q1.sid, q1.sname, q1.major
	from (
	select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t 
		 natural join booklessthan60 b 
		 join CSMajors m1 on (m1.sid = s.sid) 
	union
	select distinct s.sid, s.sname, m.major
	from student s natural join major m natural join buys t 
		natural join booklessthan60 b  
		join buys t1 on(s.sid = t1.sid)
		join booklessthan30 b1 on (b1.bookno = t1.bookno)
	)q1)q;

\qecho 'We can further eliminate one natural join using the conditions. As we know that in the except clause'
\qecho 'we want books less than 60 and books less than 30 so if we just take books less than 30, we would get the same result as it covers books less than 60 too '

with 
CSMajors as (select m.sid from major m where m.major = 'CS'),
booklessthan60 as (select b.bookno, b.price from book b where b.price < 60),
booklessthan30 as (select b.bookno, b.price from book b where b.price < 30),
commonjoin as (select s.sid, s.sname, m.major from student s natural join major m)
select q.sid, q.sname, q.major
from (select distinct s.sid, s.sname, s.major
	from commonjoin s natural join buys t natural join booklessthan60 b
	except
	select distinct q1.sid, q1.sname, q1.major
	from (
	select distinct s.sid, s.sname, s.major
	from commonjoin s natural join buys t 
		 natural join CSMajors m1 
	union
	select distinct s.sid, s.sname, s.major
	from commonjoin s natural join buys t 
		natural join booklessthan30 b1 
	)q1)q;

\qecho ''
\qecho 'Question 5'

\qecho 'Convert >=all to not exists'
select distinct s.sid, s.sname, b.bookno 
from student s, buys t, book b 
where s.sid = t.sid and t.bookno = b.bookno and 
not exists (select 1
		   from book b1 
		   where b.price < b1.price and (s.sid,b1.bookno) in (select t.sid, t.bookno from buys t) );
\qecho 'not exists clause'
select q.sid, q.sname, q.bookno
from (select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
	  from student s, buys t, book b 
	  where s.sid = t.sid and t.bookno = b.bookno
	  except
	  select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
	  from student s, buys t, book b , book b1
	  where s.sid = t.sid and t.bookno = b.bookno and b.price < b1.price and (s.sid,b1.bookno) in (select t.sid, t.bookno from buys t)
 )q order by 1;
 
--  \qecho 'taking in the in clause'
-- select distinct q.sid, q.sname, q.bookno
-- from (select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
-- 	  from student s, buys t, book b 
-- 	  where s.sid = t.sid and t.bookno = b.bookno
-- 	  except
-- 	  select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
-- 	  from student s, buys t, book b , book b1, buys t1
-- 	  where s.sid = t.sid and t.bookno = b.bookno and b.price < b1.price and s.sid = t1.sid and b1.bookno = t1.bookno
--  )q order by 1;
 
 \qecho 'introducing joins'
select distinct q.sid, q.sname, q.bookno
from (select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
	  from student s natural join buys t natural join book b 
	  except
	  select distinct s.*, t.sid as sd, t.bookno as bno, b.* 
	  from student s natural join buys t natural join book b join (book b1 natural join buys t1)
	  on (b.price < b1.price and s.sid = t1.sid ))q order by 1;
	  
\qecho 'Optimization'
with B as (select bookno, price from book)
select distinct q.sid, q.sname, q.bookno
from (select s.sid, s.sname, t.bookno
	 from student s natural join buys t natural join B b
	 except 
	 select s.sid, s.sname, t.bookno
	 from student s natural join buys t natural join book b join (B b1 natural join buys t1)
	  on (b.price < b1.price and s.sid = t1.sid ))q
	  order by 1;


\qecho 'Question 6'
\qecho 'take in the exists clause' 
 
select distinct b.bookno, b.title
from book b, student s
where s.sid in (select m.sid from major m
								where m.major = 'CS'
								UNION
								select m.sid from major m
								where m.major = 'Math') and
				s.sid not in (select t.sid
							  from buys t
							  where t.bookno = b.bookno) order by 1;

-- take out Math and CS 
-- with MATHCS as (select m.sid from major m
-- 				where m.major = 'CS'
-- 				UNION
-- 				select m.sid from major m
-- 				where m.major = 'Math') 
-- select distinct b.bookno, b.title
-- from book b, student s, mathcs c
-- where s.sid = c.sid and s.sid not in (select t.sid
-- 							  from buys t
-- 							  where t.bookno = b.bookno) order by 1;

\qecho 'take in the not in clause'
with MATHCS as (select m.sid from major m
				where m.major = 'CS'
				UNION
				select m.sid from major m
				where m.major = 'Math') 
select distinct q.bookno, q.title
from (select distinct b.*, s.*
	  from book b, student s, mathcs c
	  where s.sid = c.sid
	  except
	  select distinct b.*, s.*
	  from book b, student s, mathcs c, buys t
	  where s.sid = c.sid and b.bookno = t.bookno and s.sid = t.sid)q order by 1;
	  
\qecho  'introducing join'
with MATHCS as (select m.sid from major m
				where m.major = 'CS'
				UNION
				select m.sid from major m
				where m.major = 'Math') 
select distinct q.bookno, q.title
from (select distinct b.*, s.*
	  from book b cross join student s natural join  mathcs c
	  except
	  select distinct b.*, s.*
	  from student s natural join mathcs c natural join buys t natural join book b
	  )q order by 1;

\qecho 'Optimizing the query'
\qecho 'we can remove the student relation using the laws of foreign keys'

-- with MATHCS as (select m.sid from major m
-- 				where m.major = 'CS'
-- 				UNION
-- 				select m.sid from major m
-- 				where m.major = 'Math') 
-- select distinct q.bookno, q.title
-- from (select distinct b.bookno, b.title, c.sid
-- 	  from book b cross join mathcs c
-- 	  except
-- 	  select distinct b.bookno, b.title, c.sid
-- 	  from  mathcs c natural join buys t natural join book b
-- 	  )q order by 1;

\qecho 'extract relevant attributes from relation book '

with MATHCS as (select m.sid from major m
				where m.major = 'CS'
				UNION
				select m.sid from major m
				where m.major = 'Math'),
	B as (select bookno, title from book b)
select distinct q.bookno, q.title
from (select distinct b.bookno, b.title, c.sid
	  from B b cross join mathcs c
	  except
	  select distinct b.bookno, b.title, t.sid
	  from   buys t natural join B b
	  )q order by 1;

\qecho ''
\qecho 'Question 7'
create or replace function makerandomR(m integer, n integer, l integer)
returns void as
$$
declare i integer; j integer;
begin
drop table if exists Ra; drop table if exists Rb;
drop table if exists R;
create table Ra(a int); create table Rb(b int);
create table R(a int, b int);
for i in 1..m loop insert into Ra values(i); end loop;
for j in 1..n loop insert into Rb values(j); end loop;
insert into R select * from Ra a, Rb b order by random() limit(l);
end;
$$ LANGUAGE plpgsql;

create or replace function makerandomS(n integer, l integer)
returns void as
$$
declare i integer;
begin
drop table if exists Sb;
drop table if exists S;
create table Sb(b int);
create table S(b int);
for i in 1..n loop insert into Sb values(i); end loop;
insert into S select * from Sb order by random() limit (l);
end;
$$ LANGUAGE plpgsql;
select makerandomR(3,3,4);
select makerandomS(3,1);

\qecho ''
\qecho 'question 7'
\qecho ''

\qecho '7.a'

\qecho ''
\qecho 'Optimized query'

\qecho 'non-optimized query'
select distinct r1.a
from R r1, R r2, R r3
where r1.b = r2.a and r2.b = r3.a;

\qecho 'using views and aliasing '
with R3 as (select distinct r3.a as b from r r3),
R2 as (select distinct r2.a as b from R r2, r3 where r2.b = r3.b )
select distinct r1.a
from R r1, r2
where r1.b = r2.b;

\qecho 'replacing with natural joins'
with R3 as (select distinct r3.a as b from r r3),
R2 as (select distinct r2.a as b from R r2 natural join r3)
select distinct r1.a
from R r1 natural join r2;

\qecho ''
\qecho 'question 8'
\qecho ''

\qecho '8.a'
\qecho ''
\qecho ''
\qecho 'Original query'
select ra.a
from Ra ra
where not exists (select r.b
from R r
where r.a = ra.a and
r.b not in (select s.b from S s));

\qecho 'remove the not exists'
select q.a
from (select ra.a 
	 from Ra ra
	 except
	 select ra.a 
	 from Ra ra, R r
	 where r.a = ra.a and
	 r.b not in(select s.b from S s))q;

\qecho 'remove the not in clause'
select q.a
from (select ra.a 
	 from Ra ra
	 except
	 select q1.a
	  from (select ra.a, r.b
	 		from Ra ra, R r
	 		where r.a = ra.a
		    except
		   	select ra.a, r.b
	 		from Ra ra, R r, S s
	 		where r.a = ra.a and s.b = r.b)q1)q;
			
\qecho 'introduce natural joins' 
select q.a
from (select ra.a 
	 from Ra ra
	 except
	 select q1.a
	  from (select ra.a, r.b
	 		from Ra ra natural join R r
		    except
		   	select ra.a, r.b
	 		from Ra ra natural join R r natural join S s)q1)q;
			

\qecho 'remove Ra table '
select q.a
from (select distinct ra.a 
	 from Ra ra
	 except
	 select q1.a
	  from (select r.a, r.b
	 		from R r
		    except
		   	select distinct r.a, r.b 
			from r r natural join s s )q1)q;

\qecho 'question 9'

\qecho 'Original query'
select ra.a
from Ra ra
where not exists (select s.b
from S s
where s.b not in (select r.b
from R r
where r.a = ra.a));

\qecho 'remove the not exists clause'
select q.a 
from (select ra.a
	 from Ra ra
	 except
	 (select ra.a
	 from ra ra , s s
	 where s.b not in (select r.b
										from R r
										where r.a = ra.a)))q;

\qecho 'remove he not in clause'
select q.a
from (select ra.a 
	 from ra ra
	 except
	 (select q1.a
	 from (select ra.a, s.b
		  from ra ra, s s
		  except
		  select ra.a, s.b
		  from ra ra, s s, r r
		  where r.a = ra.a and r.b = s.b)q1))q;
		  
		  
\qecho 'natural joins'
select q.a
from (select ra.a 
	 from ra ra
	 except
	 (select q1.a
	 from (select ra.a, s.b
		  from ra ra, s s
		  except
		  select r.a, r.b
		  from  r r natural join s s
		  )q1))q;
		  
\qecho 'adding cross joins'
select distinct q.a
from (select ra.a
	 from Ra ra 
	 except
	 select q1.a
	 from (select  ra.a, s.b
		  from ra ra cross join s s
		  except
		  select r.a, r.b
		  from  r r natural join s s)q1)q;



		  
\qecho 'question 12'

create or replace function setunion(A anyarray, B anyarray) returns anyarray as 
$$
with 
Aset as (select unnest(A)),
Bset as (select unnest(B))
select array((select * from Aset) union (select * from Bset) order by 1);
$$ language sql;
\qecho '12.a' 
\qecho 'function for set intersection'
create or replace function setintersection(A anyarray, B anyarray) returns anyarray as 
$$
	with 
	Aset as (select unnest(A)),
	Bset as (select unnest(B))
	select array((select * from Aset) intersect (select * from Bset) order by 1);
$$ language sql;

\qecho 'function for setdifference'
create or replace function setdifference (A anyarray, B anyarray) returns anyarray as 
$$
	with 
	Aset as (select unnest(A)),
	Bset as (select unnest(B))
	select array((select * from Aset) except (select * from Bset) order by 1 );
$$ language sql;

\qecho 'function to check if value is in the set'

create or replace function isIn(x anyelement, S anyarray) returns boolean as 
$$
	select x = SOME(S) 
$$ language sql;

\qecho 'Question 13'
create or replace view student_books as 
select s.sid, array(select t.bookno
				   from buys t 
				   where t.sid = s.sid order by t.bookno) as books
from student s order by s.sid;

\qecho 'question 13.a'
create or replace view book_students as 
	select b.bookno, array(select t.sid
						  from buys t 
						   where t.bookno = b.bookno order by t.sid) as students
	from book b order by b.bookno;

select * from book_students;

\qecho 'question 13.b'

create or replace view book_citedbooks as 
	select b.bookno, array(select c.citedbookno
						  from cites c 
						  where c.bookno = b.bookno order by c.citedbookno) as citedbooks
	from book b order by b.bookno;
select * from book_citedbooks;

\qecho 'question 13.c'
create or replace view book_citingbooks as
 select b.bookno, array(select c.bookno
					   from cites c
					   where c.citedbookno = b.bookno order by c.bookno) as citingbooks
from book b order by b.bookno;

select * from book_citingbooks;
					   
\qecho 'question 13.d'

create or replace view major_students as 
select distinct m.major , array(select m1.sid
					  from major m1
					  where m1.major = m.major order by m1.sid) as students
from major m order by m.major;

select * from major_students;

\qecho 'question 13.e'
create or replace view student_majors(sid, majors) as 
select s.sid, array(select m.major
				   from major m
				   where m.sid = s.sid order by m.major) as majors
from student s order by s.sid;

select * from student_majors;

\qecho ''
\qecho ''
\qecho 'question 14 a'
with bookslessthan50 as (select array(select b.bookno from book b where price < 50) as books)
select b.bookno,b.title
from book b, book_citedbooks b1, bookslessthan50 k
where  b.bookno = b1.bookno and cardinality(setintersection(b1.citedbooks, k.books)) >= 3;
\qecho 'question 14.b'


with CS_students as (select  s.students from major_students s where s.major = 'CS')
select b.bookno, b.title
from book b, book_students s, CS_students c
where b.bookno = s.bookno and cardinality(setintersection(s.students, c.students)) = 0;

\qecho ' question 14.c'

with booksatleast50 as (select array(select bookno from book  where price >=50 ) as books)
select s.sid
from student_books s, booksatleast50 b
where cardinality(setdifference(b.books, s.books)) = 0;


\qecho 'question 14.d'

with cs_students as (select s.students from major_students s where s.major = 'CS')
select b.bookno
from book_students b, cs_students s
where cardinality(setdifference(b.students, s.students)) !=0;


\qecho 'question 14.e'

with 
booksgreaterthan45 as (select array(select b.bookno from book b where b.price > 45) as books),
studentsboughtbookmorethan45 as (select array(select s.sid
								from student_books s, booksgreaterthan45 b 
								where cardinality(setdifference(b.books,s.books)) = 0) as students)
select b.bookno,b.title
from book b, book_students b1, studentsboughtbookmorethan45 s
where b.bookno = b1.bookno and cardinality(setdifference(b1.students, s.students)) !=0;

\qecho 'question 14.f'
select s.sid as s, c.bookno  as b
from student_books s, book_citingbooks c
where cardinality(setdifference( s.books, c.citingbooks)) >0;


\qecho 'question 14.g'
select b1.bookno as b1, b2.bookno as b2
from book_students b1, book_students b2
where  
cardinality(setdifference(b1.students, b2.students)) = 0 and 
cardinality(setdifference(b2.students, b1.students)) = 0;

\qecho 'question 14.h'
select  b1.bookno, b2.bookno
from book_students b1, book_students b2
where  cardinality(b1.students) = cardinality(b2.students) order by 1,2;

\qecho 'question 14.i'
with allbooks as (select array(select b.bookno from book b) as books)
select s.sid
from student_books s, allbooks a
where   cardinality(a.books) - cardinality(s.books) = 4;

\qecho 'question 14.j'

with psychologystudents as (select s.students from major_students s where s.major = 'Psychology'),
noBooksBoughtByPsy as (select cardinality(s.books) as noBooks from student_books s,psychologystudents p where isIn(s.sid, p.students))
select s.sid
from student_books s, noBooksBoughtByPsy n
where cardinality(s.books) <= n.noBooks;




\c postgres;

drop database pwassignment6;