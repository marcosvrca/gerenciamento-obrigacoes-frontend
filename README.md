# Frontend — Gerenciamento de Obrigações

Aplicação Flutter para cadastrar empresas, usuários responsáveis, obrigações e anexos, consumindo a API Spring Boot.

## Quadro Trello

https://trello.com/b/WFkCNXHG/gerenciamento-de-obrigacoes

## Tecnologias

- Flutter (stable)
- Dart 3
- Riverpod
- Dio
- file_picker / path_provider / open_filex

## Pré-requisitos

- Flutter SDK instalado
- API backend em execução (`http://localhost:8080`)

## Configuração

A URL da API é definida em `lib/core/config/api_config.dart` e pode ser sobrescrita em tempo de build:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Sugestões de base URL:

| Ambiente | URL |
|----------|-----|
| Windows / Web / Desktop | `http://localhost:8080` |
| Emulador Android | `http://10.0.2.2:8080` |
| Dispositivo físico | `http://<IP-da-sua-maquina>:8080` |

## Execução

```bash
flutter pub get
flutter run -d windows
# ou
flutter run -d chrome
```

## Estrutura do projeto

```
lib/
  core/                 # config, http, theme
  features/
    empresas/
    usuarios/
    obrigacoes/
    anexos/
```

Cada feature segue a separação `models / data / presentation`.

## Funcionalidades

- CRUD de empresas e usuários com filtro Ativo/Inativo
- CRUD de obrigações vinculadas a empresa e responsável
- Avanço de status (Pendente → Em andamento → Concluída)
- Upload, listagem e download de anexos

## CI/CD

Pipeline em `.github/workflows/ci.yml` executa `flutter analyze` e `flutter test`.

## Decisões arquiteturais

- Riverpod para estado assíncrono e injeção de dependências
- Repositórios isolando Dio/API da UI
- Selects de criação usam apenas empresas/usuários ativos; edição preserva vínculo histórico

## Melhorias futuras

- Autenticação JWT
- Cache offline
- Paginação nas listagens
- Preview de anexos na web
