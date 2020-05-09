CREATE DATABASE pwassignment2;
\c pwassignment2;

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



\qecho ' question 1. Find the sid and name of each student who majors in CS and who bought a book that cost more than $10. '
\qecho '1.a':
\qecho 'Comments: In this question, I am joining student, major, book and buys relation with the help of the foreign key references provided in each.'
\qecho 'Then extract data for only those tuples for which the major is CS and the price is greater than 10'
SELECT distinct s.sid, s.sname
FROM student s, major m, book bo, buys bu
	where s.sid = m.sid and
	bu.sid = s.sid and
	bo.bookno = bu.bookno and
	m.major = 'CS' and bo.price > 10;
	
\qecho 'question 1.b':
\qecho 'Comments:In this question, I check for the student ids from the student table only for those students who have their major as CS.'
\qecho 'The for the same student id I check if he has bought a book with price > 10. I have accomplished this using IN clauses, and only those students who satisfy both the conditions are extracted.'
\qecho ''
SELECT distinct s.sid, s.sname
FROM Student s
where s.sid in (select m.sid 
				from major m 
				where s.sid = m.sid  and
				m.major = 'CS') and
	  s.sid in (select bu.sid 
				from buys bu
			    where bu.bookno in (select bo.bookno
								    from book bo 
								    where bo.price > 10));

\qecho 'question 1.c':
\qecho ''
\qecho 'Comments:In this question I check if s.sid matches with some sid from the major table with the major as CS'
\qecho 'I also check if there exists some entry in the buys table where there is a book bought by the same student and if that book has price > 10'
\qecho ''
SELECT s.sid, s.sname
FROM Student s
where s.sid = SOME( select m.sid 
				   	from major m 
				   	where s.sid = m.sid and 
	  			   	m.major = 'CS') and
	  s.sid = SOME( select bu.sid 
					from buys bu
					where bu.bookno = SOME (select bo.bookno
											from book bo 
											where bo.price > 10));

\qecho 'question 1.d':
\qecho ''
\qecho 'Comments:In this question, I check for if there exists as student who has majored in Cs and if there is a book that he bought that is worth more than 10'
\qecho ''
SELECT s.sid, s.sname
FROM Student s 
where exists (select 1 
			  	from Major m 
			  	where s.sid = m.sid and 
	  		  	m.major = 'CS') and 
	  exists (select 1 
				from buys bu
			    where s.sid = bu.sid and 
				exists (select 1
							from book bo 
							where bo.bookno = bu.bookno and
							bo.price > 10) );
\qecho 'question 2.Find the bookno, title, and price of each book that was not bought by any Math student.'

\qecho 'question 2.a'
\qecho ''
\qecho 'Comments:I remove all the rows from books which have been bought by any student whose major is Math'
\qecho ''
SELECT  bo.bookno, bo.title, bo.price
FROM Book bo 
except
SELECT  bo1.bookno, bo1.title, bo1.price
FROM Book bo1, major m1, buys bu1
where bu1.bookno = bo1.bookno and
m1.sid = bu1.sid and m1.major = 'Math';


\qecho 'question 2.b'
\qecho ''
\qecho 'Comments: In this question, I eliminate books from the book table which have been bought by math students using the NOT IN clause'
\qecho ''

select bo.bookno, bo.title, bo.price
from Book bo 
where bo.bookno not in (select bu.bookno 
						from buys bu
						where bu.sid in (select m.sid 
										 from major m 
										 where m.major = 'Math') );
\qecho 'question 2.c'

\qecho ''
\qecho 'Comments: In this question, I check if any book from the book table is not equal to all the books bought by math students'
\qecho ''
select bo.bookno, bo.title, bo.price
from  Book bo 
where bo.bookno != all( select bu.bookno
						from buys bu
						where bu.sid = some(select m.sid 
											from major m 
											where m.major = 'Math'));

\qecho 'question 2.d'
\qecho ''
\qecho 'Comments: In this question, I eliminate books from the book table which have been bought by math students using EXISTs clause'
\qecho ''
select bo.bookno, bo.title, bo.price
from Book bo
where not exists (select 1 
				  from buys bu 
				  where bu.bookno = bo.bookno and
				  exists(select 1 
				  		 from major m 
						 where m.major = 'Math' and
						 m.sid = bu.sid) );
										
\qecho 'question 3.a'
\qecho ''
\qecho 'Find the bookno, title, and price of each book that cites at least two books that cost less than $60.'
\qecho ''
\qecho 'Comments: Here I use the relations book bo and since we have been asked to check if at least 2 cited books cost less than 60, I have used the references of two cites tables.'
\qecho 'I check that if the price of two disticnt cited books is less than 60, then select the book that cites them.'
\qecho ''
SELECT distinct bo.bookno, bo.title, bo.price 
from Book bo, cites c1, cites c2, book bo2, book bo3  
where bo.bookno = c1.bookno and
	bo.bookno = c2.bookno and
	c1.citedbookno != c2.citedbookno and
	bo2.bookno = c1.citedbookno and
	bo3.bookno = c2.citedbookno and
	bo2.price < 60 and
	bo3.price < 60;

\qecho 'question 3.b'
\qecho ''
\qecho 'Comments: In this quesry that if the book that cites 2 different books that cost less than 60 or not. If not, then I do not extract that book'
\qecho ''
select bo.bookno, bo.title, bo.price
from Book bo 
where bo.bookno in (select c.bookno 
					from cites c
					where c.citedbookno in (select bo1.bookno 
											from book bo1 
											where bo1.price < 60 ) and
						  c.bookno in (select c1.bookno 
										from cites c1 
										where c1.citedbookno != c.citedbookno and
									    c.bookno = c1.bookno and
									    c1.citedbookno in (select bo2.bookno 
														  from book bo2 
														  where bo2.price < 60 )));
\qecho 'question 3.c'
\qecho ''
\qecho 'Comments: In this quesry that if the book that cites 2 different books that cost less than 60 or not. If not, then I do not extract that book using the Exists clause'
\qecho ''

select bo.bookno, bo.title, bo.price
from Book bo
where exists (select c.bookno
			from cites c
			where c.bookno = bo.bookno and
			exists (select bo1.bookno 
					 from book bo1 
					 where bo1.price < 60 and
					 bo1.bookno = c.citedbookno) and
			exists (select c1.bookno 
					 from cites c1 
					 where c1.citedbookno != c.citedbookno and
					 c.bookno = c1.bookno and
					 exists (select bo2.bookno 
							 from book bo2 
							 where bo2.price < 60 and
							 c1.citedbookno = bo2.bookno )));
\qecho 'question 4.Find the sid and name of each student along with the title and price of the most expensive book(s) bought by that student.'
\qecho ''
\qecho 'question 4.a'
\qecho ''
\qecho 'In this query, i eliminate all the books that are less costlier than any other book that has been bought by the student using except '
select s.sid, s.sname, bo.title, bo.price
from student s, book bo, buys bu
where bu.sid = s.sid and bo.bookno = bu.bookno
except
select s.sid, s.sname, bo.title, bo.price
from student s, book bo, buys bu, student s1, book bo1, buys bu1 
where s1.sid = s.sid and
	bu.sid = s.sid and
	bu1.sid = s1.sid and
	bo1.bookno = bu1.bookno and
	bo.bookno = bu.bookno and
	bo.price < bo1.price;


\qecho ''
\qecho 'question 4.b'
\qecho ''
\qecho ''
\qecho 'In this i select that one book bought by the student which is costlier than all the other books bought by him'
\qecho ''

select s.sid, s.sname, bo.title, bo.price
from student s, book bo, buys bu
where s.sid = bu.sid and 
	bo.bookno = bu.bookno and
	bo.price >= all ( select bo1.price 
						from book bo1, buys bu1
						where bu1.sid = s.sid and
						bo1.bookno = bu1.bookno);
				

\qecho 'question 5'
\qecho 'Find the sid and name of each student who bought at most one book that cost more than $20.'
\qecho 'Here I eliminate the students who bought more than 1 books that costs more than 20'
select s.sid , s.sname 
from student s
where s.sid not in (select bu1.sid 
					from book bo1, book bo2, buys bu1, buys bu2 
					where s.sid = bu1.sid and
					bu2.sid = s.sid and
					bu2.bookno = bo2.bookno and
					bu1.bookno = bo1.bookno and
					bo1.price > 20 and
					bo2.price > 20 and
					bo1.bookno != bo2.bookno);



\qecho 'question 6'
\qecho 'Without using the ALL or SOME set predicates, find the booknos and titles of books with the next to highest price.'
\qecho ''
\qecho 'In this query I eliminate the most costly book from the list of books and then select the book from the remaining set that is the costliest.'
\qecho ''

select distinct b1.bookno , b1.title, b1.price
								from book b1, book b2
								where b1.bookno != b2.bookno
								and b1.price < b2.price
except
select distinct d.bookno, d.title, d.price from (select distinct b1.bookno, b1.price, b1.title 
								from book b1, book b2
								where b1.bookno != b2.bookno and
							    b1.price < b2.price) d, 
							   (select distinct b1.bookno , b1.price, b1.title
								from book b1, book b2
								where b1.bookno != b2.bookno
								and b1.price < b2.price) c
								where d.price < c.price and
								c.bookno != d.bookno;
 

\qecho 'question 7'
\qecho 'Find the bookno, title, and price of each book that cites a book which is not among the most expensive books.'
\qecho ''
\qecho 'I select all the books that site some books which are not the most costly ones.'
\qecho ''


select distinct bo.bookno, bo.title, bo.price
from book bo, cites c
where bo.bookno = c.bookno
and c.citedbookno not in (select bo1.bookno
							from book bo1
							where bo1.price >=all(select bo3.price from book bo3));

						

\qecho 'question 8'
\qecho 'Find the sid and name of each student who has a single major and such that none of the book(s) bought by that student cost less than $40.'
\qecho ''
\qecho 'Here I intersect two relations, first by searching for students who have a single major with the students who have not bought any book less than $40'
\qecho ''

(select distinct s.sid, s.sname
from student s, major m
where s.sid = m.sid and  
s.sid not in (select s1.sid 
			  from student s1, major m1, major m2
			  where s1.sid = m1.sid and
			  s1.sid = m2.sid and 
			  m1.major !=m2.major))
intersect
select distinct s.sid, s.sname
from student s
where s.sid  not in (select bu.sid 
				     from buys bu, book bo
			         where bu.bookno = bo.bookno
			         and bo.price < 40 );

\qecho 'question 9'
\qecho 'Find the bookno and title of each book that is bought by all students who major in both CS and in Math'
\qecho ''
\qecho 'I translated this query to find a book such that there does not exist a student who major both in CS and Math and has not bought the book'
\qecho ' So first I find books not bought by students of CS and Math and then eliminated both of them from the books list'
\qecho ''


select bo.bookno, bo.title
from book bo 
where bo.bookno in (select distinct bu1.bookno
					from buys bu1 
					where not exists (select 1 
										from student s, major m
										where s.sid = m.sid
										and m.major = 'CS' 
										and s.sid not in (select bu.sid 
														   from buys bu 
														   where bu1.bookno = bu.bookno)
										intersect 
										select 1 
										from student s, major m
										where s.sid = m.sid
										and m.major = 'Math'
										and s.sid not in (select bu.sid 
														  from buys bu 
														  where bu1.bookno = bu.bookno)));
												

					
					
					
\qecho 'question 10'
\qecho 'Find the sid and name of each student who, if he or she bought a book that cost at least $70 then he also bought a book that cost less than $30.'
\qecho 'I solve this case wise using the truth table of an implication. If a student has bought a book atleast greater than 70 then he must buy a book less than 30. If a student hasnot bought a book greater than =70, then it does not matter if he buys a book less than 30. So I have added those too. '
\qecho 'This way, I do not take those students who bought a book greater than 70 but not less than 30'
(select s.sid, s.sname 
from student s
where s.sid in (select bu1.sid 
			    from buys bu1, book bo1, buys bu2, book bo2 
			    where bo2.bookno = bu2.bookno and
				bu1.bookno = bo1.bookno and
				bu2.bookno != bu1.bookno and
				bu2.sid = bu1.sid and
				bo1.price >=70 and bo2.price < 30))
union
(select s.sid, s.sname
from student s
where s.sid not in (select bu.sid
				    from buys bu, book bo
				    where bu.bookno = bo.bookno
				    and bo.price > 70));

--select bu.bookno from 

\qecho 'question 11'
\qecho 'Find each pair (s1; s2) where s1 and s2 are the sids of students who have a common major but who did not buy the same books.'
\qecho 'In this I first select students who have bought at least one different book.Then from these, I select only those students who have the same major. '

select distinct s3.sid, s4.sid  
	 from student s3, student s4, major m1, major m2
	 where s3.sid!= s4.sid
	 and m1.sid = s3.sid and s4.sid = m2.sid and m1.major= m2.major
	 and (s3.sid, s4.sid) in
(select distinct b3.sid, b4.sid
from buys b3, buys b4
where (b3.sid, b4.sid) in (select distinct b1.sid, b2.sid
							from buys b1, buys b2
							where b1.sid != b2.sid
							and b1.bookno = b2.bookno)
and (b3.bookno not in( select b5.bookno
					from buys b5
					where b5.sid = b4.sid)
or b4.bookno not in(select b6.bookno
					from buys b6
					where b6.sid = b3.sid)));


\qecho 'question 12'
\qecho 'Find the tuple (s1; b1; s2; sb) such that if the student with sid s1 bought book with bookno b1 then the student with sid s2 did not buy the book with bookno b2.'
\qecho 'In this query, since this is an implication, I first create all possible combinations of books with students and then I eliminate that condition where if the student buys a book b1 and if the other student buys some other book.'
\qecho 'This way, I eliminate the False condition in the truth table of an implication.'
\qecho ''
select count (*)
from(select s1.sid, bo1.bookno, s2.sid, bo2.bookno
from student s1, student s2, book bo1, book bo2
except
select s1.sid, bu1.bookno, s2.sid, bu2.bookno
from student s1, student s2, buys bu1, buys bu2
where s2.sid = bu2.sid and s1.sid = bu1.sid) c;

\qecho 'question 13'
\qecho 'Define a view bookAtLeast30 that defines the books whose price is at least $30. Consider the query \Find the sid and name of each student who bought fewer than two books that cost less than $30." Write a SQL that uses the view bookAtLeast30 to solve this query. After solving this problem drop the view bookAtLeast30'
\qecho 'I create a view for books whose price is at least 30. Then if i find a student who has bought at least 2 different books that are less then 30 by checking if the books meet the condition described in the view, I eliminate them'
\qecho ''
create view bookAtLeast30 as
	select * 
	from book bo
	where bo.price >= 30;

select s.sid, s.sname
from student s
where s.sid not in(select bu1.sid
				  from buys bu1, buys bu2
				  where bu1.sid = bu2.sid
				  and bu1.bookno != bu2.bookno
				  and bu1.bookno not in (select bo.bookno
									     from bookAtLeast30 bo)
				  and bu2.bookno not in (select bo.bookno
									     from bookAtLeast30 bo));
drop view bookAtLeast30;

\qecho 'question 14'
\qecho 'Reconsider the query in Problem 13. Redo this problem but this time by using temporary views (i.e., use the WITH statement).' 
\qecho 'I create a view for books whose price is at least 30. Then if i find a student who has bought at least 2 different books that are less then 30 by checking if the books meet the condition described in the view, I eliminate them'
\qecho ''
with bookAtLeast30 as
	(select bo.bookno
	from book bo 
	where bo.price >=30)
select s.sid, s.sname
from student s
where s.sid not in(select bu1.sid
				  from buys bu1, buys bu2
				  where bu1.sid = bu2.sid
				  and bu1.bookno != bu2.bookno
				  and bu1.bookno not in (select bo.bookno from bookAtLeast30 bo)
				  and bu2.bookno not in (select bo.bookno from bookAtLeast30 bo));



\qecho 'question 15'
 create function citesBooks(b integer)
 	returns table (bookno integer, title text , price integer) as
 	$$
 		select bo.bookno, bo.title, bo.price
		from book bo
		where bo.bookno in(select c.citedbookno 
				  			from cites c
				  			where c.bookno = b)
 	$$ language SQL;

-- Use this parameterized view to write a SQL query that finds the bookno and title of each book that cites the book with bookno 2001
-- as well as cites a book that cost less than $50.

\qecho 'question 15.a'
\qecho 'In this question, I select the book that sites 2 different books one of which has book id 2001 and the other has book price < 50'

select distinct  b.bookno, b.title
from book b, citesBooks(b.bookno) c1, citesBooks(b.bookno) c2
where c1.bookno != c2.bookno and
c1.bookno = 2001 and
c2.price < 50;

\qecho 'question 15.b'
\qecho 'I try to find a book that at least 2 different books using exists and citesbooks function.'
select bo.bookno, bo.title
from book bo
where exists (select 1
			  from citesBooks(bo.bookno) c1, citesBooks(bo.bookno) c2
			  where c1.bookno != c2.bookno);



\c postgres;
DROP DATABASE pwassignment2;