# Diaryletter — AI 편지 일기 앱

> **보안 알림**: 이 저장소는 보안상의 이유로 중간 개발 과정의 커밋 히스토리와 민감한 설정 파일들이 제거된 포트폴리오용 공개 버전입니다. 원본은 private 저장소에서 관리되고 있습니다.

Flutter 기반의 개인 일기 및 AI 편지 생성 앱으로, 실제 iOS/Android 스토어에 배포된 프로덕션 앱입니다. 현대적인 아키텍처와 성능 최적화 기술을 적용했습니다.

---

## 🚀 핵심 기술 특징

### **상태 관리 & 아키텍처**
- **Provider 패턴**: Theme, Font, Notification 등 전역 상태 관리
- **Reactive Programming**: ValueNotifier를 활용한 실시간 UI 갱신
- **Clean Architecture**: 비즈니스 로직과 UI 레이어 분리

### **성능 최적화**
- **효율적인 캐싱**: SharedPreferences 기반 로컬 데이터 캐싱
- **무한 스크롤**: 페이지네이션을 통한 메모리 효율성
- **가로/세로 모드 최적화**: 필요한 화면에서만 회전 허용

### **보안 & 인증**
- **Supabase RLS**: Row Level Security를 통한 데이터 보안
- **환경변수 관리**: API 키 및 민감 정보 보호
- **다중 인증**: Google/Apple OAuth + 이메일 인증 지원

### **AI 통합**
- **서버리스 아키텍처**: Supabase Edge Functions를 통한 안전한 AI API 호출
- **개인화된 편지**: 사용자 일기 데이터 기반 맞춤형 AI 편지 생성
- **다국어 AI 응답**: 언어별 맞춤형 AI 응답 처리

---

## 📱 주요 기능

### **일기 관리**
- 달력 기반 인터페이스로 직관적인 일기 탐색
- 감정, 날씨, 활동 카테고리를 통한 구조화된 일기 작성
- 실시간 검색 및 필터링 기능

### **AI 편지 생성**
- Gemini AI를 활용한 개인화된 편지 생성
- 사용자의 일기 내용을 분석하여 공감하는 편지 작성
- 다국어 지원 (한국어, 영어, 일본어)

### **다국어 & 테마 시스템**
- 중앙 집중식 번역 관리 시스템 (한국어, 영어, 일본어)
- 런타임 언어 전환 지원
- 다크/라이트 테마 동적 전환
- 타입 안전한 문자열 관리

### **알림 시스템**
- 로컬 알림을 통한 일기 작성 리마인더
- iOS 배지 관리
- 사용자 맞춤형 알림 설정

---

## 🛠 기술 스택

### **프론트엔드**
- **Flutter/Dart**: 크로스 플랫폼 모바일 앱 개발
- **Provider**: 상태 관리
- **Material Design 3**: 현대적인 UI/UX

### **백엔드 & 인프라**
- **Supabase**: PostgreSQL 데이터베이스 + 실시간 기능
- **Supabase Auth**: OAuth 및 이메일 인증
- **Supabase Edge Functions**: 서버리스 AI API 프록시

### **AI & 외부 서비스**
- **Google Gemini API**: AI 편지 생성
- **Google/Apple Sign-In**: 소셜 로그인

---

## 📊 데이터 모델

```sql
-- diary 테이블 (메인)
CREATE TABLE diary (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  emotion TEXT,
  weather TEXT,
  social_context TEXT,
  activity_type TEXT,
  user_id UUID REFERENCES auth.users(id)
);

-- app_versions 테이블 (버전 관리)
CREATE TABLE app_versions (
  id SERIAL PRIMARY KEY,
  min_supported_version TEXT NOT NULL,
  latest_version TEXT NOT NULL,
  force_update BOOLEAN DEFAULT false,
  update_message_kr TEXT,
  update_message_en TEXT,
  update_message_jp TEXT,
  is_active BOOLEAN DEFAULT true
);
```

---

## 🏗 아키텍처 구조

```
lib/
├── const/                    # 상수 및 테마 정의
│   ├── colors.dart
│   ├── themes.dart
│   └── strings/             # 다국어 문자열
├── model/                   # 데이터 모델
├── providers/               # 전역 상태 관리
│   ├── theme_provider.dart
│   ├── font_provider.dart
│   └── notification_provider.dart
├── services/               # 비즈니스 로직
│   ├── version_service.dart
│   └── supabase_service.dart
├── utils/                  # 유틸리티
│   └── string_utils.dart   # 다국어 관리
└── widgets/               # UI 컴포넌트
    ├── diary/            # 일기 관련 위젯
    ├── ai/              # AI 편지 관련 위젯
    ├── setting/         # 설정 관련 위젯
    └── ui/              # 공통 UI 컴포넌트
```

---

## 💡 핵심 구현 사항

### **효율적인 상태 관리**
```dart
// 실시간 UI 갱신을 위한 ValueNotifier 사용
final ValueNotifier<bool> refreshNotifier = ValueNotifier(false);

// Provider를 통한 전역 상태 관리
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
```

### **안전한 AI API 호출**
```dart
// Supabase Edge Function을 통한 프록시
final response = await supabase.functions.invoke(
  'generate-letter',
  body: {
    'diary_content': diaryContent,
    'language': currentLanguage,
  },
);
```

### **다국어 시스템**
```dart
// 중앙 집중식 번역 관리
class StringUtils {
  static final Map<String, Map<String, String>> _translations = {
    'kr': {'back': '뒤로', 'confirm': '확인'},
    'en': {'back': 'Back', 'confirm': 'Confirm'},
    'jp': {'back': '戻る', 'confirm': '確認'},
  };

  static String get(String key) =>
    _translations[_currentLanguage]?[key] ?? key;
}
```

---

## 🎯 주요 성과

- **크로스 플랫폼**: 하나의 코드베이스로 iOS/Android 지원
- **확장 가능한 아키텍처**: 새로운 기능 추가 용이
- **타입 안전성**: Dart의 강력한 타입 시스템 활용
- **사용자 경험**: 직관적인 UI/UX 및 부드러운 애니메이션
- **보안성**: 데이터 암호화 및 인증 보안 강화

