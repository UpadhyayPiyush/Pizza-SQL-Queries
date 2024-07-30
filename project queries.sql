-- Basic Queries:
-- Retrieve the total number of orders placed.
select count(order_id) as Total_Orders from orders;

-- Calculate the total revenue generated from pizza sales.
select 
round(sum(od.quantity * pz.price),2) as Total_Sales
from order_details od
join pizzas pz on pz.pizza_id=od.pizza_id;

-- Identify the highest-priced pizza.
select pt.name as Name, pz.price as Highest_Price_Pizza
from pizza_types pt
join pizzas pz on pz.pizza_type_id=pt.pizza_type_id
order by Highest_Price_Pizza desc
Limit 1;

-- Identify the most common pizza size ordered.
select pz.size, count(od.order_details_id) as Total_Count
from pizzas as pz
join order_details od on od.pizza_id=pz.pizza_id
group by size
order by Total_Count desc;

-- List the top 5 most ordered pizza types along with their quantities.
 select pt.name as NAME, sum(od.quantity) as Total_Quantity
 from pizza_types pt join pizzas pz
 on pt.pizza_type_id=pz.pizza_type_id
 join order_details od
 on od.pizza_id= pz.pizza_id
 group by NAME
 order by Total_Quantity desc
 limit 5;

-- Intermediate Queries:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category as Category, sum(od.quantity) as Total_Quantity 
from pizza_types pt join pizzas pz 
on pz.pizza_type_id=pt.pizza_type_id
join order_details od
on od.pizza_id=pz.pizza_id
group by Category
order by Total_Quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(o.order_time) as Time_of_order, count(o.order_id) as Total_Orders
from orders o
group by Time_of_order;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as Total_Count
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(Quantity)) as AVG_OF_PIZZA_PERDAY from 
(select date(order_date), sum(od.quantity) as Quantity
from orders o join order_details od
on od.order_id=o.order_id
group by date(order_date)) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select name as Name, sum(od.quantity*pz.price) as Revenue
from pizza_types pt join pizzas pz
on pz.pizza_type_id=pt.pizza_type_id
join order_details od 
on od.pizza_id=pz.pizza_id
group by Name
order by Revenue desc
Limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, round(sum(od.quantity*pz.price)/(select 
round(sum(od.quantity * pz.price),2) as Total_Sales
from order_details od
join pizzas pz on pz.pizza_id=od.pizza_id) *100,2) as revenue
from pizza_types pt join pizzas pz 
on pz.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id=pz.pizza_id
group by category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue from
(select o.order_date, sum(quantity*pz.price) as revenue
from order_details od join pizzas pz
on pz.pizza_id= od.pizza_id
join orders o on o.order_id=od.order_id
group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from 
(select name,category,revenue, rank() over(partition by category order by revenue desc) as rn from 
(select name, category, sum(od.quantity*pz.price) as revenue
from pizza_types pt join pizzas pz
on pt.pizza_type_id=pz.pizza_type_id
join order_details od 
on od.pizza_id=pz.pizza_id
group by category,name)as a)as b
where rn<=3;


 



