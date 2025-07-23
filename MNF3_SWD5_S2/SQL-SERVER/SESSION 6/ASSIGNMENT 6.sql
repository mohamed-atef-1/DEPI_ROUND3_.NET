
--1.Customer Spending Analysis
DECLARE @CustomerID INT = 1
DECLARE @TotalSpent DECIMAL(10,2)

SELECT 
    @TotalSpent = SUM(oi.quantity * oi.list_price )
FROM sales.orders O JOIN sales.order_items OI 
ON O.order_id = OI.order_id
WHERE O.customer_id = @CustomerID

IF @TotalSpent > 5000
    print 'VIP Customer'
ELSE
    print 'Regular Customer'

--------------------------------------------------------------------
--2.Product Price Threshold Report
DECLARE @Threshold INT = 1500
DECLARE @Product_Count INT

SELECT @Product_Count = COUNT(P.list_price)
FROM production.products P
WHERE P.list_price > @Threshold

PRINT 'ThreShold = $' + CAST(@Threshold AS VARCHAR(100))
PRINT 'Number of Products: ' + CAST(@Product_Count AS VARCHAR(100))

--------------------------------------------------------------------
--3.Staff Performance Calculator
DECLARE @StaffId INT = 2
DECLARE @SalesYear INT = 2017
DECLARE @TotelSales DECIMAL(10,2)

SELECT @TotelSales = SUM(oi.quantity * oi.list_price )
FROM sales.orders O JOIN sales.order_items OI 
ON O.order_id = OI.order_id
WHERE O.staff_id = @StaffId AND YEAR(O.order_date) = @SalesYear

SELECT @StaffId  Staff_ID,@SalesYear  Sales_Year,@TotelSales  Total_Sales

--------------------------------------------------------------------------

--4. Global Variables Information
SELECT @@SERVERNAME AS Server_Name, @@VERSION AS SQL_Version, @@ROWCOUNT AS Rows_Count

--------------------------------------------------------------------------
--5.Write a query that checks the inventory level for product ID 1 in store ID 1. Use IF statements to display different messages based on stock levels:

DECLARE @Quantity INT
SELECT @Quantity = S.quantity
FROM production.stocks S
WHERE product_id =1 AND store_id = 1

    IF @Quantity > 20
        PRINT 'Well stocked';
    ELSE IF @Quantity BETWEEN 10 AND 20
        PRINT 'Moderate stock';
    ELSE
        PRINT 'Low stock - reorder needed'

--------------------------------------------------------------------

--6.Create a WHILE loop that updates low-stock items (quantity < 5) in batches of 3 products at a time. Add 10 units to each product and display progress messages after each batch.
WHILE EXISTS (SELECT 1 FROM production.stocks WHERE quantity < 5)
BEGIN

    UPDATE TOP (3) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;

    PRINT 'Batch updated';
END

--------------------------------------------------------------------

--7. Product Price Categorization
SELECT P.product_name,P.list_price,
    CASE 
        WHEN P.list_price < 300 THEN 'Budget'
        WHEN P.list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN P.list_price BETWEEN 801 AND 2000 THEN 'Premium'
        WHEN P.list_price > 2000 THEN 'Luxury' 
    END Price_Category
FROM production.products P

--------------------------------------------------------------------

--8. Customer Order Validation
IF EXISTS (SELECT * FROM sales.customers WHERE customer_id = 5)
	SELECT C.customer_id,COUNT(*)  'Count of Orders'
	FROM sales.customers C JOIN sales.orders O
	ON C.customer_id = O.customer_id
	WHERE C.customer_id = 5
	GROUP BY C.customer_id
ELSE
	PRINT 'Customer Not Found'

	--------------------------------------------------------------------

--9. Shipping Cost Calculator Function
CREATE OR ALTER FUNCTION sales.CalculateShipping (@Order DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Shipping DECIMAL(10, 2)

    IF @Order > 100
        SET @Shipping = 0
    ELSE IF @Order BETWEEN 50 AND 99
        SET @Shipping = 5.99
    ELSE IF  @Order < 50
        SET @Shipping = 12.99

    RETURN @Shipping
END

SELECT sales.CalculateShipping (500.00)

--------------------------------------------------------------------

--10. Product Category Function
CREATE OR ALTER FUNCTION sales.GetProductsByPriceRange (@Min DECIMAL(10, 2),@Max DECIMAL(10, 2))
RETURNS TABLE
AS
RETURN
(
    SELECT P.product_name,P.list_price,B.brand_name,C.category_name
    FROM production.products P JOIN production.brands B ON P.brand_id = B.brand_id
    JOIN production.categories C ON P.category_id = C.category_id
    WHERE P.list_price BETWEEN @Min AND @Max
)

SELECT * FROM sales.GetProductsByPriceRange(500,1000)

--------------------------------------------------------------------

--11. Customer Sales Summary Function
CREATE or alter FUNCTION sales.GetCustomerYearlySummary (@CustomerID AS INT)
RETURNS @Summary TABLE 
(
 OrderYear INT,

 OrderCount INT,

 TotalAmount DECIMAL(10,2),

 AvgOrder DECIMAL(10,2)
)

AS

BEGIN

INSERT INTO @Summary
SELECT YEAR(O.order_date),COUNT(O.order_id),SUM(OI.list_price*OI.quantity),AVG(OI.list_price*OI.quantity)
FROM sales.customers C JOIN sales.orders O
ON C.customer_id = O.customer_id 
JOIN sales.order_items OI
ON O.order_id = OI.order_id
WHERE C.customer_id = @CustomerID
GROUP BY YEAR(O.order_date)

RETURN
END

SELECT * FROM sales.GetCustomerYearlySummary(1)

--------------------------------------------------------------------

--12. Discount Calculation Function
CREATE OR ALTER FUNCTION sales.Calculate_Discount (@Quantity INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Discount DECIMAL(10, 2)

    IF @Quantity BETWEEN 1 AND 2
        SET @Discount = 0.00
    ELSE IF @Quantity BETWEEN 3 AND 5
        SET @Discount = 0.05
    ELSE IF @Quantity BETWEEN 6 AND 9
        SET @Discount = 0.10
    ELSE IF @Quantity >= 10
        SET @Discount = 0.15

    RETURN @Discount
END

select sales.Calculate_Discount (50)

--------------------------------------------------------------------

--13. Customer Order History Procedure
CREATE OR ALTER PROCEDURE sales.sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE NULL,
    @EndDate DATE NULL ,
AS
BEGIN
     SELECT O.order_id,O.order_date,
    SUM(OI.quantity * OI.list_price) order_total
        FROM sales.orders O JOIN sales.order_items OI ON O.order_id = OI.order_id
        WHERE O.customer_id = @CustomerID AND O.order_date BETWEEN @StartDate AND @EndDate
         GROUP BY O.order_id,O.order_date  
END

EXEC sales.sp_GetCustomerOrderHistory 
    @CustomerID = 10,
    @StartDate = '2013-01-01',
    @EndDate = '2012-12-31';

--------------------------------------------------------------------

--14 Inventory Restock Procedure
CREATE OR ALTER PROCEDURE sales.sp_RestockProduct 
	@store_id INT,
    @product_id INT,
    @Restock_Quantity INT
AS
BEGIN

  SELECT S.quantity  'OLD Quantity',@Restock_Quantity+S.quantity  'New Quantity'
  FROM production.stocks S
  WHERE S.product_id = @product_id AND S.store_id = @store_id


  UPDATE production.stocks 
  SET quantity +=  @Restock_Quantity
  WHERE store_id = @store_id AND  product_id = @product_id
END

EXEC sales.sp_RestockProduct  4,5,44

--------------------------------------------------------------------

--15. Order Processing Procedure
CREATE PROCEDURE sp_ProcessNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Qty INT,
    @StoreID INT
AS
BEGIN
    BEGIN TRAN;
    BEGIN TRY
        DECLARE @Price MONEY;
        SELECT @Price = list_price FROM Products WHERE product_id = @ProductID;

        INSERT INTO Orders(customer_id, order_date, total_amount, staff_id, store_id)
        VALUES(@CustomerID, GETDATE(), @Price * @Qty, 1, @StoreID);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------------------------------------------------------------
--16. Dynamic Product Search Procedure
CREATE  OR ALTER PROCEDURE sales.sp_SearchProducts 
    @CategoryID INT,
    @Min DECIMAL(10,2),
    @Max DECIMAL(10,2)
AS
BEGIN
    SELECT * FROM production.products P
    WHERE p.category_id = @CategoryID AND P.list_price BETWEEN @Min AND @Max
END

EXEC sales.sp_SearchProducts 1, 500, 1000

--------------------------------------------------------------------

--17. Staff Bonus Calculation System
DECLARE @StartDate DATE = '2017-01-01';
DECLARE @EndDate DATE = '2017-03-31';

SELECT 
    S.staff_id, CONCAT(S.first_name, ' ', S.last_name) Staff_Name,
    SUM(OI.quantity * OI.list_price ) Total_Sales
FROM sales.staffs S
JOIN sales.orders O ON S.staff_id = O.staff_id
JOIN sales.order_items OI ON O.order_id = OI.order_id
WHERE O.order_date BETWEEN @StartDate AND @EndDate
GROUP BY S.staff_id, S.first_name, S.last_name;

--------------------------------------------------------------------

--18. Smart Inventory Management
SELECT P.product_name, C.category_name, S.quantity ,

    CASE 
        WHEN C.category_name = 'Bikes' AND S.quantity < 5 THEN 15
        WHEN C.category_name = 'Bikes' AND S.quantity <= 10 THEN 10
        WHEN C.category_name = 'Accessories' AND S.quantity < 3 THEN 20
     
    END AS Restockqty

FROM production.stocks S JOIN production.products P ON S.product_id = P.product_id
JOIN production.categories C ON P.category_id = C.category_id

--------------------------------------------------------------------

--19. Customer Loyalty Tier Assignment
SELECT C.customer_id,
    CONCAT(C.first_name, ' ', C.last_name) Customer_Name,
    SUM(OI.list_price) AS Total_Price,

    CASE 
        WHEN SUM(OI.list_price) >= 3000 THEN 'VIP'
        WHEN SUM(OI.list_price) >= 2000 THEN 'Gold'
        WHEN SUM(OI.list_price) >= 500 THEN 'Silver'
        WHEN SUM(OI.list_price) > 0 THEN 'Bronze'
        ELSE 'New Customer'
    END  Loyalty

FROM sales.customers C JOIN sales.orders O ON C.customer_id = O.customer_id
JOIN sales.order_items OI ON O.order_id = OI.order_id
GROUP BY C.customer_id, C.first_name, C.last_name

--------------------------------------------------------------------

--20. Product Lifecycle Management
CREATE OR ALTER PROCEDURE SALES.DiscontinueProduct
    @ProductID INT
AS
BEGIN
    UPDATE production.stocks
    SET quantity = 0
    WHERE product_id = @ProductID

    PRINT ' Product stock set to 0'
END

EXEC SALES.DiscontinueProduct 5