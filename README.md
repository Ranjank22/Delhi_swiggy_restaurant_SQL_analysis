# Delhi_swiggy_restaurant_SQL_analysis

This project involves performing advanced SQL queries on a dataset of restaurants in Delhi, sourced from Swiggy. The goal is to extract meaningful insights, such as the impact of ratings on prices, identifying outliers in delivery times, clustering restaurants by price range, and much more.

## Table of Contents
1. [Database Setup](#database-setup)
2. [Schema Modifications](#schema-modifications)
3. [Data Exploration](#data-exploration)
4. [Advanced Queries](#advanced-queries)
    1. [Restaurants' Rating and Price Impact Analysis](#restaurants-rating-and-price-impact-analysis)
    2. [Outliers in Delivery Time (Z-score)](#outliers-in-delivery-time-z-score)
    3. [Clustering Restaurants by Price and Delivery Speed](#clustering-restaurants-by-price-and-delivery-speed)
    4. [Rating-based Restaurant Retention Analysis](#rating-based-restaurant-retention-analysis)
    5. [Popular Restaurant Categories Across Price Ranges](#popular-restaurant-categories-across-price-ranges)
    6. [Predictive Trend: Delivery Time vs Price](#predictive-trend-delivery-time-vs-price)
    7. [Average Ratings and Price for Specific Cuisines](#average-ratings-and-price-for-specific-cuisines)
    8. [Average Delivery Time for Different Food Categories](#average-delivery-time-for-different-food-categories)

## Database Setup

Before performing the SQL queries, the database is set up using the `swiggy` database. Ensure you are using this database for all queries.

```sql
-- Switch to the Swiggy database
USE swiggy;
```

## Schema Modifications

Some modifications are made to the existing table and column names for clarity and consistency:

```sql
-- Rename table and columns for better clarity
ALTER TABLE delhi_swiggy_restaurants
RENAME TO delhi_restro_data;

ALTER TABLE delhi_restro_data
RENAME COLUMN `Avg ratings` TO avg_ratings;
RENAME COLUMN `Delivery time` TO delivery_time;
RENAME COLUMN `Food type` TO food_type;
```

## Data Exploration

Basic exploration of the data by selecting all records:

```sql
-- Display all records in the delhi_restro_data table
SELECT * FROM delhi_restro_data;
```

## Advanced Queries

### 1. Restaurants' Rating and Price Impact Analysis

This query helps identify how restaurant ratings impact their price category, categorizing restaurants as "Premium," "Mid-range," or "Budget."

```sql
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
```

### 2. Outliers in Delivery Time (Z-score)

This query identifies outliers in delivery time using the Z-score method. Restaurants with unusually high or low delivery times are flagged.

```sql
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
```

### 3. Clustering Restaurants by Price and Delivery Speed

This query clusters restaurants based on price range and delivery speed, offering insights into which categories have more restaurants.

```sql
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
```

### 4. Rating-based Restaurant Retention Analysis

This query helps in analyzing how many times a restaurant with high ratings (≥ 4) appears in the dataset.

```sql
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
```

### 5. Popular Restaurant Categories Across Price Ranges

This query analyzes which areas have more restaurants across different price ranges, helping to identify popular restaurant categories in specific areas.

```sql
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
```

### 6. Predictive Trend: Delivery Time vs Price

The predictive trend query shows how delivery time changes with price, showing whether more expensive restaurants deliver faster or slower.

```sql
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
    COUNT(distinct Restaurant) AS total_restaurants
FROM price_delivery
GROUP BY Price
ORDER BY avg_delivery_time DESC;
```

### 7. Average Ratings and Price for Specific Cuisines

This query helps identify the average price and rating for restaurants offering a specific type of cuisine.

```sql
SELECT 
    food_type,
    Area,
    AVG(Price) AS avg_price, 
    AVG(avg_ratings) AS avg_ratings
FROM delhi_restro_data
WHERE food_type LIKE '%Indian%'  -- Modify for different cuisines
GROUP BY food_type, Area
ORDER BY avg_ratings DESC;
```

### 8. Average Delivery Time for Different Food Categories

This query shows how delivery times vary for different types of food.

```sql
SELECT 
    food_type, 
    AVG(delivery_time) AS avg_delivery_time, 
    COUNT(DISTINCT Restaurant) AS total_restaurants
FROM delhi_restro_data
GROUP BY food_type
ORDER BY avg_delivery_time ASC;
```

## Conclusion

These advanced SQL queries offer deep insights into the restaurant industry in Delhi, specifically looking at patterns in restaurant pricing, delivery times, and customer ratings. The analysis can be extended further based on specific business needs.
