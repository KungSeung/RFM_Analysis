-- 재구매율 : 재구매(2번이상) 유저 수/한번이라도 구매 이력이 있는 유저 수

-- 1번 이상 구매한 사람들
WITH user_orders AS (
    SELECT 
        more1_ord.user_id,
        more1_ord.order_id,
        more1_ord.created_at,
        LAG(more1_ord.created_at) OVER(PARTITION BY more1_ord.user_id ORDER BY more1_ord.created_at) AS prev_order_date,
        MIN(more1_ord.created_at) OVER(PARTITION BY more1_ord.user_id) AS first_purchase_date
    FROM 
        looker-ecommerce-441405.Kaggle_Data_Processing.more1_orders AS more1_ord
    LEFT JOIN 
        looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
    ON 
        more1_ord.user_id = u.id
),

cohort_data AS (
    SELECT 
        user_id,
        first_purchase_date,
        COUNT(order_id) AS total_orders,
        CASE 
            WHEN COUNT(order_id) > 1 AND MIN(DATE_DIFF(created_at, first_purchase_date, DAY)) <= 90 THEN 'Retained within 90 days'
            ELSE 'Not Retained within 90 days'
        END AS retention_status
    FROM 
        user_orders
    GROUP BY 
        user_id, first_purchase_date
),

retention_cohort AS (
    SELECT 
        DATE_TRUNC(first_purchase_date, quarter) AS cohort_quarter,
        COUNT(DISTINCT user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN retention_status = 'Retained within 90 days' THEN user_id END) AS retained_users
    FROM 
        cohort_data
    GROUP BY 
        cohort_quarter
)

-- 최종 재구매율 계산
-- SELECT 
--     cohort_quarter as cohort_month,
--     total_users,
--     retained_users,
--     CONCAT(ROUND(SAFE_DIVIDE(retained_users, total_users) * 100, 2), '%') AS retention_rate
-- FROM 
--     retention_cohort
-- ORDER BY 
--     cohort_month;

select *
from retention_cohort