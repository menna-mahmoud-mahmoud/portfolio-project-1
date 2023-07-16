
/*
  Data exploration of orders made at the Olist store (a Brazilian e-commerce website)

  skills used: Aggregate Functions, Converting Data Types, Joins, Windows Functions,
               CTE(Common Table Expressions), Temporary Tables, Creating Views
*/




-- Select the data that we are going to start with.

SELECT 
  order_id,
   payment_type,
   payment_installments,
   payment_value
FROM 
  olist_order_payments_dataset





-- Finding out the top 10 installments customers usually choose to pay in.

SELECT
   TOP 10 payment_installments, 
   COUNT(payment_installments) AS count_installments
FROM 
  olist_order_payments_dataset
GROUP BY 
   payment_installments
ORDER BY 
   count_installments DESC;




-- Discover the correlation between installments and payment value.

SELECT 
   payment_installments, 
   AVG(payment_value) AS avg_payment
FROM 
  olist_order_payments_dataset
GROUP BY 
   payment_installments
ORDER BY 
   avg_payment




-- Discover relationship between product weight and price using join

SELECT DISTINCT
  items.product_id, items.price, cast(product.product_weight_g as int) AS weight
FROM 
   olist_order_items_dataset as items
JOIN 
   olist_products_dataset as product
   ON items.product_id = product.product_id
WHERE 
   product.product_weight_g is not null
ORDER BY 
   items.price, weight;




-- using CTE(Common Table Expressions) to store the sum of each seller profit from different products in different orders
-- Then calculating percentage of each product in the total profit of each seller 

WITH sellerProfit AS
(
SELECT 
  order_id, product_id, price, seller_id, sum(price) over(partition by seller_id) AS profit
FROM 
 olist_order_items_dataset
 )

SELECT DISTINCT
 product_id, seller_id, profit, (price/profit)*100 AS percentage
FROM 
 sellerProfit




-- using temporary table to store the profit of each category

CREATE TABLE categoryProfit(
  product_id  nvarchar(255),
  product_category_name  nvarchar(255),
  profit numeric 
) 

INSERT INTO categoryProfit
SELECT DISTINCT
  product.product_id, product.product_category_name, sum(profit.price)over(partition by profit.product_id) AS profit
FROM olist_products_dataset AS product
JOIN olist_order_items_dataset AS profit
ON product.product_id = profit.product_id
SELECT * FROM categoryProfit




-- creating a view to store the most profitable categories for later visualizations
-- translate the category name from Portuguese to English

CREATE VIEW mostProfitableCategory AS 
SELECT DISTINCT
  t.column2 AS category, sum(c.profit)over(partition by t.column2) AS profit
FROM categoryProfit AS c
JOIN product_category_name_translation AS t
ON t.column1 = c.product_category_name
ORDER BY profit desc offset 0 rows 
