	
-- Import database 
USE RFM_Sales_Analysis

-- Exploring Data 
SELECT * FROM sales_data

-- Checking unique values 
SELECT DISTINCT STATUS FROM sales_data 						
SELECT DISTINCT YEAR_ID FROM sales_data
SELECT DISTINCT PRODUCTLINE FROM sales_data 				
SELECT DISTINCT COUNTRY FROM sales_data						
SELECT DISTINCT DEALSIZE FROM sales_data					
SELECT DISTINCT TERRITORY FROM sales_data

-- # ===================================== Preliminary Analysis ===================================== #

-- Que 1. What is the Total sales across different countries.
SELECT ROUND(SUM(SALES),0) FROM sales_data

-- Total sales generated is 10032629.
----------------------------------------------------------------------------------------------------------------------------------

-- Que 2. Find the Total number of orders.
SELECT COUNT(DISTINCT ORDERNUMBER) FROM sales_data

-- Total 307 orders are placed. 
----------------------------------------------------------------------------------------------------------------------------------

-- Que 3. From which countries the orders are usually placed.
SELECT COUNT(DISTINCT COUNTRY) FROM sales_data

-- From 19 countries variety of orders are placed.
----------------------------------------------------------------------------------------------------------------------------------

-- Que 4. Find out the Unique Customers.
SELECT COUNT(DISTINCT CUSTOMERNAME) FROM sales_data

-- A total of 92 unique customers order products.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 5. Find the sales of all the products sold.

SELECT PRODUCTLINE, SUM(SALES) AS Revenue
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY Revenue DESC ;

-- Classic Cars and Vintage cars are high selling products.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 6. Find the sales against all deal size. 

SELECT DEALSIZE, SUM(SALES) AS Revenue
FROM sales_data
GROUP BY DEALSIZE
ORDER BY Revenue DESC;

-- Medium size is the highest selling deal size.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 7. Find the count of distinct status of orders and their respective percentages.

SELECT STATUS, COUNT(STATUS) AS Status_Count, 
	COUNT(STATUS)*100 /(SELECT COUNT(STATUS) FROM sales_data) AS Percent_Count
FROM sales_data
GROUP BY STATUS ;

-- 92% of products are shipped, whereas only 2% are cancelled.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 8. Which is the Best Selling Year? 

SELECT YEAR_ID, ROUND(SUM(SALES),3) AS Revenue
FROM sales_data
GROUP BY YEAR_ID
ORDER BY Revenue DESC;

-- 2004 is the best selling year.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 9. Find out the percent changes in revenue from year to year. 

WITH SalesByYear AS (
    SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS Revenue
    FROM sales_data
    GROUP BY YEAR_ID
)

SELECT 
    YEAR_ID, 
    Revenue, 
    LAG(Revenue) OVER (ORDER BY YEAR_ID) AS PreviousYearSales,
    CASE 
        WHEN LAG(Revenue) OVER (ORDER BY YEAR_ID) IS NULL THEN NULL
        ELSE ROUND(((Revenue - LAG(Revenue) OVER (ORDER BY YEAR_ID)) / LAG(Revenue) OVER (ORDER BY YEAR_ID)) * 100, 2)
    END AS Percent_Difference
FROM SalesByYear;

-- From 2003 to 2004, the sales have increase by 34.32%, whereas from 2004 to 2005 the sales have dropped by 62.08%. 
----------------------------------------------------------------------------------------------------------------------------------

-- Que 10. What was the best month for sales in a specific year and how much amount was earned in that month? 

SELECT MONTH_ID ,ROUND(SUM(SALES),3) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM sales_data
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC ;

-- November in 2003 and 2004 is best reven generating month i.e Nov is the best selling month

----------------------------------------------------------------------------------------------------------------------------------

-- # Que 11. What product is sold in November?

SELECT MONTH_ID , PRODUCTLINE, ROUND(SUM(SALES),3) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM sales_data
WHERE MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC ;

-- Best product is classic car in 2003 and 2004

----------------------------------------------------------------------------------------------------------------------------------

-- Que 12. Sales across the city, country and its repespective price.

SELECT COUNTRY, CITY, ROUND(SUM(SALES),3) as Revenue 
FROM sales_data
GROUP BY COUNTRY, CITY
ORDER BY Revenue DESC;

----------------------------------------------------------------------------------------------------------------------------------

-- Que 13. Find out the Top 5 High Revenue generating Countries.

SELECT DISTINCT TOP 5 COUNTRY, ROUND(SUM(SALES),3) as Revenue 
FROM sales_data
GROUP BY COUNTRY
ORDER BY Revenue DESC;

-- USA, Spain and France are top 3 high revenue generating countries.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 14. Which is the Highest Product Selling in Countries according to sales.

WITH RankedSales AS (
    SELECT 
        COUNTRY, 
        PRODUCTLINE, 
        ROUND(SUM(SALES), 3) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY SUM(SALES) DESC) AS rn
    FROM sales_data
    GROUP BY COUNTRY, PRODUCTLINE ) ,
TopProducts AS (
    SELECT COUNTRY, PRODUCTLINE, Revenue
    FROM RankedSales
    WHERE rn = 1 )

SELECT DISTINCT TOP 5 COUNTRY, PRODUCTLINE, Revenue
FROM TopProducts
ORDER BY Revenue DESC;

-- Classic cars is the most sold product across all the top revenue generating countries.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 15. Find out the High Revenue Cities.

SELECT DISTINCT TOP 5 CITY , ROUND(SUM(SALES),3) as Revenue
FROM sales_data
GROUP BY CITY
ORDER BY Revenue DESC;

-- Madrid, San Rafael and NYC are the top 3 high revenue generating cities.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 16. High Revenue generating cities and most sold product corresponding to it.

WITH RankedSales AS (
    SELECT 
        CITY, 
        PRODUCTLINE, 
        ROUND(SUM(SALES), 3) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY SUM(SALES) DESC) AS rn
    FROM sales_data
    GROUP BY CITY, PRODUCTLINE ) ,
TopProducts AS (
    SELECT CITY, PRODUCTLINE, Revenue
    FROM RankedSales
    WHERE rn = 1 )

SELECT DISTINCT TOP 5 CITY, PRODUCTLINE, Revenue
FROM TopProducts
ORDER BY Revenue DESC;

-- Classic cars is the common product sold across top 5 cities.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 17. Which territories are highest and lowest sales generating.

SELECT TERRITORY, ROUND(SUM(SALES),3) as Revenue
FROM sales_data
GROUP BY TERRITORY
ORDER BY Revenue DESC;

-- The EMEA territory should be focused more upon.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 18. Analyze the Quaterly Sold Product and its corresponding sales stats.

SELECT QTR_ID, COUNT(QTR_ID) AS Quarterly_Quantity_Sold, 
	COUNT(QTR_ID)*100 /(SELECT COUNT(QTR_ID) FROM sales_data) AS Percent_Quantity_Sold,
	ROUND(SUM(SALES),2) as Quaterly_Revenue,
	ROUND(SUM(SALES)*100 / (SELECT SUM(SALES) FROM sales_data),2) AS Percent_Sales
FROM sales_data
GROUP BY QTR_ID
ORDER BY Quaterly_Revenue DESC;

-- The fourth quarter of the year sold the highest product with 38.62% sales for all the years.

----------------------------------------------------------------------------------------------------------------------------------

-- Que 19. Find the Yearly Sales of all Products. 

SELECT DISTINCT PRODUCTLINE, YEAR_ID, ROUND(SUM(SALES),2) AS Revenue
FROM sales_data
GROUP BY PRODUCTLINE, YEAR_ID
ORDER BY PRODUCTLINE, YEAR_ID;

----------------------------------------------------------------------------------------------------------------------------------

-- Que 20. Yearly Difference in Sales for particular product.

WITH SalesData AS (
    SELECT PRODUCTLINE, YEAR_ID, SUM(SALES) AS Revenue,
        LAG(SUM(SALES)) OVER (PARTITION BY PRODUCTLINE ORDER BY YEAR_ID) AS PreviousYearSales
    FROM sales_data
	GROUP BY PRODUCTLINE, YEAR_ID
)
SELECT 
    PRODUCTLINE,
    YEAR_ID,
	ROUND(Revenue,2) AS Yearly_Sales,
    ROUND(PreviousYearSales,2) AS Previous_Year_Sale,
    CASE 
        WHEN PreviousYearSales IS NULL THEN NULL
        ELSE ROUND(((Revenue - PreviousYearSales) / PreviousYearSales) * 100, 2)
    END AS Percent_Difference
FROM SalesData
-- WHERE PRODUCTLINE='Planes' 
ORDER BY PRODUCTLINE, YEAR_ID;

-- The negative since indicates that the sales have decreased from previous year.

----------------------------------------------------------------------------------------------------------------------------------

-- # ===================================== RFM Analysis ===================================== #

-- Que 21. Find out the Best Customers using RFM Analysis.

DROP TABLE IF EXISTS #RFM                                  
WITH RFM AS
	(
		SELECT 
			CUSTOMERNAME, 
			ROUND(SUM(SALES),3) AS Monetary_Value,
			ROUND(AVG(SALES),3) AS Avg_Monetary_Value,
			COUNT(ORDERNUMBER) AS Frequency,
			MAX(ORDERDATE) AS Last_order_date,
			(SELECT MAX(ORDERDATE) FROM sales_data) AS Max_order_date,
			DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM sales_data)) as Recency
	FROM sales_data
	GROUP BY CUSTOMERNAME 
	), 
RFM_CALC AS
	( 
		SELECT r.*,
			NTILE(4) OVER (ORDER BY Recency DESC) RFM_Recency,
			NTILE(4) OVER (ORDER BY Frequency) RFM_Frequency,		
			NTILE(4) OVER (ORDER BY Monetary_Value) RFM_Monetary
		FROM RFM r 
	)

SELECT C.*, RFM_Recency + RFM_Frequency + RFM_Monetary AS RFM_CELL,
CAST(RFM_Recency AS VARCHAR) + CAST(RFM_Frequency AS VARCHAR) + CAST(RFM_Monetary AS VARCHAR) AS RFM_CELL_CODE
INTO #RFM
FROM RFM_CALC C ;

SELECT * FROM #RFM ;
-- We can see the closer the last order date is to max order date the higher is the recency


-- # ===================================== Segmentation Analysis  ===================================== #

SELECT CUSTOMERNAME, RFM_Recency, RFM_Frequency , RFM_Monetary, 
	CASE
		WHEN RFM_CELL_CODE in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost Customers'  --lost customers
		WHEN RFM_CELL_CODE  in (133, 134, 143, 244, 334, 343, 344, 144, 234) THEN 'Slipping Away, Cant Lose' -- Big spenders who haven’t purchased lately and slipping away
		WHEN RFM_CELL_CODE in (311, 411, 331,412,423) THEN 'New Customers'
		WHEN RFM_CELL_CODE  in (222, 223, 233, 322, 232, 221) THEN 'Potential Churners'
		WHEN RFM_CELL_CODE  in (323, 333,321, 422, 332, 432, 421) THEN 'Active' --(Customers who buy often & recently, but at low price points)
		WHEN RFM_CELL_CODE  in (433, 434, 443, 444) THEN 'Loyal'
	END Customer_Status
FROM #RFM;

----------------------------------------------------------------------------------------------------------------------------------

-- Que 22. Find the percentage of each segments 

SELECT CUSTOMERNAME, RFM_Recency, RFM_Frequency , RFM_Monetary, 
	CASE
		WHEN RFM_CELL_CODE in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost Customers'  --lost customers
		WHEN RFM_CELL_CODE in (133, 134, 143, 244, 334, 343, 344, 144, 234) THEN 'Slipping Away, Cant Lose' -- Big spenders who haven’t purchased lately and slipping away
		WHEN RFM_CELL_CODE in (311, 411, 331,412,423) THEN 'New Customers'
		WHEN RFM_CELL_CODE in (222, 223, 233, 322, 232, 221) THEN 'Potential Churners'
		WHEN RFM_CELL_CODE in (323, 333,321, 422, 332, 432, 421) THEN 'Active' --(Customers who buy often & recently, but at low price points)
		WHEN RFM_CELL_CODE in (433, 434, 443, 444) THEN 'Loyal'
	END Customer_Status
INTO #SEGMENTS
FROM #RFM;

SELECT * FROM #SEGMENTS

SELECT Customer_Status, COUNT(Customer_Status)*100 / (SELECT COUNT(Customer_Status) FROM #SEGMENTS) AS Percenta
FROM #SEGMENTS
GROUP BY Customer_Status

-- The company has lost 22% of customers and has only 15% loyal customers.

--------------------------------------------------------------------------------------------------------------------------------

-- Que 23. Which products are more often sold together?  (Often Selling Product Combinations) 

SELECT DISTINCT ORDERNUMBER, STUFF(
			(SELECT ',' + PRODUCTCODE
			FROM sales_data p
			WHERE ORDERNUMBER IN
					(SELECT ORDERNUMBER
					 FROM
							(SELECT ORDERNUMBER, COUNT(*) AS Order_Number
							 FROM sales_data
							 WHERE STATUS = 'Shipped'
							 GROUP BY ORDERNUMBER) AS Order_Info
					 WHERE Order_Number = 2
					)
			AND p.ORDERNUMBER = s.ORDERNUMBER
			FOR XML PATH ('') 
			), 
		    1,1 , '') AS Product_Codes
FROM sales_data s
ORDER BY 2 DESC ;

--x-------------------------------------------------x--------------------------------------------------x------------------------