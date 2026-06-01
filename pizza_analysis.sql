drop table if exists pizzas;

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR (100),
    size VARCHAR(255),
    price numeric(10,2)
);

select * from pizzas;

select count(*) from pizzas;

CREATE TABLE pizza_types (
    pizza_type VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(100),
    ingredients VARCHAR(255)
);

select * from pizza_types;

CREATE TABLE orders (
    order_id   numeric(10) PRIMARY KEY,
    date_col   DATE NOT NULL,
    time_col   VARCHAR(100)
);

select * from orders;

CREATE TABLE order_details (
    order_details_id   numeric(10)    PRIMARY KEY,
    order_id           numeric(10)    NOT NULL,
    pizza_id           VARCHAR(50)  NOT NULL,
    quantity           numeric(5)     NOT NULL,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

select * from order_details;

--Basic:
--Retrieve the total number of orders placed.

select * from orders;

select count(order_id) as total_orders from orders;

--Calculate the total revenue generated from pizza sales.

select * from order_details;

select * from pizzas;

select sum(p.price*od.quantity) as total_revenue from order_details as od 
join pizzas as p on p.pizza_id = od.pizza_id;

--Identify the highest-priced pizza.

select * from pizza_types;

ALTER TABLE pizza_types RENAME COLUMN pizza_type to pizza_type_id;

select pt.name,pt.category, p.price from pizzas as p join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id order by p.price desc limit 1;


--Identify the most common pizza size ordered.

select * from order_details;

select * from pizzas;

select pizzas.size , count(od.quantity) as most_order from order_details as od join
pizzas on pizzas.pizza_id = od.pizza_id group by pizzas.size order by most_order desc limit 1;

--List the top 5 most ordered pizza types along with their quantities.

select * from pizza_types;

select * from order_details;

select * from pizzas;

select pt.pizza_type_id, pt.name, pt.category , sum(od.quantity) as total_order from pizza_types as pt join
pizzas as p on p.pizza_type_id = pt.pizza_type_id join
order_details as od on od.pizza_id = p.pizza_id group by pt.pizza_type_id order by total_order desc limit 5;

Intermediate:


--Join the necessary tables to find the total quantity of each pizza category ordered.

select * from pizzas;

select * from pizza_types;

select * from orders;

select * from order_details;

select pt.category , sum(od.quantity) as total_quantity from order_details as od join
pizzas on pizzas.pizza_id = od.pizza_id join pizza_types as pt on
pt.pizza_type_id = pizzas.pizza_type_id group by pt.category order by total_quantity desc;

--Determine the distribution of orders by hour of the day.
SELECT 
    DATE_PART('hour', time_col::time) AS hours,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY DATE_PART('hour', time_col::time)
ORDER BY total_orders DESC;


--Join relevant tables to find the category-wise distribution of pizzas.

select * from pizza_types;

select * from pizzas;

select category , count(name) from pizza_types group by category order by count(name) desc;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select * from orders;

select * from order_details;

SELECT round(AVG(daily_total),0) AS avg_daily_quantity
FROM (
    SELECT 
        orders.date_col,
        SUM(od.quantity) AS daily_total
    FROM order_details od
    JOIN orders ON orders.order_id = od.order_id
    GROUP BY orders.date_col
) AS t;

--Determine the top 3 most ordered pizza types based on revenue.

select * from order_details;

select * from pizza_types;

select * from pizzas;

select pt.name, pt.category , sum(od.quantity*pizzas.price) as revenue from
order_details as od join pizzas on pizzas.pizza_id = od.pizza_id join
pizza_types as pt on pt.pizza_type_id = pizzas.pizza_type_id group by pt.name,pt.category 
order by revenue desc limit 3;


---Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.

select * from pizza_types;

select * from pizzas;

select * from order_details;

select * from orders;

select pt.category,concat(round((sum(pizzas.price * od.quantity)/(select sum(p.price*od.quantity) as total_revenue
from order_details as od join pizzas as p on p.pizza_id = od.pizza_id))*100,2),'%') as percentage from 
pizza_types as pt join pizzas on (pizzas.pizza_type_id = pt.pizza_type_id) join
order_details as od on (od.pizza_id = pizzas.pizza_id) group by pt.category
order by percentage desc;

--Analyze the cumulative revenue generated over time.
select date_col , sum (revenue) over (order by date_col) as cummulative_revenue
from
(select orders.date_col, sum(od.quantity*pizzas.price) as revenue from 
orders join order_details as od on (od.order_id = orders.order_id)
join pizzas on (pizzas.pizza_id = od.pizza_id) group by orders.date_col 
) as sales;

--using window function and subquery

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select * from pizza_types;

select * from order_details;

select * from pizzas;

select category, name, revenue, rn from
(select category, name , revenue, rank() over (partition by category order by revenue desc) as rn
from 
(select pt.category , pt.name, sum(od.quantity*pizzas.price) as revenue 
from pizza_types as pt join pizzas on (pizzas.pizza_type_id = pt.pizza_type_id)
join order_details as od on (od.pizza_id = pizzas.pizza_id)
group by pt.category, pt.name) as revenue_3) where rn<=3;