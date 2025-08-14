class AppStrings {
  // Geral
  static const String appName = 'Estagio';
  static const String loading = 'Carregando...';
  static const String error = 'Erro';
  static const String success = 'Sucesso';
  static const String warning = 'Aviso';
  static const String info = 'Informação';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String save = 'Salvar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String add = 'Adicionar';
  static const String search = 'Pesquisar';
  static const String filter = 'Filtrar';
  static const String refresh = 'Atualizar';
  static const String retry = 'Tentar novamente';
  static const String noData = 'Nenhum dado encontrado';
  static const String noResults = 'Nenhum resultado encontrado';
  static const String registrationSuccessful = 'Cadastro realizado com sucesso';
  static const String close = 'Fechar';
  static const String errorOccurred = 'Ocorreu um erro';
  static const String tryAgain = 'Tentar novamente';

  // Auth
  static const String login = 'Entrar';
  static const String logout = 'Sair';
  static const String register = 'Cadastrar';
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar senha';
  static const String forgotPassword = 'Esqueci minha senha';
  static const String resetPassword = 'Redefinir senha';
  static const String loginSuccess = 'Login realizado com sucesso';
  static const String loginError = 'Erro ao fazer login';
  static const String registerSuccess = 'Cadastro realizado com sucesso';
  static const String registerError = 'Erro ao fazer cadastro';
  static const String logoutSuccess = 'Logout realizado com sucesso';

  // Validation
  static const String fieldRequired = 'Este campo é obrigatório';
  static const String invalidEmail = 'E-mail inválido';
  static const String passwordTooShort =
      'Senha deve ter pelo menos 6 caracteres';
  static const String passwordsDontMatch = 'Senhas não coincidem';
  static const String invalidName = 'Nome inválido';

  // User Roles
  static const String student = 'Estudante';
  static const String supervisor = 'Supervisor';

  // Navigation
  static const String home = 'Início';
  static const String profile = 'Perfil';
  static const String settings = 'Configurações';
  static const String about = 'Sobre';

// Student
  static const String studentHome = 'Página Inicial do Estudante';
  static const String students = 'Estudantes';
  static const String studentProfile = 'Perfil do Estudante';
  static const String timeLog = 'Registro de Horas';
  static const String timeRecord = 'Registro de Horas';
  static const String clockIn = 'Entrada';
  static const String clockOut = 'Saída';
  static const String totalHours = 'Total de Horas';
  static const String todayHours = 'Horas Hoje';
  static const String weekHours = 'Horas da Semana';
  static const String monthHours = 'Horas do Mês';

  // Supervisor
  static const String supervisors = 'Supervisores';
  static const String supervisorProfile = 'Perfil do Supervisor';
  static const String manageStudents = 'Gerenciar Estudantes';
  static const String viewReports = 'Ver Relatórios';

  // Contract
  static const String contracts = 'Contratos';
  static const String contractDetails = 'Detalhes do Contrato';
  static const String contractStatus = 'Status do Contrato';
  static const String startDate = 'Data de Início';
  static const String endDate = 'Data de Término';
  static const String workload = 'Carga Horária';
  static const String contractInformation = 'Informações do Contrato';
  static const String noContractsFound = 'Nenhum contrato encontrado';
  static const String errorLoadingContracts = 'Erro ao carregar contratos';

  // Errors
  static const String networkError = 'Erro de conexão';
  static const String serverError = 'Erro do servidor';
  static const String unknownError = 'Erro desconhecido';
  static const String timeoutError = 'Tempo limite excedido';
  static const String unauthorizedError = 'Não autorizado';
  static const String forbiddenError = 'Acesso negado';
  static const String notFoundError = 'Não encontrado';

  // Additional fields
  static const String requiredField = 'Este campo é obrigatório';
  static const String registerSupervisorPage = 'Cadastrar Supervisor';
  static const String fullName = 'Nome Completo';
  static const String selectRole = 'Selecionar Função';
  static const String siapeRegistration = 'Matrícula SIAPE';
  static const String siapeHint = 'Digite sua matrícula SIAPE';
  static const String phoneNumber = 'Telefone';
  static const String totalStudents = 'Total de Estudantes';
  static const String activeStudents = 'Estudantes Ativos';
  static const String inactiveStudents = 'Estudantes Inativos';
  static const String expiringContracts = 'Contratos Expirando';
  static const String checkIn = 'Entrada';
  static const String checkOut = 'Saída';

  // Reports
  static const String reports = 'Relatórios';
  static const String reportsTitle = 'Relatórios de Supervisão';
  static const String performance = 'Performance';
  static const String analysis = 'Análises';
  static const String performanceSummary = 'Resumo de Performance';
  static const String contractsSummary = 'Resumo de Contratos';
  static const String generalAnalysis = 'Análise Geral';
  static const String studentsList = 'Lista de Estudantes';
  static const String recentContracts = 'Contratos Recentes';
  static const String statusDistribution = 'Distribuição por Status';
  static const String pendingApprovals = 'Aprovações Pendentes';
  static const String expiringIn30Days = 'A Vencer em 30d';
  static const String totalContracts = 'Total de Contratos';
  static const String closed = 'Encerrados';

  // Time logs
  static const String noTimeLogsFound = 'Nenhum registo de tempo encontrado.';
  static const String addFirstTimeLog = 'Adicionar Primeiro Registo';
  static const String startTimeRecord = 'Iniciar Registro';
  static const String finishTimeRecord = 'Finalizar Registro';

  // Profile
  static const String incompleteProfile = 'Perfil Incompleto';
  static const String completeProfile = 'Completar Perfil';
  static const String editProfile = 'Editar Perfil';

  // Empty states
  static const String noStudentsForReports =
      'Nenhum estudante encontrado para gerar relatórios de performance.';
  static const String noContractsForReports =
      'Nenhum contrato encontrado para gerar relatórios.';
  static const String noDataForAnalysis =
      'Nenhum dado disponível para gerar análises.';
  static const String errorLoadingReports =
      'Erro ao carregar dados dos relatórios';

  // Time approval
  static const String timeApproval = 'Aprovações de Horas';
  static const String confirmApproval = 'Confirmar Aprovação';
  static const String approveHours = 'Deseja aprovar as horas de';
  static const String approve = 'Aprovar';
  static const String reject = 'Rejeitar';
  static const String rejectTimeRecord = 'Rejeitar Registo de Tempo';
  static const String rejectionReason = 'Motivo da Rejeição (Opcional)';
  static const String confirmRejection = 'Confirmar Rejeição';
  static const String approved = 'Aprovado';
  static const String entry = 'Entrada';
  static const String exit = 'Saída';
  static const String hoursLogged = 'Horas Registadas';
  static const String description = 'Descrição';
  static const String date = 'Data';
  static const String hours = 'Horas';

  // Manage students
  static const String manageStudentsTitle = 'Gerenciar Estudantes';
  static const String searchPlaceholder =
      'Pesquisar por nome, curso ou matrícula...';
  static const String noStudentsFound = 'Nenhum estudante encontrado';
  static const String noResultsFor = 'Nenhum resultado para';
  static const String registration = 'Matrícula';
  static const String advisor = 'Orientador';
  static const String shift = 'Turno';
  static const String hoursCompleted = 'Horas Completadas';
  static const String contractPeriod = 'Contrato';
  static const String active = 'Ativo';
  static const String inactive = 'Inativo';
  static const String pending = 'Pendente';
  static const String morning = 'Manhã';
  static const String afternoon = 'Tarde';
  static const String evening = 'Noite';
  static const String fullTime = 'Integral';
  static const String ead = 'EAD';

  // Contract types
  static const String mandatory = 'Obrigatório';
  static const String nonMandatory = 'Não obrigatório';
  static const String contractType = 'Tipo';

  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
