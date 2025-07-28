// lib/features/shared/pages/offline_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../core/constants/app_colors.dart';

class OfflineSettingsPage extends StatefulWidget {
  const OfflineSettingsPage({super.key}); // Use super.key

  @override
  State<OfflineSettingsPage> createState() => _OfflineSettingsPageState();
}

class _OfflineSettingsPageState extends State<OfflineSettingsPage> {
  final SyncService _syncService = Modular.get<SyncService>();
  final ConnectivityService _connectivityService =
      Modular.get<ConnectivityService>();
  final CacheService _cacheService = Modular.get<CacheService>();
  // No longer instantiating FeedbackService, as its methods are static.
  // final FeedbackService _feedbackService = FeedbackService();

  bool _isOnline = false;
  bool _isSyncing = false;
  Map<String, dynamic> _syncStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
    _setupListeners();
  }

  void _setupListeners() {
    // Escutar mudanças de conectividade
    _connectivityService.connectionStatus.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });

    // Escutar status de sincronização
    _syncService.syncStatus.listen((status) {
      if (mounted) {
        setState(() {
          _isSyncing = status.isInProgress;
        });

        // Mostrar feedback baseado no status
        switch (status) {
          case SyncStatus.synced:
            FeedbackService.showSuccess(
                context,
                'Sincronização concluída!');
            break;
          case SyncStatus.syncError:
            FeedbackService.showError(
                context,
                'Erro na sincronização');
            break;
          case SyncStatus.partialSync:
            FeedbackService.showWarning(
                context,
                'Sincronização parcial');
            break;
          default:
            break;
        }

        // Recarregar estatísticas após mudança de status
        _loadOfflineData();
      }
    });
  }

  Future<void> _loadOfflineData() async {
    try {
      setState(() => _isLoading = true);

      final stats = await _syncService.getSyncStats();
      final isOnline = _connectivityService.isOnline;
      final isSyncing = _syncService.isSyncing;

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _syncStats = stats;
        _isOnline = isOnline;
        _isSyncing = isSyncing;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      FeedbackService.showErrorDialog(
        context, // Pass context with named parameter
        title: 'Erro ao carregar dados',
        'Não foi possível carregar as informações offline: $e',
      );
    }
  }

  Future<void> _forcSync() async {
    if (!_isOnline) {
      if (!mounted) return; // Check if widget is still mounted
      FeedbackService.showError(
          context,
          'Dispositivo offline - não é possível sincronizar');
      return;
    }

    try {
      await FeedbackService.executeWithFeedback(
        context,
        loadingMessage: 'Sincronizando dados...',
        operation: () async {
          final success = await _syncService.forcSync();
          if (!mounted) return; // Check if widget is still mounted
          if (success) {
            FeedbackService.showSuccess(
                context, 'Sincronização concluída!');
          } else {
            FeedbackService.showError(
                context, 'Falha na sincronização');
          }
        },
      );
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      FeedbackService.showError(
          context, 'Erro na sincronização');
    }
  }

  Future<void> _clearCache() async {
    // Access static method directly and provide named parameters
    final confirmed = await FeedbackService.showConfirmationDialog(
      context,
      title: 'Limpar Cache',
      message:
          'Tem certeza que deseja limpar todos os dados offline? Esta ação não pode ser desfeita.',
      confirmText: 'Limpar',
      cancelText: 'Cancelar',
    );

    // Unchecked use of nullable value: confirmed can be null. Check if it's true.
    if (confirmed == true) {
      try {
        await FeedbackService.executeWithFeedback(
          context,
          loadingMessage: 'Limpando cache...',
          operation: () async {
            final success = await _syncService.clearAllData();
            if (!mounted) return; // Check if widget is still mounted
            if (success) {
              FeedbackService.showSuccess(
                  context, 'Cache limpo com sucesso!');
              await _loadOfflineData();
            } else {
              FeedbackService.showError(
                  context, 'Erro ao limpar cache');
            }
          },
        );
      } catch (e) {
        if (!mounted) return; // Check if widget is still mounted
        FeedbackService.showError(
            context, 'Erro ao limpar cache');
      }
    }
  }

  Future<void> _clearExpiredData() async {
    try {
      await FeedbackService.executeWithFeedback(
        context,
        loadingMessage: 'Limpando dados expirados...',
        operation: () async {
          final deletedCount = await _cacheService.clearExpiredData();
          if (!mounted) return; // Check if widget is still mounted
          FeedbackService.showSuccess(
            context,
            '$deletedCount itens expirados removidos!',
          );
          await _loadOfflineData();
        },
      );
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      FeedbackService.showError(
          context, 'Erro ao limpar dados expirados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações Offline'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOfflineData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOfflineData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildStatisticsCard(),
                    const SizedBox(height: 16),
                    _buildActionsCard(),
                    const SizedBox(height: 16),
                    _buildConnectivityCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: _isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status de Conectividade',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Conectividade',
              _isOnline ? 'Online' : 'Offline',
              _isOnline ? Colors.green : Colors.red,
            ),
            _buildStatusItem(
              'Sincronização',
              _isSyncing ? 'Em andamento...' : 'Inativa',
              _isSyncing ? Colors.orange : Colors.grey,
            ),
            _buildStatusItem(
              'Serviços',
              _syncService.isInitialized
                  ? 'Inicializados'
                  : 'Não inicializados',
              _syncService.isInitialized ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas de Cache',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Itens em Cache',
              '${_syncStats['cachedItems'] ?? 0}',
              Icons.storage,
            ),
            _buildStatItem(
              'Operações Pendentes',
              '${_syncStats['pendingOperations'] ?? 0}',
              Icons.sync_problem,
            ),
            _buildStatItem(
              'Itens Expirados',
              '${_syncStats['expiredItems'] ?? 0}',
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOnline && !_isSyncing ? _forcSync : null,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                    _isSyncing ? 'Sincronizando...' : 'Forçar Sincronização'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearExpiredData,
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Limpar Dados Expirados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Limpar Todo o Cache'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityCard() {
    final connectivity =
        _syncStats['connectivity'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Conectividade',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Tipo de Conexão',
                connectivity['connectionType'] ?? 'Desconhecido'),
            _buildInfoItem('Status',
                connectivity['isOnline'] == true ? 'Online' : 'Offline'),
            _buildInfoItem('Última Verificação',
                _formatTimestamp(connectivity['timestamp'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Nunca';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Agora mesmo';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min atrás';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h atrás';
      } else {
        return '${difference.inDays} dias atrás';
      }
    } catch (e) {
      return 'Formato inválido';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
