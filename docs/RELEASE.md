# TuliMovie — Release (PWA + APK)

## Pré-requisitos

1. `flutter doctor`
2. `flutterfire configure` → `lib/core/config/firebase_options.dart`
3. Copie `.firebaserc.example` → `.firebaserc` com seu project ID
4. Atualize `web/firebase-messaging-sw.js` com o `firebaseConfig` real
5. Firebase Console → Cloud Messaging → **Web Push certificates** → copie a chave VAPID

## Variáveis (`--dart-define`)

| Variável | Obrigatória | Uso |
|----------|-------------|-----|
| `TMDB_API_KEY` | Sim | Catálogo TMDB |
| `FCM_VAPID_KEY` | Web Push | PWA iOS/Android |

## Build Web (PWA)

```powershell
flutter pub get
flutter build web --release `
  --dart-define=TMDB_API_KEY=sua_chave `
  --dart-define=FCM_VAPID_KEY=sua_vapid
```

Ou:

```powershell
$env:TMDB_API_KEY="..."
$env:FCM_VAPID_KEY="..."
.\scripts\build_release.ps1
```

## Deploy Firebase Hosting

```powershell
.\scripts\deploy_web.ps1
```

URL típica: `https://SEU_PROJECT.web.app`

### Instalar no iPhone (PWA)

1. Abrir no **Safari**
2. Compartilhar → **Adicionar à Tela de Início**
3. Aceitar notificações quando o app pedir (iOS 16.4+)

## APK Android

```powershell
flutter build apk --release --dart-define=TMDB_API_KEY=sua_chave
```

Saída: `build/app/outputs/flutter-apk/app-release.apk`

## Ícones PWA

Se faltar `web/icons/`, rode:

```powershell
flutter create . --platforms=web
```

(mantém o `web/index.html` customizado — faça merge se necessário)

## Checklist de auditoria

- [ ] Controllers com `dispose()` (feed scroll, match swiper, timers)
- [ ] `MovieSearchNotifier` cancela debounce no `dispose`
- [ ] Async com `try/catch` ou `AppException`
- [ ] Widgets visuais só em `core/presentation/widgets`
