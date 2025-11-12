# 앱 ID 대소문자 불일치 문제 해결

**작성일:** 2025-11-13  
**문제:** Debug 빌드에서 "⚠️ 광고 정책 없음" 경고 발생  
**원인:** Supabase 데이터와 앱 ID의 대소문자 불일치

---

## 📋 문제 상황

### 로그 분석
```
AdPolicyRepo: Total rows fetched: 6
AdPolicyRepo: ⚠️ 광고 정책 없음 (app_id: com.sweetapps.pocketukulele.debug)
AdPolicyRepo: ⚠️ 기본값 사용됨
```

### 근본 원인
- **앱에서 사용하는 ID**: `com.sweetapps.pocketukulele.debug` (소문자)
- **Supabase에 저장된 ID**: `com.sweetapps.PocketUkulele.debug` (대문자 P)
- **결과**: 앱 ID 불일치로 정책을 찾을 수 없음

---

## 🔍 원인 분석

### 1. 앱 설정 (build.gradle.kts)
```kotlin
android {
    defaultConfig {
        applicationId = "com.sweetapps.pocketukulele"  // ← 소문자
    }
    
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"  // ← 소문자
            // 결과: com.sweetapps.pocketukulele.debug
        }
    }
}
```

### 2. SQL 스크립트 문제
기존 SQL 스크립트들이 대문자 `PocketUkulele`를 사용:
- `07-create-debug-test-data.sql`
- `ad-policy-add-debug-build.sql`
- `test-scripts-debug.sql`
- 기타 테스트 스크립트

---

## 🛠️ 해결 방법

### 방법 1: Supabase SQL 실행 (권장)

#### Step 1: 전체 정책 테이블 수정
Supabase SQL Editor에서 실행:
```sql
-- 파일: docs/sql/fix-all-policy-appid-case.sql
```
이 스크립트는:
- ✅ 모든 정책 테이블에 올바른 소문자 앱 ID 데이터 삽입
- ✅ emergency_policy, update_policy, notice_policy, ad_policy 모두 처리
- ✅ Release와 Debug 빌드 모두 수정
- ✅ ON CONFLICT 사용으로 안전한 재실행 가능

#### Step 2: 결과 확인
스크립트 실행 후 각 테이블에 2개 행이 있어야 함:
- `com.sweetapps.pocketukulele` (Release)
- `com.sweetapps.pocketukulele.debug` (Debug)

#### Step 3: 잘못된 데이터 삭제 (선택사항)
확인 후 대문자 데이터 삭제:
```sql
DELETE FROM emergency_policy WHERE app_id LIKE '%PocketUkulele%';
DELETE FROM update_policy WHERE app_id LIKE '%PocketUkulele%';
DELETE FROM notice_policy WHERE app_id LIKE '%PocketUkulele%';
DELETE FROM ad_policy WHERE app_id LIKE '%PocketUkulele%';
```

### 방법 2: 광고 정책만 빠르게 수정

광고 정책만 급하게 수정이 필요한 경우:
```sql
-- 파일: docs/sql/ad-policy-fix-debug-appid.sql
```

---

## ✅ 검증 방법

### 1. Supabase에서 확인
```sql
-- 모든 정책 테이블의 앱 ID 확인
SELECT 'ad_policy' as table_name, app_id, is_active
FROM ad_policy
WHERE app_id LIKE '%pocketukulele%'
UNION ALL
SELECT 'emergency_policy', app_id, CAST(is_active AS TEXT)
FROM emergency_policy
WHERE app_id LIKE '%pocketukulele%'
UNION ALL
SELECT 'update_policy', app_id, CAST(is_active AS TEXT)
FROM update_policy
WHERE app_id LIKE '%pocketukulele%'
UNION ALL
SELECT 'notice_policy', app_id, CAST(is_active AS TEXT)
FROM notice_policy
WHERE app_id LIKE '%pocketukulele%'
ORDER BY table_name, app_id;
```

예상 결과: 각 테이블에 2개의 소문자 앱 ID

### 2. 앱 로그에서 확인
앱을 재시작하고 Logcat 확인:
```
✅ 성공 시:
AdPolicyRepo: Total rows fetched: 6
AdPolicyRepo: ✅ 광고 정책 발견 (app_id: com.sweetapps.pocketukulele.debug)
AdPolicyRepo: is_active=true, banner=true, interstitial=true, app_open=true

❌ 실패 시:
AdPolicyRepo: Total rows fetched: 6
AdPolicyRepo: ⚠️ 광고 정책 없음 (app_id: com.sweetapps.pocketukulele.debug)
```

---

## 📝 향후 예방 조치

### 1. SQL 스크립트 업데이트
모든 SQL 스크립트에서 앱 ID를 소문자로 통일:
- [ ] `07-create-debug-test-data.sql` 수정
- [ ] `ad-policy-add-debug-build.sql` 수정
- [ ] `test-scripts-debug.sql` 수정
- [ ] `test-scripts-release.sql` 확인

### 2. 앱 ID 검증 로직 추가
AdPolicyRepository에 대소문자 불일치 감지 로직 추가 고려:
```kotlin
// 디버그 모드에서 대소문자 불일치 경고
if (BuildConfig.DEBUG) {
    val expectedAppId = BuildConfig.SUPABASE_APP_ID
    val foundIds = allRows.map { it.appId }
    val caseInsensitiveMatch = foundIds.find { 
        it.equals(expectedAppId, ignoreCase = true) && it != expectedAppId 
    }
    if (caseInsensitiveMatch != null) {
        Log.w(TAG, "⚠️ 앱 ID 대소문자 불일치 발견!")
        Log.w(TAG, "   예상: $expectedAppId")
        Log.w(TAG, "   발견: $caseInsensitiveMatch")
    }
}
```

### 3. 테스트 체크리스트
새 빌드 타입 추가 시:
- [ ] `build.gradle.kts`에서 정확한 applicationId 확인
- [ ] Supabase에 올바른 앱 ID로 테스트 데이터 추가
- [ ] 앱 실행 후 로그에서 정책 로드 확인

---

## 📚 관련 파일

### 생성된 SQL 스크립트
- `docs/sql/fix-all-policy-appid-case.sql` - 전체 정책 테이블 수정 (권장)
- `docs/sql/ad-policy-fix-debug-appid.sql` - 광고 정책만 수정

### 수정이 필요한 기존 파일
- `docs/sql/07-create-debug-test-data.sql`
- `docs/sql/ad-policy-add-debug-build.sql`
- `docs/sql/test-scripts-debug.sql`
- `docs/sql/test-scripts-debug-part2.sql`

### 앱 코드
- `app/build.gradle.kts` - applicationId 정의
- `app/src/main/java/com/sweetapps/pocketukulele/data/supabase/repository/AdPolicyRepository.kt`

---

## 🎯 요약

| 항목 | 잘못된 값 | 올바른 값 |
|------|----------|-----------|
| Release | `com.sweetapps.PocketUkulele` | `com.sweetapps.pocketukulele` |
| Debug | `com.sweetapps.PocketUkulele.debug` | `com.sweetapps.pocketukulele.debug` |

**해결 방법:** `fix-all-policy-appid-case.sql` 실행 → 앱 재시작 → 로그 확인

---

**상태:** ✅ 해결 방법 제공 완료  
**다음 단계:** Supabase에서 SQL 스크립트 실행 필요

