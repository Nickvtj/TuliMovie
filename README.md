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
flutter run -d chrome --dart-define=TMDB_API_KEY=sua_chave_v3
```

Firebase: `flutterfire configure` gera `lib/core/config/firebase_options.dart`. Ative **Authentication → E-mail/Senha** e crie índice/coleção `users`.

## Auth (Fase 3)

```
features/auth/
  domain/     UserEntity, AuthRepository, LoginWithEmailUseCase, RegisterUseCase
  data/       FirebaseAuth + Firestore users/
  presentation/  Riverpod (authSessionProvider), LoginRegisterPage glassmorphism
```

Sessão: `authSessionProvider` (stream). Gate: `AuthGatePage`.

## Feed & TMDB UI (Fase 4)

- `ReviewCardWidget` + `DiscordBadge` + reações rápidas (bottom sheet)
- `FeedPage` — pull-to-refresh, scroll infinito, skeleton
- `MovieSearchPage` — debounce 420ms
- `MovieDetailsPage` — SliverAppBar, streaming, elenco, avaliações do grupo
- `ActorDetailsPage` — **Assistidos pela Turma** (reutiliza `ReviewCardWidget`)

Firestore: coleção `reviews` + índices compostos (`createdAt`, `tmdbMovieId+createdAt`).

## Infra (Fase 2)

```
lib/core/network/          # Dio + interceptors (auth TMDB, cache, log, erro)
lib/core/services/         # IBaseFirestoreService (CRUD genérico)
lib/core/di/injection.dart # get_it
lib/features/movies/
  domain/                  # entities + MovieRepository
  data/                    # TMDB datasource, models, mappers, impl
```

Uso do repositório:

```dart
final movies = sl<MovieRepository>();
final results = await movies.searchMovies(query: 'matrix');
```

## Design tokens

| Token | Valor |
|-------|--------|
| Background | `#0F0F14` |
| Gold | `#FFC107` |
| Neon Red | `#FF2E93` / `#FF0055` |
| Radius padrão | `16` |

Import único: `import 'package:tulimovie/core/core.dart';`
