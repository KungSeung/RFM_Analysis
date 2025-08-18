# RFM Analysis Project

데이터 과정 마지막 프로젝트: BigQuery를 활용한 전자상거래 고객 행동 분석

## 개요

이 프로젝트는 전자상거래 플랫폼의 고객 데이터를 기반으로 RFM (Recency, Frequency, Monetary) 분석과 고객 행동 패턴을 분석하는 SQL 기반 프로젝트입니다. 
Google BigQuery를 사용하여 Kaggle E-commerce 데이터셋을 분석하고, 다양한 고객 세그멘테이션 및 비즈니스 인사이트를 도출합니다.

## 데이터셋 정보

### 사용 데이터
- **플랫폼**: Google BigQuery
- **데이터셋**: Kaggle E-commerce Dataset
- **분석 기간**: 2019-2023년
- **테이블 구조**:

| 테이블명 | 설명 | 주요 컬럼 |
|---------|------|----------|
| `orders` | 주문 정보 | user_id, order_id, status, created_at |
| `order_items` | 주문 상품 정보 | order_id, product_id, sale_price |
| `users` | 사용자 정보 | id, country, created_at |
| `events` | 사용자 행동 이벤트 | user_id, event_type, session_id |
| `products` | 상품 정보 | id, brand, category |
| `inventory_items` | 재고 정보 | id, sold_at, cost |

## 주요 분석 기능

### 1. 데이터 전처리 (`Data-processing.sql`)
- 2019-2023년 데이터 필터링
- 취소/반품 주문 제외 처리
- 재구매 고객 세그멘테이션
- 클린 데이터 뷰 생성

### 2. 코호트 분석 (`cohort.sql`, `cohort_chart.sql`)
- 분기별 코호트 그룹 생성
- 90일 리텐션 분석
- 재구매율 계산 및 추적

### 3. 고객 여정 퍼널 분석
| 분석 파일 | 분석 내용 | 주요 지표 |
|----------|----------|----------|
| `funnel.sql` | 전체 고객 퍼넬 분석 | 각 단계별 전환율, 머무는 시간 |
| `country_funnel.sql` | 국가별 퍼넬 분석 | 지역별 행동 패턴 차이 |
| `time_funnel.sql` | 시간대별 퍼넬 분석 | 시간별 구매 패턴 |

### 4. 재구매 행동 분석
| 분석 파일 | 분석 내용 | 측정 지표 |
|----------|----------|----------|
| `repeat_purchase.sql` | 재구매 주기 분석 | 중앙값 89일 |
| `timeToPurchase.sql` | 구매까지 소요시간 | 평균 288일, 중앙값 191일 |
| `brand_timeToPurchase.sql` | 브랜드별 재구매 패턴 | 브랜드 충성도 분석 |

### 5. 장바구니-구매 전환 분석
| 분석 파일 | 분석 내용 | 비고 |
|----------|----------|------|
| `1try_cartToPurchase.sql` | 첫 시도 전환율 분석 | 기본 전환 패턴 |
| `2try_cartToPurchase.sql` | 재시도 전환율 분석 | 개선된 분석 로직 |

### 6. 트래픽 소스 분석 (`traffic_source.sql`)
- 국가별 트래픽 선호도 분석
- 주요 분석 대상 국가: 중국, 미국, 브라질
- 트래픽 소스별 구매 전환율

## 주요 분석 결과

### 고객 행동 패턴
| 지표 | 수치 | 설명 |
|------|------|------|
| 재구매 주기 (중앙값) | 89일 | 고객이 재구매하기까지 걸리는 시간 |
| 평균 구매 소요시간 | 288일 | 첫 방문부터 구매까지 평균 시간 |
| 90일 리텐션율 | 분기별 추적 | 코호트 기반 고객 유지율 |

### 국가별 특성
- **중국**: 높은 재구매율, 브랜드 충성도
- **미국**: 다양한 트래픽 소스 활용
- **브라질**: 특정 채널 집중도 높음

### 퍼넬 분석 인사이트
- 각 단계별 평균 머무는 시간 측정
- 이탈 지점 및 개선 포인트 식별
- 시간대별 구매 패턴 파악

## 파일 구조 및 실행 순서

```
RFM_Analysis/
├── Data-processing.sql           # 1. 데이터 전처리 (필수 선행)
├── cohort.sql                    # 2. 코호트 기본 분석
├── cohort_chart.sql              # 3. 코호트 차트 데이터
├── funnel.sql                    # 4. 기본 퍼넬 분석
├── country_funnel.sql            # 5. 국가별 퍼넬
├── time_funnel.sql               # 6. 시간대별 퍼넬
├── repeat_purchase.sql           # 7. 재구매 분석
├── timeToPurchase.sql            # 8. 구매 시간 분석
├── brand_timeToPurchase.sql      # 9. 브랜드별 분석
├── 1try_cartToPurchase.sql       # 10. 장바구니 전환 (v1)
├── 2try_cartToPurchase.sql       # 11. 장바구니 전환 (v2)
├── order_table_join_data.sql     # 12. 주문 데이터 조인
├── traffic_source.sql            # 13. 트래픽 소스 분석
├── sequence_number_events.sql    # 14. 이벤트 시퀀스 분석
└── repeat_users%_country.sql     # 15. 국가별 재구매 비율
```

## 기술 스택

| 기술 | 용도 | 버전/특징 |
|------|------|-----------|
| **Google BigQuery** | 데이터 웨어하우스 | 클라우드 기반 분석 플랫폼 |
| **SQL** | 쿼리 언어 | 복잡한 윈도우 함수, CTE 활용 |
| **Kaggle Dataset** | 데이터 소스 | E-commerce 실제 거래 데이터 |

## 실행 방법

### 1. 환경 설정
```sql
-- BigQuery 프로젝트 설정
PROJECT_ID: looker-ecommerce-441405
DATASET: Kaggle_Data_Processing
```

### 2. 데이터 전처리 실행
```sql
-- 먼저 Data-processing.sql 실행
-- 모든 뷰 테이블 생성 완료 후 다른 분석 진행
```

### 3. 순차적 분석 실행
- 각 SQL 파일을 목적에 맞게 실행
- 결과 데이터를 시각화 도구로 연동 가능

## 주요 분석 쿼리 예시

### 재구매율 계산
```sql
WITH repeat_customers AS (
  SELECT user_id, COUNT(*) as order_count
  FROM orders 
  WHERE status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id
  HAVING COUNT(*) > 1
)
SELECT 
  COUNT(DISTINCT repeat_customers.user_id) / COUNT(DISTINCT orders.user_id) * 100 as repeat_rate
FROM orders 
LEFT JOIN repeat_customers ON orders.user_id = repeat_customers.user_id;
```

### 코호트 분석 구조
```sql
WITH cohort_data AS (
  SELECT 
    user_id,
    DATE_TRUNC(first_purchase_date, QUARTER) as cohort_quarter,
    CASE WHEN retention_days <= 90 THEN 'Retained' 
         ELSE 'Not Retained' END as retention_status
  FROM user_purchase_data
)
SELECT cohort_quarter, retention_rate
FROM cohort_summary;
```

## 비즈니스 인사이트

### 1. 고객 세그멘테이션
- **신규 고객**: 첫 구매 후 90일 이내 재구매 가능성
- **충성 고객**: 89일 주기로 재구매하는 패턴
- **이탈 위험 고객**: 288일 이상 미구매 고객

### 2. 마케팅 최적화
- **타겟팅**: 국가별 선호 트래픽 소스 활용
- **타이밍**: 재구매 주기 기반 리마케팅
- **개인화**: 브랜드 충성도 기반 상품 추천

### 3. 운영 개선
- **퍼널 최적화**: 단계별 이탈 방지 전략
- **재고 관리**: 재구매 주기 기반 재고 계획
- **고객 서비스**: 국가별 특성 반영 서비스

## 한계 및 개선 방향

### 현재 한계
- 정적 SQL 분석으로 실시간 모니터링 제한
- 시각화 부분 별도 구현 필요
- 예측 모델링 기능 부재

### 개선 방향
- **대시보드 연동**: Looker Studio, Tableau 연결
- **자동화**: DBT를 활용한 파이프라인 구축
- **머신러닝**: BigQuery ML을 활용한 예측 모델
- **실시간 분석**: Streaming 데이터 처리

## 프로젝트 성과

- **데이터 처리량**: 2019-2023년 5년간 거래 데이터
- **분석 영역**: 15개 주요 비즈니스 지표 도출
- **국가별 분석**: 9개 주요 국가 고객 행동 패턴 파악
- **실행 가능한 인사이트**: 재구매 주기, 퍼넬 최적화 포인트 제시

## 개발자 정보

- **프로젝트 타입**: 데이터 분석 과정 최종 프로젝트
- **개발 도구**: Google BigQuery, SQL
- **분석 방법론**: RFM 분석, 코호트 분석, 퍼널 분석
- **데이터 기간**: 2019-2023년 (5년)

이 프로젝트는 실제 전자상거래 데이터를 활용하여 고객 행동 분석과 비즈니스 인사이트 도출에 중점을 둔 종합적인 데이터 분석 프로젝트입니다.
