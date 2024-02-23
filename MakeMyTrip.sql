--           MakeMyTrip Case Study 

use case_studies;
CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);

INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');
;

CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);


INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');

select * from booking_table;
select * from user_table;

-- Problem 1: Write an SQL query that gives the below output
-- Segment      Total_user_count    User_who_booked_flight_in_april_2022
--   S1                 3                  2  
--   S2                 2                  2
--   S3                 5                  1


-- Step 1

select segment,count(distinct u.user_id) as cnt
from user_table u
left join booking_table b on u.user_id = b.user_id
where year(booking_date)=2022 and month(booking_date)=04 and line_of_business="flight"
group by segment;

-- Step 2

select segment,count(user_id) as cnt2
from user_table
group by segment;


-- Step 3

with cte as(
select segment,count(distinct u.user_id) as cnt
from user_table u
left join booking_table b on u.user_id = b.user_id
where year(booking_date)=2022 and month(booking_date)=04 and line_of_business="flight"
group by segment),
cte2 as(
select segment,count(user_id) as cnt2
from user_table
group by segment)
select c1.segment,cnt2 as Total_users_count,cnt as Users_who_booked_flight_in_April_2022
from cte c1
inner join cte2 c2 on c1.segment=c2.segment;

-- Problem 2: Write a query to identify users whose first booking was hotel booking

-- Step 1

select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date;

-- Step 2

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date)
select user_id from cte
where rn=1 and line_of_business="hotel";

-- Problem 3: Write a query to calculate first and last booking of each user

-- Step 1

select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date;


-- Step 2

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date)
select user_id,
case when rn=1 then booking_date else null end as first_booking_date,
case when rn2=1 then booking_date else null end as last_booking_date
from cte;

-- Step 3

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date),
cte2 as(
select user_id,
case when rn=1 then booking_date else null end as first_booking_date,
case when rn2=1 then booking_date else null end as last_booking_date
from cte)
select user_id, MAX(first_booking_date) as first_booking_date,
MAX(last_booking_date) as last_booking_date
from cte2
group by user_id;

-- # Alternative Solution

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date),
cte2 as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date desc)
select user_id,booking_date,line_of_business  
from cte
where rn=1
union all
select user_id,booking_date,line_of_business 
from cte2
where rn2=1
order by user_id;

-- Problem 4: Write a query to calculate days between first and last booking of each user

-- Step 1

select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date;

-- Step 2

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date)
select user_id,
case when rn=1 then booking_date else null end as first_booking_date,
case when rn2=1 then booking_date else null end as last_booking_date
from cte;


-- Step 3

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date),
cte2 as(
select user_id,
case when rn=1 then booking_date else null end as first_booking_date,
case when rn2=1 then booking_date else null end as last_booking_date
from cte)
select user_id, MAX(first_booking_date) as first_booking_date,
MAX(last_booking_date) as last_booking_date
from cte2
group by user_id;

-- Step 4

with cte as(
select u.user_id,booking_date,line_of_business,
row_number() over(partition by u.user_id order by booking_date) as rn,
row_number() over(partition by u.user_id order by booking_date desc) as rn2
from user_table u
inner join booking_table b on u.user_id = b.user_id
order by u.user_id,booking_date),
cte2 as(
select user_id,
case when rn=1 then booking_date else null end as first_booking_date,
case when rn2=1 then booking_date else null end as last_booking_date
from cte),
cte3 as(
select user_id, MAX(first_booking_date) as first_booking_date,
MAX(last_booking_date) as last_booking_date
from cte2
group by user_id)
select *, datediff(last_booking_date,first_booking_date) as Difference
from cte3;

-- Problem 5: Write a query to count the number of flight and hotel bookings in each of the user segments for the year 2022.

# step1

select u.user_id,segment,line_of_business,
case when line_of_business="flight" then 1 else null end as flight_count,
case when line_of_business="hotel" then 1 else null end as hotel_count
from user_table u
inner join booking_table b on u.user_id = b.user_id
where year(booking_date)= 2022
order by u.user_id,booking_date;


-- step 2

select segment,
count(case when line_of_business="flight" then 1 else null end) as flight_count,
count(case when line_of_business="hotel" then 1 else null end) as hotel_count
from user_table u
inner join booking_table b on u.user_id = b.user_id
where year(booking_date)= 2022
group by segment
order by u.user_id,booking_date;




