# Configurar Firebase — TuliMovie

Project ID deste repo: **`tulimovie`**.

## 1. Console (obrigatório)

### Authentication + E-mail/senha

Erro **`configuration-not-found`** = Auth ainda não iniciado ou E-mail/senha desativado.

1. https://console.firebase.google.com/project/tulimovie/authentication → **Começar** (se aparecer)
2. https://console.firebase.google.com/project/tulimovie/authentication/providers → **E-mail/senha** → **Ativar** → Salvar
3. https://console.firebase.google.com/project/tulimovie/authentication/settings → domínio **`localhost`** autorizado

### Firestore

1. https://console.firebase.google.com/project/tulimovie/firestore → **Criar banco**
2. Aba **Regras** → cole o conteúdo de `firestore.rules` da raiz do repo → **Publicar**

Se aparecer **client is offline**: desative adblock para `firestore.googleapis.com` e `localhost`.

## 2. CLI (gerar `firebase_options.dart`)

**Login (CMD):**

```cmd
scripts\firebase_login.cmd
```

**Configurar FlutterFire:**

```cmd
scripts\firebase_setup.cmd tulimovie
```

**Git Bash — rodar o app com TMDB:**

```bash
./run.sh
```

## 3. TMDB (busca de filmes)

Copie `dart_defines.example.json` → `dart_defines.json` (não vai pro Git) e preencha **API Key v3** ([themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)). Use a chave v3, **não** o Read Access Token (JWT).

## Problemas comuns

| Problema | Solução |
|----------|---------|
| PowerShell bloqueia `.ps1` | Use `.cmd`: `firebase_login.cmd`, `firebase_setup.cmd` |
| `firebase` não reconhecido | Use `scripts\firebase_login.cmd` (CLI em `%LOCALAPPDATA%\firebase-cli`) |
| `C:/flutter` dubious ownership | `git config --global --add safe.directory C:/flutter` |
| `flutterfire` não acha `firebase` | `scripts\firebase_configure.cmd tulimovie` |

## Deploy Hosting

```powershell
Copy-Item web/firebase-messaging-sw.js build/web/ -Force
firebase deploy --only hosting
```

Use `.firebaserc` apontando para `tulimovie`.
