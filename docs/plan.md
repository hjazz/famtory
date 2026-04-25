# Famtory — 가족 한줄일기 공유 앱

## Context
가족끼리 매일 한 줄씩 일기를 쓰고 공유하는 iOS 앱. 초대 코드로 가족 그룹을 만들고,
서로의 일기에 이모지 반응을 남기며, 달력으로 히스토리를 볼 수 있다.

**Stack:** iOS SwiftUI + Firebase (Auth/Firestore/FCM) + Apple Sign In  
**Dependencies:** Swift Package Manager로 Firebase iOS SDK 설치

---

## 디자인 테마 (앱 아이콘 기반)

**컨셉:** 안경 쓴 아빠 햄스터, 꽃핀 엄마 햄스터, 아기 햄스터가 함께 일기책을 읽는 따뜻하고 귀여운 세계관

**컬러 팔레트:**
- Background: `#FFF9F2` (따뜻한 아이보리)
- Primary: `#F4A261` (햄스터 갈색/오렌지)
- Blue: `#74B9FF` (아빠 셔츠 파랑)
- Pink: `#FF8FAB` (엄마 셔츠 핑크)
- Yellow: `#FDCB6E` (하트/반짝이 노랑)
- Green: `#7EC8A4` (배경 풀숲 그린)
- Text: `#5C4033` (따뜻한 다크 브라운)

**폰트:** SF Rounded (iOS 기본 둥근 폰트)  
**스타일:** 둥근 모서리, 파스텔 컬러, 부드러운 그림자, 넉넉한 패딩  
**앱 내 햄스터 이모지 활용:** 🐹 일기 카드 아바타, 빈 상태 일러스트에 활용

---

## Architecture

### 프로젝트 구조
```
Famtory/
├── project.yml                  ← XcodeGen 스펙
├── Famtory/
│   ├── App/
│   │   ├── FamtoryApp.swift     ← @main, Firebase 초기화
│   │   └── AppDelegate.swift    ← FCM 토큰 등록
│   ├── Models/
│   │   ├── User.swift           ← id, name, fcmToken, familyId
│   │   ├── Family.swift         ← id, name, inviteCode, memberIds[]
│   │   └── DiaryEntry.swift     ← id, userId, userName, content, date, reactions
│   ├── Services/
│   │   ├── AuthService.swift    ← Apple Sign In + Firebase Auth
│   │   ├── FamilyService.swift  ← 가족 그룹 CRUD, 초대 코드 생성/참여
│   │   ├── DiaryService.swift   ← 일기 작성/조회/반응
│   │   └── NotificationService.swift ← FCM 토큰 저장, 알림 처리
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── FamilyViewModel.swift
│   │   ├── HomeViewModel.swift   ← 오늘 피드, 일기 작성
│   │   └── CalendarViewModel.swift
│   └── Views/
│       ├── Auth/
│       │   └── SignInView.swift  ← Apple Sign In 버튼
│       ├── Onboarding/
│       │   ├── FamilySetupView.swift  ← 가족 만들기 or 참여하기
│       │   ├── CreateFamilyView.swift
│       │   └── JoinFamilyView.swift
│       ├── Main/
│       │   ├── RootView.swift         ← 인증 상태에 따라 라우팅
│       │   ├── HomeView.swift         ← 오늘 가족 피드 + 작성 버튼
│       │   ├── DiaryEntryCard.swift   ← 한줄 + 이모지 반응 UI
│       │   ├── WriteEntryView.swift   ← 한줄 작성 시트
│       │   └── CalendarView.swift     ← 달력 히스토리
│       └── Components/
│           └── EmojiPickerView.swift
```

### Firestore 데이터 모델
```
users/{userId}
  - name: String
  - fcmToken: String
  - familyId: String?

families/{familyId}
  - name: String
  - inviteCode: String (6자리 랜덤)
  - memberIds: [String]
  - createdAt: Timestamp

families/{familyId}/entries/{entryId}
  - userId: String
  - userName: String
  - content: String (최대 100자)
  - date: String (yyyy-MM-dd)
  - reactions: {emoji: [userId]} (e.g. {"❤️": ["uid1", "uid2"]})
  - createdAt: Timestamp
```

---

## 구현 단계

### 1. 프로젝트 생성 (XcodeGen)
- `project.yml` 작성 → `xcodegen generate`
- Firebase SDK SPM 패키지 추가 지시 포함

### 2. Firebase 설정
- `FamtoryApp.swift`에서 `FirebaseApp.configure()` 호출
- `AppDelegate`에서 FCM 등록 및 토큰 Firestore 저장

### 3. 인증 레이어
- `AuthService`: Apple Sign In credential → Firebase Auth
- `AuthViewModel`: 로그인 상태 `@Published`로 관리

### 4. 가족 그룹
- `FamilyService.createFamily()`: 6자리 코드 생성, families 문서 생성
- `FamilyService.joinFamily(code:)`: inviteCode로 조회 후 memberIds에 추가
- 가입 후 `users/{uid}.familyId` 업데이트

### 5. 일기 핵심 기능
- `DiaryService.writeEntry()`: 하루 1개 제한 (date 기준 중복 체크)
- `DiaryService.addReaction()`: reactions 맵 업데이트 (arrayUnion/arrayRemove)
- `DiaryService.streamEntries()`: Firestore 실시간 리스너 → Combine publisher

### 6. 달력 뷰
- `CalendarView`: 월별 그리드, 날짜 탭 시 해당일 가족 일기 표시
- `CalendarViewModel`: 월 단위 entries 쿼리

### 7. 푸시 알림
- 가족 멤버가 일기를 쓰면 나머지 멤버에게 FCM 알림
- 방식: Cloud Functions Firestore trigger → FCM 멀티캐스트
- `functions/index.js` 포함 (Firebase CLI로 배포)

### 8. Firestore 보안 규칙
- `firestore.rules` 파일 작성
- 가족 멤버만 해당 family 문서/entries 읽기/쓰기 가능

---

## 파일 목록 (생성할 파일)
- `project.yml`
- `Famtory/App/FamtoryApp.swift`
- `Famtory/App/AppDelegate.swift`
- `Famtory/Models/User.swift`, `Family.swift`, `DiaryEntry.swift`
- `Famtory/Services/AuthService.swift`, `FamilyService.swift`, `DiaryService.swift`, `NotificationService.swift`
- `Famtory/ViewModels/AuthViewModel.swift`, `FamilyViewModel.swift`, `HomeViewModel.swift`, `CalendarViewModel.swift`
- `Famtory/Views/**` (위 구조 전체)
- `functions/index.js` (Cloud Functions)
- `firestore.rules`
- `firestore.indexes.json`
- `README.md` (Firebase 프로젝트 연결 방법 안내)

---

## 검증 방법
1. `xcodegen generate` → Xcode에서 빌드 성공 확인
2. Simulator에서 Apple Sign In 테스트 (실기기 필요, Simulator는 mock)
3. 두 시뮬레이터 계정으로 초대 코드 그룹 참여 확인
4. 일기 작성 후 실시간 동기화 확인
5. FCM은 Firebase Console → Cloud Messaging으로 수동 테스트

---

## 전제 조건 (사용자 직접 설정 필요)
- Firebase 프로젝트 생성 후 `GoogleService-Info.plist` 다운로드
- Xcode에서 Apple Sign In capability 추가
- Firebase Console에서 Apple Sign In 활성화
- `xcodegen` 설치: `brew install xcodegen`
