# famtory 🐹

가족과 함께 쓰는 한줄 일기 앱. iOS SwiftUI + Firebase.

---

## 사전 준비

### 1. 도구 설치

```bash
brew install xcodegen
brew install firebase-cli   # 푸시 알림 Functions 배포 시
```

### 2. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com) → **프로젝트 추가**
2. **Authentication** → 로그인 제공업체 → **Apple** 활성화
3. **Firestore Database** → 데이터베이스 만들기 (프로덕션 모드)
4. **Cloud Messaging** → APNs 인증 키 업로드 (Apple Developer에서 발급)
5. **프로젝트 설정** → iOS 앱 추가 → Bundle ID: `com.famtory.app`
6. `GoogleService-Info.plist` 다운로드

### 3. GoogleService-Info.plist 배치

다운로드한 파일을 `Famtory/` 폴더 안에 넣으세요:

```
famtory/
└── Famtory/
    └── GoogleService-Info.plist  ← 여기
```

---

## Xcode 프로젝트 생성

```bash
cd famtory
xcodegen generate
open Famtory.xcodeproj
```

### Xcode 설정 (필수)

1. **Signing & Capabilities** → Team 선택
2. **+ Capability** → **Sign In with Apple** 추가
3. **+ Capability** → **Push Notifications** 추가
4. **+ Capability** → **Background Modes** → Remote notifications 체크

---

## Firestore 보안 규칙 배포

```bash
firebase login
firebase use <your-project-id>
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

---

## Cloud Functions 배포 (푸시 알림)

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

---

## 프로젝트 구조

```
Famtory/
├── App/               FamtoryApp, AppDelegate
├── Models/            FamtoryUser, Family, DiaryEntry
├── Services/          AuthService, FamilyService, DiaryService, NotificationService
├── ViewModels/        AuthViewModel, FamilyViewModel, HomeViewModel, CalendarViewModel
└── Views/
    ├── Auth/          SignInView
    ├── Onboarding/    FamilySetupView, CreateFamilyView, JoinFamilyView
    ├── Main/          RootView, HomeView, CalendarView, FamilyInfoView
    │                  DiaryEntryCard, WriteEntryView
    └── Components/    DesignSystem, EmojiPickerView
functions/             Cloud Functions (FCM 푸시)
firestore.rules        보안 규칙
firestore.indexes.json 인덱스
```

---

## 컬러 팔레트

| 이름 | 헥스 | 용도 |
|------|------|------|
| famBackground | `#FFF9F2` | 앱 배경 |
| famPrimary | `#F4A261` | 주요 액션, 강조 |
| famBlue | `#74B9FF` | 보조 액션 |
| famPink | `#FF8FAB` | 포인트 |
| famBrown | `#5C4033` | 본문 텍스트 |

---

## 앱 흐름

```
로그인 (Apple Sign In)
  └→ 신규: 가족 만들기 / 초대 코드 참여
       └→ 홈 (오늘 피드) ←→ 달력 ←→ 가족 정보
```
