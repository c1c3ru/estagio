# Diretrizes de Performance e Gerenciamento de Estado

## 1. Uso de BlocSelector para Granularidade

### ❌ Evitar - BlocBuilder genérico
```dart
BlocBuilder<NotificationBloc, NotificationState>(
  builder: (context, state) {
    // Todo o widget é reconstruído mesmo se apenas unreadCount mudar
    return Text('Total: ${state.notifications.length}');
  },
)
```

### ✅ Preferir - BlocSelector específico
```dart
BlocSelector<NotificationBloc, NotificationState, int>(
  selector: (state) => state is NotificationLoadAllSuccess ? state.unreadCount : 0,
  builder: (context, unreadCount) {
    // Reconstrói apenas quando unreadCount muda
    return Text('Não lidas: $unreadCount');
  },
)
```

## 2. Gerenciamento de Subscriptions

### ✅ Sempre cancelar subscriptions em dispose
```dart
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // CRÍTICO: Evita memory leaks
    super.dispose();
  }
}
```

## 3. Performance em Listas

### ✅ Use ListView.builder para listas grandes
```dart
ListView.builder(
  itemCount: notifications.length,
  itemBuilder: (context, index) {
    final notification = notifications[index];
    return NotificationTile(notification: notification);
  },
)
```

### ✅ Use const constructors quando possível
```dart
const NotificationTile({
  Key? key,
  required this.notification,
}) : super(key: key);
```

## 4. Logs de Performance

### ✅ Use PerformanceService para operações críticas
```dart
Future<void> loadNotifications() async {
  PerformanceService().startOperation('load_notifications');
  try {
    final notifications = await repository.getAllNotifications();
    // Process notifications
  } finally {
    PerformanceService().endOperation('load_notifications');
  }
}
```

## 5. ThemeService - Migração para Bloc (Recomendado)

### Problema atual: Singleton com ChangeNotifier
- Pode causar rebuilds excessivos
- Difícil de testar isoladamente
- Estado global compartilhado

### Solução recomendada: ThemeBloc
```dart
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeLoaded>(_onThemeLoaded);
  }
  
  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    // Handle theme change
    await _saveThemeConfig(event.config);
    emit(state.copyWith(config: event.config));
  }
}
```

## 6. Checklist de Performance

### Antes de fazer commit:
- [ ] Todos os StreamSubscription são cancelados em dispose?
- [ ] Listas grandes usam ListView.builder?
- [ ] BlocSelector é usado em vez de BlocBuilder quando apropriado?
- [ ] Widgets pesados usam const constructors?
- [ ] Operações críticas são monitoradas via PerformanceService?
- [ ] Não há listeners desnecessários ou duplicados?

## 7. Monitoramento em Produção

### Firebase Performance Monitoring
```dart
// Adicionar ao pubspec.yaml
dependencies:
  firebase_performance: ^0.9.3+8

// Uso
final trace = FirebasePerformance.instance.newTrace('load_dashboard');
await trace.start();
try {
  await loadDashboardData();
} finally {
  await trace.stop();
}
```

## 8. Testes de Performance

### Teste de stress para listas
```dart
testWidgets('Lista com 1000 itens não causa lag', (tester) async {
  final notifications = List.generate(1000, (i) => 
    NotificationEntity(id: '$i', title: 'Test $i'));
  
  await tester.pumpWidget(NotificationList(notifications: notifications));
  await tester.pumpAndSettle();
  
  // Verificar se não há frames perdidos
  expect(tester.binding.hasScheduledFrame, false);
});
```
