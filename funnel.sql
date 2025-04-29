-- 회원별 각 단계 횟수
-- select *
-- from looker-ecommerce-441405.Kaggle_Data_Processing.events
-- where user_id is not null
-- order by user_id, session_id, created_at

with sort_events as(
  select user_id, sequence_number,
      session_id, created_at,
      ip_address, event_type
  from looker-ecommerce-441405.Kaggle_Data_Processing.events
  where user_id is not null
  order by user_id, session_id, created_at
),

spend_time as (
  select *,  
      CASE 
        WHEN sequence_number = 1 THEN TIMESTAMP('1970-01-01 00:00:00 UTC') 
        ELSE LAG(created_at) OVER (partition by cast(user_id as int64), session_id ORDER BY created_at)
      END AS prev_created_at,
      LAG(event_type) OVER (partition by cast(user_id as int64), session_id ORDER BY created_at) as prev_event_type
  from sort_events
  order by user_id, session_id
),

diff_time as (
  select *, 
      case
        when prev_created_at = TIMESTAMP('1970-01-01 00:00:00 UTC') then 0
        else timestamp_diff(created_at, prev_created_at, second)
      end as diff
  from spend_time
),

-- 각 단계별 가장 오래 머무른 시간 / 가장 적게 머무른 시간 / 평균값
event_stats AS (
  SELECT 
    event_type,
    round(MAX(diff)/60,1) AS max_time,  
    round(MIN(diff)/60,1) AS min_time,  
    round(AVG(diff)/60,1) AS avg_time   
  FROM 
    diff_time
  where
    prev_created_at != timestamp('1970-01-01 00:00:00 UTC')
  GROUP BY 
    event_type
)

-- select *
-- from event_stats

select *
from diff_time
where prev_created_at != timestamp('1970-01-01 00:00:00 UTC')
order by user_id, session_id




