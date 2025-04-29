-- 1번 이상 구매한 사람들
-- cohort_month : 첫달 활동한 고객들
-- visited_month : 재구매를 한 고객들
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

city_users as(
    select 
        DATE_TRUNC(first_purchase_date, QUARTER) AS cohort_month,
        DATE_TRUNC(created_at, month) as visited_month,
        user_id,
        country
    from user_orders
)

select *
from city_users





