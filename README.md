# Dream Canvas 🌙

말로 풀어낸 꿈을 AI 이미지로 그려주는 iOS 앱입니다.
음성으로 꿈 이야기를 들려주면 텍스트로 변환되고, OpenAI 이미지 생성 모델이 그 내용을 바탕으로 그림을 만들어 줍니다. 생성된 꿈은 감정 태그와 함께 기록되어 나만의 "꿈 일기"로 쌓입니다.

## 주요 기능

- **음성으로 꿈 기록**: Apple Speech Framework로 음성을 실시간 텍스트로 변환
- **AI 이미지 생성**: OpenAI `gpt-image-1` API로 꿈 내용을 그림으로 변환
- **이미지 스타일 선택**: 수채화, 유화, 사진풍, 애니메이션, 파스텔 중 선택
- **감정 태그**: 행복, 무서움, 신비로움, 슬픔, 평온함, 흥미진진 6종 감정 분류
- **즐겨찾기**: 마음에 드는 꿈 기록을 즐겨찾기로 저장하고 필터링
- **꿈 기록 보관함**: 검색, 스타일/즐겨찾기 필터, 상세 보기, 삭제
- **공유 및 사진 저장**: 생성된 이미지를 공유하거나 사진 앱에 저장
- **다크 모드 지원**: 라이트/다크 모드에 따라 자동으로 색상 전환

## 화면 흐름

```
MainView (홈)
  └─ RecordingView (음성 녹음)
       └─ ContentConfirmView (텍스트 확인 · 스타일/감정 선택)
            └─ DreamResultView (생성된 이미지 확인 · 저장/공유)

MainView
  └─ DreamListView (꿈 기록 목록 · 검색/필터/삭제)
       └─ DreamDetailView (꿈 상세 보기)
```

## 기술 스택

- Swift / SwiftUI (+ UIKit `AppDelegate`/`SceneDelegate`)
- Apple Speech Framework (음성 인식)
- OpenAI Image API (`gpt-image-1`)
- `UserDefaults` 기반 로컬 저장 (`Codable`)

## 프로젝트 구조

```
FinalProject/
├── AppDelegate.swift / SceneDelegate.swift / ViewController.swift
├── Config.swift.example       # API 키 설정 템플릿
├── Models/
│   └── DreamEntry.swift        # 꿈 기록 데이터 모델
├── ViewModels/
│   └── DreamViewModel.swift    # 상태 관리 및 비즈니스 로직
├── Views/
│   ├── MainView.swift
│   ├── RecordingView.swift
│   ├── ContentConfirmView.swift
│   ├── DreamResultView.swift
│   └── DreamListView.swift
├── Services/
│   ├── SpeechRecognitionService.swift
│   ├── ImageGenerationService.swift
│   └── DreamStorageService.swift
└── Extensions/
    ├── Color+Hex.swift
    └── Color+Theme.swift       # 다크모드 대응 색상 테마
```

## 시작하기

### 요구 사항

- Xcode 16 이상
- iOS 17 이상 (실기기 권장 — 음성 인식·마이크 권한 필요)
- OpenAI API 키 (이미지 생성 기능 사용 시 필요)

### 설정 방법

1. 저장소를 클론합니다.
   ```bash
   git clone <저장소 URL>
   ```
2. API 키를 설정합니다.
   ```bash
   cd FinalProject/FinalProject
   cp Config.swift.example Config.swift
   ```
   `Config.swift`를 열어 `openAIAPIKey` 값을 본인의 OpenAI API 키로 교체합니다.

   > ⚠️ `Config.swift`는 `.gitignore`에 포함되어 있어 깃허브에 올라가지 않습니다. API 키를 절대 직접 커밋하지 마세요.

3. `FinalProject.xcodeproj`를 Xcode로 열고 실기기에서 빌드/실행합니다.
4. 최초 실행 시 마이크 · 음성 인식 · 사진 라이브러리 권한 요청을 허용해 주세요.

## 사용 방법

1. 홈 화면에서 "꿈 말하기 시작"을 눌러 꿈 이야기를 음성으로 들려줍니다.
2. 인식된 텍스트를 확인/수정하고, 이미지 스타일과 감정 태그를 선택합니다.
3. "이미지 생성하기"를 누르면 AI가 꿈 그림을 생성합니다.
4. 생성된 이미지를 저장(앱 기록 + 사진 앱)하거나 공유합니다.
5. "꿈 기록 보기"에서 지난 꿈들을 검색·필터링하고, 즐겨찾기/삭제할 수 있습니다.
