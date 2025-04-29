-- **세션 및 이벤트 참여율**: 세션 수와 이벤트 참여 빈도를 측정하여 활성화 수준을 파악
-- events / orders join
-- 입장부터 ~ 구매까지의 시간도 있으면 좋겠다
-- 시퀀스가 적은 물품이 어떤것인가? orders와 조인하거나 << 얘가 좀더 정확할듯? /department단계의 brand를 살펴보는것도 좋겠다
WITH ranked_data AS (
  SELECT
    u.country,
    e.sequence_number,
    COUNT(*) AS value_counts
  FROM
    looker-ecommerce-441405.Kaggle_Data_Processing.events AS e
  LEFT JOIN
    looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
  ON
    e.user_id = u.id
  WHERE
    e.event_type = 'purchase'
    AND u.country IN ('China', 'United States', 'Brasil', 'España', 'Deutschland', 'Austria', 'Colombia', 'Poland', 'Japan')
  GROUP BY
    u.country, e.sequence_number
),

total_traffic_by_country AS (
  SELECT
    country,
    SUM(value_counts) AS total_traffic_counts
  FROM
    ranked_data
  GROUP BY
    country
),

test as (
  SELECT
    e.user_id,
    e.sequence_number,
    ord.created_at,
    
  FROM
    looker-ecommerce-441405.Kaggle_Data_Processing.events AS e
  LEFT JOIN
    looker-ecommerce-441405.Kaggle_Data_Processing.orders AS ord
  ON
    e.user_id = ord.user_id
  WHERE
    e.event_type = 'purchase'
    and ord.created_at is not null
  
  order by e.user_id, ord.created_at
),

-- 상위 3개 나라
data_Top3_country as (
  select *
  from ranked_data
  where country in ('China', 'United States', 'Brasil')
),

-- 하위 5개 나라
data_Bottom5_country as(
  select *
  from ranked_data
  where country in ('España', 'Deutschland', 'Austria', 'Colombia', 'Poland')
),

-- 중간값에 해당하는 나라
data_median_country as(
  select *
  from ranked_data
  where country in ('Japan')
),

traffic_counts as (
  select c.*, ttbc.total_traffic_counts
  from data_Top3_country as c
  left join total_traffic_by_country as ttbc
  on c.country = ttbc.country
)

-- select *, round(value_counts/total_traffic_counts*100, 2)as traffic_ratio
-- from traffic_counts
-- order by country, sequence_number

select *
from test


