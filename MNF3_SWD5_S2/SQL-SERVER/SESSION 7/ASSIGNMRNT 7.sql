
--1.Create a non-clustered index on the email column in the sales.customers table to improve search performance when looking up customers by email.

CREATE NONCLUSTERED INDEX Customers_Email
ON sales.customers(email)
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--2.Create a composite index on the production.products table that includes category_id and brand_id columns to optimize searches that filter by both category and brand.

CREATE NONCLUSTERED INDEX Product_Category_Brand
ON production.products (category_id, brand_id)

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--3.Create an index on sales.orders table for the order_date column and include customer_id, store_id, and order_status as included columns to improve reporting queries.

CREATE NONCLUSTERED INDEX Order_OrderDate
ON sales.orders(order_date)
INCLUDE (customer_id, store_id, order_status)

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4.Create a trigger that automatically inserts a welcome record into a customer_log table whenever a new customer is added to sales.customers. (First create the log table, then the trigger)

CREATE OR ALTER TRIGGER Welcome_Customer
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.customer_log (customer_id, log_message)
    SELECT customer_id,'Welcome customer'
    FROM inserted 
END

  
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--5.Create a trigger on production.products that logs any changes to the list_price column into a price_history table, storing the old price, new price, and change date.

CREATE OR ALTER TRIGGER PriceChange
ON production.products
AFTER UPDATE
AS
BEGIN
    INSERT INTO production.price_history (product_id, old_price, new_price)
    SELECT I.product_id,D.list_price,I.list_price 
    FROM inserted I
    JOIN deleted D ON I.product_id = D.product_id
    WHERE I.list_price <> D.list_price
END


------------------------------------------------------------------------------------------------------------------------------------------------------------------

--6.Create an INSTEAD OF DELETE trigger on production.categories that prevents deletion of categories that have associated products. Display an appropriate error message.

CREATE OR ALTER TRIGGER PreventCategoryDelete
ON production.categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted D JOIN production.products P 
		ON P.category_id = D.category_id
    )
    BEGIN
        RAISERROR (' You cant delete category: Products are associated with this category.', 16, 1)
        RETURN
    END

    DELETE FROM production.categories
    WHERE category_id IN (SELECT category_id FROM deleted)
END


------------------------------------------------------------------------------------------------------------------------------------------------------------------

--7.Create a trigger on sales.order_items that automatically reduces the quantity in production.stocks when a new order item is inserted.

CREATE OR ALTER TRIGGER Update_Stock
ON sales.order_items
AFTER INSERT
AS
BEGIN
    UPDATE S
    SET S.quantity = S.quantity - I.quantity
    FROM production.stocks S JOIN inserted I 
	ON S.product_id = I.product_id;
END

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--8.Create a trigger that logs all new orders into an order_audit table, capturing order details and the date/time when the record was created.

CREATE OR ALTER TRIGGER Log_Order
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_audit (order_id, customer_id, store_id, staff_id, order_date, audit_timestamp)
    SELECT I.order_id, I.customer_id, I.store_id, I.staff_id, I.order_date, GETDATE()
    FROM inserted I
END