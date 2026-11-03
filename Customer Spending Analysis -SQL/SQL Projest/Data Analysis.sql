-- 1. Customer Purchase Summary
-- For every customer, display the customer name, city, total number of orders, total spending, and average order
-- value. Include customers who have never placed an order.

SELECT customers.customer_name,customers.city,
COUNT(orders.order_id) AS total_orders,
sum(orders.amount) AS total_spending,
avg (orders.amount) AS AVG_order_value
FROM Customers LEFT JOIN orders
on customers.customer_id=orders.customer_id
group by customers.customer_id,customers.customer_name,customers.city;

-- 2. Top 5 High-Value Customers
-- Using completed orders only, find the five customers who generated the highest total revenue. Display customer
-- name, total spending, and number of completed orders

-- SELECT customers.customer_name,
-- sum(orders.amount) AS total_spending,
-- COUNT(orders.order_id) AS completed_orders
-- FROM customers
-- JOIN orders
-- ON customers.customer_id = orders.customer_id
-- WHERE orders.status ='completed'
-- GROUP BY customers.customer_id,customers.customer_name
-- ORDER BY total_spending DESC
-- LIMIT 5;

-- 3. City-Wise Revenue Analysis
-- Calculate completed sales revenue and the number of unique customers for each city. Sort the results from highest
-- to lowest revenue.

SELECT customers.city,
sum(orders.amount) AS total_revenue,
COUNT(distinct customers.customer_id) AS unique_customers
from customers
join orders 
on customers.customer_id = orders.customer_id
WHERE orders.status='completed'
GROUP BY customers.city
order by total_revenue DESC;

-- 4. Above-Average Spending Customers
-- Find customers whose total spending from completed orders is greater than the average customer spending across
-- all customers. Use a subquery to calculate the average.

-- SELECT
-- customers.customer_name,
-- SUM(orders.amount) AS total_spending
-- FROM customers
-- LEFT JOIN orders
-- ON customers.customer_id = orders.customer_id
-- AND orders.status = 'Completed'
-- GROUP BY
-- customers.customer_id,
-- customers.customer_name
-- HAVING SUM(orders.amount) >

-- (SELECT AVG(customer_total)
-- FROM (SELECT
-- customers.customer_id,
-- SUM(orders.amount) AS customer_total
-- FROM customers
-- LEFT JOIN orders
-- ON customers.customer_id = orders.customer_id
-- AND orders.status = 'Completed'
-- GROUP BY customers.customer_id) AS customer_spending);

-- 5. Monthly Revenue Trend
-- For each month, calculate completed sales revenue, total number of orders, and number of unique customers.
-- Arrange the results to identify the month with the highest revenue

SELECT
DATE_FORMAT(orders.order_date, '%Y-%m') AS order_month,
SUM(orders.amount) AS total_revenue,
COUNT(orders.order_id) AS total_orders,
COUNT(DISTINCT orders.customer_id) AS unique_customers
FROM orders
WHERE orders.status = 'Completed'
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
ORDER BY total_revenue DESC;

-- 6. Customers Who Never Purchased
-- Find customers who have never placed any order. Display their customer ID, name, city, and signup date.

-- SELECT
-- customers.customer_id,
-- customers.customer_name,
-- customers.city,
-- customers.signup_date
-- FROM customers
-- LEFT JOIN orders
-- ON customers.customer_id = orders.customer_id
-- WHERE orders.order_id IS NULL;

-- 7. Customers with Multiple Orders
-- Find customers with at least three completed orders. Show their completed order count, total spending, and
-- average order value.

-- SELECT
-- customers.customer_name,
-- COUNT(orders.order_id) AS completed_order_count,
-- SUM(orders.amount) AS total_spending,
-- AVG(orders.amount) AS average_order_value
-- FROM customers
-- INNER JOIN orders
-- ON customers.customer_id = orders.customer_id
-- WHERE orders.status = 'Completed'
-- GROUP BY customers.customer_id, customers.customer_name
-- HAVING COUNT(orders.order_id) >= 3;

-- 8. Highest-Spending Customer in Each City
-- Find the customer or customers with the highest completed-order revenue in each city. If multiple customers tie for
-- the highest revenue in a city, include all of them.

SELECT
 customer_id, 
 customer_name, 
 city, 
 total_revenue
FROM (
SELECT
customers.customer_id,
customers.customer_name,
customers.city,
SUM(orders.amount) AS total_revenue,
dense_rank() OVER (PARTITION BY customers.city ORDER BY SUM(orders.amount) DESC) as rnk
FROM customers 
JOIN orders  ON customers.customer_id = orders.customer_id
WHERE orders.status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name, customers.city
) ranked
WHERE rnk = 1;

-- 9. Order Value Above the Overall Average
-- Find orders whose amount is greater than the average amount of all orders, regardless of status. Display customer
-- name, order ID, order date, and amount.

-- SELECT
-- customers.customer_name,
-- orders.order_id,
-- orders.order_date,
-- orders.amount
-- FROM customers
-- JOIN orders
-- ON customers.customer_id = orders.customer_id
-- WHERE orders.amount > (
-- SELECT AVG(orders.amount)
-- FROM orders);

-- 10. Customer Segmentation Report
-- Calculate each customer's total revenue from completed orders and assign a segment: High Value = 50,000 or
-- more; Medium Value = 20,000 or more but less than 50,000; Low Value = less than 20,000, including
-- customers with no completed purchases. Then count the number of customers in each segment.

SELECT 
  customer_name,
  total_spending,
  CASE
    WHEN total_spending >= 50000 THEN 'High_value'
    WHEN total_spending >= 20000 THEN 'Medium_value'
    WHEN total_spending < 20000 THEN 'Low_value'
    ELSE 'no_details'
  END AS segment
FROM (
  SELECT
    customers.customer_name,
    COUNT(orders.order_id) AS completed_order_count,
    SUM(orders.amount) AS total_spending,
    AVG(orders.amount) AS average_order_value
  FROM customers 
  JOIN orders ON customers.customer_id = orders.customer_id
  WHERE orders.status = 'Completed'
  GROUP BY customers.customer_name
) AS summary;




