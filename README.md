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
    ├── auth/
    ├── feed/
    ├── movies/
    └── …
```

## Rodar

Se ainda não existir pasta `android/` / `web/icons/`, na raiz:

```powershell
flutter create . --org com.tulimovie --project-name tulimovie --platforms=android,web
flutter pub get
flutter run -d chrome --dart-define=TMDB_API_KEY=sua_chave_v3 --dart-define=FCM_VAPID_KEY=sua_vapid

**Dev sem digitar a chave toda vez:** edite `dart_defines.json` (só na sua máquina, não vai pro Git) com a **API Key v3** e rode:

- Windows CMD: `run.cmd` ou `scripts\run_web.cmd`
- **Git Bash:** `./run.sh`
- Cursor/VS Code: **F5** (`TuliMovie (Chrome + TMDB)`)

Use a **API Key (v3)**, não o *Read Access Token* (JWT).
```

Release completo: [docs/RELEASE.md](docs/RELEASE.md)

Firebase: passo a passo em [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) — `scripts\firebase_login.cmd` e depois `scripts\firebase_setup.cmd tulimovie`.

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

## Dinâmicas (Fase 5)

- `matches/` — salas temporárias + subcoleção `swipes`
- `watchlist/shared/items` — roleta
- `cinepass/queue` — fila semanal
- Aba **Diversão** → Cinepass, Roleta, Tinder do Cinema

## Engajamento (Fase 6)

- `ReviewShareCardWidget` + `ImageExportService` + `share_plus` (PNG 9:16 off-screen)
- **Perfil**: Top 4, Filômetro, rótulo cinéfilo, badges
- **Tuli Awards**: slides verticais + votação cômica (`awards/{year}/votes`)

## PWA & Push (Fase 7)

- `web/manifest.json` + meta tags iOS em `web/index.html`
- `firebase_messaging` + `web/firebase-messaging-sw.js`
- Scripts: `scripts/build_release.ps1`, `scripts/deploy_web.ps1`

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
