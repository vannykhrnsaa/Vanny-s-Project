--Product&Sales Analysis
---1. Product by the Total Sales (Revenue)
SELECT p.product_id, p.product_name,
SUM(os.quantity*os.price_at_order) AS TotalSales
FROM products AS p
JOIN order_sales AS os ON p.product_id=os.product_id
GROUP BY p.product_id, p.product_name
ORDER BY TotalSales DESC;

---2. Product by the Number of Sold Unit
SELECT p.product_id, p.product_name,
SUM(os.quantity) AS TotalSoldProducts
FROM products AS p
JOIN order_sales AS os ON p.product_id=os.product_id
GROUP BY p.product_id, p.product_name
ORDER BY TotalSoldProducts DESC;

--Campaign Efectiveness Using Campaign, Order, and Engagement Table
-----Scenario: When The seller wants to know the effectiveness of a campaign on products

---1. Sold Unit, Revenue, and Percentage of Sales on Pre vs During Campaign
WITH CampaignPeriods AS (
SELECT c.campaign_id, c.campaign_name, 
c.start_date AS CampaignStartDate,
c.end_date AS CampaignEndDate,
DATEDIFF(day, c.start_date, c.end_date) + 1 AS CampaignDurationDays,
DATEADD(day, -1, c.start_date) AS PreCampaignEndDate,
DATEADD(day, -(DATEDIFF(day, c.start_date, c.end_date) + 1), DATEADD(day, -1, c.start_date)) AS PreCampaignStartDate
FROM campaigns AS c),

-----Sales During the Campaign
SalesDuringCampaign AS (
SELECT cp.campaign_id, cp.campaign_name, p.product_id, p.product_name,
SUM(
CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS DECIMAL(18,2)) ELSE 0 END *
CASE WHEN ISNUMERIC(os.price_at_order) = 1 THEN CAST(os.price_at_order AS DECIMAL(18,2)) ELSE 0 END
) AS CampaignRevenue,
SUM(CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS INT) ELSE 0 END) AS CampaignUnitsSold
FROM order_sales AS os
JOIN orders AS o ON os.order_id = o.order_id
JOIN products AS p ON os.product_id = p.product_id
JOIN CampaignPeriods AS cp ON o.order_date >= cp.CampaignStartDate AND o.order_date <= cp.CampaignEndDate
GROUP BY cp.campaign_id, cp.campaign_name, p.product_id, p.product_name),

-----Sales Pre-Campaign
SalesBeforeCampaign AS (
SELECT cp.campaign_id, cp.campaign_name, p.product_id, p.product_name,
SUM(
CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS DECIMAL(18,2)) ELSE 0 END *
CASE WHEN ISNUMERIC(os.price_at_order) = 1 THEN CAST(os.price_at_order AS DECIMAL(18,2)) ELSE 0 END
) AS PreCampaignRevenue,
SUM(CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS INT) ELSE 0 END) AS PreCampaignUnitsSold
FROM order_sales AS os
JOIN orders AS o ON os.order_id = o.order_id
JOIN products AS p ON os.product_id = p.product_id
JOIN CampaignPeriods AS cp ON o.order_date >= cp.PreCampaignStartDate AND o.order_date <= cp.PreCampaignEndDate
GROUP BY cp.campaign_id, cp.campaign_name, p.product_id, p.product_name)

-----Campaign Sales Performance
SELECT 'Sales Performance' AS MetricType, sdc.campaign_name, sdc.product_name,
COALESCE(sdc.CampaignUnitsSold, 0) AS CampaignUnitsSold,
COALESCE(sbc.PreCampaignUnitsSold, 0) AS PreCampaignUnitsSold,
COALESCE(sdc.CampaignRevenue, 0) AS CampaignRevenue,
COALESCE(sbc.PreCampaignRevenue, 0) AS PreCampaignRevenue,
CASE
WHEN COALESCE(sbc.PreCampaignUnitsSold, 0) = 0 THEN 'N/A (No pre-campaign sales)'
ELSE CONVERT(VARCHAR(50),
CAST(
((COALESCE(sdc.CampaignUnitsSold, 0) - COALESCE(sbc.PreCampaignUnitsSold, 0)) * 100.0)
/ COALESCE(sbc.PreCampaignUnitsSold, 1)
AS DECIMAL(18,2))) + '%'
END AS UnitSoldPercentageChange,
CASE
WHEN COALESCE(sbc.PreCampaignRevenue, 0) = 0 THEN 'N/A (No pre-campaign revenue)'
ELSE CONVERT(VARCHAR(50),
CAST(
((COALESCE(sdc.CampaignRevenue, 0) - COALESCE(sbc.PreCampaignRevenue, 0)) * 100.0)
/ COALESCE(sbc.PreCampaignRevenue, 1)
AS DECIMAL(18,2))) + '%'
END AS RevenuePercentageChange
FROM SalesDuringCampaign AS sdc
LEFT JOIN
SalesBeforeCampaign AS sbc ON sdc.product_id = sbc.product_id AND sdc.campaign_id = sbc.campaign_id
ORDER BY sdc.campaign_name, sdc.product_name;

---2. Campaign's Impression of Product
-----Numbers of Clicks and Impression during Campaign
WITH CampaignPeriods AS (
SELECT c.campaign_id, c.campaign_name, 
c.start_date AS CampaignStartDate,
c.end_date AS CampaignEndDate,
DATEDIFF(day, c.start_date, c.end_date) + 1 AS CampaignDurationDays,
DATEADD(day, -1, c.start_date) AS PreCampaignEndDate,
DATEADD(day, -(DATEDIFF(day, c.start_date, c.end_date) + 1), DATEADD(day, -1, c.start_date)) AS PreCampaignStartDate
FROM campaigns AS c),

CampaignEngagement AS (
SELECT cp.campaign_id, cp.campaign_name, p.product_id, p.product_name,
SUM(pe.impressions) AS TotalImpressions,
SUM(pe.clicks) AS TotalClicks
FROM product_engagement AS pe
JOIN products AS p ON pe.product_id = p.product_id
JOIN CampaignPeriods AS cp ON pe.view_date >= cp.CampaignStartDate AND pe.view_date <= cp.CampaignEndDate
GROUP BY cp.campaign_id, cp.campaign_name, p.product_id, p.product_name)

SELECT 'Campaign Engagement Metrics' AS MetricType,
campaign_name, product_name TotalImpressions, TotalClicks,
CASE
WHEN TotalImpressions > 0 THEN CAST(TotalClicks * 100.0 / TotalImpressions AS DECIMAL(10,2))
ELSE 0.00
END AS CTR_Percentage
FROM CampaignEngagement
ORDER BY campaign_name, TotalImpressions DESC;

-- Costumer Behaviours
-----Declaring Time Analysis
DECLARE @AnalysisStartDate DATE = '2024-06-01'; 
DECLARE @AnalysisEndDate DATE = '2024-06-30'; 
PRINT 'Analysing Engagement from: ' + CONVERT(VARCHAR, @AnalysisStartDate, 23) + ' to ' + CONVERT(VARCHAR, @AnalysisEndDate, 23);

-----Define the Product Engagement and Sales Algortihm
WITH ProductEngagementAndSales AS (
SELECT p.product_id, p.product_name,
SUM(pe.impressions) AS TotalImpressions,
SUM(pe.clicks) AS TotalClicks,
SUM(CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS INT) ELSE 0 END) AS TotalUnitsSold
FROM products AS p
LEFT JOIN product_engagement AS pe ON p.product_id = pe.product_id
AND pe.view_date >= @AnalysisStartDate
AND pe.view_date <= @AnalysisEndDate
LEFT JOIN order_sales AS os ON p.product_id = os.product_id
LEFT JOIN orders AS o ON os.order_id = o.order_id
AND o.order_date >= @AnalysisStartDate
AND o.order_date <= @AnalysisEndDate
GROUP BY p.product_id, p.product_name)

---1. Engagement using Impressions, Clicks, and Click Ratio Rate (CTR)
SELECT 'Engagement Performance' AS ReportType, product_name,
COALESCE(TotalImpressions, 0) AS TotalImpressions,
COALESCE(TotalClicks, 0) AS TotalClicks,
CASE 
WHEN COALESCE(TotalImpressions, 0) > 0
THEN CAST(COALESCE(TotalClicks, 0) * 100.0 / COALESCE(TotalImpressions, 1) AS DECIMAL(10,2))
ELSE 0.00 
END AS CTR_Percentage
FROM ProductEngagementAndSales
ORDER BY TotalImpressions DESC, CTR_Percentage DESC;

---2.Ordering Products by the Number of Unit Sold and CTR
-----Declaring Time Analysis
DECLARE @AnalysisStartDate DATE = '2024-06-01'; 
DECLARE @AnalysisEndDate DATE = '2024-06-30'; 
PRINT 'Analysing Engagement from: ' + CONVERT(VARCHAR, @AnalysisStartDate, 23) + ' to ' + CONVERT(VARCHAR, @AnalysisEndDate, 23);

-----Define the Product Engagement and Sales Algortihm
WITH ProductEngagementAndSales AS (
SELECT p.product_id, p.product_name,
SUM(pe.impressions) AS TotalImpressions,
SUM(pe.clicks) AS TotalClicks,
SUM(CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS INT) ELSE 0 END) AS TotalUnitsSold
FROM products AS p
LEFT JOIN product_engagement AS pe ON p.product_id = pe.product_id
AND pe.view_date >= @AnalysisStartDate
AND pe.view_date <= @AnalysisEndDate
LEFT JOIN order_sales AS os ON p.product_id = os.product_id
LEFT JOIN orders AS o ON os.order_id = o.order_id
AND o.order_date >= @AnalysisStartDate
AND o.order_date <= @AnalysisEndDate
GROUP BY p.product_id, p.product_name)

-----With 'High Impression & Low Sales' Schema
SELECT 'High Impressions, Low Sales Potential' AS ReportType, product_name,
COALESCE(TotalImpressions, 0) AS TotalImpressions,
COALESCE(TotalUnitsSold, 0) AS TotalUnitsSold,
CASE
WHEN COALESCE(TotalImpressions, 0) >= 1000 AND COALESCE(TotalUnitsSold, 0) < 10 THEN 'Potential Issue'
WHEN COALESCE(TotalImpressions, 0) >= 500 AND COALESCE(TotalUnitsSold, 0) = 0 THEN 'Zero Sales, Good Engagement'
ELSE 'Normal'
END AS SalesPerformanceIndicator
FROM ProductEngagementAndSales
WHERE COALESCE(TotalImpressions, 0) > 0
ORDER BY TotalImpressions DESC, TotalUnitsSold ASC;

--Finance&Operational Report Summary
-----Define the time
DECLARE @AnalysisStartDate DATE = '2024-01-01';
DECLARE @AnalysisEndDate DATE = '2024-12-31';
PRINT 'Analysing Financial/Operational Data from: ' + CONVERT(VARCHAR, @AnalysisStartDate, 23) + ' to ' + CONVERT(VARCHAR, @AnalysisEndDate, 23);

-----Making New Temporer Table Contains Several Metrics from orders and order_sales Table
CREATE TABLE #OrderRevenueData (order_id INT PRIMARY KEY, order_date DATE, order_status VARCHAR(50), OrderTotalRevenue DECIMAL(18,2));

INSERT INTO #OrderRevenueData (order_id, order_date, order_status, OrderTotalRevenue)
SELECT o.order_id, o.order_date, o.order_status,
SUM(
CASE WHEN ISNUMERIC(os.quantity) = 1 THEN CAST(os.quantity AS DECIMAL(18,2)) ELSE 0 END *
CASE WHEN ISNUMERIC(os.price_at_order) = 1 THEN CAST(os.price_at_order AS DECIMAL(18,2)) ELSE 0 END
) AS OrderTotalRevenue
FROM orders AS o
JOIN order_sales AS os ON o.order_id = os.order_id
WHERE o.order_date >= @AnalysisStartDate
AND o.order_date <= @AnalysisEndDate
GROUP BY  o.order_id, o.order_date o.order_status;

---1. Total Sales (Reveneu) each Day
SELECT 'Daily Sales Overview' AS ReportType,
CONVERT(DATE, order_date) AS SalesDate,
SUM(OrderTotalRevenue) AS TotalDailySales
FROM #OrderRevenueData
GROUP BY CONVERT(DATE, order_date)
ORDER BY SalesDate;

---2. The Number of Orders by Status Orders (Pending&Shipping Only)
-----Scenario: Sellers can easly know how much order to process
SELECT 'Orders Needing Processing' AS ReportType, order_status,
COUNT(order_id) AS NumberOfOrders
FROM #OrderRevenueData
WHERE order_status IN ('Pending', 'Shipped')
GROUP BY order_status
ORDER BY order_status;

---3. Total of Orders with Order Status and Revenue each Status
SELECT 'Order Status Summary' AS ReportType, order_status,
COUNT(order_id) AS TotalOrders,
SUM(OrderTotalRevenue) AS TotalRevenueByStatus
FROM #OrderRevenueData
GROUP BY order_status
ORDER BY order_status;
