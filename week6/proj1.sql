-- comp9311 21T1 Project 1 sql part
--
-- MyMyUNSW Solutions

--psql proj1 -f /import/ravel/3/z5333605/Project1Directory/proj1.sql

-- Q1:
create or replace view Q1(subject_longname, subject_num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select longname as subject_longname, count(*) as subject_num
from subjects where longname LIKE '%PhD%' 
group by longname
having count(*)>1;
-- Q2:
create or replace view Q2(OrgUnit_id, OrgUnit, OrgUnit_type, Program)
as
--... SQL statements, possibly using other views/functions defined by you ...
select OrgUnits.id as OrgUnit_id, OrgUnits.name as OrgUnits,
OrgUnit_types.name as OrgUnit_type, Programs.name as Program 
from OrgUnit_types JOIN OrgUnits 
ON OrgUnit_types.id = OrgUnits.utype JOIN Programs ON OrgUnits.id=Programs.offeredby
WHERE uoc>300
;
 
-- Q3:
create or replace view Q3(course,student_num,avg_mark)
as 
--... SQL statements, possibly using other views/functions defined by you ...
select only_tutor.course as course, count(Course_enrolments.mark) as student_num, 
cast(avg(Course_enrolments.mark) as numeric(4,2)) as avg_mark
from (select distinct courses.id as course from 
course_staff join courses on course_staff.course=courses.id 
where course_staff.course not in(select distinct course_staff.course from course_staff
 join courses on courses.id=course_staff.course where course_staff.role!=3004)
) 
as only_tutor join Course_enrolments on only_tutor.course=Course_enrolments.course 
group by only_tutor.course
having count(Course_enrolments.mark)>10 and cast(avg(Course_enrolments.mark) as numeric(4,2)) >70.00;

-- Q4:
create or replace view Q4(student_num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(*) as student_num from(
select distinct course_enrolments.student from 
 (select distinct target.id,count(*) from 
(select distinct courses.id , build.name
from  (select * from buildings where buildings.name='Quadrangle' or buildings.name='Red Centre')
as build join rooms on rooms.building=build.id
join (select * from classes where ctype=1) as classes on rooms.id=classes.room
join courses on courses.id=classes.course
order by courses.id) as target
group by target.id
having count(*)=2) as both_lec join Course_enrolments on both_lec.id=Course_enrolments.course)
as results;


--Q5:
create or replace view Q5(unswid, min_mark, course)
as
--... SQL statements, possibly using other views/functions defined by you ...
select 
 min_data.staff,min_data.min_mark,all_data.course from 
(
select staff.id as staff, min(mark) as min_mark
from courses 
join subjects on courses.subject=subjects.id join course_staff
on course_staff.course=courses.id join staff on course_staff.staff=staff.id
join (select * from subjects where offeredby=165)
as offeredbylaw on courses.subject=offeredbylaw.id
join Course_enrolments on Course_enrolments.course=courses.id
group by staff.id) as min_data 
join 
(select staff.id as staff,courses.id as course,mark
from courses 
join subjects on courses.subject=subjects.id join course_staff
on course_staff.course=courses.id join staff on course_staff.staff=staff.id
join (select * from subjects where offeredby=165)
as offeredbylaw on courses.subject=offeredbylaw.id
join Course_enrolments on Course_enrolments.course=courses.id ) as all_data
on min_data.min_mark=all_data.mark and min_data.staff=all_data.staff
order by  min_mark desc;




-- Q6:
create or replace view Q6(course_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
select total_number.id as course_id from
(select avg_mark.id as id, count(*) as num from 
(select courses.id,avg(mark) as avgmark
from (select course_enrolments.course as id,count(*) as num
from courses join course_enrolments
on course_enrolments.course=courses.id
join semesters on courses.semester=semesters.id
where course_enrolments.mark is not null and (semesters.year=2010
or semesters.year=2009)
group by course_enrolments.course
having count(course_enrolments.mark)>10) as courses
join course_enrolments
 on course_enrolments.course=courses.id
group by courses.id) as avg_mark
join course_enrolments on course_enrolments.course=avg_mark.id
where course_enrolments.mark > avg_mark.avgmark
group by avg_mark.id)
 as higher_number
join 
(select course_enrolments.course as id,count(*) as num
from courses join course_enrolments
on course_enrolments.course=courses.id
join semesters on courses.semester=semesters.id
where course_enrolments.mark is not null and (semesters.year=2010
or semesters.year=2009)
group by course_enrolments.course
having count(course_enrolments.mark)>10) as total_number
on higher_number.id=total_number.id
where cast (higher_number.num as numeric)/cast (total_number.num as numeric)<0.4
order by course_id;

-- Q7:
create or replace view Q7(staff_name, semester, course_num)
as
select all_data.staff_name as staff_name,all_data.semester as semester,
max_data.num  as course_num from 
(select max(num) as num ,semester from
(select People.name as staff_name,semesters.longname as semester,count(*) as num from 
(select id from 
(select  courses.id as id,target_semester.longname as longname from courses join
(select id,longname  from semesters
where year>2004 and year<2008) as target_semester on 
courses.semester=target_semester.id) as target_course
join Course_enrolments on Course_enrolments.course=target_course.id
group by id
having count(*)>=20) as vaild_course 
join course_staff on course_staff.course=vaild_course.id join courses on 
courses.id=vaild_course.id join semesters on courses.semester=semesters.id
join People on People.id=course_staff.staff
group by People.name,semesters.longname
) as all_data
group by semester) as max_data join
(select People.name as staff_name,semesters.longname as semester,count(*) as num from 
(select id from 
(select  courses.id as id,target_semester.longname as longname from courses join
(select id,longname  from semesters
where year>2004 and year<2008) as target_semester on 
courses.semester=target_semester.id) as target_course
join Course_enrolments on Course_enrolments.course=target_course.id
group by id
having count(*)>=20) as vaild_course 
join course_staff on course_staff.course=vaild_course.id join courses on 
courses.id=vaild_course.id join semesters on courses.semester=semesters.id
join People on People.id=course_staff.staff
group by People.name,semesters.longname
) as all_data
on all_data.num=max_data.num and all_data.semester=max_data.semester;
-- Q8:
create or replace view Q8(role_id, role_name, num_students)
as
select role_id,Staff_roles.name as role_name,count_num.num_students as num_students
from (select  enrolment_data.role as role_id,count(*) as num_students from 
(select count(*),course_enrolments.student as student,course_staff.role as role
from (select course_enrolments.course,course_enrolments.student from course_enrolments
join courses on course_enrolments.course=courses.id join semesters
on courses.semester=semesters.id
where semesters.year=2010
 ) as course_enrolments join (select course_staff.staff,course_staff.role,course_staff.course
  from course_staff join
 affiliations on course_staff.staff=affiliations.staff
 where affiliations.Orgunit=89) as course_staff
 on course_enrolments.course=course_staff.course
group by course_enrolments.student,course_staff.role) as enrolment_data 
group by enrolment_data.role) as count_num  join Staff_roles
on count_num.role_id=Staff_roles.id;

-- Q9:
create or replace view Q9(year, term, stype, average_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
select * from 
(select semesters.year as year,semesters.term as term
,students.stype as stype,cast (avg(course_enrolments.mark) as numeric(4,2)) as  average_mark from 
course_enrolments join (select courses.id,courses.semester from courses 
join subjects on courses.subject=subjects.id
where subjects.name='Data Management') as target_course on
course_enrolments.course=target_course.id join semesters on 
semesters.id=target_course.semester join students on students.id=course_enrolments.student
group by semesters.year,semesters.term,students.stype) as results
where results.average_mark is not null;

-- Q10:
create or replace view Q10(room, capacity, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select rooms.longname as room,rooms.capacity,id_numof_fac.num from 

(select id_fac.id,count(*) as num from
(select distinct id,facility from rooms 
join room_facilities on rooms.id=room_facilities.room    
where capacity>=100 and facility is not null
) as id_fac 
group by id_fac.id) as id_numof_fac
join 
rooms
on id_numof_fac.id=rooms.id
join 
(select rooms.capacity,max(id_numof_fac.num) as max from 
(select id_fac.id,count(*) as num from
(select distinct id,facility from rooms 
join room_facilities on rooms.id=room_facilities.room    
where capacity>=100 and facility is not null
) as id_fac 
group by id_fac.id) as id_numof_fac join rooms
on id_numof_fac.id=rooms.id
group by rooms.capacity) as max_data
on max_data.max=id_numof_fac.num and max_data.capacity=rooms.capacity;




-- Q11:
create or replace view Q11(staff, subject, num)
as
select people.name as staff,subjects.longname as subject,max(num) as num from 
(
select target_course_staff.staff,target_course_staff.subject,courses.id,count(*) as num from 
(select distinct subject,staff,count(*)
from(
select subject,staff,year,year-row_number() over(partition by staff,subject order by year asc) diff
 from
(select distinct courses.subject,semesters.year,course_staff.staff from 
courses join semesters on courses.semester=semesters.id
join course_staff on course_staff.course=courses.id
join course_enrolments on course_enrolments.course=courses.id
where (semesters.term='S1' or semesters.term='S2') 
and cast(course_staff.staff as longstring) like '%50354%'
order by staff,subject desc) as target_course
) as con_course
group by diff,subject,staff
having count(*)>2) as target_course_staff 
join courses on target_course_staff.subject=courses.subject
join course_staff on course_staff.course=courses.id
join course_enrolments on courses.id=course_enrolments.course
join semesters on courses.semester=semesters.id
where course_staff.staff=target_course_staff.staff and course_enrolments.mark is not null
and (semesters.term='S1' or semesters.term='S2')
group by target_course_staff.staff,target_course_staff.subject,courses.id) as finalr
join people on people.id=finalr.staff
join subjects on finalr.subject=subjects.id
group by staff,subjects.id,subjects.longname,people.name;











-- Q12:
create or replace view Q12(staff, role, hd_rate)
as
select people.name as staff,staff_roles.name as role,
cast(cast (hd_number.num as numeric)/cast (total_number.num as numeric) as numeric(4,2))
as hd_rate from 
(select course_staff.staff,course_staff.role,count(*) as num from 
(select staff from
(select staff,subject from
(select count(*),staff,role,subject from 
(select course_staff.course,course_staff.staff,course_staff.role,courses.subject
from course_staff join courses on courses.id=course_staff.course)
as distinct_role
group by subject,staff,role) as distinct_data
group by staff,subject
having count(*)=3
order by staff ) as distinct_role
group by distinct_role.staff
having count(*)>1) as target_teacher
join course_staff on target_teacher.staff=course_staff.staff
join course_enrolments on course_enrolments.course=course_staff.course
where course_enrolments.mark is not null
group by course_staff.staff,course_staff.role) as total_number
join
(select course_staff.staff,course_staff.role,count(*) as num from 
(select staff from
(select staff,subject from
(select count(*),staff,role,subject from 
(select course_staff.course,course_staff.staff,course_staff.role,courses.subject
from course_staff join courses on courses.id=course_staff.course)
as distinct_role
group by subject,staff,role) as distinct_data
group by staff,subject
having count(*)=3
order by staff ) as distinct_role
group by distinct_role.staff
having count(*)>1) as target_teacher
join course_staff on target_teacher.staff=course_staff.staff
join course_enrolments on course_enrolments.course=course_staff.course
where course_enrolments.mark >= 85
group by course_staff.staff,course_staff.role) as hd_number
on hd_number.staff=total_number.staff and hd_number.role=total_number.role
join staff_roles on hd_number.role=staff_roles.id
 join people on people.id=hd_number.staff;

