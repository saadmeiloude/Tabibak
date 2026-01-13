import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/config/api_config.dart';
import '../models/chat_message.dart';
import '../core/api/token_storage.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  StompClient? _client;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  bool get isConnected => _client?.connected ?? false;

  void activate() async {
    if (isConnected) return;

    final token = await TokenStorage.getAccessToken();
    var baseUrl = ApiConfig.baseUrl.endsWith('/') 
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1).replaceAll('http', 'ws').replaceAll('/api', '/ws')
        : ApiConfig.baseUrl.replaceAll('http', 'ws').replaceAll('/api', '/ws');
    
    // On Web, we cannot pass headers, so we pass the token as a query parameter
    if (token != null) {
      baseUrl += '?access_token=$token'; 
    }

    _client = StompClient(
      config: StompConfig(
        url: baseUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => print('⚠️ WebSocket Error: $error'),
        onStompError: (dynamic error) => print('⚠️ Stomp Error: $error'),
        onDisconnect: (frame) => print('🔌 Disconnected'),
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
        // webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {}, // Ignored on Web
      ),
    );

    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('✅ WebSocket Connected');
  }

  void subscribeToRoom(String roomId) {
    if (_client == null || !isConnected) return;

    // Subscribe to messages
    _client?.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            final message = ChatMessage.fromJson(data);
            _messageController.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }
      },
    );

    // Subscribe to typing indicators
    _client?.subscribe(
      destination: '/topic/chat/$roomId/typing',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            _typingController.add(data);
          } catch (e) {
            print('Error parsing typing: $e');
          }
        }
      },
    );
  }

  void sendMessage(String roomId, String text, int senderId) {
    _client?.send(
      destination: '/app/api/chat/$roomId/send',
      body: json.encode({
        'content': text, // Note: Model might expect 'text' but RequestBody Message usually maps content/text
        'text': text,
        'type': 'TEXT',
        'senderId': senderId,
      }),
    );
  }

  void sendTyping(String roomId) {
    _client?.send(
      destination: '/app/api/chat/$roomId/typing',
    );
  }

  void deactivate() {
    _client?.deactivate();
  }
}
