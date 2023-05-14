USE Hotel
GO



ALTER TABLE Orders ADD Estimated_Delivery_Date DATE
ALTER TABLE Orders DROP COLUMN Order_Estimated_Delivery_Date 


UPDATE Orders
SET Estimated_Delivery_Date = CONVERT(DATE,Order_Estimated_Delivery_Date)





--Total Revenue From OLIST ecommerce platform
SELECT ROUND(SUM(Payment_Value),2) AS Total_Revenue
FROM Order_Payment
LEFT JOIN Orders
ON Order_Payment.Order_Id = Orders.Order_Id
WHERE Order_Status NOT IN ('canceled', 'created')


--Change in revenue over time from OLIST ecommerce Platform
SELECT YEAR(Order_Date) AS Years, DATEPART(QUARTER,Order_Date) AS Quarters, DATEPART(MONTH,Order_Date) AS Months, ROUND(SUM(Payment_Value),2) AS Revenue
FROM Orders
LEFT JOIN Order_Payment
ON Orders.Order_Id = Order_Payment.Order_Id
WHERE Order_Status NOT IN ('canceled','created')
GROUP BY YEAR(Order_Date) ,DATEPART(QUARTER,Order_Date), DATEPART(MONTH,Order_Date)
ORDER BY Years, Quarters, Months




SELECT *
FROM Orders

SELECT *
FROM Order_Payment


--Total Number of Orders placed over-time on the ecommerce platform
SELECT DATEPART(YEAR,Order_Date) AS Years, DATEPART(QUARTER,Order_Date) AS Quarters, DATEPART(MONTH,Order_Date) AS Months, COUNT(*) AS Total_Number_of_Orders
FROM Orders
GROUP BY DATEPART(YEAR,Order_Date), DATEPART(QUARTER,Order_Date), DATEPART(MONTH,Order_Date)
ORDER BY Years, Quarters, Months

SELECT *
FROM Products


SELECT * 
FROM Order_Items

SELECT *
FROM Orders

SELECT *
FROM Product_Category

SELECT *
FROM Order_Payment

--Sales volume of each product category(Inner Join gives the same result)
SELECT Product_Category_Name_English AS Product_Category, COUNT(OD.Order_Id) AS Sales_Volume
FROM Product_Category AS PC
LEFT JOIN Products AS PRO
ON  PC.Product_Category_Name = PRO.Product_Category_Name
LEFT JOIN Order_Items AS OI
ON PRO.Product_Id = OI.product_id
LEFT JOIN Orders AS OD
ON OI.order_id = OD.Order_Id
GROUP BY Product_Category_Name_English
ORDER BY Sales_Volume DESC

--Average Order Value and how it varies by pament_method & Product Category

SELECT Payment_Type, ROUND(AVG(Payment_Value),2) AS Average_Order_Value
FROM Order_Payment AS OP
LEFT JOIN Orders AS OD
ON OP.Order_Id = OD.Order_Id
GROUP BY Payment_Type
ORDER BY Average_Order_Value DESC;




SELECT Product_Category_Name_English AS Product_Category, ROUND(AVG(Payment_Value),2) AS Average_Order_Value
FROM Order_Payment AS OP
LEFT JOIN Orders AS OD
ON OP.Order_Id = OD.Order_Id
GROUP BY Payment_Type
ORDER BY Average_Order_Value

SELECT *
FROM Sellers

SELECT *
FROM Orders

SELECT *
FROM Order_Payment

SELECT *
FROM Order_Items

ALTER TABLE Order_Items ADD Shipping_Time TIME
ALTER TABLE Order_Items DROP COLUMN Shipping_Time_Limit


UPDATE Order_Items
SET Shipping_Time = CONVERT(TIME,Shipping_Time_Limit)


--Active Sellers in a year for at least 3 Months and above
SELECT 
	YEAR(Order_Date) AS Year, 
	COUNT(DISTINCT Seller_ID) AS Active_Sellers,
	MIN(Order_Date) AS First_Purchase_Date,
	MAX(Order_Date) AS Last_Purchase_Date,
	ROUND(
	SUM(Payment_Value),2)AS REVENUE
FROM Orders AS OD
JOIN Order_Items AS OI
ON OD.Order_Id = OI.order_id
JOIN Order_Payment AS OP
ON OI.order_id = OP.Order_Id
WHERE OD.Order_Status <> 'canceled'
GROUP BY YEAR(Order_Date)
HAVING DATEDIFF(MONTH, MIN(Order_Date),MAX(Order_Date)) >= 3
ORDER BY Year


--Distribution of sellers ratings (This categorises the rating per year based on total orders and revenue)
SELECT  YEAR(Order_Date) AS Year, Review_Score,  COUNT(Order_Date) AS Total_Number_of_Orders, ROUND(SUM(Payment_Value),2) AS Total_Revenue_Based_on_Reviews
FROM Orders AS OD
JOIN Order_Reviews AS ORV
ON OD.Order_Id=ORV.Order_Id
JOIN Order_Payment OP
ON ORV.Order_Id=OP.Order_Id
GROUP BY YEAR(Order_Date), Review_Score
ORDER BY Year ASC, Review_Score DESC;

--Distribution of sellers ratings (This categorises the rating based on seller and average rating and total_orders)
SELECT DISTINCT(SL.Seller_ID), YEAR(Order_Date) As Year, COUNT(OI.Order_Id) AS Total_Orders, ROUND(AVG(ORR.Review_Score),1) AS Avg_Rating, ROUND(SUM(OP.Payment_Value),2) AS Revenue
FROM Sellers AS SL
LEFT JOIN Order_Items AS OI
ON SL.Seller_ID= OI.seller_id
LEFT JOIN Order_Reviews AS ORR
ON OI.order_id = ORR.Order_Id
LEFT JOIN Orders AS OD
ON ORR.Order_Id = OD.Order_Id
LEFT JOIN Order_Payment AS OP
ON OD.Order_Id=OP.Order_Id
WHERE OD.Order_Status <> 'canceled'
GROUP BY YEAR(Order_Date), SL.Seller_ID
ORDER BY Year, Avg_Rating DESC



--Repeat Customers on Olist
SELECT DISTINCT(Customer_Unique_Id), COUNT(Orders.Order_Id) AS total_no_of_Orders 
FROM Customers
INNER JOIN Orders
ON Customers.Customer_Id = Orders.Customer_Id
GROUP BY Customer_Unique_Id
HAVING COUNT(Orders.Order_Id) > 1
ORDER BY total_no_of_Orders DESC


--Average rating of products sold on Olist
SELECT Product_Category_Name_English, COUNT(OD.Order_Id) AS Total_Orders, ROUND(AVG(Review_Score),2) AS Average_Review_Score, ROUND(SUM(OP.Payment_Value),2) AS revenue
FROM Product_Category AS PC
INNER JOIN Products AS P
ON PC.Product_Category_Name=P.Product_Category_Name
INNER JOIN Order_Items AS OI
ON P.Product_Id = OI.product_id
INNER JOIN Orders AS OD
ON OI.order_id = OD.Order_Id
INNER JOIN Order_Payment AS OP
ON OD.Order_Id = OP.Order_Id
INNER JOIN Order_Reviews AS ORS
ON OP.Order_Id = ORS.Order_Id
GROUP BY Product_Category_Name_English
ORDER BY Total_Orders DESC


