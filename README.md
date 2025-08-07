# Student Supervisor App

## Visão Geral

O Student Supervisor App é uma aplicação Flutter desenvolvida seguindo os princípios da Clean Architecture, projetada para gerenciar estudantes, supervisores e contratos de estágio. A aplicação utiliza Supabase como backend e implementa padrões modernos de desenvolvimento Flutter.

## Arquitetura do Projeto

A aplicação segue a Clean Architecture com separação clara de responsabilidades em camadas:

```
┌─────────────────┐
│   Presentation  │ ← UI/Widgets/Pages/BLoC
├─────────────────┤
│   Domain        │ ← Entities/UseCases/Repositories
├─────────────────┤
│   Data          │ ← Models/DataSources/Repositories
└─────────────────┘
```

## Estrutura de Pastas

```
📦lib
 ┣ 📂core
 ┃ ┣ 📂constants
 ┃ ┣ 📂enums
 ┃ ┣ 📂errors
 ┃ ┣ 📂guards
 ┃ ┣ 📂theme
 ┃ ┣ 📂utils
 ┃ ┗ 📂widgets
 ┣ 📂data
 ┃ ┣ 📂datasources
 ┃ ┣ 📂models
 ┃ ┗ 📂repositories
 ┣ 📂domain
 ┃ ┣ 📂entities
 ┃ ┣ 📂repositories
 ┃ ┗ 📂usecases
 ┣ 📂features
 ┃ ┣ 📂auth
 ┃ ┣ 📂shared
 ┃ ┣ 📂student
 ┃ ┗ 📂supervisor
 ┣ 📜app_module.dart
 ┣ 📜app_widget.dart
 ┣ 📜main.dart
 ┗ 📜r.dart
```

## Camadas da Arquitetura

### 1. Presentation Layer (features/)

**Responsabilidade:** Interface do usuário e gerenciamento de estado.

**Componentes:**
- Pages: Telas da aplicação.
- BLoC: Gerenciamento de estado usando padrão BLoC.
- Widgets: Componentes visuais específicos de cada feature.

### 2. Domain Layer (domain/)

**Responsabilidade:** Regras de negócio e contratos.

**Componentes:**
- Entities: Modelos de negócio puros.
- UseCases: Casos de uso específicos.
- Repository Interfaces: Contratos para acesso a dados.

### 3. Data Layer (data/)

**Responsabilidade:** Acesso e manipulação de dados.

**Componentes:**
- DataSources: Implementações de acesso a dados (Supabase).
- Models: Modelos de dados com serialização.
- Repository Implementations: Implementações concretas dos repositórios.

## Padrões Utilizados

### Clean Architecture
- Separação clara de responsabilidades.
- Inversão de dependências.
- Testabilidade.

### BLoC Pattern
- Gerenciamento de estado reativo.
- Separação entre lógica de negócio e UI.
- Facilita testes unitários.

### Repository Pattern
- Abstração do acesso a dados.
- Facilita troca de fontes de dados.
- Melhora testabilidade.

### Dependency Injection
- Usando Modular para injeção de dependências.
- Facilita testes e manutenção.

## Módulos da Aplicação

### Auth Module
- Autenticação de usuários
- Registro de estudantes e supervisores
- Recuperação de senha

### Student Module
- Dashboard do estudante
- Perfil e configurações
- Controle de ponto

### Supervisor Module
- Dashboard do supervisor
- Gerenciamento de estudantes
- Aprovação de horas

## Configuração do Ambiente

### Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  flutter_modular: ^6.3.2
  supabase_flutter: ^1.10.25
  equatable: ^2.0.5
  dartz: ^0.10.1
```

### Configuração do Supabase

```dart
// Em app_constants.dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## Fluxo de Dados

```
UI Event → BLoC → UseCase → Repository → DataSource → Supabase
                     ↓
UI Update ← BLoC ← Entity ← Repository ← Model ← DataSource
```

## Convenções de Código

### Nomenclatura
- Classes: PascalCase (ex: StudentEntity)
- Arquivos: snake_case (ex: student_entity.dart)
- Variáveis: camelCase (ex: studentName)
- Constantes: UPPER_SNAKE_CASE (ex: API_BASE_URL)

### Estrutura de Arquivos
- Um arquivo por classe.
- Imports organizados (dart, flutter, packages, relative).
- Exports organizados em barrel files quando necessário.

## Testes

### Estrutura de Testes

```
test/
├── features/
│   ├── auth/
│   │   └── bloc/
│   │       └── auth_bloc_test.dart
│   └── student/
│       └── bloc/
│           └── student_bloc_test.dart
├── domain/
│   └── usecases/
└── data/
    └── repositories/
```

## Scripts Úteis

### Comandos Flutter

```bash
# Executar aplicação
flutter run

# Executar testes
flutter test

# Gerar código (build_runner)
flutter packages pub run build_runner build

# Análise de código
flutter analyze
```

## Considerações de Segurança

- Nunca commitar chaves de API.
- Usar variáveis de ambiente para configurações sensíveis.
- Implementar validação adequada em todas as camadas.
- Sanitizar dados de entrada.

## Roadmap

- [ ] Implementação de testes unitários completos
- [ ] Implementação de testes de integração
- [ ] Documentação de API
- [ ] CI/CD pipeline
- [ ] Monitoramento e analytics

## Versão

**Versão:** 1.0.0
**Última atualização:** Junho 2025
**Desenvolvido com:** Flutter 3.x + Supabase