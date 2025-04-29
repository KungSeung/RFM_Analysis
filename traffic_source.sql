-- **브라우저 및 트래픽 소스 분석**: (지리적인 요소 추가)활성화에 기여하는 트래픽 소스를 분석하고, 특정 소스에서 유입된 고객의 활성화 비율을 계산


-- traffic source는 2가지 경로 존재
-- events / users

-- events 테이블
-- 1 Email 2 Facebook 3	Adwords 4	YouTube 5	Organic
-- users 테이블
-- 1 Search 2 Organic 3	Display 4	Facebook 5 Email

-- events와 유저 join
-- 각 나라마다 트래픽 선호율

WITH join_data AS (
  SELECT
    u.country,
    e.traffic_source,
    COUNT(e.traffic_source) AS traffic_counts
  FROM
    looker-ecommerce-441405.Kaggle_Data_Processing.events AS e
  LEFT JOIN
    looker-ecommerce-441405.Kaggle_Data_Processing.users AS u
  ON
    e.user_id = u.id
  WHERE
    e.event_type = 'purchase' and
    u.country IN ('China', 'United States', 'Brasil', 'España', 'Deutschland', 'Austria', 'Colombia', 'Poland', 'Japan')
  GROUP BY
    u.country,
    e.traffic_source
),

total_traffic_by_country AS (
  SELECT
    country,
    SUM(traffic_counts) AS total_traffic_counts
  FROM
    join_data
  GROUP BY
    country
),

traffic_with_ratios AS (
  SELECT
    j.country,
    j.traffic_source,
    j.traffic_counts,
    t.total_traffic_counts,
    ROUND((j.traffic_counts / t.total_traffic_counts) * 100, 2) AS traffic_ratio -- 트래픽 비율 계산
  FROM
    join_data AS j
  INNER JOIN
    total_traffic_by_country AS t
  ON
    j.country = t.country
)

SELECT 
  country,
  traffic_source,
  traffic_counts,
  total_traffic_counts,
  traffic_ratio
FROM 
  traffic_with_ratios
where
  country in ('China', 'United States', 'Brasil')
ORDER BY 
  country, traffic_source

