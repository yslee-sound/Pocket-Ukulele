# 🐛 배너 광고 Supabase 정책 미적용 문제 해결

**발견일**: 2025-11-13  
**문제**: Supabase에서 배너 광고를 OFF 했는데도 앱에서 계속 표시됨  
**원인**: **app_id 대소문자 불일치**  
**상태**: ✅ **해결 완료**

---

## 🔍 문제 분석

### 증상
- Supabase `ad_policy` 테이블에서 `ad_banner_enabled = FALSE` 설정
- 앱 재시작 후에도 배너 광고 계속 표시
- 3분 대기 후에도 동일

### 원인 발견

**Supabase 테이블 데이터**:
```
Row 5: app_id = "com.sweetapps.pocketukulele"         (배너 TRUE)
Row 6: app_id = "com.sweetapps.pocketukulele.debug"   (배너 FALSE) ← 설정한 행
```

**build.gradle.kts (수정 전)**:
```kotlin
debug {
    buildConfigField(
        "String",
        "SUPABASE_APP_ID",
        "\"com.sweetapps.PocketUkulele.debug\""  // ❌ P가 대문자
    )
}

release {
    buildConfigField(
        "String",
        "SUPABASE_APP_ID",
        "\"com.sweetapps.PocketUkulele\""  // ❌ P가 대문자
    )
}
```

**문제**:
- 앱이 `"com.sweetapps.PocketUkulele.debug"` (P 대문자)를 찾음
- Supabase 테이블에는 `"com.sweetapps.pocketukulele.debug"` (p 소문자)만 존재
- **일치하는 정책을 찾지 못함** → `adPolicy == null`
- `null`일 때 **기본값 `true` 사용** (장애 대응 로직)
- 결과: 배너 광고가 계속 표시됨

---

## ✅ 해결 방법

### 수정 내용

**build.gradle.kts**:
```kotlin
debug {
    // 디버그 빌드용 Supabase app_id
    buildConfigField(
        "String",
        "SUPABASE_APP_ID",
        "\"com.sweetapps.pocketukulele.debug\""  // ✅ p를 소문자로 수정
    )
}

release {
    // 릴리즈 빌드용 Supabase app_id
    buildConfigField(
        "String",
        "SUPABASE_APP_ID",
        "\"com.sweetapps.pocketukulele\""  // ✅ p를 소문자로 수정
    )
}
```

### 적용 단계

1. ✅ `build.gradle.kts` 수정
2. ✅ `gradlew clean` 실행
3. ✅ `gradlew assembleDebug` 실행
4. ✅ `gradlew installDebug` 실행

---

## 🧪 검증 방법

### 1. Logcat 확인

앱 시작 후 다음 로그 확인:

**수정 전 (정책 찾지 못함)**:
```
MainActivity: [정책] 정책 없음 - 기본값(true) 사용
MainActivity: 🎯 배너 광고 정책: 활성화
```

**수정 후 (정책 정상 조회)**:
```
AdPolicyRepo: ===== Ad Policy Fetch Started =====
AdPolicyRepo: ✅ 광고 정책 발견!
AdPolicyRepo:   - is_active: true
AdPolicyRepo:   - Banner Ad: false  ← FALSE 확인
MainActivity: [정책] 배너 광고 비활성화
MainActivity: 🎯 배너 광고 정책: 비활성화
```

### 2. 앱 UI 확인

- 배너 광고 위치에 **회색 플레이스홀더**만 표시
- 실제 광고 표시 안 됨

### 3. Logcat 필터
```
adb logcat -s MainActivity:D AdPolicyRepo:D -v time
```

---

## 📊 코드 흐름

### AdPolicyRepository.getPolicy()

```kotlin
suspend fun getPolicy(): Result<AdPolicy?> = runCatching {
    // Supabase에서 모든 정책 조회
    val allPolicies = client.from("ad_policy")
        .select()
        .decodeList<AdPolicy>()
    
    // app_id로 필터링
    val policy = allPolicies.firstOrNull { 
        it.appId == appId  // ← 여기서 대소문자 정확히 일치해야 함!
    }
    
    if (policy != null) {
        Log.d(TAG, "✅ 광고 정책 발견!")
        Log.d(TAG, "  - Banner Ad: ${policy.adBannerEnabled}")
    } else {
        Log.d(TAG, "⚠️ 광고 정책 없음 (app_id: $appId)")
    }
    
    policy
}
```

### MainActivity 정책 체크

```kotlin
val adPolicy = adPolicyRepo.getPolicy().getOrNull()

val newBannerEnabled = when {
    adPolicy == null -> {
        Log.d("MainActivity", "[정책] 정책 없음 - 기본값(true) 사용")
        true  // ← 대소문자 불일치로 여기에 빠짐!
    }
    !adPolicy.isActive -> {
        Log.d("MainActivity", "[정책] is_active = false - 모든 광고 비활성화")
        false
    }
    else -> {
        Log.d("MainActivity", "[정책] 배너 광고 ${if (adPolicy.adBannerEnabled) "활성화" else "비활성화"}")
        adPolicy.adBannerEnabled
    }
}
```

---

## 🎯 근본 원인

### 왜 대소문자 불일치가 발생했나?

1. **Supabase 테이블 생성 시**: 소문자로 입력
   - `com.sweetapps.pocketukulele`
   - `com.sweetapps.pocketukulele.debug`

2. **build.gradle.kts 작성 시**: Android 패키지 규칙 따름
   - 일반적으로 `com.CompanyName.AppName` 형식 사용
   - `PocketUkulele` (대문자 P)로 작성

3. **문자열 비교**: 대소문자 구분
   - `"PocketUkulele" != "pocketukulele"`
   - `firstOrNull { it.appId == appId }` 실패

---

## 🛡️ 재발 방지

### 체크리스트

- [ ] **Supabase app_id와 BuildConfig.SUPABASE_APP_ID가 정확히 일치**
- [ ] **대소문자 확인** (특히 P/p)
- [ ] **Debug와 Release 둘 다 확인**
- [ ] **Logcat에서 "광고 정책 발견" 메시지 확인**

### 개선 제안

#### 1. 앱 시작 시 app_id 검증
```kotlin
// PocketChordApplication.kt
override fun onCreate() {
    super.onCreate()
    
    // app_id 검증
    Log.d("App", "Current SUPABASE_APP_ID: ${BuildConfig.SUPABASE_APP_ID}")
    
    // 정책 조회 테스트
    lifecycleScope.launch {
        val repo = AdPolicyRepository(supabase)
        val policy = repo.getPolicy().getOrNull()
        
        if (policy == null) {
            Log.e("App", "⚠️ 광고 정책을 찾을 수 없습니다!")
            Log.e("App", "⚠️ Supabase에서 app_id를 확인하세요: ${BuildConfig.SUPABASE_APP_ID}")
        } else {
            Log.d("App", "✅ 광고 정책 로드 성공")
        }
    }
}
```

#### 2. 대소문자 무관 조회 (선택사항)
```kotlin
// AdPolicyRepository.kt
val policy = allPolicies.firstOrNull { 
    it.appId.equals(appId, ignoreCase = true)  // 대소문자 무시
}
```

**주의**: 대소문자 무시 시 의도치 않은 정책 매칭 가능

---

## 📝 수정 이력

### build.gradle.kts

**수정 전**:
```kotlin
"SUPABASE_APP_ID", "\"com.sweetapps.PocketUkulele.debug\""
"SUPABASE_APP_ID", "\"com.sweetapps.PocketUkulele\""
```

**수정 후**:
```kotlin
"SUPABASE_APP_ID", "\"com.sweetapps.pocketukulele.debug\""
"SUPABASE_APP_ID", "\"com.sweetapps.pocketukulele\""
```

---

## 🎉 결과

### 수정 후 동작

1. **앱 시작 시**:
   ```
   AdPolicyRepo: Target app_id: com.sweetapps.pocketukulele.debug
   AdPolicyRepo: ✅ 광고 정책 발견!
   AdPolicyRepo:   - Banner Ad: false
   MainActivity: [정책] 배너 광고 비활성화
   ```

2. **UI**:
   - 배너 광고 영역: 회색 플레이스홀더만 표시
   - 실제 광고 없음

3. **3분 후**:
   - 정책 재확인
   - `adBannerEnabled = false` 계속 유지

---

## 🔍 관련 이슈

### 다른 앱에서도 동일한 문제 발생 가능

**점검 사항**:
1. Supabase 테이블의 `app_id` 값
2. `BuildConfig.SUPABASE_APP_ID` 값
3. 대소문자 정확히 일치하는지 확인

**권장 사항**:
- **모두 소문자 사용** (Android 패키지 규칙)
- 또는 **모두 대문자 사용** (일관성 유지)

---

## 📁 수정된 파일

- ✅ `app/build.gradle.kts`

## 적용 명령어

```bash
cd G:\Workspace\PocketUkulele
gradlew clean
gradlew assembleDebug
gradlew installDebug
```

---

**해결 완료일**: 2025-11-13  
**수정 시간**: 약 5분  
**영향 범위**: Debug 및 Release 빌드 모두

