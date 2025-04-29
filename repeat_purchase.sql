-- 재구매 주기 89일(중앙값)
-- 1. 손님을 그룹으로 묶은 중앙값 -> 2. 모든 유저들의 중앙값의 중앙값
-- 리텐션 주기를 3달로 잡는다
-- 3달 간격 / 첫 구매 고객을 동질 집단(cohort)로 해서 리텐션 분석을 한다

WITH user_orders AS (
    SELECT 
        r_ord.user_id,
        r_ord.order_id,
        r_ord.created_at,
        LAG(r_ord.created_at) OVER(PARTITION BY r_ord.user_id ORDER BY r_ord.created_at) AS prev_order_date,
        row_number() over(partition by r_ord.user_id order by r_ord.created_at) as purchase_cnt,
    FROM 
        looker-ecommerce-441405.Kaggle_Data_Processing.repeat_orders AS r_ord
    LEFT JOIN 
        looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
    ON 
        r_ord.user_id = u.id
),

user_diff_date as (
  SELECT user_id, order_id, created_at, prev_order_date,
        date_diff(created_at, prev_order_date, day) as diff_date,
        purchase_cnt
  FROM user_orders
  WHERE prev_order_date IS NOT NULL
  order by diff_date
)

-- select avg(diff_date) as median_height
-- from(
--   select diff_date,
--       row_number() over(order by diff_date asc) as rownumber,
--       count(1) over() as tot_cnt
--   from user_diff_date
-- )
-- where (2*rownumber - tot_cnt) between 0 and 2

select *
from user_diff_date


