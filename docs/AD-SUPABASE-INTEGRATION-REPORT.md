# 🔍 PocketUkulele 광고 시스템 Supabase 연동 분석 보고서

**작성일**: 2025-11-13  
**프로젝트**: PocketUkulele  
**분석 대상**: 배너광고, 전면광고, 앱오프닝광고

---

## ✅ 결론: **모든 광고가 Supabase와 연동되어 있음**

---

## 📊 광고 시스템 구성

### 1️⃣ **배너 광고 (Banner Ad)** ✅

**연동 상태**: **완전 연동**

**위치**: `MainActivity.kt`
- **Supabase 정책 조회**: `AdPolicyRepository` 사용
- **확인 필드**: `adBannerEnabled`
- **갱신 주기**: 3분마다 자동 갱신
- **동작 방식**:
  ```kotlin
  LaunchedEffect(Unit) {
      val adPolicyRepo = AdPolicyRepository(app.supabase)
      
      while (true) {
          val adPolicy = adPolicyRepo.getPolicy().getOrNull()
          
          val newBannerEnabled = when {
              adPolicy == null -> true  // Supabase 장애 시 기본값
              !adPolicy.isActive -> false  // is_active = false면 모든 광고 비활성화
              else -> adPolicy.adBannerEnabled  // 개별 플래그 확인
          }
          
          isBannerEnabled = newBannerEnabled
          delay(3 * 60 * 1000L)  // 3분마다 체크
      }
  }
  ```

**표시 위치**:
- 화면 상단 (TopBannerAd 컴포저블)
- 앱오프닝 광고 표시 중에는 숨김

---

### 2️⃣ **전면 광고 (Interstitial Ad)** ✅

**연동 상태**: **완전 연동**

**파일**: `InterstitialAdManager.kt`
- **Supabase 정책 조회**: `AdPolicyRepository` 사용
- **확인 필드**: `adInterstitialEnabled`, `adInterstitialMaxPerHour`, `adInterstitialMaxPerDay`
- **빈도 제어**: Supabase에서 실시간 제어 가능

**주요 기능**:
```kotlin
private suspend fun isInterstitialEnabledFromPolicy(): Boolean {
    val policy = adPolicyRepository.getPolicy().getOrNull()
    
    // 정책 없으면 기본값 true
    if (policy == null) {
        return true
    }
    
    // is_active가 false이면 모든 광고 비활성화
    if (!policy.isActive) {
        return false
    }
    
    // 개별 플래그 확인
    return policy.adInterstitialEnabled
}
```

**빈도 제한 체크**:
```kotlin
// Supabase에서 설정한 값 사용
val maxPerHour = policy.adInterstitialMaxPerHour  // 기본값: 2
val maxPerDay = policy.adInterstitialMaxPerDay    // 기본값: 15

// 시간당/일일 카운트 체크
if (hourlyCount >= maxPerHour) {
    Log.d(TAG, "❌ 시간당 제한 도달 ($hourlyCount/$maxPerHour)")
    return false
}
```

**표시 시점**:
- 코드 목록 → 홈 화면 이동 시
- 메트로놈/튜너 → 홈 화면 이동 시
- More → 설정 화면 이동 시

---

### 3️⃣ **앱 오프닝 광고 (App Open Ad)** ✅

**연동 상태**: **완전 연동**

**파일**: `AppOpenAdManager.kt`
- **Supabase 정책 조회**: `AdPolicyRepository` 사용
- **확인 필드**: `adAppOpenEnabled`
- **갱신 방식**: 광고 표시 시점마다 정책 확인

**주요 기능**:
```kotlin
private suspend fun isAppOpenEnabledFromPolicy(): Boolean {
    val policy = adPolicyRepository.getPolicy().getOrNull()
    
    // 정책 없으면 기본값 true
    if (policy == null) {
        return true
    }
    
    // is_active가 false이면 모든 광고 비활성화
    if (!policy.isActive) {
        return false
    }
    
    // 개별 플래그 확인
    return policy.adAppOpenEnabled
}
```

**표시 시점**:
- 앱 첫 실행 (콜드 스타트)
- 백그라운드에서 돌아올 때 (웜 스타트)
- 4시간 이상 경과 시

**UI 연동**:
- `PocketUkuleleApplication`의 `isShowingAppOpenAd` StateFlow로 상태 관리
- 광고 표시 중에는 배너 광고 숨김

---

## 🗄️ Supabase 테이블 구조

### **ad_policy 테이블**

```sql
CREATE TABLE ad_policy (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    app_id TEXT UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- 광고 ON/OFF
    ad_app_open_enabled BOOLEAN DEFAULT TRUE,
    ad_interstitial_enabled BOOLEAN DEFAULT TRUE,
    ad_banner_enabled BOOLEAN DEFAULT TRUE,
    
    -- 광고 빈도 제어
    ad_interstitial_max_per_hour INT DEFAULT 2,
    ad_interstitial_max_per_day INT DEFAULT 15
);
```

---

## 🔄 데이터 모델

### **AdPolicy.kt**

```kotlin
@Serializable
data class AdPolicy(
    val appId: String,
    val isActive: Boolean = true,
    
    // 광고 ON/OFF
    val adAppOpenEnabled: Boolean = true,
    val adInterstitialEnabled: Boolean = true,
    val adBannerEnabled: Boolean = true,
    
    // 빈도 제어
    val adInterstitialMaxPerHour: Int = 2,
    val adInterstitialMaxPerDay: Int = 15
)
```

---

## 📡 AdPolicyRepository

### 주요 기능

1. **Supabase 조회**:
   ```kotlin
   suspend fun getPolicy(): Result<AdPolicy?>
   ```
   - `ad_policy` 테이블에서 `app_id`로 정책 조회
   - 3분 캐싱으로 네트워크 요청 최소화

2. **캐시 관리**:
   - 캐시 지속 시간: 3분 (긴급 대응 가능 + 효율적)
   - 캐시 초기화: `clearCache()`
   - 동기 조회: `getCachedPolicy()`

3. **장애 대응**:
   - Supabase 장애 시 기본값 사용 (`true`)
   - 정책이 없어도 앱 작동 가능

---

## 🎯 제어 로직

### 계층 구조

```
1. is_active = false
   └─> 모든 광고 비활성화

2. is_active = true
   └─> 개별 플래그 확인
       ├─> adAppOpenEnabled
       ├─> adInterstitialEnabled
       └─> adBannerEnabled
```

### 예시 시나리오

#### 시나리오 1: 모든 광고 끄기
```json
{
  "is_active": false,
  "ad_app_open_enabled": true,  // 무시됨
  "ad_interstitial_enabled": true,  // 무시됨
  "ad_banner_enabled": true  // 무시됨
}
```
**결과**: 모든 광고 비활성화 ❌

#### 시나리오 2: 배너만 끄기
```json
{
  "is_active": true,
  "ad_app_open_enabled": true,
  "ad_interstitial_enabled": true,
  "ad_banner_enabled": false
}
```
**결과**: 
- 배너 광고: ❌
- 전면 광고: ✅
- 앱오프닝 광고: ✅

#### 시나리오 3: 전면 광고 빈도 낮추기
```json
{
  "is_active": true,
  "ad_interstitial_enabled": true,
  "ad_interstitial_max_per_hour": 1,
  "ad_interstitial_max_per_day": 5
}
```
**결과**: 전면 광고 표시 횟수 제한

---

## 📊 광고 표시 흐름도

### 배너 광고
```
MainActivity 시작
  ↓
LaunchedEffect 실행
  ↓
3분마다 AdPolicyRepository.getPolicy()
  ↓
adBannerEnabled 확인
  ↓
isBannerEnabled 상태 업데이트
  ↓
TopBannerAd() 또는 TopBannerAdPlaceholder() 표시
```

### 전면 광고
```
화면 전환 (예: 코드목록 → 홈)
  ↓
InterstitialAdManager.tryShowAd()
  ↓
isInterstitialEnabledFromPolicy() 확인
  ↓
빈도 제한 체크 (시간당/일일)
  ↓
광고 표시 또는 스킵
```

### 앱오프닝 광고
```
앱 시작 또는 포그라운드 진입
  ↓
AppOpenAdManager.showAdIfAvailable()
  ↓
isAppOpenEnabledFromPolicy() 확인
  ↓
광고 표시 또는 스킵
  ↓
isShowingAppOpenAd 상태 업데이트
  ↓
배너 광고 숨김/표시
```

---

## 🔒 RLS (Row Level Security) 정책

### 현재 정책
- `is_active = TRUE`인 정책만 조회 가능
- 비활성화된 정책은 클라이언트에서 접근 불가

### 구현 방식
현재는 **클라이언트 필터링** 사용:
```kotlin
val allPolicies = client.from("ad_policy")
    .select()
    .decodeList<AdPolicy>()

val policy = allPolicies.firstOrNull { it.appId == appId }
```

**개선 제안**: RLS를 활용한 서버 필터링
```sql
-- RLS 정책 예시 (현재 미사용)
CREATE POLICY "Enable read for active policies"
ON ad_policy FOR SELECT
USING (is_active = TRUE);
```

---

## 📝 로그 출력

### 배너 광고
```
MainActivity: [정책] 배너 광고 활성화
MainActivity: 🎯 배너 광고 정책: 활성화
```

### 전면 광고
```
InterstitialAdManager: [정책] 전면 광고 활성화
InterstitialAdManager: ⏰ 시간당 카운트 리셋
InterstitialAdManager: ✅ 광고 표시 가능
```

### 앱오프닝 광고
```
AppOpenAdManager: [정책] 앱 오픈 광고 활성화
AppOpenAdManager: ✅ 광고 표시 시작
```

### AdPolicyRepository
```
AdPolicyRepo: ===== Ad Policy Fetch Started =====
AdPolicyRepo: 🔄 Supabase에서 광고 정책 새로 가져오기
AdPolicyRepo: ✅ 광고 정책 발견!
AdPolicyRepo:   - is_active: true
AdPolicyRepo:   - App Open Ad: true
AdPolicyRepo:   - Interstitial Ad: true
AdPolicyRepo:   - Banner Ad: true
AdPolicyRepo:   - Max Per Hour: 2
AdPolicyRepo:   - Max Per Day: 15
AdPolicyRepo: ===== Ad Policy Fetch Completed =====
```

---

## 🎛️ 실시간 제어 가능 항목

### Supabase 콘솔에서 즉시 변경 가능:

1. **전체 광고 ON/OFF**:
   - `is_active`: `true` → `false`
   - 효과: 모든 광고 즉시 비활성화 (3분 이내)

2. **개별 광고 ON/OFF**:
   - `ad_app_open_enabled`
   - `ad_interstitial_enabled`
   - `ad_banner_enabled`

3. **전면 광고 빈도**:
   - `ad_interstitial_max_per_hour` (기본: 2)
   - `ad_interstitial_max_per_day` (기본: 15)

### 적용 시간:
- **배너 광고**: 최대 3분 후 (LaunchedEffect 주기)
- **전면 광고**: 다음 광고 시도 시 즉시
- **앱오프닝 광고**: 다음 광고 시도 시 즉시

---

## 🛡️ 장애 대응

### Supabase 장애 시나리오

1. **네트워크 오류**:
   ```kotlin
   val policy = adPolicyRepository.getPolicy().getOrNull()
   // policy == null → 기본값 true 사용
   ```
   - 모든 광고 계속 표시 (사용자 경험 우선)

2. **RLS 정책 오류**:
   - 클라이언트 필터링으로 우회
   - `allPolicies.firstOrNull { it.appId == appId }`

3. **캐시 활용**:
   - 3분간 캐시 사용으로 네트워크 부담 최소화
   - 일시적 장애 시에도 정상 작동

---

## 📈 성능 최적화

### 네트워크 요청 최소화
- **3분 캐싱**: 불필요한 Supabase 요청 방지
- **lazy 초기화**: 필요할 때만 Repository 생성
- **코루틴 활용**: 메인 스레드 블로킹 방지

### 메모리 효율
- **StateFlow 사용**: Compose 상태 관리
- **캐시 초기화**: `clearCache()` 메서드 제공

---

## 🔍 확인 방법

### Logcat 필터링
```
tag:AdPolicyRepo OR tag:InterstitialAdManager OR tag:AppOpenAdManager OR tag:MainActivity
```

### 테스트 체크리스트

1. **배너 광고**:
   - [ ] Supabase `ad_banner_enabled = false` 설정
   - [ ] 3분 대기
   - [ ] 배너 광고 숨김 확인

2. **전면 광고**:
   - [ ] Supabase `ad_interstitial_enabled = false` 설정
   - [ ] 화면 전환 (코드목록 → 홈)
   - [ ] 전면 광고 미표시 확인

3. **앱오프닝 광고**:
   - [ ] Supabase `ad_app_open_enabled = false` 설정
   - [ ] 앱 재시작
   - [ ] 앱오프닝 광고 미표시 확인

4. **전체 광고 OFF**:
   - [ ] Supabase `is_active = false` 설정
   - [ ] 3분 대기
   - [ ] 모든 광고 미표시 확인

---

## 📁 관련 파일

### 광고 관리
- `InterstitialAdManager.kt` - 전면 광고
- `AppOpenAdManager.kt` - 앱오프닝 광고
- `MainActivity.kt` - 배너 광고 (TopBannerAd 컴포저블)

### Supabase 연동
- `AdPolicyRepository.kt` - 광고 정책 조회
- `AdPolicy.kt` - 데이터 모델

### 앱 설정
- `PocketChordApplication.kt` - Supabase 클라이언트 초기화
- `BuildConfig.SUPABASE_APP_ID` - 앱 식별자

---

## ✅ 최종 결론

### 모든 광고가 Supabase와 완전히 연동되어 있음

| 광고 타입 | Supabase 연동 | 실시간 제어 | 빈도 제어 |
|-----------|--------------|------------|----------|
| **배너 광고** | ✅ | ✅ (3분 이내) | - |
| **전면 광고** | ✅ | ✅ (즉시) | ✅ (시간당/일일) |
| **앱오프닝 광고** | ✅ | ✅ (즉시) | - |

### 주요 장점

1. **실시간 제어**: Supabase 콘솔에서 즉시 광고 ON/OFF 가능
2. **세밀한 제어**: 개별 광고 타입 독립적 제어
3. **빈도 제어**: 전면 광고 표시 횟수 실시간 조정
4. **장애 대응**: Supabase 장애 시에도 정상 작동 (기본값 사용)
5. **성능 최적화**: 3분 캐싱으로 네트워크 부담 최소화
6. **독립적 운영**: app_policy와 분리된 광고 전용 정책

### 운영 가이드

**긴급 광고 중단**:
```sql
UPDATE ad_policy 
SET is_active = FALSE 
WHERE app_id = 'com.sweetapps.pocketukulele';
```
→ 3분 이내 모든 광고 중단

**특정 광고만 중단**:
```sql
UPDATE ad_policy 
SET ad_banner_enabled = FALSE 
WHERE app_id = 'com.sweetapps.pocketukulele';
```
→ 배너 광고만 중단

**전면 광고 빈도 낮추기**:
```sql
UPDATE ad_policy 
SET ad_interstitial_max_per_hour = 1,
    ad_interstitial_max_per_day = 5
WHERE app_id = 'com.sweetapps.pocketukulele';
```
→ 전면 광고 표시 제한

---

**보고서 작성일**: 2025-11-13  
**버전**: v1.0  
**작성자**: AI Assistant

