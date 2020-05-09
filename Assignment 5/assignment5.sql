create database pwassignment5;
\c pwassignment5;

								

create table cites(bookno int, citedbookno int);
create table book(bookno int, title text, price int);
create table student(sid int, sname text);
create table major(sid int, major text);
create table buys(sid int, bookno int);


-- Data for the student relation.
INSERT INTO student VALUES(1001,'Jean'),
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

-- Data for the book relation.
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


-- Data for the buys relation.

INSERT INTO buys VALUES(1001,2002),
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

-- Data for the cites relation.
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


-- Data for the major relation.

INSERT INTO major VALUES(1001,'Math'),
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

\qecho ''
\qecho 'question 1'
with CSStudents as
        (select distinct m.sid
        from major m join major m1 on(m.sid = m1.sid and m1.major = 'CS')),
    booksNotBoughtByCSStudents as
        (select b.bookno, s.sid
        from book b, CSStudents s
        except
        select t.bookno, t.sid
        from buys t),
		
    atleast2 as
        (select distinct b1.bookno
        from booksNotBoughtByCSStudents b1 join booksNotBoughtByCSStudents b2 
                                          on (b1.bookno = b2.bookno and b1.sid !=b2.sid)),
    atleast3 as
		(select distinct k.bookno
		from 
		(select b1.bookno, b1.sid as s1, b2.sid as s2 
		from booksNotBoughtByCSStudents b1 join 
											booksNotBoughtByCSStudents b2 
		 									on (b1.sid!=b2.sid and b1.bookno = b2.bookno)) k 
		 									join booksNotBoughtByCSStudents b3 
											on (k.s1 !=b3.sid and k.s2 != b3.sid and b3.bookno = k.bookno))
    select b.bookno, b.title
    from book b natural join(select b.bookno
                                from atleast2 b
                                except 
                                select b.bookno
                                from atleast3 b)p;

\qecho ''
\qecho ''
\qecho 'Question 2. a'
\qecho ''
create table E1(x int);
create table E2(x int);
create table F(x int);
insert into F values(1),(2),(3);
insert into E1 values (10),(20),(30);
insert into E2 values (-10),(-20),(-30);
\qecho 'table E1'
table E1;
\qecho 'table E2'
table E2;
\qecho 'Case when there are elements in F output E1'
select e1.*
    from E1 e1 cross join F
    union
    select e2.*
    from E2 e2
    except
    (select e2.*
    from E2 e2 cross join F);
\qecho ''
\qecho 'Case when there are no elements in F. output E2'
\qecho ''
delete from f;
select e1.*
    from E1 e1 cross join F
    union
    select e2.*
    from E2 e2
    except
    (select e2.*
    from E2 e2 cross join F);
	

\qecho ''
\qecho ''
\qecho 'Question 2. b'
create table A (x int);
insert into A values(1),(2),(3);
\qecho ''
\qecho 'Case when A is not empty. Output true'
 select t.A_isNotEmpty
 from (select true as A_isNotEmpty) t
 cross join (select distinct row() from  A)k

 union

 (select t.A_isNotEmpty
 from (select false as A_isNotEmpty) t
 except
 select t.A_isNotEmpty
 from (select false as A_isNotEmpty) t
   cross join (select distinct row() from A) k);
delete from A;
\qecho ''
\qecho ''
\qecho 'Case when A is empty. Output false'
 select t.A_isNotEmpty
 from (select true as A_isNotEmpty) t
 cross join (select distinct row() from  A)k

 union

 (select t.A_isNotEmpty
 from (select false as A_isNotEmpty) t
 except
 select t.A_isNotEmpty
 from (select false as A_isNotEmpty) t
   cross join (select distinct row() from A) k);


\qecho ''
\qecho ''
\qecho 'question 7'
with 
cs_major as 
		(select sid from major
		 where major='CS'),
studentswhoboughbooksmorethan10 as
							(select distinct sid 
							from buys t join book b on (b.bookno=t.bookno and b.price > 10))

select distinct sid, sname
from student natural join (select sid
						  from  cs_major natural join studentswhoboughbooksmorethan10 ) b;

\qecho ''
\qecho ''
\qecho 'question 8'
with booklessthan60 as 
(select bookno
from book where price < 60),
citeslessthan60 as 
(select c.bookno, c.citedbookno
from cites c join booklessthan60 b on(c.citedbookno = b.bookno))
select distinct bookno, title, price
from book natural join (select c1.bookno
					   from citeslessthan60  c1 join citeslessthan60  c2 
					   on(c1.bookno = c2.bookno and c1.citedbookno!=c2.citedbookno)) b;
\qecho ''
\qecho ''
\qecho 'Question 9'
with MathMajor as 
(select sid
from Major
where major = 'Math'),

BooksBoughtByMathMajors as 
(select distinct bookno
from buys natural join MathMajor)

select bookno, title, price
from book natural join (select b1.bookno
					   from book b1
					   except 
					   select mm.bookno
					   from  BooksBoughtByMathMajors mm) n;
\qecho ''
\qecho ''
\qecho 'Question 10'


with connectbuysbook as
						(select distinct t.sid,t.bookno,n.price
						from buys t join (select bookno as bno, price from book)n on(n.bno = t.bookno)),
selectnotmostexpensive as 
						(select distinct m1.sid, m1.bookno
						from connectbuysbook m1 join connectbuysbook m2 on(m1.price < m2.price and m1.sid = m2.sid))
select s.sid, s.sname, k.title, k.price
from student s join
				(select n.sid,m.title, m.price
				from book m join 
							(select distinct sid,bookno
							from buys 
							except 
							select sid, bookno
							from selectnotmostexpensive) n on (n.bookno = m.bookno )) k
				on (s.sid = k.sid)
order by 1;


\qecho ''
\qecho ''
\qecho 'Question 11'
with nothighestpricedbook as
					(select distinct b1.*
					from book b1 join book b2 on(b1.price<b2.price))
select distinct bookno, title, price
from nothighestpricedbook
except
select distinct r1.bookno, r1.title, r1.price
from nothighestpricedbook r1 join nothighestpricedbook r2
							 on(r1.price < r2.price);

\qecho ''
\qecho ''
\qecho 'Question 12'
with mostexpensivebooks as 
					(select bookno
					from book
					except
					select b1.bookno
					from book b1 join book b2 
					 on(b1.price<b2.price)),

citetablewithoutexpensivecitations as 
								 (select bookno, citedbookno
								 from cites
								 except
								 select c.bookno, c.citedbookno
								 from cites c join mostexpensivebooks m on(m.bookno = c.citedbookno))
select distinct bookno, title, price
from book natural join citetablewithoutexpensivecitations;

\qecho ''
\qecho ''
\qecho 'Question 13'
with 
singleMajorStudents as
						(select sid
						from major
						except
						select m1.sid
						from major m1 join major m2 
						on(m1.major!=m2.major and m1.sid=m2.sid)),

bookslessthan40 as 
				(select bookno
				from book 
				where price < 40),

studentswhoboughtbooksnotlessthan40 as 
				(select sid
				from student
				except
				select sid
				from buys natural join bookslessthan40)

select sid, sname
from student natural join (select s.sid
						  from singleMajorStudents s natural join studentswhoboughtbooksnotlessthan40  )q;
						  
\qecho ''
\qecho ''
\qecho 'Question 14'
with CSMathStudents as
					(select distinct m1.sid
					from major m1 join major m2 
					 on (m1.major='CS' 
						 and m2.major = 'Math' 
						 and m1.sid=m2.sid))
select bookno, title
from
Book natural join (select bookno
					from book
					except
					select bookno
					from (select distinct sid, bookno
							from CSMathStudents cross join Book
						 except
						 select sid, bookno
						 from buys T)n)m;

\qecho ''
\qecho ''
\qecho 'Question 15'

with f as 
			(select t.sid
			from buys t join book b on(b.bookno = t.bookno and b.price >=70)),
e as 
			(select sid
			from student s
			except
			 (select t.sid
			 from buys t
			 except(select t1.sid
				   from buys t1 join book b on(b.bookno = t1.bookno and b.price <30))))

select s.sid, s.sname
from student s natural join
(select m.*
from e m cross join F
union
select m2.*
from (select m3.*
	 from e m3 
	 except 
	 select m4.* 
	 from e m4 cross join f) m2) m6;


\qecho ''
\qecho ''
\qecho 'Question 16'

with commonmajor as
				(select distinct s1.sid as s1, s2.sid as s2
				from major s1 join major s2 
				 on(s1.sid !=s2.sid and s1.major=s2.major)),
joinstudents as 
				(select s1.s1, s2.s2 
				from commonmajor s1 cross join commonmajor s2),
bookjoin1 as 
				(select s1, s2, b.bookno
				from joinstudents join buys b 
				 on (b.sid = s1)
				except
				select s1, s2, b.bookno
				from joinstudents join buys b 
				 on (b.sid = s2)
				),
bookjoin2 as 
				(select s1, s2, b.bookno
				from joinstudents join buys b 
				 on (b.sid = s2)
				except
				select s1, s2, b.bookno
				from joinstudents join buys b 
				 on (b.sid = s1)
				)
select distinct s1, s2
from commonmajor
natural join (select n.s1, n.s2 from(select s1, s2, bookno
from bookjoin1
union
select s1, s2, bookno
from bookjoin2) n)m
order by 1,2;

\c postgres;
drop database pwassignment5;