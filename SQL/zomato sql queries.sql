-- Row counts
SELECT 'restaurants', COUNT(*) FROM Zomato_Restaurants
UNION ALL
SELECT 'orders', COUNT(*) FROM Zomato_Orders;

-- Sample rows
SELECT * FROM Zomato_Restaurants LIMIT 5;
SELECT * FROM Zomato_Orders LIMIT 5;

-- Rename ï»¿restaurant_id -> restaurant_id but keep it as text for now
ALTER TABLE Zomato_Restaurants
  CHANGE `ï»¿restaurant_id` restaurant_id VARCHAR(50);



-- Null scan: Restaurants
SELECT
  SUM(restaurant_id IS NULL) AS n_restaurant_id_null,
  SUM(restaurant_name IS NULL OR restaurant_name='') AS n_restaurant_name_null,
  SUM(city IS NULL OR city='') AS n_city_null,
  SUM(area IS NULL OR area='') AS n_area_null,
  SUM(cuisine IS NULL OR cuisine='') AS n_cuisine_null,
  SUM(avg_rating IS NULL) AS n_avg_rating_null,
  SUM(total_ratings IS NULL) AS n_total_ratings_null,
  SUM(price_range IS NULL OR price_range='') AS n_price_range_null,
  SUM(delivery_available IS NULL OR delivery_available='') AS n_delivery_available_null
FROM Zomato_Restaurants;

-- Null scan: Orders
SELECT
  SUM(order_id IS NULL) AS n_order_id_null,
  SUM(restaurant_id IS NULL) AS n_rest_restaurant_id_null,
  SUM(customer_id IS NULL) AS n_customer_id_null,
  SUM(order_date IS NULL) AS n_order_date_null,
  SUM(order_time IS NULL) AS n_order_time_null,
  SUM(delivery_time IS NULL) AS n_delivery_time_null,
  SUM(total_cost IS NULL) AS n_total_cost_null,
  SUM(item_count IS NULL) AS n_item_count_null,
  SUM(payment_method IS NULL OR payment_method='') AS n_payment_method_null,
  SUM(customer_rating IS NULL) AS n_customer_rating_null
FROM Zomato_Orders;
------------------------------------------------------------------------------------
-- Drop if it already exists (safe re-run)
DROP TABLE IF EXISTS zomato_orders_clean;

-- Create with correct data types (no data yet)
CREATE TABLE zomato_orders_clean (
  order_id        VARCHAR(50)  NOT NULL PRIMARY KEY,  -- your IDs are strings
  restaurant_id   VARCHAR(50)  NOT NULL,              -- alphanumeric FK
  customer_id     VARCHAR(50)  NULL,                  -- keep as text ID
  order_ts        DATETIME     NULL,                  -- combined date+time
  delivery_time   INT          NULL,                  -- minutes
  total_cost      DECIMAL(10,2) NULL,                 -- money
  item_count      INT          NULL,                  -- items in order
  payment_method  VARCHAR(30)  NULL,                  -- normalized label
  customer_rating TINYINT      NULL                   -- 1..5 only
);

-- Helpful indexes for joins & time filters
CREATE INDEX ix_orders_restaurant ON zomato_orders_clean(restaurant_id);
CREATE INDEX ix_orders_ts         ON zomato_orders_clean(order_ts);

INSERT INTO zomato_orders_clean (
  order_id, restaurant_id, customer_id, order_ts,
  delivery_time, total_cost, item_count,
  payment_method, customer_rating
)
SELECT
  CAST(order_id      AS CHAR(50)) AS order_id,
  CAST(restaurant_id AS CHAR(50)) AS restaurant_id,
  CAST(customer_id   AS CHAR(50)) AS customer_id,

  -- Build one DATETIME from date + time (great for line charts)
  CASE
    WHEN order_date IS NOT NULL AND order_time IS NOT NULL THEN
      STR_TO_DATE(CONCAT(order_date, ' ', order_time), '%Y-%m-%d %H:%i:%s')
    WHEN order_date IS NOT NULL THEN
      STR_TO_DATE(CONCAT(order_date, ' 00:00:00'), '%Y-%m-%d %H:%i:%s')
    ELSE NULL
  END AS order_ts,

  -- Gentle safety checks (don’t change valid data; only guard against garbage)
  CASE WHEN delivery_time IS NULL OR delivery_time < 0 THEN NULL ELSE delivery_time END AS delivery_time,
  CASE WHEN total_cost    IS NULL OR total_cost    < 0 THEN NULL ELSE ROUND(total_cost,2) END AS total_cost,
  CASE WHEN item_count    IS NULL OR item_count    < 1 THEN 1    ELSE item_count END AS item_count,

  -- Normalize payment method so slicers don’t show UPI/upi/Upi as separate
  CASE
    WHEN payment_method IS NULL OR TRIM(payment_method) = '' THEN 'UNKNOWN'
    ELSE UPPER(TRIM(payment_method))
  END AS payment_method,

  -- Keep only valid 1..5; else NULL
  CASE
    WHEN customer_rating BETWEEN 1 AND 5 THEN customer_rating
    ELSE NULL
  END AS customer_rating
FROM (
  -- Tag duplicates: keep the latest row per order_id (by date/time)
  SELECT
    o.*,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY
        COALESCE(order_date, '0001-01-01') DESC,
        COALESCE(order_time, '00:00:00') DESC
    ) AS rn
  FROM Zomato_Orders o
) t
WHERE rn = 1;   -- <-- this is the deduplication



SELECT COUNT(*) AS orders_clean_rows FROM zomato_orders_clean;

SELECT payment_method, COUNT(*) 
FROM zomato_orders_clean 
GROUP BY payment_method 
ORDER BY COUNT(*) DESC;

SELECT * FROM zomato_orders_clean;

SELECT COUNT(*) AS total, COUNT(DISTINCT order_id) AS distinct_ids
FROM zomato_orders_clean;
-- Expect: total == distinct_ids

SELECT order_id 
FROM zomato_orders_clean
WHERE order_id LIKE '%E+%';


UPDATE zomato_orders_clean
SET order_id = 'UNKNOWN_ORDER'
WHERE order_id LIKE '%E+%';

SELECT order_id 
FROM Zomato_Orders
WHERE order_id LIKE '%E+%';

-- Build the list of bad IDs
CREATE TEMPORARY TABLE bad_ids AS
SELECT order_id AS bad_id
FROM zomato_orders_clean
WHERE order_id LIKE '%E+%';

-- Update via equality on the PK (safe-updates compatible)
UPDATE zomato_orders_clean o
JOIN bad_ids b ON o.order_id = b.bad_id
SET o.order_id = CONCAT(o.order_id, '_BAD');

SELECT * FROM zomato_orders_clean;

----------------------------------------------------------------

DROP TABLE IF EXISTS zomato_restaurants_clean;

CREATE TABLE zomato_restaurants_clean (
  restaurant_id     VARCHAR(50)  NOT NULL PRIMARY KEY,  -- string key
  restaurant_name   VARCHAR(255) NULL,
  city              VARCHAR(100) NULL,
  area              VARCHAR(150) NULL,
  cuisine           VARCHAR(150) NULL,
  avg_rating        DECIMAL(3,2) NULL,                  -- keep as-is
  total_ratings     INT          NULL,
  price_range       VARCHAR(20)  NULL,                  -- normalized
  delivery_available VARCHAR(10) NULL                   -- Yes/No/Unknown
);

INSERT INTO zomato_restaurants_clean (
  restaurant_id, restaurant_name, city, area, cuisine,
  avg_rating, total_ratings, price_range, delivery_available
)
SELECT
  CAST(restaurant_id AS CHAR(50)) AS restaurant_id,
  TRIM(restaurant_name) AS restaurant_name,
  UPPER(TRIM(city))    AS city,     -- standardize so MUMBAI vs mumbai don’t split
  TRIM(area)           AS area,
  TRIM(cuisine)        AS cuisine,

  -- Keep avg_rating as-is; (optionally clamp to 0..5 if needed)
  avg_rating,
  COALESCE(total_ratings, 0) AS total_ratings,

  -- Normalize price range to Low/Medium/High if possible; else keep original
  CASE
    WHEN LOWER(TRIM(price_range)) IN ('low','medium','high') THEN
      CONCAT(UCASE(LEFT(TRIM(price_range),1)), LOWER(SUBSTRING(TRIM(price_range),2)))
    ELSE TRIM(price_range)
  END AS price_range,

  -- Normalize delivery flag to Yes/No/Unknown
  CASE
    WHEN UPPER(TRIM(delivery_available)) IN ('YES','Y','TRUE','1') THEN 'Yes'
    WHEN UPPER(TRIM(delivery_available)) IN ('NO','N','FALSE','0') THEN 'No'
    ELSE 'Unknown'
  END AS delivery_available
FROM (
  -- If duplicates exist, keep the row with highest total_ratings
  SELECT
    r.*,
    ROW_NUMBER() OVER (
      PARTITION BY restaurant_id
      ORDER BY COALESCE(total_ratings,0) DESC
    ) AS rn
  FROM Zomato_Restaurants r
) t
WHERE rn = 1;

SELECT COUNT(*) AS restaurants_clean_rows FROM zomato_restaurants_clean;

SELECT COUNT(*) total, COUNT(DISTINCT restaurant_id) distinct_ids
FROM zomato_restaurants_clean;

-- City distribution (look for UPPER() effect)
SELECT city, COUNT(*) AS n
FROM zomato_restaurants_clean
GROUP BY city
ORDER BY n DESC
LIMIT 20;

-- Price range & delivery flags tidy?
SELECT price_range, COUNT(*) FROM zomato_restaurants_clean GROUP BY price_range;
SELECT delivery_available, COUNT(*) FROM zomato_restaurants_clean GROUP BY delivery_available;

-- Check if any restaurant IDs have E+ artifacts
SELECT restaurant_id
FROM zomato_restaurants_clean
WHERE restaurant_id LIKE '%E+%';

SELECT * FROM zomato_restaurants_clean;
-------------------------------------------------------------

-- Query 1: Number of restaurants in each city
SELECT 
    city,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants_clean
GROUP BY city
ORDER BY restaurant_count DESC;

-- Query 2: Top 5 cities with the highest number of orders
SELECT 
    r.city,
    COUNT(o.order_id) AS total_orders
FROM zomato_orders_clean o
JOIN zomato_restaurants_clean r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total_orders DESC
LIMIT 5;

-- Query 3: Total revenue generated by each restaurant
SELECT 
    r.restaurant_name,
    SUM(o.total_cost) AS total_revenue
FROM zomato_orders_clean o
JOIN zomato_restaurants_clean r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC;

-- Query 4: Average order amount for each city
SELECT 
    r.city,
    AVG(o.total_cost) AS avg_order_amount
FROM zomato_orders_clean o
JOIN zomato_restaurants_clean r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY avg_order_amount DESC;

-- Query 5: Top 5 restaurants with the highest total sales
SELECT 
    r.restaurant_name,
    SUM(o.total_cost) AS total_sales
FROM zomato_orders_clean o
JOIN zomato_restaurants_clean r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_sales DESC
LIMIT 5;

-- Enriched orders with restaurant info (recommended for Power BI)
SELECT
  o.order_id,
  o.order_ts,
  o.restaurant_id,
  r.restaurant_name,
  r.city,
  r.area,
  o.customer_id,
  o.delivery_time,
  o.total_cost,
  o.item_count,
  o.payment_method,
  o.customer_rating
FROM zomato_orders_clean o
JOIN zomato_restaurants_clean r
 ON o.restaurant_id = r.restaurant_id;
