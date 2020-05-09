create database pwassignment3;
\c pwassignment3;

create table A (x int);
create table B (x int);

insert into A values(-1),
					(-234),
					(56),
					(34);
insert into B values(-1),
					(-234),
					(56);

\qecho ' '
\qecho 'question 1.a'
\qecho 'In this query, I check if there exists values after taking a difference of B from A and A from B and if there exists intersection or not and display the values accordingly'
\qecho ''
select not exists(select A.x
				  from A
				  except
				  select B.x
				  from B) as empty_a_minus_b, 
		not exists(select B.x
				   from B
				   except
				   select A.x
				   from A)as empty_b_minus_a,
		not exists (select B.x
			 		from B
			 		intersect
			  		select A.x
			   		from A)as empty_a_intersection_b ;
\qecho ' '
\qecho ' question 1.b'
\qecho 'In this query, I check if there does not exist a value in table A which is not in B, this gives me whether the result of the expression is null or not, I use the same for the B-A part and then I check if any element of A is in B, which automatically proves that A intersection B is an empty set or not. '
\qecho ''
select not exists (select A.x 
					from A 
					where A.x not in(select B.x
				   					 from B)) as empty_a_minus_b, 
	   not exists (select B.x 
					from B 
					where B.x not in(select A.x
				   					 from A)) as empty_b_minus_a, 
	   not exists (select A.x
				   from A
				   where A.x in (Select B.x
								 from B)) as empty_a_intersection_b;

drop table A;
drop table B;
\qecho ''
\qecho 'question 2'
\qecho ' In this question, I converted the if--then statement into a statement with ands and ors and computed the Truth table on that basis.'
create table p(x boolean);
create table q(x boolean);
create table r(x boolean);
insert into p values(true),
					(false),
					(NULL);
insert into q values(true),
					(false),
					(NULL);
insert into r values(true),
					(false),
					(NULL);

select p.x as p, q.x as q, r.x as r, p.x and not q.x or not r.x as value
from p,q,r;

drop table r;
drop table p;
drop table q;
\qecho ''
\qecho 'question 3.a'
\qecho 'In this I have used the distance formula to calculate whether the distance between the two points is the least amongst distances between all the points '
\qecho ''

create table Point(pid integer primary key, x float, y float);
insert into Point values(1,0,0),
						(2,0,1),
						(3,1,0);
\qecho ''	
select p1.pid as p1, p2.pid as p2
from Point p1, Point p2
where p1.pid != p2.pid and 
sqrt(power(p1.x-p2.x,2) + power(p1.y-p2.y,2)) <= all( select sqrt(power(p3.x-p4.x,2) + power(p3.y-p4.y,2))
														   from Point p3, Point p4
														where p3.pid != p4.pid);

\qecho ''
\qecho 'question  3.b'
\qecho 'I have used the area of triangle formula to check of the area formed by the points is zero or not. If yes then the points are collinear.'
drop table point;
create table point(pid int primary key, x float, y float);
insert into point values(1, 2,4),
					(2,4,6),
					(3,6,8);
					
select p1.pid, p2.pid, p3.pid
from point p1, point p2, point p3
where p1.pid != p2.pid and
	p2.pid != p3.pid and
	p3.pid!= p1.pid and
	((p1.x-p2.x)*(p2.y - p3.y) - (p2.x-p3.x)*(p1.y-p2.y)) = 0;
drop table point;

\qecho 'question 4.a'
\qecho 'In this question, I have tried to identify where the given SET is has attribute A as its primary key or not by contructing a view, that converts the data into a set and then I check the condition that there should not exist two tuples with same primary key and different values for any of the other attributes. '
create table R(A int, 
				B int , 
				C int);
insert into R values(1, 2, 3),
					(2, 2, 3),
					(3, 2, 3);

with isPrimaryKeyView as 
	(select distinct R.a, r.b, r.c
	from R)
select not exists(select r1.a 
	from isPrimaryKeyView r1, isPrimaryKeyView r2
	where (r1.a = r2.a and
	r1.b !=r2.b) or
	(r1.c !=r2.c and r1.a = r2.a)) as isPrimaryKey;

drop table R;
\qecho 'question 4.b'
\qecho ' Relation with primary key'
create table R(A int, B int , C int);
insert into R values(1, 2, 3),
(2, 2, 3),
(3, 3, 4),
(8, 6, 5),
(7, 6, 5);
with isPrimaryKeyView as 
	(select distinct R.a, r.b, r.c
	from R)
select not exists(select r1.a 
	from isPrimaryKeyView r1, isPrimaryKeyView r2
	where (r1.a = r2.a and
	r1.b !=r2.b) or
	(r1.c !=r2.c and r1.a = r2.a)) as isPrimaryKey;

drop table R;



\qecho 'Relation without primary key'
create table R(A int, B int , C int);
insert into R values(1,2,3),
					(2,3,4),
					(2,4,5);
with isPrimaryKeyView as 
	(select distinct R.a, r.b, r.c
	from R)
select not exists(select r1.a 
	from isPrimaryKeyView r1, isPrimaryKeyView r2
	where (r1.a = r2.a and
	r1.b !=r2.b) or
	(r1.c !=r2.c and r1.a = r2.a)) as isPrimaryKey;

drop table R;

\qecho 'question 5'
\qecho ' In this question, I created a function that calculates the M^2 value as needed. Then, I use another quesry to calculate the multiplication of the result obtined from that view and finally get the output'
create table M(row int, colmn int, value int);
insert into M values(1, 1, 1),
(1, 2, 2),
(1, 3, 3),
(2, 1, 1),
(2, 2, -3),
(2, 3, 5),
(3, 1, 4),
(3, 2, 0),
(3, 3, -2);


-- return extended val

create view matrix_mul as
	select m1.row as row, m2.colmn as colmn, sum(m1.value * m2.value) as value
	from m m1, m m2
	where m1.colmn = m2.row 
	group by (m1.row, m2.colmn);


select m1.row, m2.colmn, sum(m1.value * m2.value) as value
	from matrix_mul m1, matrix_mul m2
	where m1.colmn = m2.row 
	group by (m1.row, m2.colmn);
drop view matrix_mul;
drop table M;
\qecho ''
\qecho 'question 6'
\qecho 'I checked for the numbers which have equivalent remainders and then I grouped them together on the basis of the remainder value.'

create table A(x int);
insert into A values(51),
					(562),
					(21),
					(8868),
					(2),
					(5),
					(48),
					(2),
					(3),
					(7),
					(5);
select (select abs(a1.x) % 4) as remainder , count(1) no_of_values  
from A a1
where exists( select 1
			from A a2 
			where a2.x != a1.x and 
				abs(a1.x) % 4 = abs(a2.x) % 4)
group by (remainder)
order by 1;
drop table a;

\qecho ''
\qecho 'question 7'
\qecho 'In this when I performed group by on the values, I immediately got a set out of the bag'
create table A(x int);
insert into A values(5),
					(3),
					(3),
					(2),
					(1),
					(5),
					(3);

select a1.x as x
from A a1
group by a1.x
order by 1;

drop table a;
\qecho 'questions 8-16'
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

delete from buys;
delete from major;
delete from cites;
delete from student;

delete from book;
INSERT INTO student VALUES(1001,'Jean'),
						  (1002,'Maria'),
						  (1003,'Anna'),
						  (1004,'Chin'),
						  (1005,'John'),
						  (1006,'Ryan'),
						  (1007,'Catherine'),
						  (1008,'Emma'),
						  (1009,'Jan');
INSERT INTO student VALUES(1010,'Linda'),
						  (1011,'Nick'),
						  (1012,'Eric'),
						  (1013,'Lisa'),
						  (1014,'Filip'),
						  (1015,'Dirk'),
						  (1016,'Mary'),
						  (1017,'Ellen'),
						  (1020,'Ahmed');
insert into student values (1021, 'Kris');

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
insert into book values     (4001, 'LinearAlgebra', 30),
							(4002, 'MeasureTheory', 75), 
							(4003, 'OptimizationTheory', 30);


insert into major values (1021, 'CS'),
						 (1021, 'Math');
insert into buys values     (1001,3000),   
							(1001,2004),   
							(1021, 2001),  
							(1021, 2002),  
							(1021, 2003),   
							(1021, 2004),   
							(1021, 2005),   
							(1021, 2006),   
							(1021, 2007),   
							(1021, 2008),   
							(1021, 2009),   
							(1021, 2010),   
							(1021, 2011),   
							(1021, 4003),   
							(1021, 4001),   
							(1021, 4002),   
							(1015, 2001),   
							(1015, 2002),   
							(1016, 2001),   
							(1016, 2002),   
							(1015, 2004),   
							(1015, 2008),   
							(1015, 2012),   
							(1015, 2011),   
							(1015, 3000),   
							(1016, 2004),   
							(1016, 2008),   
							(1016, 2012),   
							(1016, 2011),   
							(1016, 3000),   
							(1002, 4003),   
							(1011, 4003),   
							(1015, 4003),   
							(1015, 4001),   
							(1015, 4002),   
							(1016, 4001),   
							(1016, 4002);

-- Data for the book relation.
-- Data for the buys relation.
INSERT INTO buys VALUES (1001,2002),
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
						(1006,2011);
INSERT INTO buys VALUES(1006,2012),
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

	
\qecho 'question 8.a'
\qecho 'In this query, I created a user defined function that returns the total number of times the book was bought by CS students. Then i use this to filter only those books that were bought less than 3 times and I also check for the price to be less than 40'
-- create a view of CS stidents 
create view cs_students as 
	select s.sid
	from student s, major m
	where s.sid = m.sid
	and m.major = 'CS';

create function count_no_CS(bno int)
returns bigint as
	$$ select count(1)
		from buys bu
		where bu.sid in(select s.sid from cs_students s)
		and bu.bookno = bno;
	$$ language sql;
	

select b.bookno, b.title
from book b
where count_no_CS(b.bookno) < 3
and b.price < 40;

drop view cs_students;

\qecho 'question 8.b'
\qecho ''
\qecho 'In this I first counted the number of books bought by students from the buys table and aggregating them and checking of they cose les than 200 and then I added the people who did not buy any book'
(select  s.sid,s.sname, count(b.bookno) as numberofbooksbought
from student s, book b, buys bu
where s.sid= bu.sid and b.bookno = bu.bookno
group by (s.sid)
having sum(b.price) < 200)
union
(select s.sid, s.sname, 0 as numberofbooksbought
from student s
where s.sid not in(select bu.sid from buys bu));



\qecho 'question 8.c'
\qecho ''
\qecho 'In this question, I calculate the total money spent by each student on the the books he/she bought and then I compared it with others to see if it is the maximum'
select  s.sid,s.sname
from student s, book b, buys bu
where s.sid= bu.sid and b.bookno = bu.bookno
group by (s.sid)
having sum(b.price) >=all((select  sum(b.price)
							from student s, book b, buys bu
							where s.sid= bu.sid and b.bookno = bu.bookno
							group by (s.sid)));

\qecho 'question 8.d'
\qecho ''
\qecho 'I first obtained students in each major.I then summed over the price of books bought in each major'
create function students_in_major(maj text)
returns table(sid int) as
$$
	select s.sid
	from student s, major m
	where s.sid = m.sid and
	m.major = maj;
$$ language sql;

select m1.major, sum(m1.price) as totalpriceofbooksbought
from
(select distinct m.major, bo.price as price, s.sid, bo.bookno
from  major m, students_in_major(m.major) s, buys bu, book bo
where bo.bookno = bu.bookno and
 bu.sid = s.sid) m1
 group by m1.major;

drop function students_in_major;
\qecho 'question 8.e'
\qecho 'I created a function that calculates the number of cs students who bought a book. Then I compared 2 books at a time to see for which books the count matched.'
create function books_bought_by_cs(bno int) 
returns bigint as
$$
select count(bu.sid)
from buys bu 
where bu.sid in(select s.sid
			   from student s, major m
			   where m.sid = s.sid
			   and m.major = 'CS')
and bu.bookno = bno
$$ language sql;

select  distinct bo1.bookno as b1, bo2.bookno as b2
from book bo1, book bo2
where bo1.bookno != bo2.bookno and
books_bought_by_cs(bo1.bookno) = books_bought_by_cs(bo2.bookno);

drop function books_bought_by_cs;
\qecho 'question 9'
\qecho 'Here, I found names of students for whom there exists a book not bought by them that costs more than 50. So they did not buy all the books that cost more than 50'
create view booksMoreThan50 as
	select bo.bookno
			from book bo
			where bo.price > 50;

create function booksboughtbystudent(sid int)
returns table (bookno int) as
	$$
		select bu.bookno
		from buys bu
		where bu.sid = booksboughtbystudent.sid
	$$ language sql;
			
select s.sid, s.sname
from student s 
where exists( 
			select bo.bookno
			from booksMoreThan50 bo
			 except
			select bo.bookno
			from booksboughtbystudent(s.sid) bo
			);
drop view booksMoreThan50;
drop function booksboughtbystudent;
\qecho ''
\qecho 'question 10'
\qecho 'In this question I created 2 sets. One with students who bought a book and the other with students majoring in Cs or Math. Then, I subtracted Cs_math students from students who bought the book and if there exists such people who are not in CS and Math and have bought the book then those books were listed'
create view Students_in_CS_Math as
	select distinct s.sid
	from student s, major m
	where s.sid = m.sid and  
	m.major = 'CS'
	union
	select distinct s.sid
	from student s, major m
	where s.sid = m.sid and  
	m.major = 'Math';

create function bookboughtby(bookno int)
returns table(sid int) as
$$
	select bu.sid
	from buys bu
	where bu.bookno = bookboughtby.bookno
$$language sql;			
 
select distinct bo.bookno, bo.title
from book bo
where  
exists(select bu.sid
			from bookboughtby(bo.bookno) bu
			except 
			select c.sid
			from Students_in_CS_Math c)
order by 1;
drop function bookboughtby;
drop view Students_in_CS_Math;

\qecho 'question 11'
\qecho ''
\qecho ' Here I first created a view for the least expensive books. Then I created a function that returns a list of all thebooks bought by that student. I check the condition that there should not exist a book bought by that student which is least expensive. So the intersection should return null in this case. In this way I obtained the answer.'
create view least_expensive as
	select b.bookno, b.title, b.price
	from book b
	where b.price = (select min(bo1.price)
						 from book bo1);

create function booksboughtbystudent(sid int)
returns table(bookno int) as 
$$
	select bu.bookno
	from buys bu
	where bu.sid = booksboughtbystudent.sid
$$ language sql;


select distinct s.sid, s.sname
from student s, buys bu
where s.sid = bu.sid and
not exists (select bu1.bookno
		   from booksboughtbystudent(s.sid) bu1
		   intersect
		   select b.bookno
		   from least_expensive b);

drop view least_expensive;
drop function booksboughtbystudent;
\qecho ''
\qecho 'question 12'
\qecho ' For this case to be true, we need to find CS students who have bought book1 and book 2 and when we find the difference it should be 0 for students buying book1 - students buying book2  and students buying book2 - students buying book1. I created a function to find CS students who bought the book and then ran 2 sets of book instances to find if the difference is null or not'
create function sid_CS_student_who_bought_book(bno int) 
returns table(sd int) as
	$$
		select bu.sid
		from buys bu
		where bu.bookno = bno and 
		bu.sid in (select s.sid
				  from student s, major m
				  where s.sid = m.sid and
				  m.major = 'CS');
	$$ language sql; 
select distinct b1.bookno as b1, b2.bookno as b2
from buys b1, buys b2
where b1.bookno != b2.bookno and
not exists ( select s1.sd
				 from sid_CS_student_who_bought_book(b1.bookno) s1
				 except
				 select s2.sd
				 from sid_CS_student_who_bought_book(b2.bookno) s2)
and not exists (select s2.sd
				 from sid_CS_student_who_bought_book(b2.bookno) s2
				 except
				 select s1.sd
				 from sid_CS_student_who_bought_book(b1.bookno) s1)
order by b1.bookno, b2.bookno ;
drop function sid_CS_student_who_bought_book;

\qecho 'question 13'
\qecho 'In this question, I created a function that returns the booknos of books bought by Cs students and intersected it with the view that returns the books that cost less than 50. Then I counted the resulting set and if it is less than 4 or not and returned the results.'
create function books_bought_by_CS(sid int)
returns table(bookno int )as
	$$	
	select distinct bu.bookno
	from buys bu
	where bu.sid = books_bought_by_CS.sid;
	$$ language sql;

create view books_less_than_50 as
select b.bookno
from book b
where b.price < 50;

select s.sid, s.sname
from student s, major m
where m.sid = s.sid and 
m.major = 'CS'and (select count(1)
				  from(select b.bookno
					  from books_bought_by_CS(s.sid) b
					   intersect
					   select b.bookno
					   from books_less_than_50 b) n ) < 4;
drop function books_bought_by_CS;
\qecho 'question 14'
\qecho ''
\qecho 'In this question, I calculate the no of CS students buying the book . Using the count function I counted and divided it by 2 to check if the remainder is 0 or 1. To check if it is odd or even.'
create function studs_buying_book(bookno int) 
returns table(sid int) as
	$$
		select bu.sid
		from buys bu
		where bu.bookno = studs_buying_book.bookno;
	$$ language sql;

create view CS_students as
	select s.sid 
	from student s, major m
	where m.major = 'CS' and
	m.sid = s.sid;

select bo.bookno, bo.title
from book bo
where (select count(1)
	  from (select s.sid 
		   from studs_buying_book(bo.bookno) s
		   intersect
		   select s.sid
		   from CS_students s)n) %2 != 0;

drop view CS_students;
drop function studs_buying_book;

\qecho 'question 15'
\qecho ' In this question, I created a parameterized view that returns the books bought by each student and then i check if the total number or books minus the books bought by the student equal 3 or not'

create function books_bought(sd int)
returns table(bookno int) as 
$$
	select bu.bookno
	from buys bu
	where bu.sid = sd;
$$ language sql;

select s.sid, s.sname
from student s 
where(select count(1)
	 from (select bo1.bookno
		  from book bo1
		  except
		  select bo.bookno
		  from books_bought(s.sid) bo) n) = 3;
drop function books_bought;

\qecho 'question 16'
\qecho ''
\qecho 'Here I check if the difference between the count of number of students who bought book1 and count of number of students who bought book2 is 0 or not. If it is zero then same number of students bought it.'
create function student_id_buying_books(bno int)
returns table(sid int) as
$$
	select distinct bu.sid
	from buys bu
	where bu.bookno = bno;
$$ language sql;

select distinct b1.bookno as b1, b2.bookno as b2
from book b1, book b2
where b1.bookno != b2.bookno and
(select count(1) 
	   from (select s.sid from
			student_id_buying_books(b1.bookno) s
			except
			select s.sid from
			student_id_buying_books(b2.bookno) s) n) = 0;

drop function student_id_buying_books;

\c postgres;
drop database pwassignment3;	


