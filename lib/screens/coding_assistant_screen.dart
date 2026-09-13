import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../controllers/admin_control.dart';

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg(this.text, this.isUser);
}

/// Text-based coding assistant, powered by Gemini. The API key is set live
/// from the admin panel (Channels & Logo card's sibling "Coding Mode" card)
/// and read here at request time - no rebuild needed when it changes.
class CodingAssistantScreen extends StatefulWidget {
  const CodingAssistantScreen({super.key});

  @override
  State<CodingAssistantScreen> createState() => _CodingAssistantScreenState();
}

class _CodingAssistantScreenState extends State<CodingAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMsg> _messages = [];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final apiKey = context.read<AdminControl>().geminiApiKey;
    if (apiKey.isEmpty) {
      setState(() => _messages.add(_ChatMsg('no api key set by admin yet.', false)));
      return;
    }
    setState(() {
      _messages.add(_ChatMsg(text, true));
      _sending = true;
      _controller.clear();
    });
    _scrollToEnd();
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
      );
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'You are a concise coding assistant inside a terminal-style app. Answer clearly with code blocks when relevant.\n\nUser: $text',
                },
              ],
            },
          ],
        }),
      );
      String reply;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        reply = data['candidates']?[0]['content']['parts'][0]['text'] as String? ?? 'no response.';
      } else {
        reply = 'error ${res.statusCode}: request failed.';
      }
      setState(() => _messages.add(_ChatMsg(reply, false)));
    } catch (e) {
      setState(() => _messages.add(_ChatMsg('connection error. try again.', false)));
    } finally {
      setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00FF41);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: green,
        title: const Text('> coding_assistant', style: TextStyle(fontFamily: 'monospace')),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (m.isUser ? '> ' : '# ') + m.text,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: m.isUser ? Colors.white : green,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('# thinking...', style: TextStyle(fontFamily: 'monospace', color: green, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: green, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'ask a coding question...',
                      hintStyle: const TextStyle(color: Color(0xFF0A8F2C), fontFamily: 'monospace'),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: green)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: green, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
