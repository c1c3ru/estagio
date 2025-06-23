Visão Geral do App
O Student Supervisor App é uma aplicação Flutter desenvolvida seguindo os princípios da Clean Architecture, projetada para gerenciar estudantes, supervisores e contratos de estágio. A aplicação utiliza Supabase como backend e implementa padrões modernos de desenvolvimento Flutter.

Arquitetura do Projeto
A aplicação segue a Clean Architecture com separação clara de responsabilidades em camadas:

Plaintext

┌─────────────────┐
│   Presentation  │ ← UI/Widgets/Pages/BLoC
├─────────────────┤
│   Domain        │ ← Entities/UseCases/Repositories
├─────────────────┤
│   Data          │ ← Models/DataSources/Repositories
└─────────────────┘
Estrutura de Pastas
Plaintext

lib/
├── app_module.dart                    # Configuração principal de injeção de dependências
├── main.dart                          # Ponto de entrada da aplicação
├── core/                              # Funcionalidades compartilhadas
│   ├── constants/                     # Constantes da aplicação
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── enums/                         # Enumerações
│   │   ├── contract_status.dart
│   │   ├── internship_shift.dart
│   │   └── user_role.dart
│   ├── errors/                        # Tratamento de erros
│   │   ├── app_exceptions.dart
│   │   └── app_failures.dart
│   ├── guards/                        # Guardas de rota e autorização
│   │   └── role_guard.dart
│   ├── utils/                         # Utilitários
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/                       # Widgets reutilizáveis
│       ├── app_button.dart
│       ├── app_text_field.dart
│       └── loading_indicator.dart
├── data/                              # Camada de dados
│   ├── datasources/                   # Fontes de dados
│   │   └── supabase/                  # Implementações Supabase
│   │       ├── auth_datasource.dart
│   │       ├── contract_datasource.dart
│   │       ├── student_datasource.dart
│   │       ├── supervisor_datasource.dart
│   │       └── time_log_datasource.dart
│   ├── models/                        # Modelos de dados
│   │   ├── contract_model.dart
│   │   ├── student_model.dart
│   │   ├── supervisor_model.dart
│   │   ├── time_log_model.dart
│   │   └── user_model.dart
│   └── repositories/                  # Implementações de repositórios
│       ├── auth_repository.dart
│       ├── contract_repository.dart
│       ├── student_repository.dart
│       ├── supervisor_repository.dart
│       └── time_log_repository.dart
├── domain/                            # Camada de domínio
│   ├── entities/                      # Entidades de negócio
│   │   ├── contract_entity.dart
│   │   ├── student_entity.dart
│   │   ├── supervisor_entity.dart
│   │   ├── time_log_entity.dart
│   │   └── user_entity.dart
│   ├── repositories/                  # Interfaces de repositórios
│   │   ├── i_auth_repository.dart
│   │   ├── i_contract_repository.dart
│   │   ├── i_student_repository.dart
│   │   ├── i_supervisor_repository.dart
│   │   └── i_time_log_repository.dart
│   └── usecases/                      # Casos de uso
│       ├── auth/                      # Casos de uso de autenticação
│       │   ├── get_current_user_usecase.dart
│       │   ├── login_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── register_usecase.dart
│       ├── contract/                  # Casos de uso de contratos
│       │   ├── create_contract_usecase.dart
│       │   ├── get_contracts_by_student_usecase.dart
│       │   └── update_contract_usecase.dart
│       ├── student/                   # Casos de uso de estudantes
│       │   ├── get_all_students_usecase.dart
│       │   ├── get_student_by_id_usecase.dart
│       │   └── update_student_usecase.dart
│       ├── supervisor/                # Casos de uso de supervisores
│       │   ├── get_all_supervisors_usecase.dart
│       │   └── get_supervisor_by_id_usecase.dart
│       └── time_log/                  # Casos de uso de registros de tempo
│           ├── clock_in_usecase.dart
│           ├── clock_out_usecase.dart
│           └── get_time_logs_usecase.dart
└── features/                          # Funcionalidades da aplicação
    ├── auth/                          # Módulo de autenticação
    │   ├── auth_module.dart
    │   ├── bloc/                      # Gerenciamento de estado
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   └── pages/                     # Páginas de autenticação
    │       ├── login_page.dart
    │       └── register_page.dart
    ├── shared/                        # Componentes compartilhados
    │   └── widgets/
    │       └── user_avatar.dart
    ├── student/                       # Módulo do estudante
    │   ├── bloc/
    │   │   ├── student_bloc.dart
    │   │   ├── student_event.dart
    │   │   └── student_state.dart
    │   ├── pages/
    │   │   ├── student_dashboard_page.dart
    │   │   ├── student_profile_page.dart
    │   │   └── student_time_tracking_page.dart
    │   └── student_module.dart
    └── supervisor/                    # Módulo do supervisor
        ├── bloc/
        │   ├── supervisor_bloc.dart
        │   ├── supervisor_event.dart
        │   └── supervisor_state.dart
        ├── pages/
        │   ├── student_details_page.dart
        │   ├── supervisor_dashboard_page.dart
        │   └── supervisor_time_approval_page.dart
        └── supervisor_module.dart
Camadas da Arquitetura
1. Presentation Layer (features/)
Responsabilidade: Interface do usuário e gerenciamento de estado.

Componentes:

Pages: Telas da aplicação.
BLoC: Gerenciamento de estado usando padrão BLoC.
Widgets: Componentes visuais específicos de cada feature.
Exemplo de estrutura BLoC:

Dart

// Event
abstract class AuthEvent extends Equatable {}

// State  
abstract class AuthState extends Equatable {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {}
2. Domain Layer (domain/)
Responsabilidade: Regras de negócio e contratos.

Componentes:

Entities: Modelos de negócio puros.
UseCases: Casos de uso específicos.
Repository Interfaces: Contratos para acesso a dados.
Exemplo de Entity:

Dart

class StudentEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  // ...
}
3. Data Layer (data/)
Responsabilidade: Acesso e manipulação de dados.

Componentes:

DataSources: Implementações de acesso a dados (Supabase).
Models: Modelos de dados com serialização.
Repository Implementations: Implementações concretas dos repositórios.
Exemplo de Model:

Dart

class StudentModel extends StudentEntity {
  // Implementação com fromJson/toJson
  factory StudentModel.fromJson(Map<String, dynamic> json) {}
  Map<String, dynamic> toJson() {}
}
Padrões Utilizados
Clean Architecture
Separação clara de responsabilidades.
Inversão de dependências.
Testabilidade.
BLoC Pattern
Gerenciamento de estado reativo.
Separação entre lógica de negócio e UI.
Facilita testes unitários.
Repository Pattern
Abstração do acesso a dados.
Facilita troca de fontes de dados.
Melhora testabilidade.
Dependency Injection
Usando Modular para injeção de dependências.
Facilita testes e manutenção.
Módulos da Aplicação
Auth Module
Dart

class AuthModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.lazySingleton((i) => AuthBloc()),
    Bind.lazySingleton((i) => LoginUsecase()),
    // ...
  ];
}
Student Module
Dashboard do estudante
Perfil e configurações
Controle de ponto
Supervisor Module
Dashboard do supervisor
Gerenciamento de estudantes
Aprovação de horas
Configuração do Ambiente
Dependências Principais
YAML

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  flutter_modular: ^6.3.2
  supabase_flutter: ^1.10.25
  equatable: ^2.0.5
  dartz: ^0.10.1
Configuração do Supabase
Dart

// Em app_constants.dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
Fluxo de Dados
Plaintext

UI Event → BLoC → UseCase → Repository → DataSource → Supabase
                     ↓
UI Update ← BLoC ← Entity ← Repository ← Model ← DataSource
Convenções de Código
Nomenclatura
Classes: PascalCase (ex: StudentEntity)
Arquivos: snake_case (ex: student_entity.dart)
Variáveis: camelCase (ex: studentName)
Constantes: UPPER_SNAKE_CASE (ex: API_BASE_URL)
Estrutura de Arquivos
Um arquivo por classe.
Imports organizados (dart, flutter, packages, relative).
Exports organizados em barrel files quando necessário.
Estados BLoC
Dart

// Estados base
abstract class StudentState extends Equatable {}
class StudentInitial extends StudentState {}
class StudentLoading extends StudentState {}
class StudentLoaded extends StudentState {}
class StudentError extends StudentState {}
Testes
Estrutura de Testes
Plaintext

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
Exemplo de Teste BLoC
Dart

blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () => AuthBloc(),
  act: (bloc) => bloc.add(AuthLoginRequested()),
  expect: () => [AuthLoading(), AuthSuccess(user)],
);
Scripts Úteis
Comandos Flutter
Bash

# Executar aplicação
flutter run

# Executar testes
flutter test

# Gerar código (build_runner)
flutter packages pub run build_runner build

# Análise de código
flutter analyze
Considerações de Segurança
Nunca commitar chaves de API.
Usar variáveis de ambiente para configurações sensíveis.
Implementar validação adequada em todas as camadas.
Sanitizar dados de entrada.
Roadmap
[ ] Implementação de testes unitários completos
[ ] Implementação de testes de integração
[ ] Documentação de API
[ ] CI/CD pipeline
[ ] Monitoramento e analytics
Versão: 1.0.0

Última atualização: Junho 2025

Desenvolvido com: Flutter 3.x + Supabase