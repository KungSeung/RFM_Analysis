with sort_events as (
  select 
      e.user_id, 
      e.sequence_number,
      e.session_id, 
      e.created_at,
      e.ip_address, 
      e.event_type,
      u.country,
      date(e.created_at) as day, -- created_at에서 날짜 추출
      extract(hour from e.created_at) as hour -- created_at에서 시간 추출
  from looker-ecommerce-441405.Kaggle_Data_Processing.events as e
  left join looker-ecommerce-441405.Kaggle_Data_Processing.users as u
      on e.user_id = u.id
  where user_id is not null
  order by user_id, session_id, created_at
),
event_summary as (
  select 
      country,
      day,
      hour,
      event_type,
      count(*) as event_count
  from sort_events
  group by country, day, hour, event_type
  order by country, day, hour, event_type
)
select * 
from event_summary;