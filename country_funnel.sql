with sort_events as (
  select 
      e.user_id, 
      e.sequence_number,
      e.session_id, 
      e.created_at,
      e.ip_address, 
      e.event_type,
      u.country
  from looker-ecommerce-441405.Kaggle_Data_Processing.events as e
  left join looker-ecommerce-441405.Kaggle_Data_Processing.users as u
      on e.user_id = u.id
  where user_id is not null
  order by user_id, session_id, created_at
),

spend_time as (
  select 
      *,  
      -- 다음 이벤트 정보
      LEAD(event_type) OVER (partition by cast(user_id as int64), session_id ORDER BY created_at) as next_event_type,
      LEAD(created_at) OVER (partition by cast(user_id as int64), session_id ORDER BY created_at) as next_created_at
  from sort_events
  order by user_id, session_id
),

diff_time as (
  select 
      *, 
      case 
          when next_created_at IS NULL then 0
          else timestamp_diff(next_created_at, created_at, second)
      end as time_diff
  from spend_time
),

pur_cnt as (
  select 
      *,
      SUM(case when event_type = 'purchase' then 1 else 0 end) 
      OVER (partition by cast(user_id as int64) ORDER BY created_at) as purchase_cnt
  from diff_time
)

select 
    *
from pur_cnt
order by user_id, session_id;
