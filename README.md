# TuliMovie

App social de cinema da turma — Flutter + Clean Architecture (feature-first).

## Estrutura (Fase 1)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── core.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_gradients.dart
│   │   ├── app_typography.dart
│   │   ├── app_theme.dart
│   │   └── theme.dart
│   └── presentation/
│       └── widgets/
│           ├── tuli_card.dart
│           ├── tuli_button.dart
│           ├── tuli_input_field.dart
│           ├── tuli_rating_stars.dart
│           ├── user_avatar_group.dart
│           ├── tuli_shimmer_loader.dart
│           └── widgets.dart
└── features/
    └── design_system/   # showcase temporário Fase 1
        └── presentation/
            └── pages/
                └── design_system_showcase_page.dart
```

## Rodar

Se ainda não existir pasta `android/` / `web/`, na raiz do projeto:

```bash
flutter create . --org com.tulimovie --project-name tulimovie --platforms=android,web
flutter pub get
flutter run -d chrome
```

## Design tokens

| Token | Valor |
|-------|--------|
| Background | `#0F0F14` |
| Gold | `#FFC107` |
| Neon Red | `#FF2E93` / `#FF0055` |
| Radius padrão | `16` |

Import único: `import 'package:tulimovie/core/core.dart';`
