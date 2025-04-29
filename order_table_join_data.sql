with sort_events as (
  select 
      e.user_id, 
      e.sequence_number,
      e.session_id, 
      e.created_at,
      e.ip_address, 
      e.event_type,
      e.uri,
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
      SUM(case when (event_type = 'purchase') and (next_event_type is null) then 1 else 0 end) 
      OVER (partition by cast(user_id as int64), session_id ORDER BY created_at) as purchase_cnt
  from diff_time
),

-- 주문정보
repeat_orders_data as (
  select id, order_id, user_id, product_id, inventory_item_id,created_at,
        status, sale_price, shipped_at_filtered, delivered_at_filtered, returned_at_filtered
  from looker-ecommerce-441405.Kaggle_Data_Processing.order_items
  where created_at <= timestamp('2024-01-01 00:00:00 UTC')
),

join_data as (
  select rod.*, pro.brand
  from repeat_orders_data as rod
  left join looker-ecommerce-441405.Kaggle_Data_Processing.products as pro
  on rod.product_id = pro.id
),

-- 조인데이터
data_with_brand AS (
  select pc.*,jd.brand
  from pur_cnt as pc
  left join join_data as jd
  on pc.created_at = jd.created_at
  AND pc.user_id = jd.user_id -- 추가 조건
),

filled_data AS (
  SELECT 
      *,
      MAX(brand) OVER (PARTITION BY session_id) AS filled_brand -- session_id별 동일한 brand 값 채우기
  FROM 
      data_with_brand
), 

filled_data_clean as(
  select user_id, sequence_number, session_id, created_at, ip_address, event_type,
      country, next_event_type, next_created_at, time_diff, purchase_cnt, filled_brand
  from filled_data
),

brand_user_data as(
  SELECT 
    filled_brand, 
    user_id, 
    COUNT(*) AS total_purchases -- 고유 user_id의 구매 횟수
  FROM 
      filled_data_clean
  WHERE 
      filled_brand IS NOT NULL 
      AND purchase_cnt = 1 -- 구매 조건
  GROUP BY 
      filled_brand, 
      user_id -- 브랜드와 사용자별로 그룹화
),

brandGroup_user_id as (
  select distinct(user_id), total_purchases, filled_brand
  from brand_user_data
  where total_purchases = 2
)

-- 같은 브랜드를 재구매한 인원은 640명.. from brandGroup_user_id

select fdc.*
from filled_data_clean as fdc
inner join brandGroup_user_id as bui
on fdc.user_id = bui.user_id
where fdc.filled_brand is not null
order by fdc.user_id, fdc.session_id




