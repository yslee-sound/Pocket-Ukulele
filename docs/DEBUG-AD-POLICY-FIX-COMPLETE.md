# Debug 빌드 광고 정책 없음 문제 - 해결 완료

**날짜:** 2025-11-13  
**문제:** Debug 빌드에서 "⚠️ 광고 정책 없음" 경고 발생  
**상태:** ✅ 해결 방법 제공 완료

---

## 📊 문제 요약

### 로그
```
AdPolicyRepo: Total rows fetched: 6
AdPolicyRepo: ⚠️ 광고 정책 없음 (app_id: com.sweetapps.pocketukulele.debug)
AdPolicyRepo: ⚠️ 기본값 사용됨
```

### 원인
**앱 ID 대소문자 불일치**
- 앱에서 사용: `com.sweetapps.pocketukulele.debug` (소문자)
- Supabase 저장: `com.sweetapps.PocketUkulele.debug` (대문자 P)

---

## ✅ 해결 방법

### 1단계: SQL 실행
Supabase SQL Editor에서 실행:
```
docs/sql/fix-all-policy-appid-case.sql
```

이 스크립트는:
- ✅ 모든 정책 테이블 (ad, emergency, update, notice) 수정
- ✅ Release와 Debug 빌드 모두 처리
- ✅ 올바른 소문자 앱 ID로 데이터 생성

### 2단계: 앱 재시작
Debug 빌드를 재시작하여 확인

### 3단계: 로그 확인
성공 시 로그:
```
AdPolicyRepo: ✅ 광고 정책 발견 (app_id: com.sweetapps.pocketukulele.debug)
AdPolicyRepo: is_active=true, banner=true, interstitial=true, app_open=true
```

---

## 📁 생성된 파일

### SQL 스크립트
1. **`docs/sql/fix-all-policy-appid-case.sql`** (메인)
   - 모든 정책 테이블의 앱 ID 수정
   - Release + Debug 빌드 모두 처리
   
2. **`docs/sql/ad-policy-fix-debug-appid.sql`** (광고만)
   - 광고 정책만 빠르게 수정

### 문서
3. **`docs/APP-ID-CASE-MISMATCH-FIX.md`**
   - 상세한 문제 분석
   - 해결 방법 설명
   - 검증 방법
   - 향후 예방 조치

### 수정된 파일
4. **`docs/sql/07-create-debug-test-data.sql`**
   - 앱 ID를 소문자로 수정
   - update_policy의 is_active를 false로 변경 (테스트 환경)
   - notice_policy의 is_active를 false로 변경 (테스트 환경)

---

## 🔄 다음 단계

### 즉시 실행 필요
- [ ] Supabase에서 `fix-all-policy-appid-case.sql` 실행
- [ ] 앱 재시작 후 로그 확인

### 추가 정리 (선택)
- [ ] 잘못된 대문자 데이터 삭제
- [ ] 다른 SQL 스크립트들도 소문자로 업데이트
  - `ad-policy-add-debug-build.sql`
  - `test-scripts-debug.sql`
  - `test-scripts-debug-part2.sql`

---

## 💡 핵심 교훈

### 문제 원인
`build.gradle.kts`에서:
```kotlin
applicationId = "com.sweetapps.pocketukulele"  // 소문자
applicationIdSuffix = ".debug"                  // 소문자
```

→ 결과: `com.sweetapps.pocketukulele.debug`

### SQL 스크립트가 대문자 사용
```sql
'com.sweetapps.PocketUkulele.debug'  ❌ 틀림
'com.sweetapps.pocketukulele.debug'  ✅ 맞음
```

### 예방 방법
1. 항상 `build.gradle.kts`의 applicationId 확인
2. SQL 스크립트 작성 시 대소문자 주의
3. 테스트 데이터 추가 후 앱에서 검증

---

## 📋 체크리스트

- [x] 문제 분석 완료
- [x] 수정 SQL 스크립트 생성
- [x] 문서화 완료
- [x] 샘플 SQL 파일 수정
- [ ] **Supabase SQL 실행 필요** ← 사용자가 실행해야 함
- [ ] 앱에서 검증 필요

---

**다음 단계:** `fix-all-policy-appid-case.sql`을 Supabase에서 실행하세요!

