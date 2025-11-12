# 광고 정책 App ID 대소문자 문제 해결 완료

**작성일**: 2025-11-13  
**상태**: ✅ 완료

## 문제 요약

### 발생한 문제
```
⚠️ 광고 정책 없음 (app_id: com.sweetapps.pocketukulele.debug)
```

### 원인
- **Supabase**: `com.sweetapps.pocketukulele` (소문자) 데이터만 존재
- **앱 실행**: `com.sweetapps.pocketukulele.debug` (Debug 빌드)를 찾음
- Debug 빌드용 광고 정책이 Supabase에 없었음

### Release 빌드 상태
✅ **Release 빌드는 문제 없음**
- Release 빌드는 `com.sweetapps.pocketukulele` 사용
- Supabase에 해당 데이터가 이미 존재
- 사진에서 확인한 것처럼 `is_active: true`로 정상 설정됨
- **오직 Debug 빌드만 문제였음**

## 해결 과정

### 1. 스키마 확인
Supabase에서 `ad_policy` 테이블 구조 확인:
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'ad_policy'
ORDER BY ordinal_position;
```

**중요 발견**:
- ❌ `updated_at` 컬럼 없음 (오직 `created_at`만 존재)
- ✅ `app_id` 컬럼에 UNIQUE 제약조건 있음

### 2. Debug 빌드용 광고 정책 추가

실행한 쿼리:
```sql
INSERT INTO ad_policy (
  app_id,
  is_active,
  ad_app_open_enabled,
  ad_interstitial_enabled,
  ad_banner_enabled,
  ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day
) VALUES (
  'com.sweetapps.pocketukulele.debug',
  true,
  true,
  true,
  true,
  2,
  15
)
ON CONFLICT (app_id) DO UPDATE
SET
  is_active = EXCLUDED.is_active,
  ad_app_open_enabled = EXCLUDED.ad_app_open_enabled,
  ad_interstitial_enabled = EXCLUDED.ad_interstitial_enabled,
  ad_banner_enabled = EXCLUDED.ad_banner_enabled,
  ad_interstitial_max_per_hour = EXCLUDED.ad_interstitial_max_per_hour,
  ad_interstitial_max_per_day = EXCLUDED.ad_interstitial_max_per_day;
```

### 3. 결과 검증

**앱 로그 (Before)**:
```
⚠️ 광고 정책 없음 (app_id: com.sweetapps.pocketukulele.debug)
⚠️ 기본값 사용됨
```

**앱 로그 (After)**:
```
✅ 광고 정책 발견!
  - is_active: true
  - App Open Ad: true
  - Interstitial Ad: true
  - Banner Ad: true
  - Max Per Hour: 2
  - Max Per Day: 15
```

## 현재 Supabase 상태

### ad_policy 테이블
  - App ID: `com.sweetapps.pocketukulele`
  - 실제 광고 ID 사용
  - 프로덕션 환경
| app_id | is_active | ad_app_open | ad_interstitial | ad_banner | max/hour | max/day |
  - App ID: `com.sweetapps.pocketukulele.debug`
  - 테스트 광고 ID 사용 (Google 제공)
  - 개발/테스트 환경

### 빌드별 App ID 설정 (build.gradle.kts)
```kotlin
buildTypes {
    debug {
        buildConfigField("String", "SUPABASE_APP_ID", 
            "\"com.sweetapps.pocketukulele.debug\"")
        applicationIdSuffix = ".debug"  // ← 이것 때문에 .debug 붙음
    }
    release {
        buildConfigField("String", "SUPABASE_APP_ID", 
            "\"com.sweetapps.pocketukulele\"")
        // suffix 없음 → 기본 ID 사용
    }
}
```
|--------|-----------|-------------|-----------------|-----------|----------|---------|
| `com.sweetapps.pocketukulele` | true | true | true | true | 3 | 20 |
- **Release는 처음부터 정상이었음** - Debug만 누락됨
- 초기 설정 시 Release만 고려하고 Debug를 잊어버림
| `com.sweetapps.pocketukulele.debug` | true | true | true | true | 2 | 15 |

### 설정 차이 (Release vs Debug)
- **Release**: 시간당 3회, 하루 20회 (더 공격적)
- **Debug**: 시간당 2회, 하루 15회 (더 보수적, 테스트 친화적)

## 관련 파일

### SQL 스크립트
- `docs/sql/fix-all-policy-appid-case.sql` - 모든 정책 테이블 수정 스크립트
  - Step 1: 현재 상태 확인
  - Step 2: 올바른 데이터 삽입 (Debug + Release)
  - Step 3: 검증 쿼리
  - Step 4: 잘못된 데이터 삭제 (선택사항)

### 앱 코드
- `app/src/main/java/com/sweetapps/pocketukulele/data/repository/AdPolicyRepository.kt`
  - `fetchAdPolicyFromSupabase()` - 광고 정책 로드
  - 디버그 로그로 상세 정보 출력

## 교훈

### 1. 스키마 확인의 중요성
- SQL 스크립트 작성 전 반드시 실제 테이블 스키마 확인 필요
- `updated_at` 같은 컬럼이 없는데 사용하면 오류 발생

### 2. Debug vs Release 빌드
- 두 빌드는 **완전히 다른 app_id**를 사용
- Supabase에 **두 개의 별도 정책**이 필요

### 3. 대소문자 민감성
- PostgreSQL은 대소문자를 구분함
- `PocketUkulele` ≠ `pocketukulele`
- 일관성 있게 소문자 사용 권장

## 다음 단계

### 다른 정책 테이블도 확인 필요
Step 2의 나머지 쿼리로 다른 정책들도 추가:
- `emergency_policy` (Debug/Release)
- `update_policy` (Debug/Release)
- `notice_policy` (Debug/Release)

### 현재는 ad_policy만 수정됨
다른 정책들도 "⚠️ 정책 없음" 경고가 나타날 수 있음

## 참고 문서
- `docs/AD-SUPABASE-INTEGRATION-REPORT.md` - Supabase 통합 가이드
- `docs/archive/supabase-guide-complete.md` - Supabase 설정 가이드
- `docs/archive/TEST-ENVIRONMENT-GUIDE-2025-11-10.md` - 테스트 환경 가이드

---

**상태**: ✅ 해결 완료  
**테스트**: ✅ 통과  
**문서화**: ✅ 완료

