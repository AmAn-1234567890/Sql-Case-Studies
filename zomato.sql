create database case_studies;
use case_studies;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'),(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- Problem 1 : What is the total amount each customer spent on zomato?

select s.userid,sum(p.price) as Money_spent
from sales s
inner join product p on s.product_id = p.product_id
group by userid
order by userid;


-- Problem 2: How many days has each customer visited zomato?

select userid, count(distinct created_date) as No_f_days_visited_by_each_customer
from sales
group by userid;

-- Problem 3: What was the first product purchased by each customer?

-- 1st method

-- 1st step

select s.userid,s.created_date,p.product_id,p.product_name,p.price, row_number() over(partition by userid order by created_date) as rn
from sales s
inner join product p on s.product_id = p.product_id;

-- 2nd step
  
with cte as(
select s.userid,s.created_date,p.product_id,p.product_name,p.price, row_number() over(partition by userid order by created_date) as rn
from sales s
inner join product p on s.product_id = p.product_id  
)
select * from cte
where rn =1;


-- Alternative method

with cte as(
select * from sales
where userid=1
order by userid,created_date
limit 1),
cte2 as(
select * from sales
where userid=2
order by userid,created_date
limit 1),
cte3 as(
select * from sales
where userid=3
order by userid,created_date
limit 1)
select * from
cte,cte2,cte3;

-- Problem 4: What is the most purchased item on the menu and how many times it was purchased by all the customers?

-- 1st method

select *, count(product_id) as cnt
from sales
group by product_id
order by cnt desc;

-- Alternative method-complete solution

-- 1st step

select product_id
from sales
group by product_id
order by count(product_id) desc
limit 1;

-- 2nd Step

select userid,count(product_id) as order_count from sales
where product_id = (
select product_id
from sales
group by product_id
order by count(product_id) desc
limit 1)
group by userid
order by userid;

-- Problem 5: Which item is popular for each customer?

-- 1-2,2-3,3-2

select userid,product_id,count(product_id)
from sales
group by userid;

-- 1-2,2-3,3-2

-- 1st step

select userid,product_id,count(product_id) as cnt
from sales
group by userid,product_id
order by userid;

-- 2nd step

with cte as(
select userid,product_id,count(product_id) as cnt
from sales
group by userid,product_id
order by userid)
select *, rank()over(partition by userid order by cnt desc) as rnk
from cte;

-- 3rd step 

with cte as(
select userid,product_id,count(product_id) as cnt
from sales
group by userid,product_id
order by userid),
cte2 as(
select *, rank()over(partition by userid order by cnt desc) as rnk
from cte)
select * from cte2
where rnk =1;
 
-- Problem 6: Which item was first purchased by the customer once they became the member?

-- Step 1

select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid 
order by userid,dd;

-- 2nd step

select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) >0 
order by userid,dd;

-- step 3

with cte as(
select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) >0 
order by userid,dd)
select *, rank() over(partition by userid order by dd) as rnk 
from cte;

-- step 4

with cte as(
select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) >0 
order by userid,dd),
cte2 as(
select *, rank() over(partition by userid order by dd) as rnk 
from cte)
select * from cte2
where rnk=1;

-- Problem 7: Which item was purchased just before user became the gold member?
-- step 1

select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
order by userid,dd;

-- step 2

select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) <0 
order by userid,dd;

-- step 3

with cte as(
select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) <0 
order by userid,dd)
select *, rank() over(partition by userid order by dd desc) as rnk 
from cte;

-- step 4

with cte as(
select s.userid,s.product_id,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd 
from sales s
inner join users u on s.userid=u.userid
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) <0 
order by userid,dd),
cte2 as(
select *, rank() over(partition by userid order by dd desc) as rnk 
from cte)
select * from cte2
where rnk=1;

-- Problem 8: What is the total orders and amount spent for each member before they became the member?

-- step 1

select s.userid,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd,count(p.product_id) as cnt,sum(p.price) as sum 
from sales s
inner join users u on s.userid=u.userid
inner join product p on s.product_id = p.product_id
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) <0 
group by s.userid
order by s.userid,dd;

-- step 2

with cte as(
select s.userid,g.gold_signup_date,s.created_date,datediff(s.created_date,g.gold_signup_date) as dd,count(p.product_id) as cnt,sum(p.price) as sum 
from sales s
inner join users u on s.userid=u.userid
inner join product p on s.product_id = p.product_id
left join goldusers_signup g on s.userid=g.userid
where datediff(s.created_date,g.gold_signup_date) <0 
group by s.userid
order by s.userid,dd)
select userid,gold_signup_date,created_date,cnt,sum
from cte;

-- Problem 9: If buying each product generates points, for eg. 5 Rs. = 2 Zomato points and each product has different purchasing points for eg. P1 5 Rs. = 1 Zomato point, P2 10 Rs. = 5 Zomato points and P3 5 Rs. = 1 Zomato point   
-- So calculate points collected by each customers and for which product most points have been collected till now?

-- Find points and cashback collected by each customers

-- step 1

select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid;

-- step 2

with cte as (
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid)
select *, 
round(case 
when product_id=1 then total_money/5 
when product_id=2 then total_money *5/10
when product_id=3 then total_money/5
else null end,0) as no_of_zomato_points
from cte;

-- step 3

with cte as (
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid),
cte2 as(
select *, 
round(case 
when product_id=1 then total_money/5 
when product_id=2 then total_money *5/10
when product_id=3 then total_money/5
else null end,0) as no_of_zomato_points
from cte)
select userid,sum(no_of_zomato_points) as total_zomato_points,round(sum(no_of_zomato_points)*5/2,1) as total_cashback_in_Rs
from cte2
group by userid;

-- For which product most points have been collected

-- step 1
 
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid;
 
-- step 2

with cte as (
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid)
select *, 
round(case 
when product_id=1 then total_money/5 
when product_id=2 then total_money *5/10
when product_id=3 then total_money/5
else null end,0) as no_of_zomato_points
from cte;

-- step 3

with cte as (
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid),
cte2 as(
select *, 
round(case 
when product_id=1 then total_money/5 
when product_id=2 then total_money *5/10
when product_id=3 then total_money/5
else null end,0) as no_of_zomato_points
from cte)
select product_id,sum(no_of_zomato_points) as total_zomato_points
from cte2
group by product_id
order by total_zomato_points desc;

-- step 4


with cte as (
select userid,p.product_id,price,count(p.product_id) as cnt,price * count(p.product_id) as total_money
from sales s 
inner join product p on s.product_id = p.product_id
group by userid,product_id
order by userid),
cte2 as(
select *, 
round(case 
when product_id=1 then total_money/5 
when product_id=2 then total_money *5/10
when product_id=3 then total_money/5
else null end,0) as no_of_zomato_points
from cte)
select product_id,sum(no_of_zomato_points) as total_zomato_points
from cte2
group by product_id
order by total_zomato_points desc
limit 1;

-- Problem 10: In the first one year after the customer joins the gold program(including their join date)irrespective of what the customers has purchsed they earn 5 zomato points for every 10 Rs. spent.Who earned more 1 or 3 and what was their points earning in their first year?
 
-- step 1

select s.userid,created_date,p.product_id,gold_signup_date, date_add(gold_signup_date, interval 1 year) as extended_date, price,round(price*5/10,0) as zomato_points_earned
from sales s
inner join goldusers_signup g on s.userid=g.userid
inner join product p on s.product_id = p.product_id;

-- step 2

with cte as(
select s.userid,created_date,p.product_id,gold_signup_date, date_add(gold_signup_date, interval 1 year) as extended_date, price,round(price*5/10,0) as zomato_points_earned
from sales s
inner join goldusers_signup g on s.userid=g.userid
inner join product p on s.product_id = p.product_id)
select * from cte
where created_date between gold_signup_date and extended_date
order by userid;


-- Problem 11: Rank all the transactions of the customers based on price. 

select userid,p.product_id,created_date,price,rank() over(partition by userid order by price desc) as rn
from sales s
inner join product p on s.product_id = p.product_id;

-- Problem 12: Rank all the transaction for each member whenever they are gold member. For every non gold member transaction marked as na.

-- step 1

select s.userid,created_date,p.product_id,price,gold_signup_date
from sales s
inner join product p on s.product_id = p.product_id
left join goldusers_signup g on s.userid = g.userid and s.created_date >= g.gold_signup_date
order by s.userid,gold_signup_date desc;

-- step 2

with cte as(
select s.userid,created_date,p.product_id,price,gold_signup_date
from sales s
inner join product p on s.product_id = p.product_id
left join goldusers_signup g on s.userid = g.userid and s.created_date >= g.gold_signup_date
order by s.userid,gold_signup_date desc)
select *, 
case 
when gold_signup_date is not null then rank()over(partition by gold_signup_date order by created_date)
else "na" end as rnk
from cte;

