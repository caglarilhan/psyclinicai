import 'package:flutter/material.dart';
import '../../models/therapy_simulation_model.dart';

class AIClientPanel extends StatefulWidget {
  final SimulationScenario scenario;
  final List<SessionMessage> messages;
  final void Function(String) onMessageSent;
  final VoidCallback onEndSession;

  const AIClientPanel({
    super.key,
    required this.scenario,
    required this.messages,
    required this.onMessageSent,
    required this.onEndSession,
  });

  @override
  State<AIClientPanel> createState() => _AIClientPanelState();
}

class _AIClientPanelState extends State<AIClientPanel> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        _buildComposer(),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isTherapist = message.sender == MessageSender.therapist;
        return Align(
          alignment: isTherapist ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: isTherapist
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isTherapist ? Colors.white : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                final text = _messageController.text;
                if (text.trim().isEmpty) return;
                _messageController.clear();
                widget.onMessageSent(text);
              },
              icon: const Icon(Icons.send),
              label: const Text('Gönder'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.onEndSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Bitir'),
            )
          ],
        ),
      ),
    );
  }
}
