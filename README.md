# Frontend — Gerenciamento de Obrigações

Aplicação **Flutter** para cadastrar empresas, usuários responsáveis, obrigações e anexos, consumindo a API Spring Boot do backend.

## Finalidade deste README

Documentar **somente o frontend**: tecnologias, como apontar para a API, como executar (Chrome, web-server, Windows), estrutura `lib/`, funcionalidades de UI, decisões de arquitetura e UX (shell unificado, dialogs, searchable select, splash, FAB mobile, paginação) e melhorias futuras.

**Links relativos** (`../README.md`, backend) funcionam quando este repo está clonado **dentro** do monorepo `player-contabilidade`. Se você clonou só o frontend, use: [raiz](https://github.com/marcosvrca/player-contabilidade) · [backend](https://github.com/marcosvrca/gerenciamento-obrigacoes-backend).

## Quadro Trello

https://trello.com/b/WFkCNXHG/gerenciamento-de-obrigacoes

## Tecnologias utilizadas

| Área | Tecnologia |
|------|------------|
| SDK | Flutter **3.50+** (stable), Dart **3.11+** |
| Estado / DI | flutter_riverpod |
| HTTP | dio |
| UI | `material_ui` (Material), design system próprio (tokens, tipografia) |
| Arquivos | file_picker, path_provider, open_filex |
| Datas | intl |
| Preferências | shared_preferences (tema / preferências locais) |

## Pré-requisitos

- **Flutter SDK 3.50+** (Dart **3.11+**) instalado e no `PATH` — `flutter --version`  
  - Dependências atuais (ex.: `shared_preferences ^2.5.6`) não resolvem em SDKs mais antigos (ex.: Flutter 3.24 / Dart 3.5).  
  - Se estiver desatualizado: `flutter upgrade` (canal `stable`).  
- **Chrome** (ou Edge) para rodar na web; ou toolchain Windows se for `flutter run -d windows`  
- **Backend** em execução (padrão `http://localhost:8080`) — ver README do backend / Docker Compose  
- **Windows:** ative o [Developer Mode](ms-settings:developers) (Configurações → Sistema → Para desenvolvedores). Sem suporte a symlinks, o Flutter pode falhar ao resolver plugins após `flutter pub get`.

## Configuração do ambiente

A base URL da API está em `lib/core/config/api_config.dart` e pode ser sobrescrita no build:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

| Ambiente | URL sugerida |
|----------|--------------|
| Windows / Web / Desktop | `http://localhost:8080` |
| Emulador Android | `http://10.0.2.2:8080` |
| Dispositivo físico | `http://<IP-da-sua-maquina>:8080` |

## Instruções de execução

Na raiz deste repositório:

```bash
flutter pub get
flutter run -d chrome
# ou
flutter run -d windows
# desenvolvimento web estável em porta fixa:
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5000
```

Atalho na raiz do monorepo (Windows): `start-frontend.cmd` — exige `flutter` no `PATH` (não usa caminho fixo de máquina).

Após mudanças grandes em `web/` ou widgets críticos, use `flutter clean` + novo `flutter run` e **hard refresh** no navegador para evitar cache do bundle antigo.

## Estrutura do projeto

```
lib/
  main.dart                 # HomeShell (chrome unificado + IndexedStack)
  core/
    config/                 # ApiConfig
    network/                # Dio / erros
    navigation/             # rotas de página (detalhe)
    theme/                  # palette, spacing, AppTheme, theme controller
    shell/                  # slots de paginação do shell
    widgets/                # page header, filters, pagination, FAB,
                            # searchable select, skeletons, etc.
  features/
    empresas/               # models / data / presentation
    usuarios/
    obrigacoes/
    anexos/
web/
  index.html                # splash “Carregando aplicação…”
  flutter_bootstrap.js      # splash até o primeiro frame
```

Cada feature segue **models / data / presentation**.

## Funcionalidades

- CRUD de **empresas** e **usuários** com filtro Ativo/Inativo (chips no desktop; dropdown no mobile)  
- CRUD de **obrigações** (empresa + responsável + prazo + status)  
- Avanço de status: Pendente → Em andamento → Concluída  
- **Paginação client-side** (15 itens) nas listagens; em usuários a barra permanece visível mesmo com uma página  
- Upload, listagem e download de **anexos** no **detalhe** da obrigação  
- Temas / design system (Ledger Ink) e splash web até o app estar pronto  

## CI/CD

Pipeline em `.github/workflows/ci.yml`: `flutter analyze` e `flutter test`.

## Decisões arquiteturais

### Base

- **Riverpod** para estado assíncrono e injeção (providers de repositório e listagens).  
- **Repositórios** isolando Dio da UI.  
- Selects de criação usam apenas empresas/usuários **ativos**; edição preserva vínculo histórico inativo.  
- Anexos no detalhe (a API exige `obrigacaoId`); o dialog de criação **não** anexa arquivo.

### Shell unificado (decisão recente)

- Menu lateral e faixa de paginação formam **um único chrome** (mesma cor de superfície), sem footer separado nem borda “costurando” shell e lista.  
- `IndexedStack` mantém as abas montadas; cada módulo publica um **slot** de paginação — a barra troca **junto** com o módulo, sem atraso do footer antigo.  
- Breakpoint desktop ≈ **900px** (sidebar); abaixo disso, `NavigationBar` + paginação na coluna da página.

### Paginação e FAB

- Widget `ListPagination` / `ListPaginationBar` (15 itens).  
- Em **usuários**, `alwaysShow` mantém a paginação com “1 / 1” quando há registros.  
- `PageCreateFab`: no **mobile**, só ícone `+` (tooltip com o rótulo); no desktop, FAB extended com texto.  
- No mobile, o FAB sobe (`liftAbovePagination`) para não cobrir os controles de página.

### Formulários em dialog (decisão recente)

- Empresa, usuário e obrigação usam **AlertDialog** com **Cancelar** e **Salvar** (mesmo padrão).  
- Obrigação deixou de ser página full-screen de criação/edição.

### Searchable select (decisão recente)

- `SearchableSelectField` baseado em **RawAutocomplete**: campo “Digite para filtrar”, lista filtrada por substring (case-insensitive), visual alinhado aos filtros de status (borda, superfície, tipografia, divisórias).  
- Usado em: **empresa** e **responsável** (dialog de obrigação) e **situação** Ativo/Inativo (dialogs de empresa e usuário).  
- Implementação anterior com `DropdownMenu` não entregava bem busca/visual no dialog; Autocomplete corrige isso.

### Splash web (decisão recente)

- `web/index.html` exibe “**Carregando aplicação…**” até o bootstrap Flutter liberar o primeiro frame (`flutter_bootstrap.js`).

### UX de listagens

- Skeletons no carregamento; filtros de status/situação polidos no mobile.  
- Content width limitado no desktop para leitura confortável.

## Melhorias futuras

### Experiência e acesso

- **Login / sessão** — tela de autenticação e fluxo de cadastro alinhados ao RBAC da API.  
- **Home leve** — entrada do app com métricas simples (totais por status, vencendo) e lista curta de alertas — sem dashboard pesado.  
- **Inbox de alertas** — notificações internas por obrigação, filtradas pelo usuário logado.  
- **Kanban** — visão por colunas de status, arrastar/avançar etapa conforme permissão; admin vê todas as obrigações.  
- **Configurações** — temas; preferências de e-mail customizáveis (marcar quais tipos receber: novas obrigações criadas, a vencer, do dia, da semana); e UI para integrações (exibir status WhatsApp/sistemas externos quando o backend existir).

### Domínio e UX

- **Indicadores de prazo** — badges “a vencer” / “atrasada” na lista, home e Kanban.  
- **Recorrência** — UI para modelos e geração de obrigações da competência.  
- **Relatórios** — exportar ou visualizar resumos por período/empresa.  
- **Anexos** — preview na web quando a API/storage permitir.

### Base técnica (app)

- Consumir paginação/filtros **server-side**; cache offline leve; i18n e testes de widget do shell.

## Relação com o backend

Documentação da API, Docker, UTF-8 e seed: [README do backend](../gerenciamento-obrigacoes-backend/README.md). Visão do monorepo: [README raiz](../README.md).
