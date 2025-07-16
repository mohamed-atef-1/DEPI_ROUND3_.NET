
-- 1. Count total number of products
SELECT COUNT(*) AS total_products 
FROM production.products;

-- 2. Average, minimum, and maximum price of products
SELECT AVG(list_price) AS average_price, MIN(list_price) AS min_price, MAX(list_price) AS max_price 
FROM production.products;

-- 3. Count products in each category
SELECT category_id, COUNT(*) AS product_count 
FROM production.products 
GROUP BY category_id
ORDER BY category_id;

-- 4. Total number of orders for each store
SELECT store_id, COUNT(*) AS total_orders 
FROM sales.orders 
GROUP BY store_id
ORDER BY store_id;

-- 5. Customer names: uppercase first name, lowercase last name (first 10)
SELECT UPPER(first_name) AS first_name, LOWER(last_name) AS last_name 
FROM sales.customers 
ORDER BY customer_id OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 6. Product name and its length (first 10)
SELECT product_name, LEN(product_name) AS name_length 
FROM production.products 
ORDER BY product_id OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 7. Area code from phone number (customers 1–15)
SELECT customer_id, phone, LEFT(phone, 3) AS area_code 
FROM sales.customers 
WHERE customer_id BETWEEN 1 AND 15;

-- 8. Current date and year/month from order date (orders 1–10)

SELECT TOP 10 order_id, order_date, GETDATE() AS current_date_, YEAR(order_date) AS order_year, MONTH(order_date) AS order_month
FROM sales.orders
ORDER BY order_id;

-- 9. Join products with categories (first 10)
SELECT p.product_name, c.category_name 
FROM production.products p JOIN production.categories c 
ON p.category_id = c.category_id 
ORDER BY p.product_id OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 10. Join customers with orders (first 10 orders)
SELECT c.first_name + ' ' + c.last_name AS customer_name, o.order_date 
FROM sales.orders o JOIN sales.customers c 
ON o.customer_id = c.customer_id 
ORDER BY o.order_id OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 11. Products with brand names (include "No Brand" if null)
SELECT p.product_name, ISNULL(b.brand_name, 'No Brand') AS brand_name 
FROM production.products p LEFT JOIN production.brands b 
ON p.brand_id = b.brand_id;

-- 12. Products priced above average
SELECT product_name, list_price 
FROM production.products 
WHERE list_price > (SELECT AVG(list_price) FROM production.products);

-- 13. Customers who placed at least one order (subquery with IN)
SELECT customer_id, first_name + ' ' + last_name AS customer_name 
FROM sales.customers 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM sales.orders WHERE customer_id IS NOT NULL);

-- 14. Each customer and total number of orders (subquery in SELECT)
SELECT first_name + ' ' + last_name AS customer_name, 
(SELECT COUNT(*) FROM sales.orders o WHERE o.customer_id = c.customer_id) AS total_orders FROM sales.customers c;

-- 15. View: easy_product_list, then select products > 100
-- CREATE THE VIEW
CREATE OR ALTER VIEW easy_product_list AS
SELECT 
    p.product_name,
    c.category_name,
    p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;

-- Query the view to get products with price > 100
SELECT *
FROM easy_product_list
WHERE list_price > 100;

-- 16. View: customer_info, then find customers from CA
-- CREATE THE VIEW
CREATE OR ALTER VIEW customer_info AS
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    email,
    city + ', ' + state AS city_state
FROM sales.customers;

--Query the view to find all customers from California (CA)
SELECT *
FROM customer_info
WHERE city_state LIKE '%, CA';

-- 17. Products between $50 and $200
SELECT product_name, list_price 
FROM production.products 
WHERE list_price BETWEEN 50 AND 200 ORDER BY list_price ASC;

-- 18. Customers per state (ordered by count descending)
SELECT state, COUNT(*) AS customer_count 
FROM sales.customers 
GROUP BY state ORDER BY customer_count DESC;

-- 19. Most expensive product in each category
SELECT c.category_name, p.product_name, p.list_price 
FROM production.products p JOIN production.categories c 
ON p.category_id = c.category_id 
WHERE p.list_price = (SELECT MAX(p2.list_price) FROM production.products p2 WHERE p2.category_id = p.category_id);

-- 20. Stores and their cities with total number of orders
SELECT s.store_name, s.city, COUNT(o.order_id) AS order_count 
FROM sales.stores s LEFT JOIN sales.orders o 
ON s.store_id = o.store_id 
GROUP BY s.store_name, s.city;
