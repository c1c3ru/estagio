# Arquitetura do Sistema de Estágio

## Visão Geral

O Sistema de Estágio foi desenvolvido utilizando **Clean Architecture** com Flutter, garantindo separação de responsabilidades, testabilidade e manutenibilidade do código.

## Princípios Arquiteturais

### Clean Architecture

A aplicação segue os princípios da Clean Architecture, organizando o código em camadas bem definidas:

```
┌─────────────────────────────────────────┐
│              PRESENTATION               │
│         (UI, BLoC, Pages)              │
├─────────────────────────────────────────┤
│               DOMAIN                    │
│      (Entities, Use Cases, Repos)      │
├─────────────────────────────────────────┤
│                DATA                     │
│    (Repositories, DataSources, DTOs)   │
├─────────────────────────────────────────┤
│             EXTERNAL                    │
│      (Supabase, APIs, Storage)         │
└─────────────────────────────────────────┘
```

### Camadas da Arquitetura

#### 1. Presentation Layer (Apresentação)
- **Responsabilidade**: Interface do usuário e gerenciamento de estado
- **Componentes**:
  - **Pages**: Telas da aplicação
  - **Widgets**: Componentes reutilizáveis de UI
  - **BLoC**: Gerenciamento de estado e lógica de apresentação
  - **Routes**: Navegação entre telas

#### 2. Domain Layer (Domínio)
- **Responsabilidade**: Regras de negócio e lógica central
- **Componentes**:
  - **Entities**: Modelos de dados do domínio
  - **Use Cases**: Casos de uso específicos
  - **Repository Interfaces**: Contratos para acesso a dados
  - **Value Objects**: Objetos de valor imutáveis

#### 3. Data Layer (Dados)
- **Responsabilidade**: Acesso e manipulação de dados
- **Componentes**:
  - **Repository Implementations**: Implementações dos contratos
  - **DataSources**: Fontes de dados (local/remoto)
  - **DTOs**: Objetos de transferência de dados
  - **Mappers**: Conversão entre DTOs e Entities

#### 4. External Layer (Externo)
- **Responsabilidade**: Integração com serviços externos
- **Componentes**:
  - **Supabase**: Backend como serviço
  - **Firebase**: Notificações push
  - **Local Storage**: SQLite, SharedPreferences
  - **Platform Services**: Serviços nativos

## Estrutura de Pastas

```
lib/
├── core/                           # Funcionalidades centrais
│   ├── constants/                  # Constantes da aplicação
│   ├── errors/                     # Tratamento de erros
│   ├── services/                   # Serviços centrais
│   │   ├── notification_service.dart
│   │   ├── performance_service.dart
│   │   ├── report_service.dart
│   │   └── ...
│   ├── theme/                      # Sistema de temas
│   ├── accessibility/              # Recursos de acessibilidade
│   └── utils/                      # Utilitários
├── data/                           # Camada de dados
│   ├── datasources/                # Fontes de dados
│   │   ├── local/                  # Dados locais
│   │   └── remote/                 # Dados remotos
│   ├── models/                     # DTOs e modelos
│   └── repositories/               # Implementações de repositórios
├── domain/                         # Camada de domínio
│   ├── entities/                   # Entidades do domínio
│   ├── repositories/               # Interfaces de repositórios
│   └── usecases/                   # Casos de uso
├── features/                       # Funcionalidades por módulo
│   ├── auth/                       # Autenticação
│   ├── student/                    # Funcionalidades do estudante
│   ├── supervisor/                 # Funcionalidades do supervisor
│   ├── shared/                     # Componentes compartilhados
│   └── settings/                   # Configurações
└── app_module.dart                 # Injeção de dependências
```

## Padrões de Design Utilizados

### 1. Repository Pattern
Abstrai o acesso a dados, permitindo trocar implementações sem afetar a lógica de negócio.

```dart
abstract class ITimeLogRepository {
  Future<Either<AppFailure, List<TimeLog>>> getTimeLogs(String studentId);
  Future<Either<AppFailure, TimeLog>> createTimeLog(TimeLog timeLog);
}
```

### 2. BLoC Pattern
Gerencia estado de forma reativa e testável.

```dart
class TimeLogBloc extends Bloc<TimeLogEvent, TimeLogState> {
  final GetTimeLogsUsecase getTimeLogsUsecase;
  
  TimeLogBloc({required this.getTimeLogsUsecase}) : super(TimeLogInitial()) {
    on<LoadTimeLogs>(_onLoadTimeLogs);
  }
}
```

### 3. Use Case Pattern
Encapsula lógica de negócio específica.

```dart
class GetTimeLogsUsecase {
  final ITimeLogRepository repository;
  
  GetTimeLogsUsecase(this.repository);
  
  Future<Either<AppFailure, List<TimeLog>>> call(String studentId) {
    return repository.getTimeLogs(studentId);
  }
}
```

### 4. Dependency Injection
Utiliza Flutter Modular para injeção de dependências.

```dart
class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ITimeLogRepository>(TimeLogRepository.new);
    i.addSingleton<GetTimeLogsUsecase>(() => GetTimeLogsUsecase(i()));
  }
}
```

### 5. Either Pattern
Tratamento funcional de erros usando dartz.

```dart
Future<Either<AppFailure, TimeLog>> createTimeLog(TimeLog timeLog) async {
  try {
    final result = await dataSource.createTimeLog(timeLog.toDto());
    return Right(result.toEntity());
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

## Fluxo de Dados

### 1. Fluxo de Leitura (Query)
```
UI → BLoC → Use Case → Repository → DataSource → External API
                                                      ↓
UI ← BLoC ← Use Case ← Repository ← DataSource ← Response
```

### 2. Fluxo de Escrita (Command)
```
UI → BLoC → Use Case → Repository → DataSource → External API
                                                      ↓
UI ← BLoC ← Use Case ← Repository ← DataSource ← Success/Error
```

### 3. Fluxo Offline
```
UI → BLoC → Use Case → Repository → CacheService → Local DB
                                         ↓
                                   SyncService (quando online)
                                         ↓
                                   External API
```

## Gerenciamento de Estado

### BLoC States
Cada funcionalidade possui estados bem definidos:

```dart
abstract class TimeLogState extends Equatable {}

class TimeLogInitial extends TimeLogState {}
class TimeLogLoading extends TimeLogState {}
class TimeLogLoaded extends TimeLogState {
  final List<TimeLog> timeLogs;
}
class TimeLogError extends TimeLogState {
  final String message;
}
```

### Event-Driven Architecture
Eventos disparam mudanças de estado:

```dart
abstract class TimeLogEvent extends Equatable {}

class LoadTimeLogs extends TimeLogEvent {
  final String studentId;
}
class CreateTimeLog extends TimeLogEvent {
  final TimeLog timeLog;
}
```

## Tratamento de Erros

### Hierarquia de Erros
```dart
abstract class AppFailure extends Equatable {
  final String message;
  const AppFailure({required this.message});
}

class ServerFailure extends AppFailure {}
class CacheFailure extends AppFailure {}
class NetworkFailure extends AppFailure {}
class ValidationFailure extends AppFailure {}
```

### Error Handling Strategy
1. **Captura**: Erros são capturados na camada de dados
2. **Transformação**: Convertidos em failures específicas
3. **Propagação**: Propagados através do Either pattern
4. **Apresentação**: Exibidos na UI de forma amigável

## Performance e Otimização

### 1. Lazy Loading
```dart
// Carregamento sob demanda de dados
i.addLazySingleton<ExpensiveService>(() => ExpensiveService());
```

### 2. Caching Strategy
```dart
// Cache inteligente com expiração
final cached = await cacheService.getCachedData(key);
if (cached != null && !isExpired(cached)) {
  return cached;
}
```

### 3. Performance Monitoring
```dart
// Monitoramento de operações
await performanceService.measureOperation('load_data', () async {
  return await dataSource.loadData();
});
```

## Testes

### Estrutura de Testes
```
test/
├── unit/                          # Testes unitários
│   ├── domain/                    # Use cases e entities
│   ├── data/                      # Repositories e datasources
│   └── presentation/              # BLoCs
├── integration/                   # Testes de integração
└── widget/                        # Testes de widgets
```

### Test Doubles
- **Mocks**: Para dependências externas
- **Fakes**: Para implementações simples
- **Stubs**: Para retornos fixos

## Segurança

### 1. Autenticação
- JWT tokens via Supabase Auth
- Refresh token automático
- Row Level Security (RLS)

### 2. Autorização
- Role-based access control
- Políticas no Supabase
- Validação no frontend e backend

### 3. Dados Sensíveis
- Criptografia de dados locais
- Variáveis de ambiente para secrets
- Sanitização de inputs

## Escalabilidade

### 1. Modularização
- Features independentes
- Shared modules para código comum
- Plugin architecture

### 2. Performance
- Lazy loading de módulos
- Code splitting
- Asset optimization

### 3. Deployment
- Multi-environment support
- CI/CD pipeline
- Monitoring e logging

## Conclusão

A arquitetura implementada garante:
- **Manutenibilidade**: Código organizado e testável
- **Escalabilidade**: Fácil adição de novas funcionalidades
- **Testabilidade**: Cobertura completa de testes
- **Performance**: Otimizações em todas as camadas
- **Segurança**: Práticas seguras de desenvolvimento
