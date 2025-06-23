import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDatasource {
  final SupabaseClient _client;

  NotificationDatasource(this._client);

  Future<List<Map<String, dynamic>>> getAllNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  Future<Map<String, dynamic>> createNotification(
      Map<String, dynamic> notificationData) async {
    try {
      final response = await _client
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Erro ao criar notificação: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Erro ao marcar notificação como lida: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
    } catch (e) {
      throw Exception('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Erro ao deletar notificação: $e');
    }
  }

  Future<void> clearAllNotifications(String userId) async {
    try {
      await _client.from('notifications').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Erro ao limpar todas as notificações: $e');
    }
  }
}
