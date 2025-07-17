use StoreDB
go
-------------------------------------------------

--1.Write a query that classifies all products into price categories:

--Products under $300: "Economy"
--Products $300-$999: "Standard"
--Products $1000-$2499: "Premium"
--Products $2500 and above: "Luxury"

SELECT P.product_id,P.product_name,P.list_price,
CASE
  WHEN  P.list_price < 300 THEN 'Economy' 
  WHEN P.list_price BETWEEN 300 AND 999 THEN 'Standard'
  WHEN P.list_price BETWEEN 1000 AND 2499 THEN 'Premium'
  ELSE 'Luxur'
END price_categories
FROM production.products P

-------------------------------------------------

--2.Create a query that shows order processing information with user-friendly status descriptions:

--Status 1: "Order Received"
--Status 2: "In Preparation"
--Status 3: "Order Cancelled"
--Status 4: "Order Delivered"

-----Also add a priority level:

--Orders with status 1 older than 5 days: "URGENT"
--Orders with status 2 older than 3 days: "HIGH"
--All other orders: "NORMAL"

SELECT O.order_id ,O.order_date, O.order_status,
CASE O.order_status
	WHEN 1 THEN 'Order Received'
	WHEN 2 THEN 'In Preparation'
	WHEN 3 THEN 'Order Cancelled'
	WHEN 4 THEN 'Order Delivered'
END status_descriptions ,
CASE 
    WHEN O.order_status = 1 AND DATEDIFF(DAY, O.order_date, GETDATE()) > 5 THEN 'URGENT'
    WHEN O.order_status = 2 AND DATEDIFF(DAY, O.order_date, GETDATE()) > 3 THEN 'HIGH'
    ELSE 'NORMAL'
END  'priority_level'
FROM sales.orders O

-------------------------------------------------

--3.Write a query that categorizes staff based on the number of orders they've handled:

--0 orders: "New Staff"
--1-10 orders: "Junior Staff"
--11-25 orders: "Senior Staff"
--26+ orders: "Expert Staff"

SELECT S.staff_id , COUNT(O.order_id) AS Count_Orders ,
CASE 
	WHEN COUNT(O.order_id) = '0' THEN 'New Staff'
	WHEN COUNT(O.order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'
	WHEN COUNT(O.order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
    ELSE 'Expert Staff'
END Staff_Category
FROM sales.staffs S LEFT JOIN sales.orders O
ON S.staff_id=O.staff_id
GROUP BY S.staff_id

-------------------------------------------------

--4.Create a query that handles missing customer contact information:

--Use ISNULL to replace missing phone numbers with "Phone Not Available"
SELECT C.customer_id , ISNULL(C.phone,'Phone Not Available') Phone
FROM sales.customers C
    
--Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
SELECT C.customer_id , COALESCE(C.phone,C.email,'No Contact Method') preferred_contact
FROM sales.customers C

-------------------------------------------------

--5.Write a query that safely calculates price per unit in stock:

--Use NULLIF to prevent division by zero when quantity is 0
--Use ISNULL to show 0 when no stock exists
--Include stock status using CASE WHEN
--Only show products from store_id = 1

SELECT S.store_id,P.product_name,P.list_price,S.quantity , 
ISNULL(P.list_price / NULLIF(s.quantity, 0),0)  price_per_unit
FROM production.products P JOIN production.stocks S
ON P.product_id= S.product_id
WHERE S.store_id='1'

-------------------------------------------------

--6.Create a query that formats complete addresses safely:

--Use COALESCE for each address component
--Create a formatted_address field that combines all components
--Handle missing ZIP codes gracefully

SELECT C.customer_id, 
    COALESCE(C.street, '-') + ', ' +
    COALESCE(C.city, '-') + ', ' +
    COALESCE(C.state, '-') + ', ' +
    COALESCE(C.zip_code, '-') Address
FROM sales.customers C

-------------------------------------------------

--7.Use a CTE to find customers who have spent more than $1,500 total:

--Create a CTE that calculates total spending per customer
--Join with customer information
--Show customer details and spending
--Order by total_spent descending

WITH Customer_Spending AS (
SELECT O.customer_id ,
SUM(OI.list_price * OI.quantity ) TOTAL_SPENT
FROM sales.orders O JOIN sales.order_items OI
ON O.order_id=OI.order_id
GROUP BY O.customer_id
)
SELECT C.customer_id,CONCAT(C.first_name,' ',C.last_name) FULL_NAME,CS.TOTAL_SPENT
FROM Customer_Spending CS JOIN sales.customers C
ON CS.Customer_id=C.customer_id
WHERE CS.TOTAL_SPENT> 1500
ORDER BY CS.TOTAL_SPENT ASC

-------------------------------------------------

--8.Create a multi-CTE query for category analysis:

--CTE 1: Calculate total revenue per category
--CTE 2: Calculate average order value per category
--Main query: Combine both CTEs
--Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"

WITH Total_Revenue AS(
SELECT P.category_id , SUM(OI.list_price * OI.quantity ) TotalRevenu
FROM sales.order_items OI JOIN production.products P
ON OI.product_id=P.product_id
GROUP BY P.category_id
),

 AverageOrder AS(
SELECT P.category_id , AVG(OI.list_price * OI.quantity ) AvgOrder
FROM sales.order_items OI JOIN production.products P
ON OI.product_id=P.product_id
GROUP BY P.category_id
)

SELECT TR.category_id,TR.TotalRevenu,AO.AvgOrder,
CASE
    WHEN TR.TotalRevenu > 50000 THEN 'Excellent'
    WHEN TR.TotalRevenu > 20000 THEN 'Good'
    ELSE 'Needs Improvement'
END Rate_Performance
FROM Total_Revenue TR JOIN AverageOrder AO
ON TR.category_id=AO.category_id


-------------------------------------------------

--9.Use CTEs to analyze monthly sales trends:

--CTE 1: Calculate monthly sales totals
--CTE 2: Add previous month comparison
--Show growth percentage
  
 WITH Month_Sales AS (
    SELECT 
        MONTH(O.order_date)  Sales_Month ,
		SUM(OI.list_price * OI.quantity )  Total_Sales
    FROM sales.orders O 
    JOIN sales.order_items OI ON O.order_id = OI.order_id
    GROUP BY MONTH(O.order_date)
)

SELECT *
FROM Month_Sales MS
ORDER BY MS.Sales_Month

-------------------------------------------------

--10.Create a query that ranks products within each category:
  
--Use ROW_NUMBER() to rank by price (highest first)
SELECT c.category_id,p.product_name,p.list_price,
    ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) Row_Num
FROM production.categories c JOIN production.products p 
ON c.category_id = p.category_id
  
--Use RANK() to handle ties
 SELECT c.category_id,p.product_name,p.list_price,
    RANK() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) Rank_Price
FROM production.categories c JOIN production.products p 
ON c.category_id = p.category_id

--Use DENSE_RANK() for continuous ranking
  WITH DenseRank AS (
  SELECT c.category_id,p.product_name,p.list_price,
    DENSE_RANK() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) Dense_Price
FROM production.categories c JOIN production.products p 
ON c.category_id = p.category_id
  )
   SELECT *
   FROM DenseRank DR 
   WHERE DR.Dense_Price <= 3

-------------------------------------------------

--11.Rank customers by their total spending:

--Calculate total spending per customer
--Use RANK() for customer ranking
--Use NTILE(5) to divide into 5 spending groups
--Use CASE for tiers: 1="VIP", 2="Gold", 3="Silver", 4="Bronze", 5="Standard"

WITH Customer_Spending AS (
SELECT O.customer_id ,
SUM(OI.list_price * OI.quantity ) TOTAL_SPENT
FROM sales.orders O JOIN sales.order_items OI
ON O.order_id=OI.order_id
GROUP BY O.customer_id
),
RANK_CUST AS (
    SELECT CS.customer_id,CS.TOTAL_SPENT,
        RANK() OVER (ORDER BY CS.TOTAL_SPENT DESC)  spending_rank,
        NTILE(5) OVER (ORDER BY CS.TOTAL_SPENT DESC)  spending_group
    FROM Customer_Spending CS
)

SELECT C.customer_id,CONCAT(C.first_name,' ',C.last_name) FULL_NAME,RC.spending_rank,RC.spending_group,
CASE RC.spending_group
	WHEN 1 THEN 'VIP'
	WHEN 2 THEN 'Gold'
	WHEN 3 THEN 'Silver'
	WHEN 4 THEN 'Bronze'
	WHEN 5 THEN 'Standard'
END Tiers
FROM sales.customers C JOIN RANK_CUST RC 
ON C.customer_id=RC.customer_id
ORDER BY RC.TOTAL_SPENT DESC

-------------------------------------------------

--12.Create a comprehensive store performance ranking:

--Rank stores by total revenue
--Rank stores by number of orders
--Use PERCENT_RANK() to show percentile performance

WITH StoreRevenue AS (
    SELECT S.store_id,S.store_name,
      SUM(OI.quantity * OI.list_price ) Total_Revenue,
      COUNT(O.order_id) Total_Orders
    FROM sales.stores S JOIN sales.orders O 
	ON S.store_id = O.store_id
    JOIN sales.order_items OI 
	ON O.order_id = OI.order_id
    GROUP BY S.store_id, S.store_name
),
Ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY SR.Total_Revenue DESC)  Revenue_Rank,
        RANK() OVER (ORDER BY SR.Total_Revenue DESC)  Order_Rank,
        PERCENT_RANK() OVER (ORDER BY SR.Total_Revenue)  Revenue_Percentile
    FROM StoreRevenue SR
)
SELECT * FROM Ranked

-------------------------------------------------

--13.Create a PIVOT table showing product counts by category and brand:

--Rows: Categories
--Columns: Top 4 brands (Electra, Haro, Trek, Surly)
--Values: Count of products

SELECT *
FROM (
    SELECT C.category_name,B.brand_name
    FROM production.products P
    JOIN production.categories C ON P.category_id = C.category_id
    JOIN production.brands B ON P.brand_id = B.brand_id
    WHERE B.brand_name IN ('Nike', 'Adidas', 'Ralph Lauren', 'Gap') 
)  Source_Data
PIVOT (
    COUNT(brand_name)
    FOR brand_name IN ([Nike], [Adidas], [Ralph Lauren], [Gap])
) AS Pivot_Table

-------------------------------------------------

--14.Create a PIVOT showing monthly sales revenue by store:

--Rows: Store names
--Columns: Months (Jan through Dec)
--Values: Total revenue
--Add a total column

SELECT 
    store_name,
    ISNULL([1], 0) Jan,
    ISNULL([2], 0) Feb,
    ISNULL([3], 0)  Mar,
    ISNULL([4], 0)  Apr,
    ISNULL([5], 0)  May

FROM (
    SELECT 
        s.store_name,
        MONTH(o.order_date)  sale_month,
        oi.quantity * oi.list_price  revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN sales.stores s ON o.store_id = s.store_id
) Source_Data

PIVOT (
    SUM(revenue)
    FOR sale_month IN ([1], [2], [3], [4], [5])
) Pivot_Table

-------------------------------------------------

--15.PIVOT order statuses across stores:

--Rows: Store names
--Columns: Order statuses (Pending, Processing, Completed, Rejected)
--Values: Count of orders

SELECT store_name,
    ISNULL([1], 0)  Pending,
    ISNULL([2], 0)  Processing,
    ISNULL([3], 0)  Rejected,
    ISNULL([4], 0)  Completed
FROM (
    SELECT S.store_name, O.order_status
    FROM sales.orders O JOIN sales.stores S 
	ON O.store_id = S.store_id
) Source_Table
PIVOT (
    COUNT(order_status)
    FOR order_status IN ([1], [2], [3], [4])
) Pivot_Table

-------------------------------------------------

--16.Create a PIVOT comparing sales across years:

--Rows: Brand names
--Columns: Years (2016, 2017, 2018)
--Values: Total revenue
--Include percentage growth calculations

SELECT *,
    ROUND(([2017] - [2016]) * 100.0 / NULLIF([2016], 0), 2) AS Growth_2016_2017_Percent,
    ROUND(([2018] - [2017]) * 100.0 / NULLIF([2017], 0), 2) AS Growth_2017_2018_Percent
FROM (
    SELECT *
    FROM (
        SELECT 
            b.brand_name,
            YEAR(o.order_date) AS sales_year,
            SUM(oi.quantity * oi.list_price) AS revenue
        FROM sales.orders o 
        JOIN sales.order_items oi ON o.order_id = oi.order_id
        JOIN production.products p ON oi.product_id = p.product_id
        JOIN production.brands b ON p.brand_id = b.brand_id
        GROUP BY b.brand_name, YEAR(o.order_date)
    ) YearSales

    PIVOT (
        SUM(revenue)
        FOR sales_year IN ([2016], [2017], [2018])
    )  Pivot_Table
) result

-------------------------------------------------

--17.Use UNION to combine different product availability statuses:

--Query 1: In-stock products (quantity > 0)
--Query 2: Out-of-stock products (quantity = 0 or NULL)
--Query 3: Discontinued products (not in stocks table)

SELECT P.product_name,S.quantity
FROM production.products P INNER JOIN production.stocks S
ON P.product_id = S.product_id
WHERE S.quantity > 0
UNION

SELECT P.product_name,S.quantity
FROM production.products P JOIN production.stocks S
ON P.product_id = S.product_id
WHERE S.quantity = 0 OR S.quantity IS NULL
UNION

SELECT P.product_name,S.quantity
FROM production.products P JOIN production.stocks S
ON P.product_id = S.product_id
WHERE S.product_id IS NULL

-------------------------------------------------

--18.Use INTERSECT to find loyal customers:

--Find customers who bought in both 2017 AND 2018
--Show their purchase patterns

SELECT C.customer_id,CONCAT(C.first_name,' ',C.last_name) FULL_NAME,O.order_id
FROM sales.customers C JOIN sales.orders O
ON C.customer_id = O.customer_id
WHERE YEAR(O.order_date) = 2017
INTERSECT
SELECT C.customer_id,CONCAT(C.first_name,' ',C.last_name) FULL_NAME,O.order_id
FROM sales.customers C JOIN sales.orders O
ON C.customer_id = O.customer_id
WHERE YEAR(O.order_date) = 2018

-------------------------------------------------

--19.Use multiple set operators to analyze product distribution:

--INTERSECT: Products available in all 3 stores
--EXCEPT: Products available in store 1 but not in store 2
--UNION: Combine above results with different labels

SELECT P.product_id,P.product_name,S.store_id  
FROM  production.stocks S join production.products P
ON P.product_id=S.product_id
WHERE S.store_id = 1

INTERSECT

SELECT P.product_id,P.product_name,S.store_id  
FROM  production.stocks S join production.products P
ON P.product_id=S.product_id
WHERE S.store_id = 2

INTERSECT

SELECT P.product_id,P.product_name,S.store_id  
FROM  production.stocks S join production.products P
ON P.product_id=S.product_id
WHERE S.store_id = 3

UNION

SELECT P.product_id,P.product_name,S.store_id   
FROM  production.stocks S join production.products P
ON P.product_id=S.product_id
WHERE store_id = 1

EXCEPT

SELECT P.product_id,P.product_name,S.store_id  
FROM  production.stocks S join production.products P
ON P.product_id=S.product_id
WHERE store_id = 2

-------------------------------------------------

--20.Complex set operations for customer retention:

--Find customers who bought in 2016 but not in 2017 (lost customers)
--Find customers who bought in 2017 but not in 2016 (new customers)
--Find customers who bought in both years (retained customers)
--Use UNION ALL to combine all three groups

SELECT O.customer_id,O.order_id,O.order_date
FROM sales.orders O
WHERE YEAR(O.order_date) = 2016

EXCEPT

SELECT O.customer_id,O.order_id,O.order_date
FROM sales.orders O
WHERE YEAR(O.order_date) = 2017

UNION ALL
  --Find customers who bought in 2017 but not in 2016 (new customers)
  SELECT O.customer_id,O.order_id,O.order_date
FROM sales.orders O
WHERE YEAR(O.order_date) = 2017

EXCEPT

SELECT O.customer_id,O.order_id,O.order_date
FROM sales.orders O
WHERE YEAR(O.order_date) = 2016

UNION ALL
  --Find customers who bought in both years 
  SELECT O.customer_id,O.order_id,O.order_date
FROM sales.orders O
WHERE YEAR(O.order_date) IN (2016,2017)



