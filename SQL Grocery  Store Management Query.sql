CREATE DATABASE GROCERY_STORE_MANAGEMENTDB;
USE GROCERY_STORE_MANAGEMENTDB;

-- 1. SUPPLIER DATA TABLE
CREATE TABLE IF NOT EXISTS supplier(
    sup_id TINYINT PRIMARY KEY,
    sup_name VARCHAR(255),
    address TEXT
);

SELECT * FROM supplier;

-- 2. CATEGORIES DATA TABLE
 CREATE TABLE IF NOT EXISTS categories (
    cat_id TINYINT PRIMARY KEY,
    cat_name VARCHAR(255)
);
SELECT * FROM categories;

-- 3. EMPLOYEES DATA TABLE
CREATE TABLE IF NOT EXISTS employees (
    emp_id TINYINT PRIMARY KEY,
    emp_name VARCHAR(255),
    hire_date VARCHAR(255)
);
SELECT * FROM employees;

-- 4. CUSTOMERS DATA TABLE
CREATE TABLE IF NOT EXISTS customers (
    cust_id SMALLINT PRIMARY KEY,
    cust_name VARCHAR(255),
    address TEXT
);
SELECT * FROM customers;

-- 5. PRODUCTS DATA TABLE
CREATE TABLE IF NOT EXISTS products (
    prod_id TINYINT PRIMARY KEY,
    prod_name VARCHAR(255),
    sup_id TINYINT,
    cat_id TINYINT,
    price DECIMAL(10,2),
    FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM products;

-- 6. ORDERS DATA TABLE
CREATE TABLE IF NOT EXISTS orders (
    ord_id SMALLINT PRIMARY KEY,
    cust_id SMALLINT,
    emp_id TINYINT,
    order_date VARCHAR(255),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM orders;

-- 7. ORDER_DETAILS DATA TABLE
CREATE TABLE IF NOT EXISTS order_details (
    ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    prod_id TINYINT,
    quantity TINYINT,
    each_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM order_details;

-- 1. FIXING AUTO_INCREMENT FOR Supplier TABLE
ALTER TABLE supplier
MODIFY sup_id TINYINT AUTO_INCREMENT;


-- 2. FIXING AUTO_INCREMENT FOR CATEGORIES TABLE
-- DROPING THE FOREIGN KEY - We drop the foreign key temporarily because MySQL does not allow modifying a referenced column directly. This ensures referential integrity. 
-- After modifying the primary key, the foreign key is re-applied.
ALTER TABLE products
DROP FOREIGN KEY products_ibfk_2;
-- Add AUTO_INCREMENT to categories
ALTER TABLE categories
MODIFY cat_id TINYINT AUTO_INCREMENT;
-- Re-add foreign key - We re-add the foreign key to restore referential integrity and ensure that relationships between tables are enforced after structural modifications.
ALTER TABLE products
ADD CONSTRAINT products_ibfk_2
FOREIGN KEY (cat_id)
REFERENCES categories(cat_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- 3. FIXING AUTO_INCREMENT EMPLOYEES TABLE
-- Drop foreign key from orders
ALTER TABLE orders
DROP FOREIGN KEY orders_ibfk_2;
-- Add AUTO_INCREMENT
ALTER TABLE employees
MODIFY emp_id TINYINT AUTO_INCREMENT;
-- Re-add foreign key
ALTER TABLE orders
ADD CONSTRAINT orders_ibfk_2
FOREIGN KEY (emp_id)
REFERENCES employees(emp_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- 4. FIXING AUTO_INCREMENT CUSTOMERS TABLE
-- Drop foreign key from orders
ALTER TABLE orders
DROP FOREIGN KEY orders_ibfk_1;
-- Add AUTO_INCREMENT
ALTER TABLE customers
MODIFY cust_id SMALLINT AUTO_INCREMENT;
-- Re-add foreign key
ALTER TABLE orders
ADD CONSTRAINT orders_ibfk_1
FOREIGN KEY (cust_id)
REFERENCES customers(cust_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- 5. FIXING AUTO_INCREMENT PRODUCTS TABLE
-- Drop foreign key from order_details
ALTER TABLE order_details
DROP FOREIGN KEY order_details_ibfk_2;
-- Add AUTO_INCREMENT
ALTER TABLE products
MODIFY prod_id TINYINT AUTO_INCREMENT;
-- Re-add foreign key
ALTER TABLE order_details
ADD CONSTRAINT order_details_ibfk_2
FOREIGN KEY (prod_id)
REFERENCES products(prod_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- 6. FIXING AUTO_INCREMENT ORDERS TABLE
-- Drop foreign key from order_details
ALTER TABLE order_details
DROP FOREIGN KEY order_details_ibfk_1;
-- Add AUTO_INCREMENT
ALTER TABLE orders
MODIFY ord_id SMALLINT AUTO_INCREMENT;
-- Re-add foreign key
ALTER TABLE order_details
ADD CONSTRAINT order_details_ibfk_1
FOREIGN KEY (ord_id)
REFERENCES orders(ord_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- check for every auto_incremented table for every tables
SHOW CREATE TABLE order_details;

-- WHY DO WE DROP THE FOREIGN KEY & ADD AUTO_INCREMENT & RE-ADD FOREIGN KEY 
-- Foreign keys restrict structural changes on referenced columns. Therefore, the foreign key is dropped temporarily to allow adding AUTO_INCREMENT to the primary key.
--  After the modification, the foreign key is re-added to restore referential integrity and enforce CASCADE rules.

SHOW TABLES;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_details;

-- Analysis Questions

SELECT * FROM customers;
-- 1️. Customer Insights
-- 1.1 How many unique customers have placed orders?
SELECT count(DISTINCT cust_id) as UNIQUE_ORDERS FROM orders;

-- 1.2 Which customers have placed the highest number of orders? 
SELECT * FROM customers;
SELECT * FROM orders;
SELECT 
c.cust_id,
c.cust_name,
COUNT(o.ord_id) as total_orders
FROM customers c
JOIN orders o
ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_orders DESC;

-- 1.3 What is the total and average purchase value per customer?
SELECT 
    c.cust_id,
    c.cust_name,
    SUM(od.total_price) AS total_purchase_value,
    AVG(od.total_price) AS average_purchase_value
FROM customers c
JOIN orders o 
    ON c.cust_id = o.cust_id
JOIN order_details od 
    ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name;

-- 1.4 Who are the top 5 customers by total purchase amount?
SELECT 
c.cust_id,
c.cust_name,
SUM(od.total_price) AS total_spent
FROM customers c
JOIN orders o
ON c.cust_id = o.cust_id
JOIN order_details od
ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_spent DESC
LIMIT 5;

-- 2. Product Performance
-- 2.1 How many products exist in each category?
SELECT * FROM products;
SELECT * FROM categories;
SELECT
c.cat_name,
COUNT(p.prod_id) as total_products
FROM categories c 
LEFT JOIN products p
ON c.cat_id = p.cat_id
GROUP BY c.cat_name;

-- 2.2 What is the average price of products by category?
SELECT * FROM products;
SELECT * FROM categories;
SELECT 
c.cat_name,
AVG(p.price) AS average_price
FROM categories c
JOIN products p
ON c.cat_id = p.cat_id
GROUP BY c.cat_name;

-- 2.3 Which products have the highest total sales volume (by quantity)?

SELECT * FROM order_details;
SELECT * FROM products;
SELECT
p.prod_name,
SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od
ON p.prod_id = od.prod_id
GROUP BY p.prod_name
ORDER BY total_quantity_sold DESC;

-- 2.4 What is the total revenue generated by each product?
SELECT * FROM order_details;
SELECT * FROM products;
SELECT
p.prod_name,
SUM(od.total_price) AS total_revenue
FROM products p 
JOIN order_details od
ON p.prod_id = od.prod_id
GROUP BY p.prod_name
ORDER BY total_revenue DESC;

-- 2.5 How do product sales vary by category and supplier?
SELECT * FROM categories;
SELECT * FROM supplier;
SELECT * FROM order_details;
SELECT
c.cat_name,
s.sup_name,
SUM(od.total_price) AS total_sales
FROM order_details od
JOIN products p ON od.prod_id = p.prod_id
JOIN categories c ON p.cat_id = c.cat_id
JOIN supplier s ON c.cat_id = s.sup_id
GROUP BY c.cat_name, s.sup_name
ORDER BY total_sales DESC;


-- 3. Sales and Order Trends
-- 3.1 How many orders have been placed in total?
SELECT * FROM orders;
SELECT COUNT(*) AS total_orders
FROM orders;

-- 3.2 What is the average value per order?
SELECT
 AVG(order_total) AS average_order_value
FROM (
SELECT 
ord_id,
SUM(total_price) AS order_total
FROM order_details
GROUP BY ord_id
)t;

-- 3.3 On which dates were the most orders placed?
SELECT * FROM orders;

SELECT 
order_date,
COUNT(ord_id) AS orders_count
FROM orders
GROUP BY order_date
ORDER BY orders_count DESC;

-- 3.4 What are the monthly trends in order volume and revenue?
SELECT * FROM order_details;
SELECT * FROM orders;
SELECT 
DATE_FORMAT(o.order_date, '%y-%m') AS MONTH,
COUNT(DISTINCT o.ord_id) AS total_orders,
SUM(od.total_price) AS total_revenue
FROM orders o
JOIN order_details od
ON o.ord_id = od.ord_id
GROUP BY MONTH
ORDER BY MONTH;

-- 3.5 How do order patterns vary across weekdays and weekends?
SELECT 
    CASE 
        WHEN DAYOFWEEK(order_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(ord_id) AS total_orders
FROM orders
GROUP BY day_type;

-- “Because the dataset does not contain any orders placed on weekends, so all orders are grouped under weekdays.”

-- 4️. Supplier Contribution
-- 4.1 How many suppliers are there in the database?
SELECT COUNT(*) AS total_suppliers
FROM supplier;

-- 4.2 Which supplier provides the most products?
SELECT 
s.sup_name,
COUNT(p.prod_id) AS total_products
FROM supplier s
JOIN products p
ON s.sup_id = p.sup_id
GROUP BY s.sup_name
ORDER BY total_products DESC;

-- 4.3 What is the average price of products from each supplier?
SELECT * FROM products;
SELECT * FROM supplier;
SELECT 
s.sup_name,
AVG(p.price) AS average_price
FROM supplier s
JOIN products p
ON s.sup_id = p.sup_id
GROUP BY s.sup_name;

-- 4.4 Which suppliers contribute the most to total product sales (by revenue)?
SELECT 
s.sup_name,
SUM(od.total_price) AS total_revenue
FROM supplier s
JOIN products p 
ON s.sup_id = p.sup_id
JOIN order_details od
ON p.prod_id = od.prod_id
GROUP BY s.sup_name
ORDER BY total_revenue DESC;

-- 5️. Employee Performance
-- 5.1 How many employees have processed orders?
SELECT * FROM orders;
SELECT COUNT(DISTINCT emp_id) AS active_employees
FROM orders;

-- 5.2 Which employees have handled the most orders?
select * from employees;
SELECT 
e.emp_name,
COUNT(o.ord_id) AS orders_handled
FROM employees e
JOIN orders o
ON e.emp_id = o.emp_id
GROUP BY e.emp_name
ORDER BY orders_handled DESC;

-- 5.3 What is the total sales value processed by each employee?
SELECT
e.emp_name,
SUM(od.total_price) AS total_sales_value
FROM employees e 
JOIN orders o 
ON e.emp_id  = o.emp_id
JOIN order_details od
ON o.ord_id = od.ord_id
GROUP BY e.emp_name;

-- 5.4 What is the average order value handled per employee?
SELECT * FROM orders;
SELECT * FROM employees;
SELECT 
e.emp_name,
AVG(order_total) AS average_order_value
FROM employees e
JOIN orders o 
ON e.emp_id = o.emp_id
JOIN (
SELECT
ord_id,
SUM(total_price) AS order_total
FROM order_details
GROUP BY ord_id
) t
ON o.ord_id = t.ord_id
GROUP BY e.emp_name;

-- 6️. Order Details Deep Dive
-- 6.1 What is the relationship between quantity ordered and total price?
SELECT * FROM order_details;
SELECT 
quantity,
total_price
FROM order_details;

-- 6.2 What is the average quantity ordered per product?
SELECT
p.prod_name,
AVG(od.quantity) AS average_quantity
FROM products p
JOIN order_details od
ON p.prod_id = od.prod_id
GROUP BY p.prod_name;

-- 6.3 How does the unit price vary across products and orders?
SELECT 
p.prod_name,
od.each_price,
od.total_price
FROM products p
JOIN order_details od
ON p.prod_id = od.prod_id;


SELECT * FROM products;