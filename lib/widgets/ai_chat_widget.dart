// lib/widgets/ai_chat_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart'; // <-- ADD THIS IMPORT
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- ADD THIS IMPORT

// Model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  _AiChatWidgetState createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  // --- ADD THIS LINE ---
  final ApiService apiService = ApiService(Supabase.instance.client);
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm your Investeeks AI financial advisor. How can I help you today?",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  // --- REPLACE the existing _handleSubmitted function with this one ---
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    final userMessage = text.trim();
    _controller.clear();

    setState(() {
      _messages.insert(0, ChatMessage(text: userMessage, isUser: true));
      _isLoading = true; // Show a loading indicator
    });

    try {
      // 1. Call the real API from your ApiService
      final botResponse = await apiService.getChatResponse(userMessage);

      // 2. Add the response from the Flask backend
      setState(() {
        _messages.insert(0, ChatMessage(text: botResponse, isUser: false));
      });
    } catch (e) {
      // 3. Handle any errors during the API call
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text:
                "Sorry, I couldn't connect to the server. Please try again later.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ... (Card Header code remains the same)
            Row(
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investeeks AI Chat',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Your personal financial assistant',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // Chat Messages Area
            SizedBox(
              height: 300,
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            const Divider(height: 1),
            // Input Area
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _handleSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Ask about investments...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _handleSubmitted(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // ... (This function remains the same)
    final isUser = message.isUser;
    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = isUser
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : Colors.grey.shade100;
    final textColor = isUser ? Theme.of(context).primaryColor : Colors.black87;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: isUser
                  ? const Radius.circular(0)
                  : const Radius.circular(16),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, height: 1.4),
          ),
        ),
      ],
    );
  }
}
