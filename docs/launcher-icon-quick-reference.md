# PocketUkulele 앱 아이콘 교체 실습 가이드

> 🎯 **PocketUkulele 프로젝트 전용 가이드**
> 
> 현재 프로젝트의 아이콘 구조를 기반으로 한 실전 교체 가이드입니다.

---

## 📋 현재 프로젝트 아이콘 구조 분석

### 기존 파일 현황
```
app/src/main/res/
├── drawable/
│   ├── ic_launcher_background.xml    (Vector - 흰색 배경)
│   ├── ic_launcher_foreground.xml    (Vector - 우쿨렐레 그래픽)
│   └── ic_launcher_monochrome.xml    (Vector - 모노크롬)
│
├── mipmap-anydpi/
│   ├── ic_launcher.xml               (Adaptive Icon 정의)
│   └── ic_launcher_round.xml         (원형 아이콘 정의)
│
├── mipmap-mdpi/
│   ├── ic_launcher.webp              (48x48)
│   └── ic_launcher_round.webp
│
├── mipmap-hdpi/
│   ├── ic_launcher.webp              (72x72)
│   └── ic_launcher_round.webp
│
├── mipmap-xhdpi/
│   ├── ic_launcher.webp              (96x96)
│   └── ic_launcher_round.webp
│
├── mipmap-xxhdpi/
│   ├── ic_launcher.webp              (144x144)
│   └── ic_launcher_round.webp
│
└── mipmap-xxxhdpi/
    ├── ic_launcher.webp              (192x192)
    └── ic_launcher_round.webp
```

### 현재 Adaptive Icon 설정
```xml
<!-- res/mipmap-anydpi/ic_launcher.xml -->
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
```

---

## 🔄 교체 시나리오 선택

### 시나리오 A: Vector Drawable로 교체 (권장)
- **장점**: 확장성 좋음, 파일 크기 작음, 수정 용이
- **단점**: SVG 변환 작업 필요
- **적합한 경우**: 로고가 단순하거나 SVG 파일이 있는 경우

### 시나리오 B: PNG 이미지로 교체
- **장점**: 간단하고 빠름, 복잡한 그래픽 지원
- **단점**: 파일 크기 큼, 수정 어려움
- **적합한 경우**: 복잡한 그래픽이나 사진 기반 아이콘

---

## 🎨 시나리오 A: Vector Drawable로 교체

### 준비 단계
1. **SVG 파일 준비**:
   - `ic_launcher_foreground.svg` (전경)
   - `ic_launcher_background.svg` (배경) - 또는 단색 사용
   - `ic_launcher_monochrome.svg` (모노크롬)

2. **SVG to Vector 변환**:
   - Android Studio: New > Vector Asset > Local file 선택
   - 또는 온라인: [svg2vector.com](https://svg2vector.com/)

### 단계별 실행

#### Step 1: Foreground 교체

**방법 1: Android Studio Vector Asset 사용**
```
1. app/src/main/res 우클릭
2. New > Vector Asset
3. Asset Type: Local file (SVG, PSD)
4. Path: ic_launcher_foreground.svg 선택
5. Name: ic_launcher_foreground_temp (임시 이름)
6. Next > Finish
7. 생성된 XML 내용을 기존 ic_launcher_foreground.xml에 복사
```

**방법 2: 직접 XML 수정**
```xml
<!-- res/drawable/ic_launcher_foreground.xml -->
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    
    <!-- 여기에 새로운 path 데이터 삽입 -->
    <path
        android:fillColor="#FF6B6B"
        android:pathData="M256,128 L384,256 L256,384 L128,256 Z" />
    
</vector>
```

#### Step 2: Background 교체

**옵션 A: 단색 배경 (간단)**
```xml
<!-- res/drawable/ic_launcher_background.xml -->
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#4CAF50"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

**옵션 B: 그라디언트 배경**
```xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path android:pathData="M0,0h512v512h-512z">
        <aapt:attr name="android:fillColor">
            <gradient
                android:type="linear"
                android:startX="0"
                android:startY="0"
                android:endX="512"
                android:endY="512"
                android:startColor="#667eea"
                android:endColor="#764ba2" />
        </aapt:attr>
    </path>
</vector>
```

#### Step 3: Monochrome 교체
```xml
<!-- res/drawable/ic_launcher_monochrome.xml -->
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    
    <!-- 단순화된 흑백 버전 -->
    <path
        android:fillColor="#000000"
        android:pathData="M256,128 L384,256 L256,384 L128,256 Z" />
    
</vector>
```

#### Step 4: Legacy 아이콘 재생성

Android Studio Image Asset Studio 사용:
```
1. res 우클릭 > New > Image Asset
2. Icon Type: Launcher Icons (Adaptive and Legacy)
3. Foreground Layer: Source Asset > Image > (512x512 합성 이미지)
4. Background Layer: 이미 설정된 경우 Skip 가능
5. Next > Finish
```

**또는 온라인 도구 사용:**
1. Foreground + Background 합성 이미지 512x512 생성
2. [Icon Kitchen](https://icon.kitchen/) 업로드
3. 모든 크기 다운로드
4. 각 mipmap 폴더에 배치

---

## 🖼️ 시나리오 B: PNG 이미지로 교체

### 준비 단계
```
✅ ic_launcher_foreground_512.png (512x512, 투명 배경)
✅ ic_launcher_background_512.png (512x512, 불투명)
✅ ic_launcher_monochrome_512.png (512x512, 흑백, 투명)
```

### 단계별 실행

#### Step 1: PNG 파일 복사
```
app/src/main/res/drawable/ 폴더에 복사:
- ic_launcher_foreground_512.png
- ic_launcher_background_512.png
- ic_launcher_monochrome_512.png
```

#### Step 2: XML 파일 수정

**Foreground:**
```xml
<!-- res/drawable/ic_launcher_foreground.xml -->
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground_512"
    android:gravity="center" />
```

**Background:**
```xml
<!-- res/drawable/ic_launcher_background.xml -->
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_background_512" />
```

**Monochrome:**
```xml
<!-- res/drawable/ic_launcher_monochrome.xml -->
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_monochrome_512"
    android:gravity="center" />
```

#### Step 3: Adaptive Icon XML 확인
```xml
<!-- res/mipmap-anydpi/ic_launcher.xml -->
<!-- 이미 올바르게 설정되어 있으면 수정 불필요 -->
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
```

#### Step 4: Legacy 아이콘 생성

**방법 A: Image Asset Studio (자동)**
```
1. res 우클릭 > New > Image Asset
2. Foreground: ic_launcher_foreground_512.png
3. Background: ic_launcher_background_512.png
4. Next > Finish
```

**방법 B: 온라인 도구 (수동)**
1. Foreground와 Background를 합성한 512x512 이미지 생성
2. [easyappicon.com](https://easyappicon.com/)에 업로드
3. Android용 모든 크기 다운로드
4. 각 mipmap 폴더에 복사:
   ```
   mipmap-mdpi/ic_launcher.png (48x48)
   mipmap-hdpi/ic_launcher.png (72x72)
   mipmap-xhdpi/ic_launcher.png (96x96)
   mipmap-xxhdpi/ic_launcher.png (144x144)
   mipmap-xxxhdpi/ic_launcher.png (192x192)
   ```

---

## 🔧 크기 및 위치 조정

### 문제: 아이콘이 너무 큼

**Vector Drawable의 경우:**
```xml
<vector
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="600"  ← 512에서 600으로 증가 = 아이콘 축소
    android:viewportHeight="600">
```

**Bitmap의 경우:**
```xml
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground_512"
    android:gravity="center"
    android:scaleType="fitCenter" />
```

### 문제: 아이콘이 너무 작음

**Vector Drawable의 경우:**
```xml
<vector
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="400"  ← 512에서 400으로 감소 = 아이콘 확대
    android:viewportHeight="400">
```

### 문제: 아이콘이 중앙에서 벗어남

**path 데이터를 translate로 조정:**
```xml
<vector>
    <group
        android:translateX="20"
        android:translateY="-10">
        <path android:pathData="..." />
    </group>
</vector>
```

---

## 🧪 테스트 절차

### 1. 프로젝트 클린 및 빌드
```cmd
cd G:\Workspace\PocketUkulele
gradlew clean
gradlew assembleDebug
```

### 2. 앱 설치
```cmd
# 기존 앱 제거 (캐시 완전 초기화)
gradlew uninstallDebug

# 새로 설치
gradlew installDebug
```

### 3. 다양한 환경에서 확인

#### Android 7.1 이하 (Legacy)
- 에뮬레이터: Nexus 5 (API 25)
- 확인: 고정 크기 아이콘만 표시

#### Android 8.0 - 12 (Adaptive)
- 에뮬레이터: Pixel 5 (API 30 또는 31)
- 확인: Foreground + Background 레이어링

#### Android 13+ (Monochrome)
- 에뮬레이터: Pixel 6 (API 33+)
- 설정 > 배경화면 및 스타일 > 테마 아이콘 켜기
- 확인: 시스템 색상으로 칠해진 Monochrome 아이콘

### 4. 프리뷰 확인

**Android Studio 내장 프리뷰:**
```
1. res/mipmap-anydpi/ic_launcher.xml 파일 열기
2. 우측 Design 탭 클릭
3. 다양한 형태 프리뷰 확인
```

**온라인 프리뷰:**
1. [adapticon.tooo.io](https://adapticon.tooo.io/) 접속
2. Foreground SVG 업로드
3. Background 색상/이미지 설정
4. 실시간 다양한 형태 확인

---

## 📝 체크리스트

### 교체 작업
- [ ] Foreground 레이어 교체 완료
- [ ] Background 레이어 교체 완료
- [ ] Monochrome 레이어 교체 완료
- [ ] `ic_launcher.xml` 파일 확인
- [ ] `ic_launcher_round.xml` 파일 확인
- [ ] Legacy 아이콘 재생성 (모든 mipmap 크기)

### 빌드 및 테스트
- [ ] `gradlew clean` 실행
- [ ] `gradlew assembleDebug` 성공
- [ ] 앱 제거 후 재설치
- [ ] Android 7.1 이하에서 확인
- [ ] Android 8.0 - 12에서 확인
- [ ] Android 13+에서 Monochrome 확인

### 시각적 확인
- [ ] 아이콘 크기 적절함
- [ ] 아이콘 위치 중앙 정렬
- [ ] Safe Zone 내 주요 콘텐츠 배치
- [ ] 색상 대비 충분함
- [ ] 다양한 형태(원형, 사각형 등)에서 잘 보임

### 최종 확인
- [ ] 앱 드로어에서 정상 표시
- [ ] 홈 화면 바로가기 정상
- [ ] 설정 > 앱 정보에서 정상
- [ ] 알림에서 정상
- [ ] Release 빌드에서도 동일하게 작동

---

## 🐛 트러블슈팅 - 프로젝트 특화

### 문제: WebP 파일이 안 보임
```
원인: 일부 이미지 뷰어가 WebP 지원 안 함
해결: Android Studio나 웹 브라우저에서 확인
```

### 문제: Vector Drawable 빌드 오류
```xml
<!-- 잘못된 예 -->
<path android:pathData="invalid path" />

<!-- 올바른 예 -->
<path android:pathData="M256,256 L384,384" />
```

**해결:**
- SVG 변환 도구 재사용
- 또는 PNG로 대체

### 문제: 기존 아이콘 백업 필요
```cmd
# Git으로 백업 (권장)
git add .
git commit -m "backup: 기존 아이콘 백업"

# 또는 수동 복사
xcopy app\src\main\res\drawable\ic_launcher_*.* backup\drawable\ /Y
xcopy app\src\main\res\mipmap-*\ic_launcher*.* backup\mipmap\ /Y /S
```

### 문제: Gradle 빌드 캐시
```cmd
# 완전한 클린
gradlew clean
gradlew cleanBuildCache

# 캐시 삭제 (Windows)
rd /s /q .gradle\caches
rd /s /q app\build

# 재빌드
gradlew assembleDebug
```

---

## 💡 PocketUkulele 전용 팁

### 1. 기존 디자인 유지
현재 프로젝트는 Vector Drawable을 사용하고 있으므로:
- 동일한 방식으로 유지하면 일관성 유지
- Gradient 효과도 이미 사용 중 (Foreground에 linear gradient)

### 2. 브랜드 색상 활용
기존 아이콘의 색상 팔레트:
```
Foreground: #FF8377 → #CB4645 (그라디언트)
Background: #FFFFFF (흰색)
```

새 아이콘에도 유사한 색상 사용 권장

### 3. 음악 앱 특성 반영
- 심플하고 인식하기 쉬운 디자인
- 음악 관련 아이콘 요소 (우쿨렐레, 음표 등)
- 친근하고 부드러운 느낌

### 4. 다크 모드 대응
현재 앱이 다크 모드를 지원하므로:
- 아이콘도 다크 배경에서 잘 보이는지 확인
- Background를 너무 어둡게 하지 않기

---

## 🎓 실습 예제

### 예제 1: 단순한 텍스트 아이콘
```xml
<!-- Foreground -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M150,200 h212 v112 h-212 z" />
    <!-- 간단한 사각형 -->
</vector>

<!-- Background -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#2196F3"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

### 예제 2: 원형 아이콘
```xml
<!-- Foreground -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M256,256 m-100,0 a100,100 0,1,1 200,0 a100,100 0,1,1 -200,0" />
    <!-- 원형 -->
</vector>
```

### 예제 3: 이미지 + 단색 배경
```xml
<!-- Foreground: PNG -->
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground_512"
    android:gravity="center" />

<!-- Background: 단색 -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#FF5722"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

---

## 📚 추가 참조 자료

- [launcher-icon-replacement-guide.md](./launcher-icon-replacement-guide.md) - 전체 가이드
- [launcher-icon-quick-reference.md](./launcher-icon-quick-reference.md) - 빠른 참조
- [Material Design - Product Icons](https://material.io/design/iconography/product-icons.html)

---

**문서 버전:** v1.0 (2025-11-13)  
**프로젝트:** PocketUkulele  
**작성자:** AI Assistant
# 앱 아이콘 교체 빠른 참조 가이드

> 📌 **빠른 실행을 위한 요약 가이드** - 자세한 설명은 [launcher-icon-replacement-guide.md](./launcher-icon-replacement-guide.md) 참조

---

## ⚡ 5분 안에 아이콘 교체하기

### 준비물
- ✅ `ic_launcher_foreground_512.png` (512x512, 투명 배경)
- ✅ `ic_launcher_background_512.png` (512x512, 불투명)
- ✅ `ic_launcher_monochrome_512.png` (512x512, 흑백, 투명 배경)

### 단계

#### 1️⃣ Image Asset Studio 열기 (30초)
```
Android Studio > 프로젝트 뷰 > app/src/main/res 우클릭
> New > Image Asset
```

#### 2️⃣ Foreground 설정 (1분)
- Icon Type: `Launcher Icons (Adaptive and Legacy)` ✅
- Name: `ic_launcher` (변경 금지)
- **Foreground Layer** 탭:
  - Source Asset: `Image`
  - Path: `foreground_512.png` 선택
  - Resize: 100% (또는 필요시 조정)

#### 3️⃣ Background 설정 (1분)
- **Background Layer** 탭:
  - Source Asset: `Image` 또는 `Color`
  - Path: `background_512.png` 선택 (또는 색상 코드 입력)

#### 4️⃣ 생성 및 확인 (30초)
- **Next** > 파일 목록 확인 > **Finish**

#### 5️⃣ Monochrome 수동 추가 (2분)
1. `ic_launcher_monochrome_512.png`를 복사:
   ```
   app/src/main/res/drawable/ic_launcher_monochrome.png
   ```

2. `res/drawable/ic_launcher_monochrome.xml` 생성:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/ic_launcher_monochrome" />
   ```

3. `res/mipmap-anydpi/ic_launcher.xml` 수정 - monochrome 라인 추가:
   ```xml
   <adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
       <background android:drawable="@drawable/ic_launcher_background" />
       <foreground android:drawable="@drawable/ic_launcher_foreground" />
       <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
   </adaptive-icon>
   ```

4. `res/mipmap-anydpi/ic_launcher_round.xml`도 동일하게 수정

#### 6️⃣ 빌드 및 테스트 (30초)
```cmd
gradlew clean
gradlew installDebug
```

---

## 🔧 필수 조절 항목

### 아이콘이 너무 작거나 큰 경우

**Vector Drawable XML에서 viewportWidth/Height 조정:**
```xml
<vector
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"  ← 작게 → 아이콘 확대
    android:viewportHeight="512"> ← 크게 → 아이콘 축소
```

**또는 Bitmap에서 scaleType 추가:**
```xml
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground"
    android:scaleType="fitCenter" />
```

### 아이콘이 잘리는 경우

**Safe Zone 규칙 확인:**
- 512x512 기준: 중앙 **336x336** 영역에 주요 콘텐츠 배치
- 가장자리 88px씩은 잘릴 수 있음
- **해결:** 원본 이미지를 중앙으로 재배치하거나 크기 축소

---

## 📁 파일 구조 체크리스트

생성되어야 할 파일들:

```
✅ res/mipmap-anydpi/ic_launcher.xml (Adaptive Icon 정의)
✅ res/mipmap-anydpi/ic_launcher_round.xml (원형 아이콘)
✅ res/drawable/ic_launcher_foreground.xml 또는 .png
✅ res/drawable/ic_launcher_background.xml 또는 .png
✅ res/drawable/ic_launcher_monochrome.xml 또는 .png (Android 13+)
✅ res/mipmap-mdpi/ic_launcher.webp (48x48)
✅ res/mipmap-hdpi/ic_launcher.webp (72x72)
✅ res/mipmap-xhdpi/ic_launcher.webp (96x96)
✅ res/mipmap-xxhdpi/ic_launcher.webp (144x144)
✅ res/mipmap-xxxhdpi/ic_launcher.webp (192x192)
✅ res/mipmap-*/ic_launcher_round.webp (각 크기별)
```

---

## 🧪 테스트 체크리스트

| 항목 | 체크 |
|------|------|
| Android 7.1 이하 (Legacy 아이콘) | ⬜ |
| Android 8.0 - 12 (Adaptive 아이콘) | ⬜ |
| Android 13+ (Monochrome 테마 아이콘) | ⬜ |
| 앱 드로어에서 확인 | ⬜ |
| 홈 화면 바로가기 | ⬜ |
| 설정 > 앱 정보 화면 | ⬜ |
| 최근 앱(멀티태스킹) 화면 | ⬜ |
| 알림 아이콘 | ⬜ |
| 다양한 런처 (Pixel, Samsung, etc.) | ⬜ |
| 다양한 형태 (원형, 사각형, etc.) | ⬜ |

---

## 🚨 자주 발생하는 문제 해결

### 1. 아이콘이 업데이트 안 됨
```cmd
gradlew clean
gradlew uninstallDebug
gradlew installDebug
```
또는: Android Studio > File > Invalidate Caches / Restart

### 2. 아이콘이 흐림
- 512x512 고해상도 PNG 사용 확인
- Vector Drawable로 변환 권장

### 3. Monochrome 아이콘이 안 보임
- Android 13+ 디바이스에서 테스트
- 설정 > 배경화면 및 스타일 > 테마 아이콘 활성화
- `mipmap-anydpi/ic_launcher.xml`에 `<monochrome>` 태그 확인

### 4. 배경이 투명하게 보임
```xml
<!-- Background를 단색으로 수정 -->
<vector>
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

---

## 📊 아이콘 크기 참조표

| Density | Resolution | Example Device |
|---------|-----------|----------------|
| mdpi    | 48x48     | Baseline       |
| hdpi    | 72x72     | Old phones     |
| xhdpi   | 96x96     | Nexus 5        |
| xxhdpi  | 144x144   | Pixel 3        |
| xxxhdpi | 192x192   | Pixel 6        |

**Safe Zone 계산:**
- 각 해상도의 66% 영역에 주요 콘텐츠 배치
- 예: 192x192 → 127x127 Safe Zone

---

## 🎨 디자인 가이드라인 요약

### Foreground (전경)
- ✅ 투명 배경 사용
- ✅ 주요 요소는 중앙 66% 안에
- ✅ 다채로운 색상 가능

### Background (배경)
- ✅ 불투명 (전체 채움)
- ✅ 단색 또는 간단한 패턴
- ✅ Foreground와 조화로운 색상

### Monochrome (모노크롬)
- ✅ 흑백 단색 (#000000 또는 #FFFFFF)
- ✅ 투명 배경 필수
- ✅ 단순화된 실루엣
- ✅ 과도한 디테일 제거

---

## 🛠️ 유용한 도구

### 아이콘 생성
- [Icon Kitchen](https://icon.kitchen/) - 올인원 아이콘 생성기
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/) - 공식 도구

### 프리뷰
- [Adaptive Icon Preview](https://adapticon.tooo.io/) - 실시간 미리보기

### SVG to Vector
- [svg2vector](https://svg2vector.com/) - SVG → Android Vector

---

## 📝 AndroidManifest.xml 확인

```xml
<application
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    ...>
```

**변경 불필요** - 파일명이 `ic_launcher`이면 자동 연결됨

---

## 🎯 프로 팁

1. **Safe Zone 가이드 사용**: 512x512 PNG에 중앙 336x336 가이드라인 추가하여 디자인
2. **Vector Drawable 선호**: 확장성이 좋고 파일 크기 작음
3. **Monochrome 필수**: Android 13+ 사용자 경험 개선
4. **다양한 런처 테스트**: 제조사마다 다른 형태 적용
5. **브랜드 일관성**: iOS, Web 아이콘과 유사한 스타일 유지

---

## 📞 추가 지원

자세한 내용은 다음 문서 참조:
- [launcher-icon-replacement-guide.md](./launcher-icon-replacement-guide.md) - 전체 가이드
- [Android Developer - Adaptive Icons](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)

---

**문서 버전:** v1.0 (2025-11-13)

