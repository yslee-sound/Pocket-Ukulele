-- ============================================
-- ad_policy 테이블 Debug 빌드 앱 ID 수정
-- ============================================
-- 작성일: 2025-11-13
-- 목적: 소문자 앱 ID로 수정 (대소문자 불일치 해결)
--
-- 문제: Supabase에 'com.sweetapps.PocketUkulele.debug' 저장됨
-- 실제: 앱은 'com.sweetapps.pocketukulele.debug' 사용
-- ============================================

-- Step 1: 기존 잘못된 데이터 확인
SELECT
  app_id,
  is_active,
  ad_app_open_enabled,
  ad_interstitial_enabled,
  ad_banner_enabled,
  ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day
FROM ad_policy
WHERE app_id LIKE '%debug%'
ORDER BY app_id;

-- Step 2: 올바른 소문자 앱 ID로 데이터 삽입
INSERT INTO ad_policy (
  app_id,
  is_active,
  ad_app_open_enabled,
  ad_interstitial_enabled,
  ad_banner_enabled,
  ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day
) VALUES (
  'com.sweetapps.pocketukulele.debug',  -- 소문자로 수정
  true,    -- 광고 정책 활성화
  true,    -- 앱 오픈 광고 ON
  true,    -- 전면 광고 ON
  true,    -- 배너 광고 ON
  2,       -- 시간당 최대 2회 (보수적)
  15       -- 하루 최대 15회 (보수적)
)
ON CONFLICT (app_id) DO UPDATE
SET
  is_active = EXCLUDED.is_active,
  ad_app_open_enabled = EXCLUDED.ad_app_open_enabled,
  ad_interstitial_enabled = EXCLUDED.ad_interstitial_enabled,
  ad_banner_enabled = EXCLUDED.ad_banner_enabled,
  ad_interstitial_max_per_hour = EXCLUDED.ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day = EXCLUDED.ad_interstitial_max_per_day,
  updated_at = NOW();

-- Step 3: Release 빌드도 소문자로 확인/수정
INSERT INTO ad_policy (
  app_id,
  is_active,
  ad_app_open_enabled,
  ad_interstitial_enabled,
  ad_banner_enabled,
  ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day
) VALUES (
  'com.sweetapps.pocketukulele',  -- Release용 (소문자)
  true,    -- 광고 정책 활성화
  true,    -- 앱 오픈 광고 ON
  true,    -- 전면 광고 ON
  true,    -- 배너 광고 ON
  3,       -- 시간당 최대 3회
  20       -- 하루 최대 20회
)
ON CONFLICT (app_id) DO UPDATE
SET
  is_active = EXCLUDED.is_active,
  ad_app_open_enabled = EXCLUDED.ad_app_open_enabled,
  ad_interstitial_enabled = EXCLUDED.ad_interstitial_enabled,
  ad_banner_enabled = EXCLUDED.ad_banner_enabled,
  ad_interstitial_max_per_hour = EXCLUDED.ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day = EXCLUDED.ad_interstitial_max_per_day,
  updated_at = NOW();

-- Step 4: 결과 확인 (올바른 앱 ID들)
SELECT
  app_id,
  is_active,
  ad_app_open_enabled,
  ad_interstitial_enabled,
  ad_banner_enabled,
  ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day,
  created_at,
  updated_at
FROM ad_policy
WHERE app_id IN (
  'com.sweetapps.pocketukulele',
  'com.sweetapps.pocketukulele.debug'
)
ORDER BY app_id;

-- Step 5 (선택사항): 잘못된 대문자 데이터 삭제
-- 아래 주석을 해제하여 실행하세요
-- DELETE FROM ad_policy
-- WHERE app_id IN (
--   'com.sweetapps.PocketUkulele',
--   'com.sweetapps.PocketUkulele.debug'
-- );

-- ============================================
-- 예상 결과
-- ============================================
-- 2개의 행이 반환되어야 함:
-- 1. com.sweetapps.pocketukulele (Release)
-- 2. com.sweetapps.pocketukulele.debug (Debug)
--
-- ✅ 앱에서 "⚠️ 광고 정책 없음" 경고가 사라져야 함
-- ============================================

