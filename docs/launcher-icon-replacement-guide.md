# 안드로이드 앱 아이콘(런처 아이콘) 교체 가이드

## 목차
1. [개요](#1-개요)
2. [사전 준비](#2-사전-준비)
3. [아이콘 교체 방법](#3-아이콘-교체-방법)
4. [적용 후 필수 조절](#4-적용-후-필수-조절)
5. [테스트 및 검증](#5-테스트-및-검증)
6. [트러블슈팅](#6-트러블슈팅)

---

## 1. 개요

안드로이드에서 앱 아이콘(런처 아이콘)은 사용자가 홈 화면이나 앱 드로어에서 보게 되는 앱의 시각적 표현입니다. Android 8.0(API 레벨 26)부터는 **Adaptive Icon** 시스템을 사용하여 다양한 디바이스와 런처에서 일관된 아이콘을 표시합니다.

### Adaptive Icon 구조
- **Foreground Layer**: 아이콘의 주요 그래픽 요소
- **Background Layer**: 배경 레이어 (단색 또는 그래픽)
- **Monochrome Layer**: Android 13+ 테마 아이콘용 (선택사항이지만 권장)

### 아이콘 크기 요구사항
- **512x512px PNG**: 각 레이어(foreground, background, monochrome)
- **Safe Zone**: 중앙 66% 영역에 주요 콘텐츠 배치 (약 336x336px)
- **투명도**: Foreground와 Monochrome은 투명 배경 사용 가능

---

## 2. 사전 준비

### 2.1 필요한 파일 준비
다음 3개의 512x512px PNG 이미지를 준비합니다:

```
ic_launcher_foreground_512.png  # 전경 레이어 (투명 배경 권장)
ic_launcher_background_512.png  # 배경 레이어 (불투명)
ic_launcher_monochrome_512.png  # 모노크롬 레이어 (투명 배경, 흑백)
```

### 2.2 이미지 디자인 가이드라인

#### Foreground (전경)
- 투명 배경 권장
- 주요 아이콘 요소는 중앙 66% 영역 안에 배치
- 가장자리 33% 영역은 마스크에 의해 잘릴 수 있음
- 다양한 색상 사용 가능

#### Background (배경)
- 단색 또는 그래픽 패턴
- 전경과 조화로운 색상 선택
- 투명 영역 없이 전체 채움 권장

#### Monochrome (모노크롬)
- Android 13 이상의 테마 아이콘용
- 검정색(#000000) 또는 흰색(#FFFFFF) 단색
- 투명 배경 필수
- 단순화된 형태 권장

### 2.3 도구 준비
- **Android Studio** (권장): Image Asset Studio 내장
- 또는 수동 작업용: 이미지 편집 도구 + 온라인 변환 도구

---

## 3. 아이콘 교체 방법

### 방법 A: Android Studio Image Asset Studio 사용 (권장)

#### Step 1: Image Asset Studio 열기
1. Android Studio에서 프로젝트 열기
2. 프로젝트 뷰에서 `app/src/main/res` 폴더 우클릭
3. **New > Image Asset** 선택

#### Step 2: Foreground Layer 설정
1. **Icon Type**: `Launcher Icons (Adaptive and Legacy)` 선택
2. **Name**: `ic_launcher` 유지
3. **Foreground Layer** 탭:
   - **Source Asset Type**: `Image` 선택
   - **Path**: `ic_launcher_foreground_512.png` 선택
   - **Resize**: 적절한 크기로 조정 (기본 100% 또는 필요시 조절)
   - **Trim**: 불필요한 여백 제거 (Yes/No 선택)

#### Step 3: Background Layer 설정
1. **Background Layer** 탭 클릭:
   - **Source Asset Type**: `Image` 또는 `Color` 선택
     - Image: `ic_launcher_background_512.png` 선택
     - Color: 단색 배경일 경우 색상 코드 입력 (예: `#FFFFFF`)
   - **Resize**: 100% 또는 필요시 조절

#### Step 4: Legacy 및 Options 설정
1. **Options** 탭:
   - **Shape**: 프리뷰용 (실제 디바이스에서는 시스템이 결정)
   - **Generate Legacy Icons**: 체크 (Android 7.1 이하 지원)
   - **Generate Round Icon**: 체크 (원형 아이콘 지원)

#### Step 5: 생성 및 확인
1. **Next** 버튼 클릭
2. 생성될 파일 목록 확인:
   ```
   res/mipmap-anydpi/ic_launcher.xml
   res/mipmap-anydpi/ic_launcher_round.xml
   res/mipmap-mdpi/ic_launcher.webp (48x48)
   res/mipmap-hdpi/ic_launcher.webp (72x72)
   res/mipmap-xhdpi/ic_launcher.webp (96x96)
   res/mipmap-xxhdpi/ic_launcher.webp (144x144)
   res/mipmap-xxxhdpi/ic_launcher.webp (192x192)
   res/drawable/ic_launcher_foreground.xml
   res/drawable/ic_launcher_background.xml
   ```
3. **Finish** 클릭

#### Step 6: Monochrome Layer 수동 추가 (Android 13+)

**⚠️ 중요: Image Asset Studio는 Monochrome Layer를 지원하지 않으므로 수동으로 추가해야 합니다.**

**📌 파일명 규칙:**
- 원본 PNG 파일명은 **자유롭게** 사용 가능 (예: `my_icon.png`)
- `drawable/` 폴더 안의 리소스명은 **소문자와 언더스코어(_)만** 사용
- XML에서 참조하는 이름과 실제 파일명이 **일치**해야 함

**방법 1: PNG 이미지 사용**

1. 준비한 PNG 파일(어떤 이름이든 상관없음)을 다음 위치에 복사:
   ```
   app/src/main/res/drawable/ic_launcher_monochrome.png
   ```
   💡 **커스텀 이름 사용 가능**: 예를 들어 `my_app_mono.png`로 저장 가능

2. `res/drawable/ic_launcher_monochrome.xml` 생성:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/ic_launcher_monochrome" />
   ```
   💡 **커스텀 이름 예시**: PNG를 `my_app_mono.png`로 저장했다면:
   ```xml
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/my_app_mono" />
   ```

**방법 2: Vector Drawable 사용 (권장)**

SVG 파일이 있다면:
1. Android Studio에서 `res/drawable` 우클릭
2. **New > Vector Asset** 선택
3. **Local file** 선택 → SVG 파일 업로드 (파일명 제한 없음)
4. **Name**: `ic_launcher_monochrome` 입력
   💡 **커스텀 이름 가능**: 예를 들어 `app_icon_mono` 등 원하는 이름 사용
5. **Next > Finish**

**Adaptive Icon XML에 Monochrome 추가**

1. `res/mipmap-anydpi/ic_launcher.xml` 파일 열기 및 수정:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
       <background android:drawable="@drawable/ic_launcher_background" />
       <foreground android:drawable="@drawable/ic_launcher_foreground" />
       <!-- 👇 이 줄 추가 (기본 이름 사용 시) -->
       <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
   </adaptive-icon>
   ```
   💡 **커스텀 이름 사용 시**: drawable 이름을 변경했다면 참조도 변경
   ```xml
   <!-- 예: my_app_mono로 저장했다면 -->
   <monochrome android:drawable="@drawable/my_app_mono" />
   ```

2. `res/mipmap-anydpi/ic_launcher_round.xml` 파일도 동일하게 수정:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
       <background android:drawable="@drawable/ic_launcher_background" />
       <foreground android:drawable="@drawable/ic_launcher_foreground" />
       <!-- 👇 이 줄 추가 -->
       <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
   </adaptive-icon>
   ```

---

### 방법 B: 수동 교체 (고급 사용자)

#### Step 1: 배경 레이어 교체

**옵션 1: PNG 이미지로 교체**
1. `ic_launcher_background_512.png`를 다음 위치에 복사:
   ```
   app/src/main/res/drawable/ic_launcher_background.png
   ```

2. `res/drawable/ic_launcher_background.xml` 파일 수정:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/ic_launcher_background" />
   ```

**옵션 2: 단색 배경 사용**
```xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

#### Step 2: 전경 레이어 교체

**PNG 이미지로 교체:**
1. `ic_launcher_foreground_512.png`를 다음 위치에 복사:
   ```
   app/src/main/res/drawable/ic_launcher_foreground.png
   ```

2. `res/drawable/ic_launcher_foreground.xml` 파일 수정:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/ic_launcher_foreground" />
   ```

**또는 Vector Drawable 사용 (SVG 변환):**
- 온라인 도구 (예: svg2vector.com) 사용
- Android Studio의 Vector Asset 기능 사용

#### Step 3: 모노크롬 레이어 추가

1. `ic_launcher_monochrome_512.png`를 다음 위치에 복사:
   ```
   app/src/main/res/drawable/ic_launcher_monochrome.png
   ```

2. `res/drawable/ic_launcher_monochrome.xml` 생성 또는 수정:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <bitmap xmlns:android="http://schemas.android.com/apk/res/android"
       android:src="@drawable/ic_launcher_monochrome" />
   ```

#### Step 4: Adaptive Icon XML 확인

`res/mipmap-anydpi/ic_launcher.xml` 파일 확인:
```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
```

`res/mipmap-anydpi/ic_launcher_round.xml` 파일도 동일하게 확인:
```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
```

#### Step 5: Legacy 아이콘 생성 (Android 7.1 이하 지원)

다음 크기의 PNG 파일을 각 mipmap 폴더에 생성:
- `mipmap-mdpi/ic_launcher.png` (48x48)
- `mipmap-hdpi/ic_launcher.png` (72x72)
- `mipmap-xhdpi/ic_launcher.png` (96x96)
- `mipmap-xxhdpi/ic_launcher.png` (144x144)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192)

**자동 생성 방법:**
- 온라인 도구: [easyappicon.com](https://easyappicon.com/) 또는 [appicon.co](https://appicon.co/)
- 512x512 이미지를 합성한 최종 아이콘을 업로드하여 모든 크기 생성

#### Step 6: Round Icon 생성 (선택사항)

원형 아이콘을 지원하는 런처를 위해 동일한 크기로 생성:
- `mipmap-mdpi/ic_launcher_round.png` (48x48)
- `mipmap-hdpi/ic_launcher_round.png` (72x72)
- ... (동일한 크기 세트)

---

## 4. 적용 후 필수 조절

### 4.1 AndroidManifest.xml 확인

`app/src/main/AndroidManifest.xml` 파일에서 아이콘 참조 확인:
```xml
<application
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    ...>
```

### 4.2 크기 및 위치 조정

#### 문제: 아이콘이 너무 크거나 작게 보임

**Vector Drawable 사용 시:**
```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <!-- 내용 -->
</vector>
```
- `viewportWidth/Height` 값 조정: 작을수록 아이콘 확대, 클수록 축소

**Bitmap 사용 시:**
```xml
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground"
    android:gravity="center"
    android:scaleType="centerInside" />
```
- `android:scaleType` 속성 추가로 크기 조절

#### 문제: 아이콘이 잘림

Safe Zone 규칙 확인:
- 주요 콘텐츠를 중앙 66% 영역 내에 배치
- 512x512 이미지 기준: 중앙 336x336 영역
- 가장자리 88px씩은 잘릴 수 있음

**해결책:**
1. 원본 512x512 이미지를 편집하여 콘텐츠를 중앙으로 이동
2. 또는 padding을 고려한 디자인으로 재작성

### 4.3 색상 및 대비 조정

#### Background와 Foreground 색상 조화
```xml
<!-- Background: 단색 사용 예시 -->
<vector>
    <path
        android:fillColor="#4CAF50"
        android:pathData="M0,0h512v512h-512z" />
</vector>
```

#### Monochrome 레이어 최적화
Android 13+의 테마 아이콘은 시스템 색상으로 자동 칠해집니다:
- 단순하고 명확한 실루엣 사용
- 과도한 디테일 제거
- 불필요한 색상 제거 (검정 또는 흰색만 사용)

### 4.4 그라디언트 및 고급 효과 (선택사항)

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path android:pathData="M...">
        <aapt:attr name="android:fillColor">
            <gradient
                android:type="linear"
                android:startX="256"
                android:startY="0"
                android:endX="256"
                android:endY="512"
                android:startColor="#FF8377"
                android:endColor="#CB4645" />
        </aapt:attr>
    </path>
</vector>
```

---

## 5. 테스트 및 검증

### 5.1 빌드 및 실행

```cmd
gradlew clean
gradlew assembleDebug
```

앱을 실제 디바이스나 에뮬레이터에서 실행:
```cmd
gradlew installDebug
```

### 5.2 다양한 환경에서 테스트

#### Android 버전별 테스트
- **Android 7.1 이하**: Legacy 아이콘 확인
- **Android 8.0 - 12**: Adaptive 아이콘 (Foreground + Background)
- **Android 13+**: Monochrome 테마 아이콘 확인

#### 런처별 테스트
- Google Pixel Launcher
- Samsung One UI
- OnePlus OxygenOS
- 기타 커스텀 런처 (Nova Launcher, etc.)

#### 다양한 형태 확인
- **원형**: Circle
- **모서리 둥근 사각형**: Squircle
- **일반 사각형**: Square
- **모서리 둥근 사각형**: Rounded square
- **물방울**: Teardrop (일부 제조사)

### 5.3 시스템 설정에서 확인

1. **앱 드로어**: 설치된 앱 목록
2. **홈 화면**: 바로가기 아이콘
3. **설정 > 앱**: 앱 정보 화면
4. **최근 앱**: 멀티태스킹 화면
5. **알림**: 알림 아이콘
6. **Android 13+**: 설정 > 배경화면 및 스타일 > 테마 아이콘

### 5.4 프리뷰 도구 사용

**Android Studio Device Manager:**
1. Tools > Device Manager
2. 다양한 가상 디바이스에서 테스트

**온라인 프리뷰 도구:**
- [Adaptive Icon Preview](https://adapticon.tooo.io/)
- [Icon Kitchen](https://icon.kitchen/)

---

## 6. 트러블슈팅

### 문제 1: 아이콘이 업데이트되지 않음

**원인:**
- 캐시 문제
- 빌드 문제

**해결책:**
```cmd
# 프로젝트 클린
gradlew clean

# 캐시 무효화 (Android Studio)
File > Invalidate Caches / Restart...

# 앱 재설치
gradlew uninstallDebug
gradlew installDebug

# 디바이스 재부팅 (최후의 수단)
```

### 문제 2: 아이콘이 흐리거나 품질이 낮음

**원인:**
- 저해상도 이미지 사용
- 부적절한 스케일링

**해결책:**
1. 512x512px 고해상도 PNG 사용
2. Vector Drawable로 변환 (SVG 기반)
3. Image Asset Studio 재생성

### 문제 3: Monochrome 아이콘이 표시되지 않음

**원인:**
- Android 13 미만
- 테마 아이콘 비활성화

**해결책:**
1. Android 13+ 디바이스에서 테스트
2. 설정 > 배경화면 및 스타일 > 테마 아이콘 활성화
3. `res/mipmap-anydpi/ic_launcher.xml`에 `<monochrome>` 태그 확인

### 문제 4: 레거시 아이콘이 깨짐

**원인:**
- Legacy 아이콘 미생성
- 잘못된 크기

**해결책:**
1. Image Asset Studio로 재생성하여 모든 크기 자동 생성
2. 각 mipmap 폴더에 적절한 크기의 PNG 수동 배치:
   - mdpi: 48x48
   - hdpi: 72x72
   - xhdpi: 96x96
   - xxhdpi: 144x144
   - xxxhdpi: 192x192

### 문제 5: 아이콘 배경이 투명하게 보임

**원인:**
- Background 레이어가 투명함
- PNG의 투명 영역

**해결책:**
1. Background 레이어를 불투명하게 수정
2. 단색 배경 사용:
   ```xml
   <vector>
       <path
           android:fillColor="#FFFFFF"
           android:pathData="M0,0h512v512h-512z" />
   </vector>
   ```

### 문제 6: 아이콘 색상이 다르게 보임

**원인:**
- 색상 프로파일 문제
- sRGB vs Display P3

**해결책:**
1. PNG를 sRGB 색상 공간으로 저장
2. 이미지 편집 도구에서 색상 프로파일 확인 및 변환

---

## 부록 A: 체크리스트

### 디자인 단계
- [ ] Foreground 512x512 PNG 준비 (투명 배경)
- [ ] Background 512x512 PNG 또는 색상 코드 준비
- [ ] Monochrome 512x512 PNG 준비 (흑백, 투명 배경)
- [ ] Safe Zone(중앙 66%) 내에 주요 콘텐츠 배치 확인
- [ ] 색상 대비 및 가독성 확인

### 구현 단계
- [ ] Image Asset Studio 실행 또는 수동 파일 배치
- [ ] Foreground 레이어 교체
- [ ] Background 레이어 교체
- [ ] Monochrome 레이어 추가
- [ ] Adaptive Icon XML 확인 (`ic_launcher.xml`, `ic_launcher_round.xml`)
- [ ] Legacy 아이콘 생성 (모든 mipmap 크기)
- [ ] AndroidManifest.xml 아이콘 참조 확인

### 테스트 단계
- [ ] 프로젝트 클린 및 리빌드
- [ ] Android 7.1 이하에서 테스트
- [ ] Android 8.0 - 12에서 Adaptive 아이콘 테스트
- [ ] Android 13+에서 Monochrome 테마 아이콘 테스트
- [ ] 다양한 런처에서 형태별 테스트
- [ ] 앱 드로어, 홈 화면, 설정, 알림에서 확인
- [ ] 크기, 위치, 색상 최종 확인

### 배포 전 확인
- [ ] Release 빌드에서도 아이콘 정상 표시 확인
- [ ] ProGuard/R8 난독화 후에도 정상 작동 확인
- [ ] 앱 스토어 스크린샷에 새 아이콘 반영
- [ ] 앱 설명 및 마케팅 자료 업데이트

---

## 부록 B: 리소스 및 도구

### 디자인 도구
- **Figma**: [figma.com](https://www.figma.com/) - 협업 디자인 도구
- **Adobe Illustrator**: 벡터 그래픽 편집
- **Sketch**: macOS용 UI 디자인 도구
- **GIMP**: 무료 이미지 편집 도구

### 아이콘 생성 도구
- **Android Asset Studio**: [romannurik.github.io/AndroidAssetStudio](https://romannurik.github.io/AndroidAssetStudio/)
- **Icon Kitchen**: [icon.kitchen](https://icon.kitchen/)
- **Easy App Icon**: [easyappicon.com](https://easyappicon.com/)
- **App Icon Generator**: [appicon.co](https://appicon.co/)

### 프리뷰 및 테스트 도구
- **Adaptive Icon Preview**: [adapticon.tooo.io](https://adapticon.tooo.io/)
- **Shape Shifter**: [shapeshifter.design](https://shapeshifter.design/) - SVG/Vector 애니메이션 도구
- **Material Design Icons**: [material.io/resources/icons](https://material.io/resources/icons/)

### 공식 문서
- **Android Developer - Adaptive Icons**: [developer.android.com/develop/ui/views/launch/icon_design_adaptive](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- **Material Design - Product Icons**: [material.io/design/iconography/product-icons.html](https://material.io/design/iconography/product-icons.html)

### SVG to Vector Drawable 변환
- **svg2vector**: [svg2vector.com](https://svg2vector.com/)
- **Shapeshifter**: [shapeshifter.design](https://shapeshifter.design/)

---

## 부록 C: 고급 팁

### 1. Vector Drawable 최적화
```cmd
# Vector Drawable 최적화 도구
npx svgo ic_launcher_foreground.xml
```

### 2. WebP 형식 사용
Android Studio는 자동으로 WebP 형식을 사용하여 파일 크기 절약:
- 손실 없는 압축
- PNG보다 작은 파일 크기

### 3. 다크 모드 대응
Android 10+ 다크 모드에서도 잘 보이는 아이콘 디자인:
- 너무 어둡거나 밝지 않은 중간 톤 사용
- Background에 충분한 대비 제공

### 4. 애니메이션 Adaptive Icon (고급)
일부 런처는 아이콘 애니메이션을 지원하지만, 표준은 아님.
- 주로 Vector Drawable의 `<animated-vector>` 사용
- 런처 호환성 제한적

### 5. 브랜드 일관성 유지
- 다른 플랫폼(iOS, Web) 아이콘과 일관성 유지
- 동일한 색상 팔레트 및 스타일 사용
- Safe Zone 규칙은 플랫폼마다 다르므로 주의

---

## 버전 히스토리
- **v1.0** (2025-11-13): 초기 문서 작성

## 라이선스
이 문서는 프로젝트 내부 사용을 위해 작성되었습니다.

## 기여
문서 개선 사항이나 오류 발견 시 프로젝트 관리자에게 문의해주세요.

