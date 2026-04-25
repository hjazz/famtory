# Famtory 프로젝트 규칙

## 커밋 메시지
- **모든 커밋 메시지는 한국어로 작성한다.**
- 제목은 명사형으로 끝낸다. (예: "프로필 이미지 교체", "달력 버그 수정")
- Co-Authored-By 태그는 영어 그대로 유지한다.

---

## 코드 컨벤션

### 네이밍 규칙
- **뷰**: `View` 접미사 (예: `SignInView`, `HomeView`)
- **뷰모델**: `ViewModel` 접미사 (예: `AuthViewModel`, `HomeViewModel`)
- **서비스**: `Service` 접미사, Singleton 패턴 (예: `AuthService.shared`)
- **모델**: 단순 명사, `Identifiable` + `Codable` 준수 (예: `Family`, `DiaryEntry`)
- **에러**: 각 서비스 내 nested `enum XxxError: LocalizedError`

### 파일 및 폴더 구조
```
Famtory/
├── App/              앱 진입점 (FamtoryApp, AppDelegate)
├── Models/           Firestore 모델 구조체
├── Services/         비즈니스 로직, Firebase 상호작용 (Singleton)
├── ViewModels/       @MainActor ObservableObject
└── Views/
    ├── Auth/         로그인 화면
    ├── Onboarding/   가입 플로우 (프로필 선택, 가족 설정)
    ├── Main/         홈, 달력, 가족 정보
    └── Components/   재사용 컴포넌트 (DesignSystem, PreviewHelpers 등)
```

### MARK 주석
섹션 구분에 `// MARK: -` 를 사용한다.
- 주요 섹션 예시: `Private`, `Helpers`, `Sub-views`, `Mock Data`

---

## 디자인 시스템 (`DesignSystem.swift`)

### 색상 — 하드코딩 금지, 반드시 extension 사용
| 이름 | 헥스 | 용도 |
|------|------|------|
| `famBackground` | `#FFF9F2` | 앱 배경 |
| `famPrimary` | `#F4A261` | 주요 액션 |
| `famBlue` | `#74B9FF` | 보조 액션 |
| `famPink` | `#FF8FAB` | 포인트 |
| `famYellow` | `#FDCB6E` | 강조 |
| `famGreen` | `#7EC8A4` | 배경 포인트 |
| `famBrown` | `#5C4033` | 본문 텍스트 |
| `famCard` | `white` | 카드 배경 |

### 폰트 — 모두 SF Rounded
- `.famTitle()` — .title2, bold
- `.famHeadline()` — .headline, semibold
- `.famBody()` — .body
- `.famCaption()` — .caption

### 공용 모디파이어
- `.famCard()` — 흰 배경 + 둥근 모서리 + 그림자
- `.famPrimaryButton(disabled:)` — 주황 버튼 (풀 너비)

새 색상/스타일은 반드시 `DesignSystem.swift`에 추가한다.

---

## Firebase / Firestore 데이터 모델

```
users/{userId}
  - name: String
  - profileType: String  // "dad" | "mom" | "son" | "daughter"
  - fcmToken: String
  - familyId: String

families/{familyId}
  - name: String
  - inviteCode: String   // 6자리 대문자
  - memberIds: [String]
  - createdAt: Timestamp

families/{familyId}/entries/{entryId}
  - userId / userName / userProfile: String
  - content: String
  - date: String         // yyyy-MM-dd
  - reactions: {emoji: [userId]}
  - createdAt: Timestamp
```

### 모델 필수 규칙
- `@DocumentID var id: String?` + `var safeId: String { id ?? "" }`
- `Equatable` 필요 시에만 채택 (`onChange` 등)
- 날짜 문자열: `DiaryEntry.todayString()` 정적 메서드 사용

---

## 뷰모델 패턴

```swift
@MainActor
final class XxxViewModel: ObservableObject {
    @Published var items: [Xxx] = []
    @Published var isLoading = false
    @Published var error: String?

    private var streamTask: Task<Void, Never>?

    deinit { streamTask?.cancel() }
}
```

- `@MainActor` 필수
- 스트리밍 시작 전 기존 `streamTask?.cancel()` 호출
- `deinit`에서 반드시 task 취소

---

## 서비스 패턴

```swift
final class XxxService {
    static let shared = XxxService()
    private init() {}
    private let db = Firestore.firestore()
}
```

### 메서드 명명
- 생성: `createXxx(...) async throws -> Xxx`
- 조회: `fetchXxx(...) async throws -> Xxx`
- 스트리밍: `streamXxx(...) -> AsyncStream<[Xxx]>`
- 토글: `toggleXxx(...) async throws`

---

## Preview / #if DEBUG 규칙

- 모든 Preview 코드는 `#if DEBUG` 블록 또는 `PreviewHelpers.swift` 내에 작성
- Mock ID: `"preview-uid-001"`, `"preview-family-001"` 형식 통일
- Mock 데이터: `static func mock(...) -> Self` 형식
- Preview 팩토리: `static func preview(...) -> XxxViewModel` 형식

```swift
#Preview("화면 이름") {
    XxxView()
        .environmentObject(AuthViewModel.preview())
}
```

---

## 새 화면/기능 추가 체크리스트

- [ ] `Models/` — 구조체 정의 (`Codable`, `Identifiable`, `safeId`)
- [ ] `Services/` — CRUD + 에러 타입 구현
- [ ] `ViewModels/` — `@MainActor` 뷰모델, `streamTask` 정리
- [ ] `Views/` — 적절한 서브폴더에 뷰 파일 생성
- [ ] DesignSystem 색상/폰트만 사용
- [ ] `PreviewHelpers.swift`에 Mock 추가 후 `#Preview` 블록 작성
- [ ] Firestore 보안 규칙(`firestore.rules`) 업데이트 필요 여부 확인

---

## 주의 / 금지 사항

### 건드리면 안 되는 파일
- `App/FamtoryApp.swift` — Firebase 초기화, EnvironmentObject 주입
- `App/AppDelegate.swift` — FCM 초기화
- `Views/Components/DesignSystem.swift` — 전역 스타일 (수정 시 모든 뷰 영향)

### 금지 사항
- 뷰에서 Firestore 직접 접근 금지 → 반드시 Service → ViewModel → View 흐름
- 색상값 하드코딩 금지 → `Color.famXxx` 사용
- `#if DEBUG` 없이 Preview 코드 프로덕션에 포함 금지
- `streamTask` 정리 없이 스트리밍 시작 금지
- reactions 업데이트 시 `FieldValue.arrayUnion/arrayRemove` 사용 (원자적 연산 보장)
