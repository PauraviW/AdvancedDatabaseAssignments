\qecho 'Problem 1.1'
CREATE DATABASE assignment1pwagh;

\c assignment1pwagh;
\qecho ''
CREATE TABLE Boat( 	bid INTEGER PRIMARY KEY ,
					bname VARCHAR(15),
					color VARCHAR(15)); 


INSERT INTO Boat VALUES	(101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red'),
						(103,	'Clipper',	'green'),
						(104,	'Marine',	'red'),
						(105,    'Indianapolis',     'blue');


CREATE TABLE Sailor (sid INTEGER PRIMARY KEY,
					sname VARCHAR(15),
					rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1),
							(31,   'Lubber',       8),
							(32,   'Andy',         8),
							(58,   'Rusty',        10),
							(64,   'Horatio',      7),
							(71,   'Zorba',        10),
							(75,   'David',        8),
							(74,   'Horatio',      9),
							(85,   'Art',          3),
							(95,   'Bob',          3);



CREATE TABLE Reserves (	 sid INTEGER,
						 bid INTEGER,
						 day VARCHAR(15),
						 PRIMARY KEY (sid, bid),
						 FOREIGN KEY (sid) REFERENCES Sailor(sid),
						 FOREIGN KEY (bid) REFERENCES Boat(bid));


INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(22,	102,	'Tuesday'),
							(22,	103,	'Wednesday'),
							(22,	105,	'Wednesday'),
							(31,	102,	'Thursday'),
							(31,	103,	'Friday'),
							(31,    104,	'Saturday'),
							(64,	101,	'Sunday'),
							(64,	102,	'Monday'),
							(74,	102,	'Saturday'); 


\qecho ''
\qecho 'Boat'
\qecho ''
SELECT * FROM Boat;
\qecho ''
\qecho 'Sailor'
\qecho ''
SELECT * FROM Sailor;
\qecho ''
\qecho 'Reserves'
\qecho ''
SELECT * FROM Reserves;

DROP TABLE Boat, Sailor, Reserves;
\qecho ''

\qecho 'Problem 1.2'
\qecho ''
\qecho 'EXAMPLE 1 : Insert operation on table with and without primary key'

\qecho ''
\qecho 'Table without a primary key' 
\qecho ''

CREATE TABLE Boat ( bid INTEGER,
					bname VARCHAR(15),
					color VARCHAR(15));

INSERT INTO Boat VALUES (1, 'Titanic', 'purple' ),
						(1, 'Meridian', 'green' ),
						(1, 'Titanic', 'purple' );


SELECT * FROM boat;
\qecho ''
\qecho 'As we can see here, there is no unique identifier, that can distinguish between the different records. For instance, we can see here that there are two records of the same titanic boat with bid 1.' 
\qecho ''
\qecho 'Redundancy is unnecesarily added which takes up space when a primary key is not specified'
\qecho ''

DROP TABLE Boat;

\qecho ''
\qecho 'Table with a primary key'
\qecho ''

CREATE TABLE Boat (	bid INTEGER PRIMARY KEY,
					bname VARCHAR(15),
					color VARCHAR(15));

INSERT INTO Boat VALUES (1, 'Titanic', 'purple' );

SELECT * FROM boat;

INSERT INTO Boat VALUES (1, 'Meridian', 'green' );
\qecho ''
\qecho 'Here the second insertion operation fails as we are trying to add a duplicate record for the same primary key (1)'
\qecho ''

SELECT * FROM Boat;

\qecho 'We can see that, only one record is present with primary key 1.'
\qecho ''

DROP TABLE Boat;

\qecho ''

\qecho 'EXAMPLE 2 : Delete operation in table with and without primary key'
\qecho ''
\qecho 'Table without a primary key'

\qecho ''

CREATE TABLE Boat (	bid INTEGER,
					bname VARCHAR(15),
					color VARCHAR(15));

INSERT INTO Boat VALUES (1, 'Titanic', 'purple' ),
						(1, 'Meridian', 'green' );

SELECT * FROM Boat;
DELETE 
FROM  Boat b 
WHERE b.bid = 1; 


SELECT * FROM Boat;
\qecho 'As you can see that both the records got deleted when we used bid to delete the data. bid = 1'
 
\qecho 'Thus, we cannot uniquely identify the records to delete them'


DROP TABLE Boat;

\qecho ''
\qecho 'Delete operation on the table Boat with a primary key'
\qecho ''

CREATE TABLE Boat (	bid INTEGER PRIMARY KEY,
					bname VARCHAR(15),
					color VARCHAR(15));

INSERT INTO Boat VALUES (1, 'Titanic', 'purple' );

INSERT INTO Boat VALUES (2, 'Meridian', 'green' );


SELECT * 
FROM Boat;
DELETE FROM Boat b 
WHERE b.bid = 1;


SELECT * FROM Boat;

\qecho ''
\qecho 'Here, since, we do not have duplicate records, we can uniquely delete the one that we wish to delete. bid = 1'
\qecho ''
\qecho 'Thus, even if we have 2 records with the same data but different primary keys, we will only delete the one that matches the bid.'

\qecho ''

DROP TABLE Boat;

\qecho '' 

\qecho 'Example 3 : Insertion operation using foreign keys'
\qecho ''

CREATE TABLE Boat(  bid INTEGER PRIMARY KEY ,
					bname VARCHAR(15),
					color VARCHAR(15)); 


INSERT INTO Boat VALUES (101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red');


CREATE TABLE Sailor (	sid INTEGER PRIMARY KEY,
						sname VARCHAR(15),
						rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7);


CREATE TABLE Reserves (	sid INTEGER,
						bid INTEGER,
						day VARCHAR(15),
						PRIMARY KEY (sid, bid),
						FOREIGN KEY (sid) REFERENCES Sailor(sid),
						FOREIGN KEY (bid) REFERENCES Boat(bid));
\qecho ''

INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(34,	102,	'Tuesday');
\qecho ''
\qecho 'Here, we see that, the insert operation on the Reserves table is unsucessful as the record with sailor id 34 is not present in the Sailor table.'
\qecho ''
\qecho 'The record will get successfully inserted when the Foreign key constraint is satisfied.'
\qecho ''

INSERT INTO Sailor VALUES	(34,   'Harry',       7);

INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(34,	102,	'Tuesday');

SELECT * FROM RESERVES;
\qecho 'As we can see that after adding a sailor with id 34 in the SAILOR relation, we can add a record in the reserves table.'

DROP TABLE Boat, Sailor, Reserves;
\qecho 'EXAMPLE 4 : Delete operation using foreign keys (CASCADE)' 
\qecho ''

CREATE TABLE Boat( 	bid INTEGER PRIMARY KEY ,
					bname VARCHAR(15),
					color VARCHAR(15)); 


INSERT INTO Boat VALUES	(101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red');


CREATE TABLE Sailor (	sid INTEGER PRIMARY KEY,
						sname VARCHAR(15),
						rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1);



CREATE TABLE Reserves (	sid INTEGER,
						bid INTEGER,
						day VARCHAR(15),
						PRIMARY KEY (sid, bid),
						FOREIGN KEY (sid) REFERENCES Sailor(sid) ON DELETE CASCADE,
						FOREIGN KEY (bid) REFERENCES Boat(bid));


INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(29,	102,	'Tuesday');


SELECT * FROM Reserves;


DELETE FROM Sailor s 
WHERE s.sid = 22;
 

SELECT * FROM Reserves;

\qecho 'On deleting the sailor with sid 22 from the Sailor table, Cascade constraint facilitated the  deletion of the record in the reserves table too.'


DROP TABLE Boat, Sailor, Reserves;

\qecho ''
\qecho 'EXAMPLE 5: Delete from original table (RESTRICT)'


\qecho ''

CREATE TABLE Boat(	bid INTEGER PRIMARY KEY ,
					bname VARCHAR(15),
					color VARCHAR(15)); 

INSERT INTO Boat VALUES (101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red');

CREATE TABLE Sailor (	sid INTEGER PRIMARY KEY,
						sname VARCHAR(15),
						rating INTEGER); 

INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1);


CREATE TABLE Reserves (	sid INTEGER,
						bid INTEGER,
						day VARCHAR(15),
						PRIMARY KEY (sid, bid),
						FOREIGN KEY (sid) REFERENCES Sailor(sid) ON DELETE RESTRICT,
						FOREIGN KEY (bid) REFERENCES Boat(bid));

INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(29,	102,	'Tuesday');

DELETE FROM Sailor s 
WHERE s.sid = 22;
 
SELECT * FROM Reserves;


DROP TABLE Boat, Sailor, Reserves;

\qecho 'Delete operation is restricted since, we have specified a restrict constraint on the Sailor table. So the sailor data will not be deleted unless we delete its reference from the reserves table first.'

\qecho ''
\qecho 'Example 6 : Drop table with and without cascade'
\qecho ''

\qecho 'Drop table with cascade'
\qecho ''

CREATE TABLE Boat(  bid INTEGER PRIMARY KEY ,
					bname VARCHAR(15),
                    color VARCHAR(15)); 


INSERT INTO Boat VALUES (101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red');


CREATE TABLE Sailor (	sid INTEGER PRIMARY KEY,
						sname VARCHAR(15),
						rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1);


CREATE TABLE Reserves (	 sid INTEGER,
						 bid INTEGER,
						 day VARCHAR(15),
						 PRIMARY KEY (sid, bid),
						 FOREIGN KEY (sid) REFERENCES Sailor(sid) ON DELETE CASCADE);


INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(29,	102,	'Tuesday');

\qecho ''
\d Reserves;

DROP TABLE SAILOR CASCADE;

\qecho ''

\d Reserves;

DROP TABLE BOAT, RESERVES;

\qecho ''
\qecho 'As we can see the on dropping the table sailor with cascade, the foreign key constraint gets removed.'


\qecho ''
\qecho 'Drop table without cascade'

\qecho ''

CREATE TABLE Boat( 	 bid INTEGER PRIMARY KEY ,
					 bname VARCHAR(15),
					 color VARCHAR(15)); 


INSERT INTO Boat VALUES (101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red');


CREATE TABLE Sailor (	sid INTEGER PRIMARY KEY,
						sname VARCHAR(15),
						rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1);



CREATE TABLE Reserves (	 sid INTEGER,
						 bid INTEGER,
						 day VARCHAR(15),
						 PRIMARY KEY (sid, bid),
						 FOREIGN KEY (sid) REFERENCES Sailor(sid) ON DELETE CASCADE);


INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(29,	102,	'Tuesday');


DROP TABLE SAILOR;
\qecho ''
\qecho 'As we can see that we get and error when we try to drop the table that references another table. We first need to delete the reference and then we can delete the original table.'



DROP TABLE RESERVES, Boat, Sailor;



\qecho ''
\qecho 'Problem 2 '

\qecho ''

CREATE TABLE Boat( 	 bid INTEGER PRIMARY KEY ,
					 bname VARCHAR(15),
					 color VARCHAR(15)); 


INSERT INTO Boat VALUES (101,	'Interlake',	'blue'),
						(102,	'Sunset',	'red'),
						(103,	'Clipper',	'green'),
						(104,	'Marine',	'red'),
						(105,    'Indianapolis',     'blue');


CREATE TABLE Sailor (	 sid INTEGER PRIMARY KEY,
						 sname VARCHAR(15),
						 rating INTEGER); 


INSERT INTO Sailor VALUES	(22,   'Dustin',       7),
							(29,   'Brutus',       1),
							(31,   'Lubber',       8),
							(32,   'Andy',         8),
							(58,   'Rusty',        10),
							(64,   'Horatio',      7),
							(71,   'Zorba',        10),
							(75,   'David',        8),
							(74,   'Horatio',      9),
							(85,   'Art',          3),
							(95,   'Bob',          3);



CREATE TABLE Reserves (	 sid INTEGER,
						 bid INTEGER,
						 day VARCHAR(15),
						 PRIMARY KEY (sid, bid),
						 FOREIGN KEY (sid) REFERENCES Sailor(sid),
						 FOREIGN KEY (bid) REFERENCES Boat(bid));


INSERT INTO Reserves VALUES	(22,	101,	'Monday'),
							(22,	102,	'Tuesday'),
							(22,	103,	'Wednesday'),
							(22,	105,	'Wednesday'),
							(31,	102,	'Thursday'),
							(31,	103,	'Friday'),
							(31,    104,	'Saturday'),
							(64,	101,	'Sunday'),
							(64,	102,	'Monday'),
							(74,	102,	'Saturday'); 

\qecho ''
\qecho ''
\qecho 'Problem 2.1'


SELECT s.sid, s.rating FROM Sailor s;

\qecho 'Problem 2.2'


SELECT s.sid, s.sname, s.rating 
FROM Sailor s 
WHERE s.rating BETWEEN 2 AND 11
AND s.rating NOT BETWEEN 8 AND 10; 

\qecho 'Problem 2.3'


SELECT b.bid, b.bname, b.color 
FROM Reserves r, Boat b, Sailor s 
WHERE b.bid = r.bid AND s.sid = r.sid AND
	  b.color != 'red' AND s.rating > 7;

\qecho 'Problem 2.4'


(SELECT b.bid, b.bname 
FROM Boat b, Reserves r1 
WHERE r1.bid = b.bid AND r1.day in ( 'Saturday', 'Sunday')) 
EXCEPT
(SELECT r2.bid, b.bname 
FROM Reserves r2, Boat b 
WHERE r2.bid = b.bid AND r2.day = 'Tuesday');

\qecho 'Problem 2.5'


SELECT DISTINCT r1.sid 
FROM Reserves r1, Reserves r2, Boat b1 , Boat b2
WHERE r1.sid = r2.sid AND b1.bid = r1.bid AND
	  b2.bid = r2.bid AND b1.color = 'red' AND
	  b2.color = 'green';

\qecho 'Problem 2.6'


SELECT DISTINCT s.sid, s.sname 
FROM Sailor s , Reserves r1, Reserves r2 
WHERE s.sid = r1.sid AND s.sid = r2.sid AND
	  r1.bid != r2.bid;

\qecho 'Problem 2.7'


SELECT DISTINCT r1.sid, r2.sid 
FROM Reserves r1, Reserves r2
WHERE r1.sid != r2.sid AND r1.bid = r2.bid;

\qecho 'Problem 2.8'

SELECT DISTINCT s.sid 
FROM Sailor s
WHERE NOT EXISTS 
(SELECT r.sid 
FROM Reserves r 
WHERE r.day IN ('Monday', 'Tuesday') AND r.sid = s.sid);

\qecho 'Problem 2.9'

SELECT s.sid, b.bid 
FROM Reserves r, Sailor s, Boat b
WHERE r.sid = s.sid AND b.bid = r.bid AND s.rating > 6 AND b.color != 'red';
	
\qecho 'Problem 2.10'

SELECT r1.bid 
FROM Reserves r1
WHERE r1.bid NOT IN 
(SELECT r2.bid 
FROM Reserves r2
WHERE r1.bid = r2.bid AND r1.sid != r2.sid);

\qecho 'Problem 2.11'

SELECT DISTINCT s.sid 
FROM Sailor s
WHERE s.sid NOT IN 
(SELECT DISTINCT r1.sid 
FROM Reserves r1, Reserves r2, Reserves r3
WHERE r1.bid != r2.bid AND r2.bid != r3.bid 
	  AND r1.bid != r3.bid AND r1.sid = s.sid 
	  AND r2.sid = s.sid AND s.sid = r3.sid);



\c postgres;

DROP DATABASE assignment1pwagh;