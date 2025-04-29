-- 각 나라별 재구매율 : 재구매(2번) 유저 수/한번이라도 구매 이력이 있는 유저 수

WITH user_orders AS (
    SELECT 
        more1_ord.user_id,
        more1_ord.created_at AS created_at,
        MIN(more1_ord.created_at) OVER(PARTITION BY more1_ord.user_id) AS first_purchase_date,
        u.country
    FROM 
        looker-ecommerce-441405.Kaggle_Data_Processing.more1_orders AS more1_ord
    LEFT JOIN 
        looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
    ON 
        more1_ord.user_id = u.id
),

user_purchase_counts AS (
    SELECT 
        user_id,
        country,
        COUNT(created_at) AS purchase_count
    FROM user_orders
    GROUP BY user_id, country
)

-- 재구매율 (%)
SELECT 
    country,
    COUNT(*) AS total_users,  
    COUNTIF(purchase_count = 2) AS repeat_users,  
    ROUND(COUNTIF(purchase_count = 2) / COUNT(*) * 100, 2) AS repeat_purchase_rate  
FROM user_purchase_counts
GROUP BY country
ORDER BY repeat_purchase_rate DESC;


