-- 1 use database
use swiggy;

-- 2 table name change
ALTER TABLE delhi_swiggy_restaurants
RENAME TO delhi_restro_data;

ALTER TABLE delhi_restro_data
RENAME COLUMN `Avg ratings` TO avg_ratings;

ALTER TABLE delhi_restro_data
RENAME COLUMN `Delivery time` TO delivery_time;

ALTER TABLE delhi_restro_data
RENAME COLUMN `Food type` TO food_type;

-- ALTER TABLE delhi_restro_data
-- DROP COLUMN delivery_time;



-- 3 print all
select*from delhi_restro_data;

----------------------------------------------------------------------------------------------------------
-- 01. Restaurants' Rating and Price Impact Analysis
----------------------------------------------------------------------------------------------------------
SELECT 
    avg_ratings, 
    AVG(Price) as avg_price, 
    COUNT(distinct Restaurant) as total_restaurants,
    CASE 
        WHEN AVG(Price) > 600 THEN 'Premium'
        WHEN AVG(Price) BETWEEN 300 AND 600 THEN 'Mid-range'
        ELSE 'Budget'
    END as price_category
FROM delhi_restro_data
GROUP BY avg_ratings
ORDER BY avg_price DESC;

---------------------------------------------------------------------------------------------------------
-- 02. Identifying Outliers in Delivery Time (Z-score method) which is Wah Ji Wah ( Budhvihar)
---------------------------------------------------------------------------------------------------------
WITH delivery_stats AS (
    SELECT 
        AVG(delivery_time) AS mean_delivery_time, 
        STDDEV(delivery_time) AS std_dev
    FROM delhi_restro_data
)
SELECT 
    Restaurant, 
    delivery_time, 
    (delivery_time - ds.mean_delivery_time) / ds.std_dev AS z_score
FROM delhi_restro_data, delivery_stats ds
WHERE ABS((delivery_time - ds.mean_delivery_time) / ds.std_dev) > 2
ORDER BY z_score DESC;

---------------------------------------------------------------------------------------------------
-- 03. Clustering Restaurants by Price Range and Delivery Time
---------------------------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Price > 800 THEN 'High-end'
        WHEN Price BETWEEN 400 AND 800 THEN 'Mid-range'
        ELSE 'Low-range'
    END AS price_range,
    CASE 
        WHEN delivery_time > 60 THEN 'Slow'
        WHEN delivery_time BETWEEN 30 AND 60 THEN 'Medium'
        ELSE 'Fast'
    END AS delivery_speed,
    COUNT(distinct Restaurant) AS total_restaurants
FROM delhi_restro_data
GROUP BY price_range, delivery_speed
ORDER BY total_restaurants DESC;

-------------------------------------------------------------------------------------------------------
-- 04. Rating-based Restaurant Retention Analysis
-------------------------------------------------------------------------------------------------------
WITH cte1 AS (
    SELECT Restaurant, COUNT(*) AS occurrences
    FROM delhi_restro_data
    WHERE avg_ratings >= 4
    GROUP BY Restaurant
)
SELECT cte1.Restaurant, food_type, Area, delivery_time, Price, occurrences
FROM delhi_restro_data d
JOIN cte1 ON d.Restaurant = cte1.Restaurant
ORDER BY occurrences DESC;

--------------------------------------------------------------------------------------------------------
-- 05. Most Popular Restaurant Categories Across Price Ranges
--------------------------------------------------------------------------------------------------------
SELECT 
    Area, 
    COUNT(distinct Restaurant) as total_restaurants, 
    CASE 
        WHEN Price > 800 THEN 'Premium'
        WHEN Price BETWEEN 400 AND 800 THEN 'Mid-range'
        ELSE 'Budget'
    END as price_category
FROM delhi_restro_data
GROUP BY Area, price_category
ORDER BY total_restaurants DESC, price_category;

----------------------------------------------------------------------------------------------------------
-- 06. Predictive Trend: Delivery Time vs Price
---------------------------------------------------------------------------------------------------------
WITH price_delivery AS (
    SELECT 
        Price, 
        delivery_time,
        Restaurant,
        ROW_NUMBER() OVER (PARTITION BY Price ORDER BY delivery_time) AS row_num
    FROM delhi_restro_data
)
SELECT 
    Price, 
    AVG(delivery_time) AS avg_delivery_time, 
    COUNT(distinct (Restaurant)) AS total_restaurants
FROM price_delivery
GROUP BY Price
ORDER BY avg_delivery_time DESC;

-------------------------------------------------------------------------------------------------------
-- 07. Average Ratings and Price for Specific Cuisine Types
-------------------------------------------------------------------------------------------------------
SELECT 
    food_type,
    Area,
    AVG(Price) AS avg_price, 
    AVG(avg_ratings) AS avg_ratings
FROM delhi_restro_data
WHERE food_type LIKE '%Indian%'  -- You can change the cuisine type here
GROUP BY food_type, Area
ORDER BY avg_ratings DESC;

---------------------------------------------------------------------------------------------------------
-- 08. Average Delivery Time for Different Food Categories
--------------------------------------------------------------------------------------------------------
SELECT 
    food_type, 
    AVG(delivery_time) AS avg_delivery_time, 
    COUNT(DISTINCT Restaurant) AS total_restaurants
FROM delhi_restro_data
GROUP BY food_type
ORDER BY avg_delivery_time ASC;

