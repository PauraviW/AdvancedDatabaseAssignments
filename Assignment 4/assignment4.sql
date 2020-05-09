create database pwassignment4;
\c pwassignment4;
\qecho ''
\qecho 'question 1 a.'
\qecho 'Primary key constraint on Primary key'
create table student(sid int, sname text, major text);
create function check_primary_key_student() returns trigger as
$$
	begin
		if new.sid in (select s.sid from student s) then
			raise exception 'Primary key sid already exists!';
		end if;
		return new;
	end;
$$ language 'plpgsql';

create trigger pk_constraint_student 
before insert on Student
for each row
execute procedure check_primary_key_student();


insert into Student values(1, 'Mary', 'CS');
\qecho 'duplicate primary key'

insert into Student values(1, 'Cynthia', 'Math');
table student;
insert into Student values(2, 'Rose', 'Biology');
table student;
\qecho ''
\qecho 'primary key contraint on Course relation'

create table Course (cno int, cname text, total int, max int);

create function check_primary_key_Course() returns trigger as
$$
	begin
		if new.cno in (select c.cno from course c) then
			raise exception 'Primary key cno already exists!';
		end if;
		return new;
	end;
$$ language 'plpgsql';

create trigger pk_constraint_course 
before insert on Course
for each row
execute procedure check_primary_key_course();

insert into course values(1001, 'Advanced Database Systems', 15, 50);
insert into course values(1001, 'Machine Learning', 5, 20);
insert into course values(1083, 'Drawing',20,20);
table course;
\qecho 'Non duplicate primary key'
insert into course values(1002, 'AI', 5, 20);
table course;

\qecho 'question 1 b'
\qecho ''

\qecho 'Foreign key constraint on prerequisite table'
create table prerequisite(cno int, prereq int);

create function check_fk_prerequisite() returns trigger as
$$
	begin
		if new.cno not in( select c.cno from course c)  then
			raise exception 'Foreign key constraint not satisfied. Course table does not have an entry for the course = %', new.cno;
		end if;
		if new.prereq  not in( select c.cno from course c) then
			raise exception 'Foreign key constraint not satisfied.Course table does not have an entry for the prerequisite course = %', new.prereq ;
		end if;
		return new;
	end;

$$ language 'plpgsql';

create trigger fk_constraint_prerequisite
before insert on prerequisite
for each row execute procedure check_fk_prerequisite();
table prerequisite; 
\qecho ''
\qecho 'Case 1: Both the cno and prereq are in the course table. Insert should happen'
insert into prerequisite values(1001, 1002);
\qecho ''
\qecho 'Case 2: Cno is in the Course table and prereq is not in the course table. Insert should not happen'
insert into prerequisite values(1001, 1003);
\qecho ''
\qecho 'Case 3: prereq is in the Course table and  Cno is not in the course table. Insert should not happen'
insert into prerequisite values(1003, 1001);
\qecho ''
\qecho 'Case 4: Both the cno and prereq are in the course table. Insert should not happen'
insert into prerequisite values(1007, 1003);
table prerequisite;


\qecho 'Delete constraint on course table(Cascading delete operations should happen on the prerequisite table)'
\qecho 'In this case, if any cno is deleted from the course table then its entry either as a main course or the prerequite course should get deleted from the prerequisite table'
create function delete_fk_constraint_course() returns trigger as
$$ 
	begin
	if old.cno in(select c.cno from prerequisite c) or old.cno in(select c.prereq from prerequisite c)   then
		delete from prerequisite p where p.cno = old.cno;
		delete from prerequisite p where p.prereq = old.cno;
	end if;
	
	return old;
	end;
$$ language 'plpgsql';
create trigger delete_constraint_course
before delete on course
for each row
execute procedure delete_fk_constraint_course();
\qecho 'insert courses 1003, 1004, 1005 and 1006 in the course table'
insert into course values(1003, 'MLSP', 23, 60);
insert into course values(1004, 'Statistics', 5, 20);
insert into course values(1005, 'Operating Systems', 19, 20);
insert into course values(1006, 'Anthropology', 5, 20);
insert into prerequisite values(1005,1004);
\qecho 'current state prerequisite table'
table prerequisite;
\qecho 'current state course table'
table course;
\qecho 'delete from course table value 1006. This value is not in the prerequisite table so gets deleted skipping the trigger condition'
delete from course where cno = 1006;
table course;
\qecho 'As we can see that not changes are done to the prerequiste table'
table prerequisite;
\qecho 'deleting from course table value that is present in the prerequisite table. So now we see that this entry should get deleted from the prerequisite table too'
delete from course where cno = 1002;
table course;
\qecho 'updated prerequisite table.'
table prerequisite;


\qecho ''
\qecho ''

\qecho 'foreign key constraint on has taken table'
\qecho 'insert'
create table HasTaken(sid int, cno int);

create function check_fk_constraint_hastaken() returns trigger as 
$$
	begin
		if new.sid not in(select s.sid from student s)   then
			raise exception 'Entry not present in the Student table for sid =%', new.sid;
		end if;
		if new.cno not in(select c.cno from course c) then 
			raise exception 'Entry not present in the Course table for cno = %', new.cno;
		end if;
		return new;
	end;
$$ language 'plpgsql';
create trigger fk_constraint_hastaken
before insert on hastaken
for each row
execute procedure check_fk_constraint_hastaken();
\qecho 'initial state of hastaken'
table hastaken;
\qecho 'table student and course'
table student;
table course;
\qecho ''
\qecho 'insert in has taken table values present in the student and the course table(1,1001)'
\qecho ''
insert into hastaken values(1, 1001);
\qecho ''
\qecho 'insert in has taken table values  not present in the student and but present in the course table(8,1001)'
\qecho ''
insert into hastaken values(8, 1001);
\qecho ''
\qecho 'insert in has taken table values present in the student and but not present in the course table(1,1009)'
\qecho ''
insert into hastaken values(1, 1009);
\qecho ''
\qecho 'insert in has taken table values not present in the student and  not present in the course table(10,1009)'
\qecho ''
insert into hastaken values(10, 1009);
\qecho ''
\qecho 'updates state of hastaken. only 1,1001 should be present in the table'
\qecho ''
table hastaken;
\qecho ''
\qecho ''
\qecho 'We can write a delete cascade trigger for the hastaken table here. But we omit that because later in question 1 c we have to prohibit deletions from the hastaken table.Thus not creating a cascade trigger here'
\qecho ''
\qecho ''



\qecho 'foreign key constraint on Enroll table'
\qecho 'insert'
\qecho ''
\qecho 'In this case, we also maintain a global table that has one boolean value indicating whether the enrollment has started or not.'
\qecho 'So whenever, any attempt for enrollment is made, which indicates that the enrollment is started, we set it to true.'
create table Enroll(sid int, cno int);
create table EnrollmentStarted(value boolean);
insert into EnrollmentStarted values(FALSE);
create function check_fk_constraint_Enroll() returns trigger as 
$$
	begin
		if new.sid not in(select s.sid from student s)   then
			raise exception 'Entry not present in the Student table for sid =%', new.sid;
		end if;
		if new.cno not in(select c.cno from course c) then 
			raise exception 'Entry not present in the Course table for cno = %', new.cno;
		end if;
		update EnrollmentStarted set value = TRUE; 
		return new;
	end;
$$ language 'plpgsql';
create trigger fk_constraint_enroll
before insert on enroll
for each row
execute procedure check_fk_constraint_enroll();
\qecho 'initial state of enroll'
table enroll;
\qecho 'table student and course'

insert into Student values(25, 'Steve', 'Quantum Mechanics');
insert into Student values(26, 'Tina', 'Geology');
insert into course values(1050, 'NLP', 19, 20);
insert into course values(1051, 'CV', 5, 20);

table student;
table course;
\qecho ''
\qecho 'insert in enroll table values present in the student and the course table(25,1050)'
\qecho ''
insert into enroll values(25, 1050);
\qecho ''
\qecho 'insert in enroll table values  not present in the student and but present in the course table(27,1050)'
\qecho ''
insert into enroll values(27, 1050);
\qecho ''
\qecho 'insert in enroll table values present in the student and but not present in the course table(25,1053)'
\qecho ''
insert into enroll values(25, 1053);
\qecho ''
\qecho 'insert in enroll table values not present in the student and  not present in the course table(27,1053)'
\qecho ''
insert into enroll values(27, 1053);
\qecho ''
\qecho 'updates state of enroll. only 25, 1050 should be present in the table'
\qecho ''
table enroll;
\qecho ''

\qecho 'delete foreign key check on enroll table'
\qecho ''
\qecho 'If the attribute is present in the enroll table and if it is deleted from either the student or the course table then its entry should get deletd from the enroll table too.'
insert into Student values(27, 'Rajesh', 'Geometry');
insert into Student values(28, 'Raj', 'Hindi');

insert into Student values(29, 'Tom', 'Hindi');
insert into enroll values(27, 1050);
insert into enroll values(27, 1051);
create function delete_from_enroll_sid() returns trigger as 
$$
	begin
	if old.sid in(select e.sid from enroll e) then
		delete from enroll where sid = old.sid;
	end if;
	return old;
	end;
$$ language 'plpgsql';

create trigger delete_sid_enroll
before delete on student
for each row
execute procedure delete_from_enroll_sid();

\qecho ' current state of student table'
table student;
\qecho ''
\qecho ' current state of enroll table'
table enroll;
\qecho ''
\qecho ' delete from student value where sid is not present in the enroll table(sid = 29)'
delete from student where sid = 29;
table student;
table enroll;
\qecho ''
\qecho ' delete from student value where sid is  present in the enroll table(sid = 27)'

delete from student where sid = 27;
table student;
table enroll;
\qecho ''
\qecho ' updated status of student and enroll tables'
table student;
table enroll;

\qecho 'delete check for course table'
insert into course values(1057, 'English', 5, 20);
insert into course values(1058, 'Economics', 5, 20);
insert into enroll values(25, 1057);
insert into enroll values(28, 1057);
\qecho ''
create function delete_from_enroll_cno() returns trigger as 
$$
	begin
	if old.cno in(select e.cno from enroll e) then
		delete from enroll where cno = old.cno;
	end if;
	return old;
	end;
$$ language 'plpgsql';

create trigger delete_cno_enroll
before delete on course
for each row
execute procedure delete_from_enroll_cno();

\qecho ' current state of course table'
table course;
\qecho ''
\qecho ' current state of enroll table'
table enroll;
\qecho ''
\qecho ' delete from course value where cno is not present in the enroll table(cno = 1058)'
delete from course where cno = 1058;
\qecho ' current state of course table'
table course;

\qecho ''
\qecho ' current state of enroll table'
table enroll;
\qecho ''

\qecho ''
\qecho ' delete from course value where cno is  present in the enroll table(cno = 1057)'

delete from course where cno = 1057;
\qecho ''
\qecho ' updated status of course and enroll tables'
table course;
table enroll;


\qecho ''
\qecho 'foreign key check on waitlist table'
create table waitlist(sid int, cno int, position int);

create function check_fk_constraint_waitlist() returns trigger as 
$$
	begin
		if new.sid not in(select s.sid from student s)   then
			raise exception 'Entry not present in the Student table for sid =%', new.sid;
		end if;
		if new.cno not in(select c.cno from course c) then 
			raise exception 'Entry not present in the Course table for cno = %', new.cno;
		end if;
		return new;
	end;
$$ language 'plpgsql';
create trigger fk_constraint_waitlist
before insert on waitlist
for each row
execute procedure check_fk_constraint_waitlist();
\qecho 'initial state of waitlist'
table waitlist;
\qecho 'table student and course'

insert into Student values(30, 'Steven', 'Quantum Mechanics');
insert into Student values(31, 'Nita', 'Geology');
insert into course values(1060, 'NLP', 5, 20);
insert into course values(1061, 'CV', 5, 20);

table student;
table course;
\qecho ''
\qecho 'insert in waitlist table values present in the student and the course table(30,1060)'
\qecho ''
insert into waitlist values(30, 1060, 1);
table waitlist;
\qecho ''
\qecho 'insert in waitlist table values  not present in the student and but present in the course table(40,1060)'
\qecho ''
insert into waitlist values(40, 1060,2);
\qecho ''
\qecho 'insert in waitlist table values present in the student and but not present in the course table(30, 1073)'
\qecho ''
insert into waitlist values(30, 1073,3);
\qecho ''
\qecho 'insert in waitlist table values not present in the student and  not present in the course table(40, 1073)'
\qecho ''
insert into waitlist values(40, 1073,4);
\qecho ''
\qecho 'updates state of waitlist. only (30, 1060, 1) should be present in the table'
\qecho ''
table waitlist;
\qecho ''


\qecho 'delete foreign key check on waitlist table'
\qecho ''
\qecho 'if the attribute is present in the waitlist table and if it is deleted from either the student or the course table then its entry should get deletd from the waitlist table too.'
insert into Student values(32, 'Harold', 'Geometry');
insert into Student values(33, 'Kumar', 'Hindi');

insert into Student values(34, 'Nick', 'Physics');
insert into waitlist values(32, 1060,1);
insert into waitlist values(32, 1061, 2);
create function delete_from_waitlist_sid() returns trigger as 
$$
	begin
	if old.sid in(select w.sid from waitlist w) then
		delete from waitlist where sid = old.sid;
	end if;
	return old;
	end;
$$ language 'plpgsql';

create trigger delete_sid_waitlist
before delete on student
for each row
execute procedure delete_from_waitlist_sid();

\qecho ' current state of student table'
table student;
\qecho ''
\qecho ' current state of waitlist table'
table waitlist;
\qecho ''
\qecho ' delete from student value where sid is not present in the waitlist table(sid = 34)'
delete from student where sid = 34;
\qecho ''
\qecho ' delete from student value where sid is  present in the waitlist table(sid = 32)'

delete from student where sid = 32;
\qecho ''
\qecho ' updated status of student and waitlist tables'
table student;
table waitlist;

\qecho 'delete check for course table'
insert into course values(1062, 'Deep Learning', 5, 20);
insert into course values(1063, 'HCI', 5, 20);
insert into waitlist values(33, 1062, 70);
insert into waitlist values(30, 1062, 80);
\qecho ''

\qecho 'delete from waitlist trigger'
create function delete_from_waitlist_cno() returns trigger as 
$$
	begin
	if old.cno in (select w.cno from waitlist w) then
		delete from waitlist where cno = old.cno;
	end if;
	return old;
	end;
$$ language 'plpgsql';

create trigger delete_cno_waitlist
before delete on course
for each row
execute procedure delete_from_waitlist_cno();

\qecho ' current state of course table'
table course;
\qecho ''
\qecho ' current state of waitlist table'
table waitlist;
\qecho ''
\qecho ' delete from course value where cno is not present in the waitlist table(cno = 1063)'
delete from course where cno = 1063;
\qecho ' current state of course table'
table course;
\qecho ''
\qecho ' current state of waitlist table'
table waitlist;
\qecho ''

\qecho ''
\qecho ' delete from course value where cno is  present in the waitlist table(cno = 1062)'

delete from course where cno = 1062;
\qecho ''
\qecho ' updated status of course and waitlist tables'
table course;
table waitlist;


\qecho ''
\qecho '1.c'
\qecho 'Trigger that bans a delete operation on the hastaken table'

create function delete_not_permitted_hastaken() returns trigger as 
$$ 
	begin
		raise exception 'Delete not permitted on hastaken table';
		return null;
	end;

$$ language 'plpgsql';

create trigger delete_banned_on_hastaken
before delete on hastaken
for each row
execute procedure delete_not_permitted_hastaken();

\qecho 'current status of hastaken table'
table hastaken;
insert into hastaken values(25,1003);
\qecho 'delete operation on hastaken'
\qecho ''
\qecho 'Deleting student'
delete from hastaken where sid = 25;
\qecho ''
table hastaken;
\qecho ''
\qecho 'Deleting course'
delete from hastaken where cno = 1003;
\qecho ''
table hastaken;




\qecho ' Insert valid value'
insert into hastaken values(31,1001);
\qecho ''
\qecho 'We have a special condition on hastaken that is, values can only be inserted on hastaken table before enrollment has begun.So for this case, I create a global table enrollment status, which will get activated when enrolment starts that is basically when the value of the variable in the enrollmentstatis is false else no insertion is allowed '
\qecho 'Check if enrollment status is set to false and then insert accordingly in the hastaken table'

delete from enroll;
--table enroll;

create function check_if_insert_allowed_on_hastaken() returns trigger as 
$$
	begin
		if (select value from EnrollmentStarted) = TRUE then
			raise exception 'Insert not allowed since enrollment has begun';
		end if;
		return new;
	end;
$$ language 'plpgsql';
create trigger insert_check_enroll_hastaken 
before insert on hastaken
for each row
execute procedure check_if_insert_allowed_on_hastaken();

update EnrollmentStarted set value = FALSE;
\qecho 'Now we have explicitly set the enrollment started value to false, so insertion in the hastaken table should be succesful'
insert into hastaken values(28, 1003);
\qecho 'table hastaken'
table hastaken;
\qecho 'insert values in the enroll table'
insert into enroll values(28, 1003);
\qecho ''
\qecho ' This insertion in enroll table, will set the value of the global variable to true, indicating that no more insertions on the hastaken table asre allowed after this.'
\qecho ''
\qecho 'table enroll'
table enroll;
\qecho ''
\qecho 'now try inserting values in hastaken table, should give an error'
insert into hastaken values(30, 1003);
\qecho 'table hastaken'
table hastaken;



\qecho '1.d'
\qecho 'Delete operation on Course Table'
create function prohibit_deletion_Course() returns trigger as 
$$ 
	begin
		raise exception 'Cannot delete from Course Table';
	return null;
	end;
$$ language 'plpgsql';
create trigger cprohibit_delete_Course
before delete on Course
for each row
execute procedure prohibit_deletion_Course();
\qecho ''
\qecho 'Delete operation on the Course table should give an error'
\qecho ''
table course;
delete from Course where cno = 1001;
\qecho ''
table course;
\qecho ''



\qecho 'delete prohibited on prerequisite course'
create function prohibit_deletion_prerequisite() returns trigger as 
$$ 
	begin
		raise exception 'Cannot delete from prerequisite Table';
	return null;
	end;
$$ language 'plpgsql';
create trigger prohibit_delete_prerequisite
before delete on prerequisite
for each row
execute procedure prohibit_deletion_prerequisite();
\qecho ''
\qecho 'Delete operation on the prerequisite table should give an error'
\qecho ''
table prerequisite;
delete from prerequisite;
table prerequisite;
\qecho ''


\qecho ' trigger to stop adding/ updating the course table once the enrollment starts'
\qecho ''
\qecho 'In this case, we see that the if the enrollment has started then we are no longer allowed to add into the course table.'
create function check_insert_allowed_Course() returns trigger as
$$
begin
	if (select value from EnrollmentStarted) = TRUE then
	raise exception 'Addition not allowed on Course table';
	end if;
	return new;
end;
$$ language 'plpgsql';
create trigger insert_check_course_table
before insert on Course
for each row
execute procedure check_insert_allowed_Course();

\qecho 'Right now the enrollment status is set to true, so addition/updation should not be allowed on course table'
\qecho ''
\qecho 'insert'
insert into Course values(1076, 'Biology', 17, 30);
\qecho ''
\qecho 'update'
update Course set total = 6 where cno = 1001;

\qecho ' Now set the enrollment status to false and we can perform addition and updation on the Course table'
delete from enroll;
update enrollmentstarted set value = FALSE;
\qecho 'insert'
table course;
\qecho 'Inserting course biology in the course table '
insert into Course values(1076, 'Biology', 29, 30);
\qecho ''
table course;
\qecho ''
\qecho 'update'
\qecho ''
table course;
\qecho 'updating the total enrollment of course 1004 to 6'
update Course set total = 6 where cno = 1004;
\qecho ''
table course;



\qecho ' trigger to stop adding/ updating the prerequisite table once the enrollment starts'
\qecho ''
\qecho 'In this case, what we do is we check the status of the enrollment started table to know if we can update the prerequisite table or not.'

create function check_insert_allowed_prerequisite() returns trigger as
$$
begin
	if (select value from EnrollmentStarted) = TRUE then
	raise exception 'Addition/Updation not allowed on prerequisite table as the enrollment has begun';
	end if;
	return new;
end;
$$ language 'plpgsql';

create trigger insert_check_prerequisite_table
before insert or update on prerequisite
for each row
execute procedure check_insert_allowed_prerequisite();
insert into enroll values(28,1001);
\qecho ''
table prerequisite;
\qecho 'Right now enrollment has started, so addition/updation should not be allowed on prerequisite table'
\qecho ''
\qecho 'insert'
insert into prerequisite values(1001, 1061);
\qecho ''
\qecho 'update'
update prerequisite set prereq = 1061 where cno = 1005;
\qecho ''
\qecho ' Now I set the enrollment started variable to false, to indicate that the enrollment has stopped.And now I perform addition and insertion on the prerequisite table'
update enrollmentstarted set value = False;
\qecho 'Addition and updation should work now'
delete from enroll;
\qecho 'table prerequisite'
table prerequisite;
\qecho 'insert'
\qecho 'Insert a new record(1001, 1061)'
insert into prerequisite values(1001, 1061);
\qecho 'table prerequisite'
table prerequisite;
\qecho ''
\qecho 'update'
\qecho 'updating record a new record with cno 1005'
\qecho 'table prerequisite'
table prerequisite;
update prerequisite set prereq = 1061 where cno = 1005;
\qecho ''
\qecho 'table prerequisite'
table prerequisite;
\qecho ''
\qecho ''




\qecho 'question 2'
\qecho ''
\qecho 'Trigger to let a student enroll only if he/she has taken all the prerequisite courses for that course and updating the waitlist and course tables if needed. '
\qecho ''
\qecho 'Here we first check if all the prerequisites have been taken or not. If yes then only add the student in the enroll table or in the waitlist table '
\qecho ''
\qecho 'If prerequistes are satisfied then check if there is any space left for the course, if yes then add the student in the enrollment table and update the total enrollment of the course by 1. If not then add the student to the waitlist tble'
create function check_all_prerequistes_completed() returns trigger as 
$$ 
	declare
	max_val int;
	begin
	if exists(select 1 
			  from prerequisite p
			  where p.cno = new.cno 
			  and p.prereq not in(select h.cno 
								  from hastaken h
								 where h.sid = new.sid)) then
		raise exception 'All prerequisites not taken. Student cannot be enrolled. Sid = %',new.sid;
	end if;
	if ((select c.total from Course c where c.cno = new.cno) < (select c1.max from Course c1 where c1.cno = new.cno)) then
		update Course set total = total + 1 where cno = new.cno;
		
		
		return new;
	else
		if not exists(select 1 from waitlist w where w.cno = new.cno) then
			insert into waitlist values(new.sid, new.cno, 1);
			
		else
			max_val = (select max(w.position) from waitlist w where w.cno = new.cno);
	
			insert into waitlist values(new.sid, new.cno, max_val+1);
		end if;
	return null;
		
	end if;
	end;
$$ language 'plpgsql';

create trigger prerequisite_taken_check
before insert on enroll
for each row
execute procedure check_all_prerequistes_completed();
insert into student values(100, 'Pauravi','Data Science');

delete from enroll;
insert into course values(1080, 'Data Mining', 19, 20);
insert into prerequisite values(1080, 1061);
insert into prerequisite values(1080, 1060);
insert into hastaken values(100, 1061);
insert into hastaken values(100, 1060);

insert into student values(101, 'Rajish','Data Science');
insert into hastaken values(101, 1061);
\qecho 'I inserted two students in the student table who wish to take the data mining course 1080. That course has 2 prerequisites 1061 and 1062. Student with sid 100 has taken all the pre-requisites  but student 101 has taken only one of the prerequisite courses.  '
\qecho ' Consequently, the student 100 will get enrolled and 101 will not get enrolled and an exception will be raised.'

\qecho ''
\qecho 'Student with prerequisites met sid = 100'
\qecho ''
table course;

insert into enroll values(100, 1080);

table course;

\qecho ''
\qecho 'Student with prerequisites met sid = 100'

table enroll;
\qecho ''
\qecho 'Student with prerequisites not met sid = 101'
\qecho ''
insert into enroll values(101, 1080);
\qecho ''
table enroll;
delete from enroll;

\qecho ' Before enforcing the delete updates on the enroll table, I will test if the insert constrainst on the enroll and waitlist table work properly or not. '
\qecho 'For that I try enrolling a student for the 1080 course which for which the maximum enrollment number has been reached. In this case, the person should get added in the waitlist table with the next available waitlist position.'
\qecho ''
\qecho 'I will test this on 2 conditions'
\qecho 'Condition 1: I will check if the course(1080) does not exist in the waitlist table then add the course in that table and set position to 1'
update enrollmentstarted set value = FALSE;
insert into student values(103, 'Jyoti','Data Science');
insert into hastaken values(103, 1061);
insert into hastaken values(103, 1060);
\qecho 'table waitlist before insertion'
table waitlist;
insert into enroll values(103, 1080);
\qecho 'table course to see that for the course 1080 maximum enrollment is reached.'
table course;
\qecho 'table enroll'
table enroll;
\qecho 'table waitlist after insertion'
table waitlist;
\qecho ''
\qecho 'Condition 2: I will check if the course  exists in the table then update the  position to next number'
\qecho 'In this case, the student 104 cannot enroll in the course as the maximum enrollment has been reached. So we add him/her in the waitlist table and since, an entry for the same course is already present in the waitlist table, we update the position.'
update enrollmentstarted set value = FALSE;
insert into student values(104, 'Jaywant','Data Science');
insert into hastaken values(104, 1061);
insert into hastaken values(104, 1060);
\qecho 'table waitlist before insertion'
table waitlist;

insert into enroll values(104, 1080);
\qecho 'table enroll'
table enroll;
\qecho 'table waitlist after insertion'
table waitlist;


\qecho 'For the delete constraint on the waitlist table, I will consider the following cases'
\qecho 'case 1: When a student drops himself from the waitlist table, then he/she gets removed. '
\qecho ''
\qecho ' table waitlist before deletion'
table waitlist ;
\qecho ''
delete from waitlist where sid = 103;
\qecho ''
\qecho ' table waitlist after deletion'
table waitlist;
\qecho ''
delete from waitlist where sid = 104;
\qecho ''
table waitlist;
\qecho ''

\qecho 'example on multiple values'
insert into student values(105, 'Jyoti','Data Science');
insert into student values(106, 'Roy','Data Science');
insert into student values(107, 'Robert','Data Science');
insert into student values(108, 'Mona','Data Science');
insert into student values(109, 'Gogo','Data Science');
table enroll;
insert into enroll values(103, 1050);
insert into enroll values(104, 1050);
insert into enroll values(107, 1050);
insert into enroll values(105, 1050);
insert into enroll values(106, 1050);
insert into enroll values(108, 1076);
insert into enroll values(107, 1076);
insert into enroll values(28, 1076);
insert into enroll values(103, 1076);
insert into enroll values(104, 1076);
insert into enroll values(105, 1076);
insert into enroll values(109, 1076);
insert into enroll values(107, 1083);
insert into enroll values(103, 1083);
insert into enroll values(108, 1083);
insert into enroll values(109, 1083);


table waitlist;
table enroll;
delete from waitlist where sid = 104;
table waitlist;



\qecho ''
\qecho 'Enforcing the restrictions where I update the enroll and waitlist tables on the basis of the deletion of a student from the enroll table'

create function update_positions_enroll() returns trigger as 
$$
declare
waitlist_data record;
begin
	update course set total = total - 1 where cno = old.cno;
	if exists(select 1 from waitlist where  cno = old.cno and position = 1) then	
	select * from waitlist where  cno = old.cno and position = (select min(position)
															   from waitlist w 
															   where w.cno = old.cno) into waitlist_data;
	insert into enroll values(waitlist_data.sid, waitlist_data.cno);
	delete from waitlist where sid = waitlist_data.sid and cno = waitlist_data.cno;
	end if;
	
	return old;
end;

$$ language 'plpgsql';
create trigger del_from_enroll
before delete on enroll
for each row
execute procedure update_positions_enroll();
table course;

table waitlist;
table enroll;
\qecho 'Deleting from enroll a student whose sid is 108, now since the student 108 was enrolled in the course 1076, he/she will be replaced by the next person on the waitlist having the mimimum position'
delete from enroll where sid = 108;
table course;
table waitlist;
table enroll;

insert into enroll values(33,1003);
table enroll;
table course;

\qecho 'In this case, since there are no students on the waiting list for the subjects(1003) taken by 33, we just decrease the enrollment number from the course table by 1.'
table waitlist;
delete from enroll where sid = 33;
\qecho 'updated tables after deletion. We can see that sid = 33 is no longer in the enroll table and the total value for the course 1003 reduces by 1 '
table enroll;
table course;

\qecho 'Now I will check for a specific student and a specific course that he/she wants to dropfrom the enroll table'
\qecho 'tables before deletion sid = 109 and cno = 1003'
insert into enroll values(109,1003);
table enroll;
table course;
table waitlist;

delete from enroll where sid = 109 and cno = 1003;
\qecho 'tables after deletion only the enrolment table and the course table total for 1003 ahs changed.'
table enroll;
table course;
table waitlist;

\qecho 'Now I will check for a specific student and a specific course that he/she wants to drop from the waitlist table'
\qecho 'tables before deletion (sid = 105 and cno = 1076)'
table waitlist;

delete from waitlist where sid = 105 and cno = 1076;
\qecho 'tables after deletion'
table waitlist;
\qecho 'No changes will take place in the course and enrollment table'




\qecho 'question 3'
\qecho 'I have created  a table expected value to store the final values of n, expected value and the standard deviation.'
\qecho 'Firstly, I trigger an event throw using insert into table T function, where I do not insert anythinf in the table but use it to trigger the event. This generates the sum of random variables between 3-18 and then I send these values to the procedure written on the trigger. Then I calculate that using the previous values. If the data is not already present then I initialize it with expected value and the standard deviation for1 throw and subsequently i use the previous result to get the next values'
\qecho 'I create expec_Val table for storing the final values of the expected value and standard deviation'
create table expec_Val(n int, et float, vt float);
\qecho 'I create this table T just to trigger the throw event' 
create table T(n int, sum int);

\qecho 'expected_val function implements the standard deviation and expected value incrementally '
create function expected_val() returns trigger as
$$
declare 
prev_exp float; 
begin
	if not exists(select 1 from expec_Val)  then
		insert into expec_Val values(1, new.sum, 0);
	else
		update expec_Val set n = new.n;
		prev_exp = (select et from expec_Val);
		update expec_Val set et = ((select v.et from expec_Val v) * (new.n - 1) + new.sum)/new.n ;
		update expec_Val set vt = sqrt(((select p.vt from expec_Val p) + ((new.sum - prev_exp) * (new.sum - (select n.et
																							from expec_Val n)))));
	end if;
	return null;
end;
$$ language 'plpgsql';


\qecho 'calc_exp_val is the trigget that calls the procedure to calculate the expected values'
create trigger calc_exp_val 
before insert on T
for each row
execute procedure expected_val();

\qecho 'expt is the function that throws and incrementally calculates the results n times. I put the results in the record variable and return it.'
create function expt(n int) returns record as 
$$
	declare i int;
	result record ;
	begin
	for i in 1..n loop
		insert into T values(i, (floor(random()*6)+1+ floor(random()*6)+1+ floor(random()*6)+1));
	end loop;
	select * from expec_Val into result ;
	return result;
	end;
$$ language 'plpgsql';

select n, Expected_value, Standard_deviation  from expt(1000) expt(n int, Expected_value float, Standard_deviation float);
drop table t;
drop table expec_Val cascade;
drop function expected_val cascade;
drop function expt;


\c postgres;
drop database pwassignment4;