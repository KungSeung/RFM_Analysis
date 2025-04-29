-- inventory_items table
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.inventory_items` AS (
SELECT *,
       CASE 
           WHEN EXTRACT(YEAR FROM sold_at) BETWEEN 2019 AND 2023 THEN sold_at
           ELSE NULL
       END AS sold_at_filtered  -- 새로운 이름으로 지정하여 중복 방지
FROM `looker-ecommerce-441405.Kaggle_Data.inventory_items`
WHERE EXTRACT(YEAR FROM created_at) BETWEEN 2019 AND 2023);

-- order_items table
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.order_items` AS (
  SELECT *,
         CASE 
             WHEN EXTRACT(YEAR FROM shipped_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE shipped_at
         END AS shipped_at_filtered,
         CASE 
             WHEN EXTRACT(YEAR FROM delivered_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE delivered_at
         END AS delivered_at_filtered,
         CASE 
             WHEN EXTRACT(YEAR FROM returned_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE returned_at
         END AS returned_at_filtered
  FROM `looker-ecommerce-441405.Kaggle_Data.order_items`
  WHERE EXTRACT(YEAR FROM created_at) BETWEEN 2019 AND 2023);

-- orders table
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.orders` AS (
  SELECT *,
         CASE 
             WHEN EXTRACT(YEAR FROM shipped_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE shipped_at
         END AS shipped_at_filtered,
         CASE 
             WHEN EXTRACT(YEAR FROM delivered_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE delivered_at
         END AS delivered_at_filtered,
         CASE 
             WHEN EXTRACT(YEAR FROM returned_at) NOT BETWEEN 2019 AND 2023 THEN NULL
             ELSE returned_at
         END AS returned_at_filtered
  FROM `looker-ecommerce-441405.Kaggle_Data.orders`
  WHERE EXTRACT(YEAR FROM created_at) BETWEEN 2019 AND 2023);

-- repeat_orders
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.repeat_orders` AS
WITH repeat_purchases AS (
  SELECT *
  FROM `looker-ecommerce-441405.Kaggle_Data_Processing.orders`
  WHERE status not in ('Cancelled', 'Returned')
  and user_id IN (
    SELECT user_id
    FROM `looker-ecommerce-441405.Kaggle_Data_Processing.orders`
    WHERE status not in ('Cancelled', 'Returned')
    GROUP BY user_id
    HAVING COUNT(order_id) > 1  -- 동일한 user_id로 두 번 이상 주문한 경우만 필터링
  )
)
SELECT *
FROM repeat_purchases;

-- more1_orders
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.more1_orders` AS
WITH more1_purchases AS (
  SELECT *
  FROM `looker-ecommerce-441405.Kaggle_Data_Processing.orders`
  WHERE status not in ('Cancelled', 'Returned')
)
SELECT *
FROM more1_purchases;

-- events
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.events` AS (
  SELECT *,
  FROM `looker-ecommerce-441405.Kaggle_Data.events`
  WHERE EXTRACT(YEAR FROM created_at) BETWEEN 2019 AND 2023);

-- users
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.users` AS (
  SELECT *,
  FROM `looker-ecommerce-441405.Kaggle_Data.users`
  WHERE EXTRACT(YEAR FROM created_at) BETWEEN 2019 AND 2023);

-- 그대로 사용하는 테이블
-- products
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.products` AS (
  SELECT *,
  FROM `looker-ecommerce-441405.Kaggle_Data.products`);

-- distribution_centers
CREATE VIEW `looker-ecommerce-441405.Kaggle_Data_Processing.distribution_centers` AS (
  SELECT *,
  FROM `looker-ecommerce-441405.Kaggle_Data.distribution_centers`);