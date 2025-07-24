# Guia de Testes em Dispositivos Reais

## Índice
1. [Configuração do Ambiente](#configuração-do-ambiente)
2. [Dispositivos de Teste](#dispositivos-de-teste)
3. [Checklist de Testes](#checklist-de-testes)
4. [Procedimentos de Validação](#procedimentos-de-validação)
5. [Testes de Performance](#testes-de-performance)
6. [Testes de Conectividade](#testes-de-conectividade)
7. [Relatórios de Bugs](#relatórios-de-bugs)

## Configuração do Ambiente

### Pré-requisitos
- Flutter SDK 3.16.0+
- Android Studio / Xcode
- Dispositivos físicos configurados
- Certificados de desenvolvimento
- Acesso às contas de desenvolvedor

### Configuração Android

#### 1. Habilitar Modo Desenvolvedor
```bash
# No dispositivo Android:
# Configurações > Sobre o telefone > Toque 7x no "Número da versão"
# Configurações > Opções do desenvolvedor > Ativar "Depuração USB"
```

#### 2. Verificar Conexão
```bash
# Verificar dispositivos conectados
adb devices

# Instalar APK de teste
adb install build/app/outputs/flutter-apk/app-debug.apk

# Visualizar logs em tempo real
adb logcat | grep flutter
```

#### 3. Configurar Assinatura de Debug
```bash
# Gerar keystore de debug (se necessário)
keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

# Verificar assinatura
keytool -list -v -keystore debug.keystore
```

### Configuração iOS

#### 1. Configurar Dispositivo
```bash
# Verificar dispositivos conectados
xcrun xctrace list devices

# Instalar via Xcode
# Product > Destination > Selecionar dispositivo físico
# Product > Run
```

#### 2. Configurar Certificados
- Abrir projeto no Xcode
- Selecionar target do projeto
- Signing & Capabilities > Team > Selecionar conta de desenvolvedor
- Verificar Bundle Identifier único

#### 3. Configurar Provisioning Profile
- Apple Developer Portal > Certificates, Identifiers & Profiles
- Registrar dispositivo de teste
- Criar/atualizar provisioning profile
- Baixar e instalar no Xcode

## Dispositivos de Teste

### Matriz de Dispositivos Recomendada

#### Android
| Dispositivo | Versão Android | RAM | Resolução | Observações |
|-------------|----------------|-----|-----------|-------------|
| Samsung Galaxy S21 | Android 13 | 8GB | 2400x1080 | Flagship atual |
| Xiaomi Redmi Note 10 | Android 11 | 4GB | 2400x1080 | Mid-range popular |
| Samsung Galaxy A32 | Android 11 | 4GB | 1600x720 | Entry-level |
| Google Pixel 6 | Android 14 | 8GB | 2400x1080 | Android puro |
| Motorola Moto G Power | Android 10 | 4GB | 2300x1080 | Versão antiga |

#### iOS
| Dispositivo | Versão iOS | RAM | Resolução | Observações |
|-------------|------------|-----|-----------|-------------|
| iPhone 14 Pro | iOS 17 | 6GB | 2556x1179 | Flagship atual |
| iPhone 12 | iOS 16 | 4GB | 2532x1170 | Popular |
| iPhone SE 3 | iOS 16 | 4GB | 1334x750 | Tela pequena |
| iPhone 11 | iOS 15 | 4GB | 1792x828 | Versão anterior |
| iPad Air 5 | iPadOS 16 | 8GB | 2360x1640 | Tablet |

### Configurações de Teste por Categoria

#### Dispositivos de Performance
- **Alto desempenho**: iPhone 14 Pro, Galaxy S21
- **Médio desempenho**: iPhone 12, Redmi Note 10
- **Baixo desempenho**: Galaxy A32, iPhone SE

#### Tamanhos de Tela
- **Pequena**: iPhone SE (4.7"), Galaxy A32 (6.4")
- **Média**: iPhone 12 (6.1"), Redmi Note 10 (6.43")
- **Grande**: iPhone 14 Pro Max (6.7"), Galaxy S21 Ultra (6.8")
- **Tablet**: iPad Air (10.9")

#### Versões de Sistema
- **Mais recente**: Android 14, iOS 17
- **Atual**: Android 13, iOS 16
- **Anterior**: Android 11-12, iOS 15
- **Legado**: Android 10, iOS 14

## Checklist de Testes

### 🔐 Autenticação e Segurança
- [ ] Login com email/senha
- [ ] Criação de conta nova
- [ ] Recuperação de senha
- [ ] Logout e limpeza de dados
- [ ] Sessão expira corretamente
- [ ] Dados sensíveis não expostos em logs
- [ ] Certificados SSL validados

### 📱 Funcionalidades Core
- [ ] Check-in funciona corretamente
- [ ] Check-out registra tempo correto
- [ ] Histórico de registros carrega
- [ ] Filtros funcionam adequadamente
- [ ] Navegação entre telas fluida
- [ ] Estados de loading aparecem
- [ ] Mensagens de erro são claras

### 🌐 Conectividade
- [ ] App funciona com Wi-Fi
- [ ] App funciona com dados móveis
- [ ] Transição Wi-Fi ↔ Dados móveis
- [ ] Modo offline funciona
- [ ] Sincronização automática
- [ ] Sincronização manual
- [ ] Indicadores de status de rede

### 📊 Relatórios e Exportação
- [ ] Gráficos renderizam corretamente
- [ ] Filtros de período funcionam
- [ ] Exportação CSV funciona
- [ ] Exportação JSON funciona
- [ ] Compartilhamento de arquivos
- [ ] Dados exportados estão corretos

### 🔔 Notificações
- [ ] Notificações push recebidas
- [ ] Notificações locais funcionam
- [ ] Lembretes de check-in/out
- [ ] Configurações de notificação
- [ ] Permissões solicitadas corretamente

### 🎨 Interface e UX
- [ ] Layout responsivo em todas as telas
- [ ] Temas claro/escuro funcionam
- [ ] Fontes legíveis em todos os tamanhos
- [ ] Botões têm área de toque adequada
- [ ] Animações fluidas
- [ ] Feedback visual adequado
- [ ] Acessibilidade funciona

### ⚡ Performance
- [ ] App inicia em < 3 segundos
- [ ] Navegação responsiva (< 300ms)
- [ ] Carregamento de dados eficiente
- [ ] Uso de memória estável
- [ ] Bateria não drena excessivamente
- [ ] Cache funciona adequadamente

### 🔄 Estados da Aplicação
- [ ] App funciona após reinstalação
- [ ] App funciona após reinício do dispositivo
- [ ] App funciona com pouco espaço
- [ ] App funciona com pouca bateria
- [ ] App funciona em background
- [ ] App retoma estado corretamente

## Procedimentos de Validação

### Teste de Instalação
```bash
# Android
1. Instalar APK via ADB
2. Verificar permissões solicitadas
3. Testar primeira execução
4. Verificar ícone e nome na tela inicial

# iOS
1. Instalar via Xcode/TestFlight
2. Verificar certificado válido
3. Testar primeira execução
4. Verificar ícone e nome na tela inicial
```

### Teste de Funcionalidades Core
```bash
# Fluxo Completo de Estudante
1. Criar conta nova
2. Fazer login
3. Completar perfil
4. Fazer check-in
5. Fazer check-out
6. Visualizar histórico
7. Gerar relatório
8. Exportar dados
9. Fazer logout

# Fluxo Completo de Supervisor
1. Fazer login
2. Visualizar dashboard
3. Aprovar/rejeitar registros
4. Gerar relatórios de equipe
5. Gerenciar contratos
6. Configurar notificações
```

### Teste de Stress
```bash
# Teste de Volume de Dados
1. Criar 1000+ registros de tempo
2. Verificar performance de carregamento
3. Testar filtros com muitos dados
4. Exportar grande volume de dados

# Teste de Uso Prolongado
1. Usar app por 2+ horas contínuas
2. Monitorar uso de memória
3. Verificar vazamentos de memória
4. Testar estabilidade geral
```

### Teste de Conectividade
```bash
# Cenários de Rede
1. Sem conexão → Com conexão
2. Wi-Fi → Dados móveis
3. Conexão lenta (2G simulado)
4. Conexão instável (perda intermitente)
5. Servidor indisponível
6. Timeout de requisições
```

## Testes de Performance

### Métricas de Performance
- **Tempo de inicialização**: < 3 segundos
- **Tempo de navegação**: < 300ms
- **Carregamento de dados**: < 2 segundos
- **Uso de memória**: < 150MB
- **Uso de CPU**: < 30% em idle
- **Uso de bateria**: < 5% por hora de uso

### Ferramentas de Monitoramento
```bash
# Android
# Monitorar performance via ADB
adb shell dumpsys meminfo com.example.estagio
adb shell top | grep estagio
adb shell dumpsys battery

# iOS
# Usar Instruments do Xcode
# Activity Monitor
# Time Profiler
# Allocations
```

### Testes Automatizados de Performance
```dart
// Exemplo de teste de performance
testWidgets('Performance test - Dashboard loading', (tester) async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});
```

## Testes de Conectividade

### Cenários de Teste
1. **Offline First**
   - Iniciar app offline
   - Fazer operações locais
   - Conectar e verificar sincronização

2. **Perda de Conexão**
   - Usar app online
   - Desconectar durante operação
   - Verificar fallback para cache

3. **Conexão Lenta**
   - Simular 2G/3G
   - Verificar timeouts apropriados
   - Testar indicadores de carregamento

4. **Reconexão**
   - Perder conexão
   - Reconectar
   - Verificar sincronização automática

### Configuração de Simulação
```bash
# Android - Simular condições de rede
adb shell settings put global airplane_mode_on 1
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE

# iOS - Usar Network Link Conditioner
# Configurações > Desenvolvedor > Network Link Conditioner
```

## Relatórios de Bugs

### Template de Bug Report
```markdown
## Bug Report

**Título**: [Descrição breve do problema]

**Prioridade**: Critical/High/Medium/Low

**Dispositivo**: 
- Modelo: [ex: iPhone 12]
- OS: [ex: iOS 16.1]
- App Version: [ex: 1.0.0+1]

**Passos para Reproduzir**:
1. [Passo 1]
2. [Passo 2]
3. [Passo 3]

**Resultado Esperado**: 
[O que deveria acontecer]

**Resultado Atual**: 
[O que realmente acontece]

**Screenshots/Videos**: 
[Anexar evidências]

**Logs**: 
```
[Colar logs relevantes]
```

**Frequência**: 
[Sempre/Frequentemente/Às vezes/Raramente]

**Workaround**: 
[Se existe alguma solução temporária]
```

### Categorização de Bugs
- **Critical**: App crasha, perda de dados
- **High**: Funcionalidade principal não funciona
- **Medium**: Funcionalidade secundária com problemas
- **Low**: Problemas cosméticos, melhorias de UX

### Ferramentas de Tracking
- **Jira**: Para tracking formal de bugs
- **GitHub Issues**: Para bugs de desenvolvimento
- **Sentry**: Para crashes automáticos
- **Firebase Crashlytics**: Para monitoramento

## Automação de Testes

### Configuração de Device Farm
```yaml
# .github/workflows/device-testing.yml
name: Device Testing

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  android-device-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        api-level: [21, 23, 28, 30, 33]
    steps:
    - uses: actions/checkout@v4
    - name: Run Android tests
      uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: ${{ matrix.api-level }}
        script: flutter test integration_test/
```

### Testes em Nuvem
- **Firebase Test Lab**: Testes Android em dispositivos reais
- **AWS Device Farm**: Testes multiplataforma
- **Sauce Labs**: Testes automatizados
- **BrowserStack**: Testes de aplicações web

## Checklist de Release

### Pré-Release
- [ ] Todos os testes passando
- [ ] Performance validada
- [ ] Bugs críticos corrigidos
- [ ] Documentação atualizada
- [ ] Certificados válidos
- [ ] Versão incrementada

### Release
- [ ] Build de produção gerado
- [ ] Testes finais em dispositivos
- [ ] Upload para lojas
- [ ] Monitoramento ativo
- [ ] Rollback plan preparado

### Pós-Release
- [ ] Monitorar crashes
- [ ] Acompanhar métricas
- [ ] Coletar feedback
- [ ] Planejar próxima versão

---

**Importante**: Sempre manter logs detalhados dos testes realizados e resultados obtidos para referência futura e melhoria contínua do processo.
