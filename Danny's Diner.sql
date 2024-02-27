--                     DANNY'S DINER CASE STUDY




CREATE TABLE sales_new (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales_new
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from sales_new;
select * from menu;
select * from members;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

-- SOLUTION:

select s.customer_id,sum(m.price) as price_per_customer
from sales_new s
left join menu m on s.product_id = m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?

-- SOLUTION:

select customer_id,count(distinct order_date) as No_of_days_visited
from sales_new
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

-- SOLUTION:

-- Step 1:

select *,
rank()over(partition by customer_id order by order_date) as rnk
from sales_new;

-- Step 2:

with cte as(
select *,
rank()over(partition by customer_id order by order_date) as rnk
from sales_new)
select * from cte
where rnk=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- Solution:

-- Step 1: To find the most purchased item

select product_name
from sales_new s
left join menu m on s.product_id = m.product_id
group by product_name
order by count(product_name) desc
limit 1;

-- How many times most purchased item was ordered by all customers.

select customer_id,count(product_name) as No_of_times_most_purchased_item_was_ordered
from sales_new s1
left join menu m1 on s1.product_id = m1.product_id
where product_name =(
select product_name
from sales_new s
left join menu m on s.product_id = m.product_id
group by product_name
order by count(product_name) desc
limit 1)
group by customer_id;


-- 5. Which item was the most popular for each customer?

-- Solution:

-- Step 1:

select customer_id,product_name,count(s.product_id) as cnt,
rank() over(partition by customer_id order by count(s.product_id) desc) as rnk
from sales_new s 
left join menu m on s.product_id = m.product_id
group by customer_id,s.product_id;

-- Step 2:

with cte as(
select customer_id,product_name,count(s.product_id) as cnt,
rank() over(partition by customer_id order by count(s.product_id) desc) as rnk
from sales_new s 
left join menu m on s.product_id = m.product_id
group by customer_id,s.product_id
)
select * from cte
where rnk=1;

-- 6. Which item was purchased first by the customer after they became a member?

-- Solution:

-- Step 1:

select s.customer_id,order_date,join_date,m1.product_id,product_name,
rank() over(partition by customer_id order by order_date) as rnk
from sales_new s
left join members m on s.customer_id = m.customer_id and order_date >= join_date
left join menu m1 on s.product_id = m1.product_id
where join_date is not null;



-- Step 2:

with cte as(
select s.customer_id,order_date,join_date,m1.product_id,product_name,
rank() over(partition by customer_id order by order_date) as rnk
from sales_new s
left join members m on s.customer_id = m.customer_id and order_date >= join_date
left join menu m1 on s.product_id = m1.product_id
where join_date is not null
)
select * from cte
where rnk=1;


-- 7. Which item was purchased just before the customer became a member?

-- Solution:

-- Step 1:

select s.customer_id,order_date,join_date,m1.product_id,product_name,
rank() over(partition by customer_id order by order_date desc) as rnk
from sales_new s
left join members m on s.customer_id = m.customer_id and order_date < join_date
left join menu m1 on s.product_id = m1.product_id
where join_date is not null;


-- Step 2:

with cte as(
select s.customer_id,order_date,join_date,m1.product_id,product_name,
rank() over(partition by customer_id order by order_date desc) as rnk
from sales_new s
left join members m on s.customer_id = m.customer_id and order_date < join_date
left join menu m1 on s.product_id = m1.product_id
where join_date is not null
)
select * from cte
where rnk=1;

-- 8. What is the total items and amount spent for each member before they became a member?

-- SOLUTION:

select s.customer_id,count(s.product_id) as Total_items_per_customer,sum(m.price) as Total_price_per_customer
from sales_new s
left join menu m on s.product_id = m.product_id
left join members m1 on s.customer_id = m1.customer_id
where order_date < join_date
group by s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- SOLUTION:

with cte as(
select customer_id,s.product_id,product_name,price,
price*10 as points
from sales_new s
join menu m on s.product_id = m.product_id)
select customer_id,
sum(case when product_name = "sushi" then 2*points else points end) as Total_points
from cte
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn.

-- SOLUTION:

-- Step 1:

select s.customer_id,s.product_id,product_name,price,order_date,join_date,
date_add(join_date, interval 7 day) as first_week,
price*10 as points
from sales_new s
left join menu m on s.product_id = m.product_id
left join members m1 on s.customer_id = m1.customer_id;

-- Step 2:

with cte as(
select s.customer_id,s.product_id,product_name,price,order_date,join_date,
date_add(join_date, interval 7 day) as first_week,
price*10 as points
from sales_new s
left join menu m on s.product_id = m.product_id
left join members m1 on s.customer_id = m1.customer_id
where join_date is not null)
select customer_id,
sum(case 
when order_date < join_date and product_name != "sushi" then points
when order_date < join_date and product_name = "sushi" then 2*points
when order_date >= join_date and order_date < first_week then 2*points
when order_date > first_week and product_name = "sushi" then 2*points
else points end) as Total_points
from cte
where month(order_date) = 1
group by customer_id;

-- BONUS QUESTIONS:

select s.customer_id,order_date,product_name,price,
case when order_date >= join_date then "Y" else "N" end as member
from sales_new s
left join menu m on s.product_id = m.product_id
left join members m1 on s.customer_id = m1.customer_id;

-- Ranking:

with cte as(
select s.customer_id,order_date,product_name,price,
case when order_date >= join_date then "Y" else "N" end as member
from sales_new s
left join menu m on s.product_id = m.product_id
left join members m1 on s.customer_id = m1.customer_id)
select *,
case
when member = "Y" then rank() over(partition by customer_id,member order by order_date)
else null end as ranking
from cte;
