# PiramidGame IFPR-Pgua

Ranking de popularidade do IFPR – Campus Paranaguá, em **Flutter** com
**Firebase Authentication** e **Cloud Firestore**.

## Como rodar

1. Crie um projeto no [Console do Firebase](https://console.firebase.google.com).
2. Em **Authentication → Sign-in method**, ative **E-mail/senha** e **Google**.
3. Em **Firestore Database**, crie o banco e publique as regras do arquivo
   [`firestore.rules`](firestore.rules).
4. Na pasta do projeto:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure     # sobrescreve lib/firebase_options.dart
   flutter pub get
   flutter run
   ```
5. Login com Google no Android: cadastre a impressão digital **SHA-1** do app no
   Firebase (`cd android && ./gradlew signingReport`) e rode `flutterfire configure` de novo.

Enquanto o `firebase_options.dart` for o modelo, o app abre uma tela
explicando que o Firebase não está configurado.

## Arquitetura (MVVM + Clean Architecture)

```
UI (views) → ViewModel (Signals + Commands) → Facade de use cases → Use cases
          → Repositories → Services → Firebase Auth / Firestore / SharedPreferences
```

| Camada | Pasta | O que faz |
|---|---|---|
| Services | `lib/data/services` | Acesso direto: `AuthService`, `GoogleAuthService`, `FirestoreService`, `LocalStorageService` (SharedPreferences) |
| Repositories | `lib/data/repositories` | Intermediam os dados: `AuthRepository`, `PessoaRepository`, `AvaliacaoRepository`, `PreferenceRepository` |
| Use cases | `lib/domain/usecases` | Regras de negócio (autoavaliação, uma avaliação por usuário+pessoa, rankings...) |
| Facades | `lib/domain/facades` | Agrupam use cases: `AuthFacade`, `PessoaFacade`, `AvaliacaoFacade`, `RankingFacade`, `PreferenceFacade` |
| ViewModels | `lib/presentation/controllers` | Estado com **Flutter Signals** e ações via **Command** |
| UI | `lib/presentation/views` | Telas; só falam com o ViewModel |

Retornos entre camadas usam o padrão **Result** (`lib/core/patterns/result.dart`).
Navegação com **go_router** (`lib/core/routes`), injeção com **auto_injector**
(`lib/core/di`).

## Firestore

```
usuarios/{uid}                    nome, email, foto, provider
pessoas/{id}                      nome, apelido, curso, turma, dataNascimento, criadoPor, usuarioUid?
avaliacoes/{avaliadorUid_pessoaId} avaliadorUid, pessoaId, 15 notas, pontuacaoTotal, dataAvaliacao
```

O id da avaliação é `avaliadorUid_pessoaId`: gravar de novo **substitui** a
avaliação, garantindo uma avaliação ativa por usuário e pessoa.

## SharedPreferences

Usado **só** para a preferência de tema claro/escuro. Não guarda pessoas,
avaliações, rankings nem senha.

## Testes

```bash
flutter test
```
