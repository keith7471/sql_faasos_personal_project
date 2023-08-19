
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


-- 1. Find the number of rolls ordered by customers>
select count(order_id) from customer_orders;

-- 2. Find the unique number of customers that ordered the rolls
select count(distinct customer_id) from customer_orders;


-- 3. Find the successfully deliveries by each driver
select driver_id, count(driver_id) from driver_order
where driver_order.cancellation not in ('Cancellation','Customer Cancellation')
group by driver_id

-- 4. Orders received for each type of rolls
select roll_id , count(roll_id) from customer_orders
group by roll_id

-- 5. Number of different types of roles that were delivered

select * from driver_order;
	with cte as (
	select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'cancelled' else 'not cancelled' end as status
	from driver_order 
	),
	   cte_2 as(
	   select cte.order_id as order_1 from cte
	   where cte.status='not cancelled')

	   select * from cte_2;
	   ,
	   cte_3 as(
	   select * from customer_orders,cte_2
	   where customer_orders.order_id in (cte_2.order_1))

	   select roll_id,count(roll_id) as total_rolls_delivered from cte_3
	   group by roll_id
	   ;

-- 6. total number of veg and non veg roles ordered by each customers

select c.*,r.roll_name from 
((select customer_id,roll_id,count(roll_id) as total_roles from customer_orders
group by customer_id,roll_id)c
inner join rolls r
on c.roll_id=r.roll_id)
order by customer_id


-- 7. total number of rolls ordered in a single order

select order_id,count(roll_id) as total_rolls from customer_orders
group by order_id


--8. How many delivered rolls had atleast one change in the ingrediant or extra ingrediant added 
--Cleaning the table 
--a) create a virtual table which free from empty and NAN values

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


with virt_1 as 
(
	select order_id,customer_id,roll_id,case when not_include_items=' ' or not_include_items is null then '0' else not_include_items end as latest_not_include_items,
	case when extra_items_included=' ' or extra_items_included is null or extra_items_included='NaN' then '0' else extra_items_included end as latest_extra_items_included,
	order_date from customer_orders
	),

   cte as (
	select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'cancelled' else 'not cancelled' end as status
	from driver_order 
	),
	   cte_2 as(
	   select order_id from cte
	   where cte.status='not cancelled')
	   
select count(roll_id) as total_rolls from virt_1 v
inner join cte_2 c
on v.order_id=c.order_id
where v.latest_not_include_items<>'0' or v.latest_extra_items_included<>'0';

--9. how many rolls where ordered each hour all the days?
select time_range,count(roll_id) as total_rolls_ordered from(
select *,datepart(hour,order_date) as hours,concat(datepart(hour,order_date),'-',datepart(hour,order_date)+1) as time_range from customer_orders
)b
group by b.time_range


-- 10. What is the average time for the driver to arrive at the shop to pickup the order?
select * from customer_orders;
select * from driver_order;

SELECT driver_id,AVG(diff) AS average_diff from
(select l.*, row_number() over(partition by order_id order by diff) as rnk
FROM (
    SELECT c.order_id,c.customer_id,d.driver_id,c.order_date,d.pickup_time,DATEDIFF(MINUTE, c.order_date, d.pickup_time) AS diff 
     FROM customer_orders c 
    INNER JOIN driver_order d ON c.order_id = d.order_id
    WHERE d.pickup_time IS NOT NULL 
) l
where diff>=0
)k
where rnk=1
GROUP BY driver_id;
