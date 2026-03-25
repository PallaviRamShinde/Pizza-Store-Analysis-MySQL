create database pizza_store;
use pizza_store;

#Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date TEXT,
    time TIME
);

#pizza_types
CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(200) PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    ingredients TEXT
);

#pizza
CREATE TABLE pizza (
    pizza_id VARCHAR(200) PRIMARY KEY,
    pizza_type_id VARCHAR(200),
    size VARCHAR(50),
    price DECIMAL(10,2),
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

#order_details
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(200),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizza(pizza_id)
);

# load order
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, date, time);

# load order_details
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_details_id, order_id, pizza_id, quantity);

SELECT * FROM orders ;
SELECT * FROM order_details ;
SELECT * FROM pizza ;
SELECT * FROM pizza_types ;

# 1.Retrieve the total number of orders placed.
select count(*) as total_orders 
from orders;

# 2.Calculate the total revenue generated from pizza sales.
select sum(p.price*od.quantity) as total_revenue
from order_details od
join pizza p on od.pizza_id = p.pizza_id;

# 3. Identify the highest-priced pizza.
select pt.name,p.price
from pizza p
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
order by p.price desc
limit 1;

select max(price) as highest_priced from pizza;

# 4.Identify the most common pizza size ordered.
select p.size,count(*) as total_orders
from order_details od
join pizza p on od.pizza_id = p.pizza_id
group by p.size
order by total_orders desc
limit 1;

# 5. List the top 5 most ordered pizza types along with their quantities. 
select pt.name,sum(od.quantity) as total_quantity
from order_details od
join pizza p on od.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by total_quantity desc
limit 5;

# 6. Find the total quantity of each pizza category ordered. 
select pt.category,sum(od.quantity) as total_quantity
from pizza_types pt
join pizza p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category;

# 7. Determine the distribution of orders by hour of the day. 
select hour(time) as order_hour,count(*) as total_orders
from orders
group by order_hour
order by order_hour;

# 8. Find the category-wise distribution of pizzas (count of pizza types per category). 
select category,count(*) as total_pizzas
from pizza_types
group by category;

# 9. Group the orders by date and calculate the average number of pizzas ordered per day. 
select o.date,avg(od.quantity) as avg_pizzas
from orders o
join order_details od on o.order_id = od.order_id
group by o.date;

# 10. Determine the top 3 most ordered pizza types based on revenue 
select pt.name,sum(p.price * od.quantity) as revenue
from order_details od
join pizza p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue desc
limit 3;

# 11. Calculate the percentage contribution of each pizza type to total revenue. 
select pt.name,
sum(p.price * od.quantity) * 100/
(select sum(p2.price * od2.quantity)
from order_details od2
join pizza p2 on od2.pizza_id = p2.pizza_id) as percentage
from order_details od
join pizza p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name;

# 12. Analyze the cumulative revenue generated over time. 
select o.date,
sum(sum(p.price * od.quantity)) over (order by o.date) as cumulative_revenue
from orders o
join order_details od on o.order_id = od.order_id
join pizza p on od.pizza_id = p.pizza_id
group by o.date;

# 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
select * from (
select pt.category, pt.name,
sum(p.price * od.quantity) as revenue,
rank() over (partition by pt.category order by sum(p.price * od.quantity) desc) as rnk
from order_details od
join pizza p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category, pt.name) t 
where rnk <=3;

# 14. Find orders where multiple pizzas were ordered but all pizzas are from the same category. 
select od.order_id
from order_details od
join pizza p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by od.order_id
having count(distinct pt.category) = 1
and count(*) > 1;

# 15. Find the ingredient that contributes the most to revenue.
select pt.ingredients,
sum(p.price * od.quantity) as revenue
from order_details od
join pizza p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.ingredients
order by revenue desc
limit 1;








