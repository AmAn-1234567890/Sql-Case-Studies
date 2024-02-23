--                                                 SPOTIFY Case Study

-- Creating a database named "Spotify" 

create database spotify;

-- Using the Spotify database

use spotify;


-- Creating a table named "Activity" in Spotify database

CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);

-- Inserting values in the Activity table

insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

-- Viewing the complete Activity table

select * from activity;

-- Spotify Case study problems

-- 1) Find Total active users each day

select event_date, count(distinct user_id) as total_active_users
from activity
group by event_date;

-- 2) Find total active users by each week

select event_date, count(distinct user_id) as Active_users_per_week
from activity
group by week(event_date);


-- 3) Find datewise total number of users who purchased on the same date as they have installed it.

with cte as (
select user_id, event_date, case when count(distinct event_name)=2 then 1 else 0 end as active_users
from activity
group by user_id,event_date
order by event_date)
select event_date, sum(active_users) as No_of_users_who_purchased_SameDay 
from cte
group by event_date;

-- 4) Percentage of paid users in India, USA and any other country should be tagged as others

with dte as(
select *, count(country) as count_share
from activity
where event_name= "app-purchase"
group by country),
dte2 as(
select sum(count_share) as total from dte
),
dte3 as(
select event_name,country,count_share,total,100*(count_share/total) as percentage_share 
from dte,dte2),
dte4 as(
select *, case when country in ('India','USA') then country else 'other' end as country_in
from dte3)
select country_in, round(sum(percentage_share),1) as total_percent_share_by_country
from dte4
group by country_in;


-- 5) Among all the users who installed the app on a given day, how many did app_purchase the very next day
  
with lag_cte as(
select *,
lag(event_date,1) over (partition by user_id order by event_date) as prev_event_date,
lag(event_name,1) over (partition by user_id order by event_date) as prev_event_name
from activity)
select event_date,count(case when event_name = 'app-purchase' and prev_event_name = 'app-installed' and datediff(event_date,prev_event_date)=1 then (user_id) else null end) as user_count
from lag_cte
group by event_date;
 
