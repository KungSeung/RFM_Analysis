-- 첫 구매 후 재구매까지의 소요 시간 -> 평균값 / 중앙값

-- 재구매율 = 2번 구매 / 1번이상 구매
-- 각 나라별+기간별 재구매율
with timeToRepeatPurchase as (
  select 
    more1_ord.user_id,  
    more1_ord.order_id,
    more1_ord.created_at,
    u.country,
    lag(more1_ord.created_at) over(partition by more1_ord.user_id order by more1_ord.created_at) as prev_order_date,
    row_number() over(partition by more1_ord.user_id order by more1_ord.created_at) as purchase_cnt,
    MIN(more1_ord.created_at) OVER(PARTITION BY more1_ord.user_id) AS first_purchase_date
  from
    looker-ecommerce-441405.Kaggle_Data_Processing.more1_orders AS more1_ord
  LEFT JOIN 
    looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
  ON 
      more1_ord.user_id = u.id
),

timeDiff as (
  select
    user_id, 
    order_id, 
    created_at, 
    prev_order_date,
    country,
    timestamp_diff(created_at, prev_order_date, day) as toPurchaseTime,
    purchase_cnt,
    first_purchase_date
  from
    timeToRepeatPurchase
  order by 
    user_id
),

ranked_data AS (
  SELECT
    country,
    toPurchaseTime,
    purchase_cnt,
    ROW_NUMBER() OVER (ORDER BY toPurchaseTime) AS row_num,
    COUNT(country) OVER (PARTITION BY country) AS country_total_rows,
    COUNT(*) OVER () AS total_rows
  FROM
    timeDiff
  order by 
    country
),

country_summary AS (
  SELECT
    country,
    countif(toPurchaseTime <= 30 and purchase_cnt = 2) as in_30_reorders,
    countif(toPurchaseTime <= 180 and purchase_cnt = 2) as in_180_reorders,
    countif(toPurchaseTime <= 360 and purchase_cnt = 2) as in_360_reorders,
    MAX(country_total_rows) AS country_total_rows -- country별 전체 행 수를 가져옴
  FROM
    ranked_data
  GROUP BY
    country
),

median_calc AS (
  SELECT
    toPurchaseTime
  FROM
    ranked_data
  WHERE
    row_num = CEIL(total_rows / 2) -- 홀수 개일 때 중앙값
    OR (MOD(total_rows, 2) = 0 AND row_num IN (total_rows / 2, total_rows / 2 + 1))  -- 짝수 개일 때 두 값의 중앙
)

-- 중앙값 / 191
-- SELECT
--   AVG(toPurchaseTime) AS median_value -- 짝수일 경우 두 값의 평균
-- FROM
--   median_calc;

-- 평균값 / 288
-- select
--   avg(toPurchaseTime) as avg_value
-- from timeDiff


-- 재구매까지 걸린시간(day) 나라별로
-- select country, count(*) as counts
-- from timeDiff
-- where country in ('China', 'United States', 'Brasil') and toPurchaseTime <= 30
-- group by country
-- order by country

select *, 
    round(in_30_reorders/country_total_rows * 100, 2) as reorders_30_ratio,
    round(in_180_reorders/country_total_rows * 100, 2) as reorders_180_ratio,
    round(in_360_reorders/country_total_rows * 100, 2) as reorders_360_ratio,
from country_summary
order by in_30_reorders desc


-- SELECT
--   country,
--   reorders_cnt,
--   toPurchaseTime,
--   round(reorders_cnt / country_total_rows * 100, 2) AS reorders_ratio -- 2번 구매 비율 계산
-- FROM
--   country_summary
-- where
--   toPurchaseTime

